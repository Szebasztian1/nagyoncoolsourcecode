local isImpoundingVehicle = false

local function impoundVehicle()
    if (isImpoundingVehicle) then return end

    local plyPed = PlayerPedId()

    if (IsPedInAnyVehicle(plyPed, false)) then
        return
    end

    local plyCoords = GetEntityCoords(plyPed)

    local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle(plyCoords)

    if (closestDistance < 3.0) then
        isImpoundingVehicle = true

        TaskTurnPedToFaceEntity(plyPed, closestVehicle, 1500)

        Citizen.Wait(1500)

        local timeToImpound = 10000

        FreezeEntityPosition(PlayerPedId(), true)
        TaskStartScenarioInPlace(plyPed, 'PROP_HUMAN_BUM_BIN', 0, true)

        startProgressBar(timeToImpound, getLocalizedText('actions:impounding_vehicle'))

        Citizen.Wait(timeToImpound)

        local vehdata = ESX.Game.GetVehicleProperties(closestVehicle)

        if (DoesEntityExist(closestVehicle)) then
            DeleteEntity(closestVehicle)
        end

        ClearPedTasks(plyPed)

        isImpoundingVehicle = false
        FreezeEntityPosition(PlayerPedId(), false)

        if not vehdata then return end

        exports["gs_eventprotect"]:GS_TriggerServerEvent("impoundcar_police", ESX.Math.Trim(vehdata.plate), vehdata)
       -- TriggerServerEvent("impoundcar_police", ESX.Math.Trim(vehdata.plate), vehdata)
    else
        notifyClient(getLocalizedText('actions:no_vehicles_close'))
    end
end
RegisterNetEvent('esx_job_creator:actions:impoundVehicle', impoundVehicle)

RegisterNetEvent("bc_jobsys:impound", function(data)
    if (isImpoundingVehicle) then return end

    local plyPed = PlayerPedId()

    if (IsPedInAnyVehicle(plyPed, false)) then
        return
    end

    local plyCoords = GetEntityCoords(plyPed)

    --local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle(plyCoords)
    local closestVehicle = data.entity

    if DoesEntityExist(plyPed) then
        isImpoundingVehicle = true

        TaskTurnPedToFaceEntity(plyPed, closestVehicle, 1500)

        Citizen.Wait(1500)

        local timeToImpound = 10000

        FreezeEntityPosition(PlayerPedId(), true)
        TaskStartScenarioInPlace(plyPed, 'PROP_HUMAN_BUM_BIN', 0, true)

        startProgressBar(timeToImpound, getLocalizedText('actions:impounding_vehicle'))

        Citizen.Wait(timeToImpound)

        local vehdata = ESX.Game.GetVehicleProperties(closestVehicle)

        if (DoesEntityExist(closestVehicle)) then
            DeleteEntity(closestVehicle)
        end

        ClearPedTasks(plyPed)

        isImpoundingVehicle = false
        FreezeEntityPosition(PlayerPedId(), false)

        exports["gs_eventprotect"]:GS_TriggerServerEvent("impoundcar_police", ESX.Math.Trim(vehdata.plate), vehdata)
       -- TriggerServerEvent("impoundcar_police", ESX.Math.Trim(vehdata.plate), vehdata)
    else
        notifyClient(getLocalizedText('actions:no_vehicles_close'))
    end
end)
