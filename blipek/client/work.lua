-- Egységesített munka-blipek.
--
-- Ezeket a blipeket a munka-resource-ok hozzák létre (ars_hunting, bc_bus, ...),
-- majd egy eseménnyel ideszólnak:  TriggerEvent('blipek:registerWorkBlip', id, blip)
-- Onnantól a Blip menüből egyenként kapcsolhatók.
--
-- A nevüket/ikonjukat alapból MEGTARTJÁK -- mindegyik olyan marad, amilyennek a
-- saját resource-a megcsinálta. Ha egységes "Munka" ikont akarsz, kapcsold be a
-- Config.WorkStyle.unify-t; onnantól a GTA egy sorba vonja őket a térkép
-- jelmagyarázatában.
--
-- MIÉRT ESEMÉNNYEL ÉS NEM EXPORTTAL
--   Így nincs kötelező függőség: ha ez a resource nem fut, az eseményt senki nem
--   kapja el, a munka-resource-ok pedig változatlanul futnak tovább a saját,
--   régi blipjükkel. Ezért nem is töröltük ki náluk a saját blip-nevezésüket --
--   az a tartalék.
local Filter = require 'client.filter'

local Work = {}

local Style <const> = Config.WorkStyle or {}

local handles = {}   -- id -> { blip, blip, ... }  (egy sorhoz több blip is tartozhat)
local named   = {}   -- blip -> true, ha nevesített blip (a terület-körök nem azok)
local origDisplay = {} -- blip -> a saját resource-a által beállított display-érték
local known   = {}   -- id -> a config sora

for _, entry in ipairs(Config.WorkBlips or {}) do
    known[entry.id] = entry
    handles[entry.id] = {}
end

--- A Blip menüben ez a tétel-id tartozik egy munka-sorhoz.
---@param id string
---@return string
local function entryId(id)
    return 'w:' .. id
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIP-MŰVELETEK
-----------------------------------------------------------------------------------------------------------------------------------------
local function applyStyle(blip)
    SetBlipSprite(blip, Style.sprite or 478)
    SetBlipColour(blip, Style.colour or 5)
    SetBlipScale(blip, (tonumber(Style.scale) or 0.85) + 0.0)
    SetBlipAsShortRange(blip, Style.shortRange and true or false)

    if Style.blipCategory and Style.blipCategory > 0 then
        SetBlipCategory(blip, Style.blipCategory)
    end

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Style.name or 'Munka')
    EndTextCommandSetBlipName(blip)
end

--- A kikapcsolás display = 0-val történik, nem RemoveBlip-pel: így a
--- munka-resource saját handle-je érvényben marad (ő törli, amikor akarja),
--- és a visszakapcsolás azonnali, újralétrehozás nélkül.
--- Visszakapcsoláskor a blip a SAJÁT eredeti display-értékét kapja vissza
--- (nem mindegyik resource 4-et használ: az ars_hunting pl. 6-ot).
local function applyVisibility(blip, state)
    if not state then
        SetBlipDisplay(blip, 0)
        return
    end
    SetBlipDisplay(blip, origDisplay[blip] or tonumber(Style.display) or 4)
end

--- Kitakarítja a már nem létező handle-öket (pl. a lunar_fishing szintlépéskor
--- újraépíti a zóna-blipjeit), és visszaadja az élő handle-ök listáját.
local function liveHandles(id)
    local list = handles[id]
    if not list then return nil end

    for i = #list, 1, -1 do
        if not DoesBlipExist(list[i]) then
            named[list[i]] = nil
            origDisplay[list[i]] = nil
            table.remove(list, i)
        end
    end

    return list
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISZTRÁCIÓ A MUNKA-RESOURCE-OKBÓL
-----------------------------------------------------------------------------------------------------------------------------------------

---@param id string a Config.WorkBlips-beli azonosító
---@param blip number a már létrehozott blip handle
---@param styleless boolean|nil true: NE kapja meg a közös nevet/ikont, csak a
---       ki-be kapcsolást kövesse. Ez kell a terület-blipekhez (AddBlipForRadius,
---       pl. a lunar_fishing színes zóna-körei) -- azokra a sprite/név
---       értelmetlen, viszont a nevesített blippel együtt kell eltűnniük.
AddEventHandler('blipek:registerWorkBlip', function(id, blip, styleless)
    if not known[id] then return end
    if type(blip) ~= 'number' or blip == 0 or not DoesBlipExist(blip) then return end

    local list = liveHandles(id)
    local shown = Filter.IsEntryShown(entryId(id))

    if origDisplay[blip] == nil then
        origDisplay[blip] = GetBlipInfoIdDisplay(blip)
    end

    for i = 1, #list do
        if list[i] == blip then
            -- már ismerjük (pl. a :workReady utáni újra-bejelentkezés) -- csak frissítünk
            if Style.unify and not styleless then applyStyle(blip) end
            named[blip] = (not styleless) or nil
            applyVisibility(blip, shown)
            return
        end
    end

    list[#list + 1] = blip
    named[blip] = (not styleless) or nil
    if Style.unify and not styleless then applyStyle(blip) end
    applyVisibility(blip, shown)
end)

-- Ha ez a resource indul újra a munka-resource-ok után, szólunk nekik, hogy
-- jelentkezzenek be még egyszer -- különben a kapcsolók üres listát kapnának.
CreateThread(function()
    Wait(0)
    TriggerEvent('blipek:workReady')
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- A SZŰRŐ FELÉ
-----------------------------------------------------------------------------------------------------------------------------------------

--- Újraalkalmazza a láthatóságot minden munka-blipre (kapcsolás után hívjuk).
function Work.Apply()
    for id in pairs(handles) do
        local list = liveHandles(id)
        local shown = Filter.IsEntryShown(entryId(id))
        for i = 1, #list do
            applyVisibility(list[i], shown)
        end
    end
end

--- Minden általunk kezelt blip handle-je. Az external.lua ezt kérdezi le, hogy
--- az idegen-blip söprő NE nyúljon hozzájuk (a sprite 478 nála a "csempészáru"
--- tétel, tehát különben összeakadnánk).
---@return number[]
function Work.OwnedHandles()
    local out = {}
    for id in pairs(handles) do
        local list = liveHandles(id)
        for i = 1, #list do
            out[#out + 1] = list[i]
        end
    end
    return out
end

--- Frissíti a menü-tételek darabszámát, és visszaadja a 'munkak' kategóriára
--- eső összes (nevesített) blipet.
---@return number
function Work.Counts()
    local total = 0

    for _, entry in ipairs(Filter.Entries()) do
        local id = entry.id:match('^w:(.+)$')
        if id and handles[id] then
            local list = liveHandles(id)
            local count = 0
            for i = 1, #list do
                if named[list[i]] then count = count + 1 end
            end
            entry.count = count
            total = total + count
        end
    end

    return total
end

--- Leállításkor visszaadjuk a láthatóságot, különben a display = 0 ott ragadna
--- a munka-resource blipjein, és újraindulásig láthatatlanok maradnának.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for id in pairs(handles) do
        local list = liveHandles(id)
        for i = 1, #list do
            applyVisibility(list[i], true)
        end
    end
end)

return Work
