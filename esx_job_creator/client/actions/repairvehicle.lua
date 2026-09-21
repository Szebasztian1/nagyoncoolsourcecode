local isRepairingVehicle = false

local function repairVehicle()
    if(isRepairingVehicle) then return end
    
    local plyPed = PlayerPedId()

    if(IsPedInAnyVehicle(plyPed, false)) then
        return
    end

    local plyCoords = GetEntityCoords(plyPed)

    local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle(plyCoords)

    if(closestDistance < 3.0) then
        ESX.TriggerServerCallback('esx_job_creator:canRepairVehicle', function(canRepair)
            if(canRepair) then
                isRepairingVehicle = true

                TaskTurnPedToFaceEntity(plyPed, closestVehicle, 1500)
        
                Citizen.Wait(1500)
        
                local timeToRepairVehicle = 45000
        
                TaskStartScenarioInPlace(plyPed, 'PROP_HUMAN_BUM_BIN', 0, true)

                FreezeEntityPosition(plyPed, true)
        
                startProgressBar(timeToRepairVehicle, getLocalizedText('actions:repairing_vehicle'))
        
                Citizen.Wait(timeToRepairVehicle)
        
                local fuellevel = GetVehicleFuelLevel(closestVehicle)
                SetVehicleFixed(closestVehicle)
                SetVehicleFuelLevel(closestVehicle,100.0)
		        DecorSetFloat(closestVehicle, "FUEL_LEVEL", GetVehicleFuelLevel(closestVehicle))
                SetEntityHealth(closestVehicle, GetEntityMaxHealth(closestVehicle))
                SetVehicleDeformationFixed(closestVehicle)

                -- A SetVehicleFixed lokalis nativ: csak a jarmu tulajdonosanak
                -- kliensen hat, a szerelo pedig szinte soha nem az. Ezert a javitast
                -- a szerveren keresztul minden kliensre kikuldjuk (relay:
                -- esx_repairkit/server/main.lua), kulonben a tank health sertult marad
                -- a vezetonel es megy tovabb az ox_fuel benzinfolyasa.
                if NetworkGetEntityIsNetworked(closestVehicle) then
                    TriggerServerEvent('bc_repair:fix', NetworkGetNetworkIdFromEntity(closestVehicle))
                end

                Wait(500)
                SetVehicleFuelLevel(closestVehicle, fuellevel)


                FreezeEntityPosition(PlayerPedId(), false)
                ClearPedTasks(plyPed)
        
                isRepairingVehicle = false
            end
        end)
    else
        notifyClient(getLocalizedText('actions:no_vehicles_close'))
    end
end
RegisterNetEvent('esx_job_creator:actions:repairVehicle', repairVehicle)