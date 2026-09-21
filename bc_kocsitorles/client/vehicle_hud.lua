---@param value number
---@param oldValue number
--[[lib.onCache('vehicle', function(value, oldValue)
    if not DoesEntityExist(value) then return end

    local expiresAt = GetGameTimer() + 4000
    local engineKey = GetKeyMappingKey(GetHashKey("vehengine"))
    local lockKey = GetKeyMappingKey(GetHashKey("vehlock"))

    while GetVehiclePedIsIn(PlayerPedId(), false) == value do
        if GetGameTimer() > expiresAt then return end
        ESX.Game.Utils.DrawText3D(
            GetEntityCoords(value),
            "Inditas - " .. engineKey .. "~n~Zar - " .. lockKey,
            1.0,
            1
        )
        Wait(1)
    end
end)]]
