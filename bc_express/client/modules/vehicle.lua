-- BC Express – jármű: lehívás/spawn, raktér ox_target ("Doboz kivétele"), törlés.

local Core = require 'client.modules.core'
local Box  = require 'client.modules.box'

local Vehicle = {}

local function addCarTarget()
    if not Core.jobVeh or not DoesEntityExist(Core.jobVeh) then return end
    exports.ox_target:addLocalEntity(Core.jobVeh, {
        {
            name = 'bcx_pickup', icon = 'fa-solid fa-boxes-stacked', label = 'Doboz kivétele', distance = 2.5,
            canInteract = function()
                return Core.jobActive and not Core.carryingBox and Core.hasActiveTarget()
                    and Core.nearActiveAddress(Config.DeliverRadius + 20.0)
            end,
            onSelect = function() Box.pickupBox() end,
        }
    })
end

-- Sikeres spawnkor a jármű handle-jét adja vissza, betöltési hibánál nil-t (a hívó bontja a munkát).
function Vehicle.spawnCar(spawn, modelName)
    local model = joaat(modelName or Config.VehicleModel)
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 500 do Wait(10) t = t + 1 end   -- max ~5 mp
    if not HasModelLoaded(model) then
        SetModelAsNoLongerNeeded(model)
        Core.phoneNotify('BC Express', 'A jármű modell nem tölthető be – próbáld újra.')
        return nil
    end
    local veh = CreateVehicle(model, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    -- bc_kocsitorles: legalis spawn jelolese
    if veh and veh ~= 0 then Entity(veh).state:set('bc_spawned', true, true) end
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleNumberPlateText(veh, 'BCX ' .. math.random(1000, 9999))
    -- teli tank: native + ox_fuel statebag (a lc_gas_stations is ezt olvassa ox_fuel mellett)
    SetVehicleFuelLevel(veh, 100.0)
    Entity(veh).state:set('fuel', 100, true)
    SetVehicleDoorsLocked(veh, 1)
    SetModelAsNoLongerNeeded(model)
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
    Core.jobVeh = veh
    addCarTarget()
    return veh
end

function Vehicle.deleteCar()
    if Core.jobVeh and DoesEntityExist(Core.jobVeh) then
        exports.ox_target:removeLocalEntity(Core.jobVeh)
        SetEntityAsMissionEntity(Core.jobVeh, true, true)
        DeleteVehicle(Core.jobVeh)
    end
    Core.jobVeh = nil
end

return Vehicle
