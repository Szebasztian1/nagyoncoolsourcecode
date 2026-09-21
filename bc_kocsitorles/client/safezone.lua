---@type boolean
local isInsideSafeZone = false

---@return boolean
function Safe()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, zoneInfo in pairs(Config.Zones) do
        local zoneCenter = vector3(zoneInfo.x, zoneInfo.y, zoneInfo.z)
        if #(zoneCenter - playerCoords) < zoneInfo.r then
            return true
        end
    end

    return false
end

exports("isPlayerSafe", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local invokingResource = GetInvokingResource()
    local isInvokedByInventory = invokingResource == "ox_inventory"

    for _, zoneInfo in pairs(Config.Zones) do
        local zoneCenter = vector3(zoneInfo.x, zoneInfo.y, zoneInfo.z)
        if #(zoneCenter - playerCoords) < zoneInfo.r then
            if not isInvokedByInventory then
                return true
            elseif not zoneInfo.caninv then
                return true
            end
        end
    end

    return false
end)

CreateThread(function()
    Wait(2000)
    while true do
        Wait(1000)

        local currentlyInZone = Safe()

        if currentlyInZone and not isInsideSafeZone then
            isInsideSafeZone = true
            TriggerEvent("esx:showNotification", "Publikus területre értél")
        elseif not currentlyInZone and isInsideSafeZone then
            isInsideSafeZone = false
            TriggerEvent("esx:showNotification", "Kiléptél a publikus területről")
        end
    end
end)



lib.callback.register("getSafezone", function()
    return exports["bc_kocsitorles"]:isPlayerSafe()
end)
