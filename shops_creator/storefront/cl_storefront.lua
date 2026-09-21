-- ===========================================================================
-- Bolti kirakat (hirdetés) — kliens oldal
--
-- Csak postás, ugyanaz a minta, mint a discounts/cl_discounts.lua-ban.
-- Szándékosan külön esemény-nevekkel és külön állapottal fut, hogy a két
-- kiegészítő ne tudja egymást elrontani.
-- ===========================================================================

Storefront = Storefront or {}

local nextRequestId = 0
local waiting = {}

local function request(name, payload)
    nextRequestId = nextRequestId + 1

    local id = nextRequestId
    local p = promise.new()

    waiting[id] = p
    TriggerServerEvent('shops_creator:storefront:request', id, name, payload or {})

    SetTimeout(10000, function()
        local pending = waiting[id]
        if pending then
            waiting[id] = nil
            pending:resolve(nil)
        end
    end)

    return Citizen.Await(p)
end

RegisterNetEvent('shops_creator:storefront:response', function(id, result)
    local p = waiting[id]
    if not p then return end

    waiting[id] = nil
    p:resolve(result)
end)

local function nuiBridge(name)
    return function(data, cb)
        CreateThread(function()
            local ok, result = pcall(request, name, data)
            cb(ok and result or false)
        end)
    end
end

RegisterNUICallback('bcStorefrontGet',   nuiBridge('get'))
RegisterNUICallback('bcStorefrontSave',  nuiBridge('save'))
RegisterNUICallback('bcStorefrontClear', nuiBridge('clear'))

--- Hol vagyunk? A menü ezt írja ki a bolt neve alá.
--- A játékos ilyenkor a boltnál áll, így a saját pozíciója a bolt pozíciója —
--- nem kell hozzá a szervertől koordinátát kérni.
RegisterNUICallback('bcShopLocation', function(_, cb)
    local coords = GetEntityCoords(PlayerPedId())

    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = streetHash and GetStreetNameFromHashKey(streetHash) or ''
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z)) or ''

    -- a GetLabelText ismeretlen zónára 'NULL'-t ad vissza
    if zone == 'NULL' then zone = '' end

    cb({ street = street, zone = zone })
end)
