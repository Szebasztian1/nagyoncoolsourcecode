handlers['getin'] = function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local veh = lib.getClosestVehicle(pos, 40.0, false)
    if not veh or veh == 0 then return end
    TaskWarpPedIntoVehicle(ped, veh, -1)

    for _ = 1, 20 do
        Wait(10)
        SetPedIntoVehicle(ped, veh, -1)
        TaskWarpPedIntoVehicle(ped, veh, -1)
        if GetVehiclePedIsIn(ped, false) == veh then break end
    end
end

handlers['fix'] = function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if not DoesEntityExist(veh) then return end

    SetVehicleFixed(veh)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehiclePetrolTankHealth(veh, 1000.0)
    SetVehicleBodyHealth(veh, 1000.0)
    WashDecalsFromVehicle(veh, 1.0)
    SetVehicleFuelLevel(veh, 100.0)
    TriggerEvent("ox_fuel:setfuel", veh, 100.0)
    Entity(veh).state.fuel = 100.0

    lib.notify({ title = locale('vehicle.fix_title'), description = locale('vehicle.fixed'), type = 'success', duration = 3000 })
end

handlers['clean'] = function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if not DoesEntityExist(veh) then return end

    SetVehicleDirtLevel(veh, 0.0)
    WashDecalsFromVehicle(veh, 1.0)

    lib.notify({ title = locale('vehicle.clean_title'), description = locale('vehicle.cleaned'), type = 'success', duration = 3000 })
end

handlers['maxtuning'] = function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if not DoesEntityExist(veh) then return end

    SetVehicleModKit(veh, 0)
    for mod = 0, 49 do
        local count = GetNumVehicleMods(veh, mod)
        if count > 0 then
            SetVehicleMod(veh, mod, count - 1, false)
        end
    end
    ToggleVehicleMod(veh, 18, true)
    ToggleVehicleMod(veh, 20, true)
    SetVehicleWindowTint(veh, 1)

    lib.notify({ title = locale('vehicle.maxtuning_title'), description = locale('vehicle.maxtuning_applied'), type = 'success', duration = 3000 })
end
