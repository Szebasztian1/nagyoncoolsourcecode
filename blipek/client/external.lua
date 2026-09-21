-- Más resource-ok által létrehozott blipek kezelése. A blip nevét a játékból
-- nem lehet visszaolvasni, ezért SPRITE (és ha meg van adva, SZÍN) alapján
-- azonosítjuk őket -- lásd Config.ForeignBlips.
--
-- A rejtés nem destruktív: az eredeti display-értéket elmentjük és
-- visszaállítjuk, a másik script blip-handle-jéhez nem nyúlunk.
local Filter = require 'client.filter'
local Work = require 'client.work'

local External = {}

local hidden = {}   -- [blipHandle] = { sprite = number, display = number }
local isOwned       -- main.lua visszahívása: a miénk-e ez a handle?
local foreign = {}  -- [blipHandle] = true, a munka-blip kezelő (work.lua) tartja
local replaced = {} -- [blipHandle] = true, saját blip váltja ki (Config.ReplacedForeignBlips)

local MAX_SPRITE = 880 -- a mostani játékverziók legnagyobb sprite id-je fölött

-----------------------------------------------------------------------------------------------------------------------------------------
-- SPRITE -> TÉTEL kikeresés
-- Egy sprite-on több rendszer is osztozhat (pl. 225 = autó), ezért a színnel
-- szűkített sorok élveznek elsőbbséget, és csak utánuk jön a szín nélküli sor.
-----------------------------------------------------------------------------------------------------------------------------------------
local bySprite = {}

for _, f in ipairs(Config.ForeignBlips or {}) do
    local list = bySprite[f.sprite]
    if not list then
        list = {}
        bySprite[f.sprite] = list
    end

    local colourSet
    if f.colours then
        colourSet = {}
        for _, c in ipairs(f.colours) do colourSet[c] = true end
    end

    list[#list + 1] = { id = 'f:' .. f.id, category = f.category, colours = colourSet }
end

---@param sprite number
---@param blip number
---@return table? entry
local function entryForBlip(sprite, blip)
    local list = bySprite[sprite]
    if not list then return nil end

    local colour = GetBlipColour(blip)
    local fallback

    for i = 1, #list do
        local e = list[i]
        if e.colours then
            if e.colours[colour] then return e end
        elseif not fallback then
            fallback = e
        end
    end

    return fallback
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- KEZELHETŐSÉG
-- Nem nyúlunk: védett sprite-hoz, a saját blipjeinkhez, entitáshoz kötött
-- bliphez (jármüvön/játékoson ülő küldetés-blip), és olyanhoz, amit a
-- work.lua tart kézben (az egységesített munka-blipek).
-----------------------------------------------------------------------------------------------------------------------------------------
local function refreshForeignOwned()
    foreign = {}
    local handles = Work.OwnedHandles()
    for i = 1, #handles do foreign[handles[i]] = true end
end

---@param sprite number
---@param blip number
---@return boolean
local function isManageable(sprite, blip)
    return not Config.ProtectedSprites[sprite]
        and not foreign[blip]
        and not replaced[blip]
        and GetBlipInfoIdEntityIndex(blip) == 0
        and not isOwned(blip)
end

local function anyManagedDisabled()
    for _, list in pairs(bySprite) do
        for i = 1, #list do
            if not Filter.IsEntryShown(list[i].id) then return true end
        end
    end
    return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ALKALMAZÁS
-- Előbb visszaadjuk azokat, amiket újra be szabad kapcsolni, aztán elrejtjük
-- a kikapcsolt tételekhez tartozó idegen blipeket. Gyakran hívható.
-----------------------------------------------------------------------------------------------------------------------------------------
function External.Apply()
    refreshForeignOwned()

    for handle, info in pairs(hidden) do
        local valid = DoesBlipExist(handle) and GetBlipSprite(handle) == info.sprite
        local entry = valid and entryForBlip(info.sprite, handle) or nil

        if replaced[handle] then
            hidden[handle] = nil -- a kiváltott blip rejtve marad
        elseif not entry or Filter.IsEntryShown(entry.id) then
            if valid then
                SetBlipDisplay(handle, info.display)
            end
            hidden[handle] = nil
        end
    end

    for sprite in pairs(bySprite) do
        local blip = GetFirstBlipInfoId(sprite)
        while blip ~= 0 and DoesBlipExist(blip) do
            if not hidden[blip] and isManageable(sprite, blip) then
                local entry = entryForBlip(sprite, blip)
                if entry and not Filter.IsEntryShown(entry.id) then
                    hidden[blip] = { sprite = sprite, display = GetBlipInfoIdDisplay(blip) }
                    SetBlipDisplay(blip, 0)
                end
            end
            blip = GetNextBlipInfoId(sprite)
        end
    end
end

--- Idegen blipek darabszáma kategóriánként; közben a tételek saját
--- számlálóját is frissíti, hogy a menüben látszódjon, hány blipet érint.
---@return table<string, number>
function External.Counts()
    refreshForeignOwned()

    local counts = {}
    local perEntry = {}

    for sprite, list in pairs(bySprite) do
        local blip = GetFirstBlipInfoId(sprite)
        while blip ~= 0 and DoesBlipExist(blip) do
            if isManageable(sprite, blip) or hidden[blip] then
                local entry = entryForBlip(sprite, blip)
                if entry then
                    counts[entry.category] = (counts[entry.category] or 0) + 1
                    perEntry[entry.id] = (perEntry[entry.id] or 0) + 1
                end
            end
            blip = GetNextBlipInfoId(sprite)
        end
        -- a nem talált tételek is nullázódjanak
        for i = 1, #list do
            perEntry[list[i].id] = perEntry[list[i].id] or 0
        end
    end

    for _, entry in ipairs(Filter.Entries()) do
        if perEntry[entry.id] ~= nil then
            entry.count = perEntry[entry.id]
        end
    end

    return counts
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- KIVÁLTOTT BLIPEK
-- Ahol a Config.Blips egy saját sora ugyanazt a helyet jelöli, az idegen blipet
-- elrejtjük (Config.ReplacedForeignBlips). Nem töröljük: a display 0 idegen
-- handle-en is biztosan működik, és a legendából is kiveszi.
-----------------------------------------------------------------------------------------------------------------------------------------
function External.HideReplaced()
    local rules = Config.ReplacedForeignBlips
    if not isOwned or not rules or #rules == 0 then return end

    for handle in pairs(replaced) do
        if not DoesBlipExist(handle) then replaced[handle] = nil end
    end

    for _, rule in ipairs(rules) do
        local blip = GetFirstBlipInfoId(rule.sprite)
        while blip ~= 0 and DoesBlipExist(blip) do
            if GetBlipInfoIdDisplay(blip) ~= 0
                and not isOwned(blip)
                and GetBlipInfoIdEntityIndex(blip) == 0
                and (rule.colour == nil or GetBlipColour(blip) == rule.colour)
                and #(GetBlipInfoIdCoord(blip) - rule.coords) <= (rule.radius or 5.0) then
                replaced[blip] = true
                SetBlipDisplay(blip, 0)
            end
            blip = GetNextBlipInfoId(rule.sprite)
        end
    end
end

---@param isOwnedCb fun(handle: number): boolean
function External.Init(isOwnedCb)
    isOwned = isOwnedCb
end

-- A többi script bármikor újra létrehozhatja a blipjeit (új handle-lel), ezért
-- a kiváltott blipeket mindig, a szűrést pedig akkor alkalmazzuk újra, amíg
-- bármelyik kezelt tétel ki van kapcsolva.
CreateThread(function()
    while true do
        Wait(5000)
        if isOwned then
            External.HideReplaced()

            if anyManagedDisabled() then
                External.Apply()
            end
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FELDERÍTŐ PARANCSOK
-----------------------------------------------------------------------------------------------------------------------------------------

-- Kilistázza az összes idegen blip sprite-ot az F8 konzolba, hogy az új
-- tételeket be lehessen tenni a Config.ForeignBlips-be.
RegisterCommand('blipsprites', function()
    if not isOwned then return end
    refreshForeignOwned()

    print('--- blipek: idegen blip sprite-ok (masold ki es kategorizald) ---')
    local total = 0

    for sprite = 1, MAX_SPRITE do
        local count = 0
        local colour, coords

        local blip = GetFirstBlipInfoId(sprite)
        while blip ~= 0 and DoesBlipExist(blip) do
            if isManageable(sprite, blip) then
                count = count + 1
                if not coords then
                    colour = GetBlipColour(blip)
                    coords = GetBlipInfoIdCoord(blip)
                end
            end
            blip = GetNextBlipInfoId(sprite)
        end

        if count > 0 then
            total = total + 1
            local list = bySprite[sprite]
            local cat = '-'
            if list then
                cat = #list == 1 and list[1].category or 'szin-fuggo'
            end
            print(('sprite %d | db: %d | szin: %d | kategoria: %s | pl.: %.1f, %.1f')
                :format(sprite, count, colour, cat, coords.x, coords.y))
        end
    end

    print(('--- osszesen %d fele sprite ---'):format(total))
    print('Tipp: waypoint a blipre + /blipmiez [szin] [kategoria] az azonositashoz/besorolashoz')
end, false)

local categoryKeys = {}
local categoryList
do
    local keys = {}
    for i, cat in ipairs(Config.Categories) do
        categoryKeys[cat.key] = true
        keys[i] = cat.key
    end
    categoryList = table.concat(keys, ', ')
end

---@param coords vector3
---@return number? sprite, number? dist, number? count, number? colour
local function findNearestForeignBlip(coords)
    local bestSprite, bestDist, bestColour

    for sprite = 1, MAX_SPRITE do
        local blip = GetFirstBlipInfoId(sprite)
        while blip ~= 0 and DoesBlipExist(blip) do
            if isManageable(sprite, blip) then
                local c = GetBlipInfoIdCoord(blip)
                local dist = #(c.xy - coords.xy)
                if not bestDist or dist < bestDist then
                    bestDist, bestSprite, bestColour = dist, sprite, GetBlipColour(blip)
                end
            end
            blip = GetNextBlipInfoId(sprite)
        end
    end

    if not bestSprite then return end

    local count = 0
    local blip = GetFirstBlipInfoId(bestSprite)
    while blip ~= 0 and DoesBlipExist(blip) do
        if isManageable(bestSprite, blip) then
            count = count + 1
        end
        blip = GetNextBlipInfoId(bestSprite)
    end

    return bestSprite, bestDist, count, bestColour
end

-- Azonosítja (és igény szerint besorolja) a waypoint alatti idegen blipet.
-- A térkép mutatja a blip nevét, ha ráviszed az egeret, tehát: rávisz ->
-- waypoint -> /blipmiez.
--   /blipmiez                  -> kiírja a sprite adatait
--   /blipmiez munkak           -> az egész sprite-ot besorolja
--   /blipmiez szin munkak      -> csak ezt a blip-színt sorolja be
-- A futásidejű besorolás a restartig él; a kiírt sort másold a config_static.lua
-- Config.ForeignBlips táblájába, hogy megmaradjon (és nevet is kapjon).
RegisterCommand('blipmiez', function(_, args)
    if not isOwned then return end
    refreshForeignOwned()

    local wp = GetFirstBlipInfoId(8)
    if not DoesBlipExist(wp) then
        print('[blipek] Tegyel eloszor waypointot az azonositando blipre a terkepen!')
        return
    end

    local sprite, dist, count, colour = findNearestForeignBlip(GetBlipInfoIdCoord(wp))
    if not sprite then
        print('[blipek] Nem talaltam idegen blipet.')
        return
    end

    local blipForCat = GetFirstBlipInfoId(sprite)
    local existing = blipForCat ~= 0 and entryForBlip(sprite, blipForCat) or nil
    print(('[blipek] Legkozelebbi idegen blip: sprite %d | szin: %d | tavolsag: %.0f m | db: %d | tetel: %s')
        :format(sprite, colour, dist, count, existing and existing.id or '-'))

    local key, colourOnly = args[1], false
    if key == 'szin' then
        colourOnly = true
        key = args[2]
    end

    if not key then
        print(('[blipek] Besorolas: /blipmiez <kategoria> vagy /blipmiez szin <kategoria>  (%s)'):format(categoryList))
        return
    end

    if not categoryKeys[key] then
        print(('[blipek] Ismeretlen kategoria: %s (hasznalhato: %s)'):format(key, categoryList))
        return
    end

    local id = ('sprite%d%s'):format(sprite, colourOnly and ('_c' .. colour) or '')
    local list = bySprite[sprite]
    if not list then
        list = {}
        bySprite[sprite] = list
    end
    list[#list + 1] = {
        id = 'f:' .. id,
        category = key,
        colours = colourOnly and { [colour] = true } or nil,
    }
    Filter.AddEntry('f:' .. id, ('sprite %d'):format(sprite), key)

    External.Apply()
    print(('[blipek] sprite %d -> %s. Vegleges mentes a config_static.lua Config.ForeignBlips tablajaba:'):format(sprite, key))
    print(("    { id = '%s', label = 'ATIRNI', category = '%s', sprite = %d%s },")
        :format(id, key, sprite, colourOnly and (', colours = { ' .. colour .. ' }') or ''))
end, false)

return External
