-- ===========================================================================
-- Bolti kedvezmények — kliens oldal
--
-- Csak postás: a NUI (html/scripts/functions.js) hívásait továbbítja a
-- szervernek és visszaadja a választ. Semmilyen döntést nem hoz — az árat és
-- a jogosultságot végig a szerver mondja meg.
-- ===========================================================================

Discounts = Discounts or {}

local nextRequestId = 0
local waiting = {}

--- Kérés a szerverhez. nil-t ad vissza, ha időtúllépés lett.
local function request(name, payload)
    nextRequestId = nextRequestId + 1

    local id = nextRequestId
    local p = promise.new()

    waiting[id] = p
    TriggerServerEvent('shops_creator:discounts:request', id, name, payload or {})

    SetTimeout(10000, function()
        local pending = waiting[id]
        if pending then
            waiting[id] = nil
            pending:resolve(nil)
        end
    end)

    return Citizen.Await(p)
end

RegisterNetEvent('shops_creator:discounts:response', function(id, result)
    local p = waiting[id]
    if not p then return end

    waiting[id] = nil
    p:resolve(result)
end)

--- A NUI-nak minden kérés ugyanaz: küldd tovább, hívd vissza a callbacket.
--- Külön szálon fut, hogy a Citizen.Await ne blokkolja a NUI-t.
local function nuiBridge(name)
    return function(data, cb)
        CreateThread(function()
            local ok, result = pcall(request, name, data)
            cb(ok and result or false)
        end)
    end
end

RegisterNUICallback('bcDiscountInfo',      nuiBridge('info'))
RegisterNUICallback('bcDiscountPrepare',   nuiBridge('prepare'))
RegisterNUICallback('bcDiscountList',      nuiBridge('list'))
RegisterNUICallback('bcDiscountAdd',       nuiBridge('add'))
RegisterNUICallback('bcDiscountRevoke',    nuiBridge('revoke'))
RegisterNUICallback('bcDiscountRevokeAll', nuiBridge('revokeAll'))

--- A szerver szól, ha valakinek a kedvezménye megváltozott (adás/visszavonás).
--- Ha épp nyitva van nála a bolt, a NUI frissíti magát.
RegisterNetEvent('shops_creator:discounts:changed', function(shopId)
    SendNUIMessage({ action = 'bcDiscountChanged', shopId = shopId })
end)
