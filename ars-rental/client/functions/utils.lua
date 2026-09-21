local CreateVehicle                   = CreateVehicle
local SetVehicleNeedsToBeHotwired     = SetVehicleNeedsToBeHotwired
local NetworkFadeInEntity             = NetworkFadeInEntity
local SetModelAsNoLongerNeeded        = SetModelAsNoLongerNeeded
local CreatePed                       = CreatePed
local FreezeEntityPosition            = FreezeEntityPosition
local SetEntityInvincible             = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents

utils                                 = {}

function utils.createVehicle(vehicleModel, ...)
    local model = lib.requestModel(vehicleModel)

    if not model then return end

    local vehicle = CreateVehicle(model, ...)
    -- bc_kocsitorles: legalis spawn jelolese
    if vehicle and vehicle ~= 0 then Entity(vehicle).state:set('bc_spawned', true, true) end

    SetVehicleNeedsToBeHotwired(vehicle, false)
    NetworkFadeInEntity(vehicle, true)
    SetModelAsNoLongerNeeded(model)

    return vehicle
end

function utils.createPed(name, coords)
    local model = lib.requestModel(name)

    if not model then return end

    local ped = CreatePed(0, model, coords, false, false)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(model)

    return ped
end

function utils.showNotification(msg, type)
    lib.notify({
        title = 'Black City Bérlő',
        description = msg,
        type = type and type or 'info'
    })
end
