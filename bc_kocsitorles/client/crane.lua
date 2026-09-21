local CRANE_MODEL <const> = "cfrc"
local FIRETRUCK_MODEL <const> = "firetruk"

local FIRETRUCK_DISABLED_CONTROLS <const> = { 68, 69, 70 }

---@param vehicleEntity number
---@return boolean
local function IsPlayerDrivingModel(vehicleEntity, modelName)
    return vehicleEntity ~= 0 and DoesEntityExist(vehicleEntity) and
        GetEntityModel(vehicleEntity) == GetHashKey(modelName)
end

---@param extraIndex number
local function ToggleCraneExtra(extraIndex)
    local playerPed = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)

    if not IsPlayerDrivingModel(currentVehicle, CRANE_MODEL) then
        return
    end

    local isExtraOn = IsVehicleExtraTurnedOn(currentVehicle, extraIndex)
    SetVehicleExtra(currentVehicle, extraIndex, isExtraOn and 1 or 0)
end

RegisterCommand("daruextra1", function()
    ToggleCraneExtra(1)
end)

RegisterCommand("daruextra2", function()
    ToggleCraneExtra(2)
end)

lib.onCache('vehicle', function(currentVehicle)
    if not IsPlayerDrivingModel(currentVehicle, FIRETRUCK_MODEL) then return end

    CreateThread(function()
        while cache.vehicle == currentVehicle do
            for _, controlId in ipairs(FIRETRUCK_DISABLED_CONTROLS) do
                DisableControlAction(0, controlId, true)
            end
            Wait(0)
        end
    end)
end)
