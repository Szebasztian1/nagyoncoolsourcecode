---@type boolean
local isRobbingTrain = false

RegisterNetEvent("bc:robTrain", function()
    isRobbingTrain = true
    Wait(15 * 60000)
    isRobbingTrain = false
end)

RegisterNetEvent("bc:cleararea", function()
    local currentCoords = GetEntityCoords(PlayerPedId())
    local clearRadius = 1000 + 0.0
    local closestVehicle = GetClosestVehicle(currentCoords.x, currentCoords.y, currentCoords.z, 25.0, 0, 70)

    if DoesEntityExist(closestVehicle) and GetVehicleType(closestVehicle) == "train" then return end
    if isRobbingTrain then return end

    ClearAreaLeaveVehicleHealth(currentCoords.x, currentCoords.y, currentCoords.z, clearRadius, false, false, false,
        false, false)
end)
