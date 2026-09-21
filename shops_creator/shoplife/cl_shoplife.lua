-- ===========================================================================
-- Bolti szavatosság — kliens oldal
--
-- Csak postás, ugyanaz a minta, mint a discounts/ és a storefront/ addonban.
-- Külön esemény-nevekkel fut, hogy a három kiegészítő ne tudja egymást
-- elrontani.
-- ===========================================================================

local nextRequestId = 0
local waiting = {}

local function request(name, payload)
    nextRequestId = nextRequestId + 1

    local id = nextRequestId
    local p = promise.new()

    waiting[id] = p
    TriggerServerEvent('shops_creator:shoplife:request', id, name, payload or {})

    SetTimeout(10000, function()
        local pending = waiting[id]

        if pending then
            waiting[id] = nil
            pending:resolve(nil)
        end
    end)

    return Citizen.Await(p)
end

RegisterNetEvent('shops_creator:shoplife:response', function(id, result)
    local p = waiting[id]
    if not p then return end

    waiting[id] = nil
    p:resolve(result)
end)

RegisterNUICallback('bcShopQuality', function(data, cb)
    CreateThread(function()
        local ok, result = pcall(request, 'quality', data)
        cb(ok and result or false)
    end)
end)
