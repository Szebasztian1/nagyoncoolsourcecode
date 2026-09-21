local vehicleNetId = nil
local heistBlip = nil
local staticBlip = nil
local trackerCoords = nil
local trackingMission = false
local isMissionOwner = false
local missionEndAt = nil
local noExitEndAt = nil
local deathReported = false

local function notify(msg, typ)
    typ = typ or 'inform'

    --if GetResourceState('okokNotify') == 'started' then
    --    exports['okokNotify']:Alert(Config.Notify.title, msg, 5000, typ)
    --    return
    --end
--
    --lib.notify({
    --    title = Config.Notify.title,
    --    description = msg,
    --    type = typ
    --})
    TriggerEvent('esx:showNotification', msg)
    print("noty", msg)
end

local function formatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format('%02d:%02d', mins, secs)
end


local function removeHeistBlip()
    if heistBlip and DoesBlipExist(heistBlip) then
        RemoveBlip(heistBlip)
    end

    heistBlip = nil
end
local function updateBlip(coords)
    if not coords then
        return
    end
    --RemoveBlip(heistBlip)
    if not heistBlip or not DoesBlipExist(heistBlip) then
        heistBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(heistBlip, Config.Blip.sprite)
        SetBlipColour(heistBlip, Config.Blip.color)
        SetBlipScale(heistBlip, Config.Blip.scale)
        SetBlipAsShortRange(heistBlip, false)
        --SetBlipRoute(heistBlip, false)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Blip.name)
        EndTextCommandSetBlipName(heistBlip)
    else
        SetBlipCoords(heistBlip, coords.x, coords.y, coords.z)
    end
end


--local function getKillerServerId()
--    local ped = PlayerPedId()
--    local killerEntity = GetPedSourceOfDeath(ped)
--
--    if not killerEntity or killerEntity == 0 then
--        return nil
--    end
--
--    if IsEntityAPed(killerEntity) and IsPedAPlayer(killerEntity) then
--        local killerPlayer = NetworkGetPlayerIndexFromPed(killerEntity)
--        if killerPlayer and killerPlayer ~= -1 then
--            return GetPlayerServerId(killerPlayer)
--        end
--    end
--
--    if IsEntityAVehicle(killerEntity) then
--        local driver = GetPedInVehicleSeat(killerEntity, -1)
--        if driver ~= 0 and IsPedAPlayer(driver) then
--            local killerPlayer = NetworkGetPlayerIndexFromPed(driver)
--            if killerPlayer and killerPlayer ~= -1 then
--                return GetPlayerServerId(killerPlayer)
--            end
--        end
--    end
--
--    return nil
--end

RegisterNetEvent('bc_vilmos_heist:client:notify', function(msg, typ)
    notify(msg, typ)
end)


RegisterNetEvent('bc_vilmos_heist:client:setVehicle', function(netId)
    vehicleNetId = netId
end)

RegisterNetEvent('bc_vilmos_heist:client:setTrackerCoords', function(coords)
    trackerCoords = coords

    --if trackingMission then
        updateBlip(coords)
    --end
end)

RegisterNetEvent('bc_vilmos_heist:client:startMission', function(netId, remainSeconds, noExitSeconds)
    vehicleNetId = netId
    trackingMission = true
    isMissionOwner = true
    deathReported = false
    missionEndAt = GetGameTimer() + ((remainSeconds or Config.MissionDuration or 600) * 1000)
    noExitEndAt = GetGameTimer() + ((noExitSeconds or Config.NoExitDuration or 180) * 1000)
    TriggerEvent("bc:alertpolicerobbery")

    --if trackerCoords then
    --    updateBlip(trackerCoords)
    --end

    CreateThread(function()
        while isMissionOwner do
            local remain = math.max(0, math.ceil((missionEndAt - GetGameTimer()) / 1000))
            local noExitRemain = math.max(0, math.ceil((noExitEndAt - GetGameTimer()) / 1000))
            local text = ('Vilmos Autó | Hátralévő idő: %s'):format(formatTime(remain))

            if noExitRemain > 0 then
                text = text .. (' | Kiszállás tiltva: %s'):format(formatTime(noExitRemain))
            end

            lib.showTextUI(text, {
                position = 'right-center'
            })

            Wait(1000)
        end

        lib.hideTextUI()
    end)

    CreateThread(function()
        while isMissionOwner do
            if noExitEndAt and GetGameTimer() < noExitEndAt then
                DisableControlAction(0, 75, true)
                DisableControlAction(27, 75, true)

                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)

                if veh == 0 and vehicleNetId then
                    local targetVeh = NetworkGetEntityFromNetworkId(vehicleNetId)

                    if targetVeh ~= 0 and DoesEntityExist(targetVeh) then
                        TaskWarpPedIntoVehicle(ped, targetVeh, -1)
                        Wait(250)
                    else
                        Wait(100)
                    end
                else
                    Wait(0)
                end
            else
                Wait(250)
            end
        end
    end)

    --CreateThread(function()
    --    local lastVehicle = 0
--
    --    while isMissionOwner do
    --        local ped = PlayerPedId()
    --        local veh = GetVehiclePedIsIn(ped, false)
--
    --        if veh ~= 0 and veh ~= lastVehicle then
    --            lastVehicle = veh
--
    --            if vehicleNetId and veh == NetworkGetEntityFromNetworkId(vehicleNetId) then
    --                TriggerServerEvent('bc_vilmos_heist:server:setFullFuel', vehicleNetId)
    --                setVehicleFuelFullByNetId(vehicleNetId)
    --            end
    --        elseif veh == 0 then
    --            lastVehicle = 0
    --        end
--
    --        Wait(500)
    --    end
    --end)

    --CreateThread(function()
    --    while isMissionOwner do
    --        local ped = PlayerPedId()
--
    --        if not deathReported and IsEntityDead(ped) then
    --            deathReported = true
    --            local killerSrc = getKillerServerId()
    --            TriggerServerEvent('bc_vilmos_heist:server:ownerDied', killerSrc)
    --            break
    --        end
--
    --        Wait(100)
    --    end
    --end)
end)

--RegisterNetEvent('bc_vilmos_heist:client:startHack', function(netId)
--    local success = lib.skillCheck(
--        Config.HackSkillcheck.difficulties,
--        Config.HackSkillcheck.keys
--    )
--
--    TriggerServerEvent('bc_vilmos_heist:server:hackResult', success == true)
--end)

--RegisterNetEvent('bc_vilmos_heist:client:unlockVehicle', function(netId)
--    local tries = 0
--    local veh = 0
--
--    while tries < 10 do
--        veh = NetworkGetEntityFromNetworkId(netId)
--
--        if veh ~= 0 and DoesEntityExist(veh) then
--            break
--        end
--
--        tries = tries + 1
--        Wait(150)
--    end
--
--    if veh ~= 0 and DoesEntityExist(veh) then
--        SetVehicleDoorsLocked(veh, 1)
--        SetVehicleNeedsToBeHotwired(veh, false)
--        SetVehicleFuelLevel(veh, 100.0)
--    end
--end)

RegisterNetEvent('bc_vilmos_heist:client:endMission', function()
    if isMissionOwner then 
    lib.hideTextUI()
    end
    trackingMission = false
    isMissionOwner = false
    deathReported = false
    missionEndAt = nil
    noExitEndAt = nil
    removeHeistBlip()
    
end)

CreateThread(function()
    Wait(1000)

    if Config.StaticBlip and Config.StaticBlip.enabled then
        staticBlip = AddBlipForCoord(
            Config.Start.coords.x,
            Config.Start.coords.y,
            Config.Start.coords.z
        )

        SetBlipSprite(staticBlip, Config.StaticBlip.sprite)
        SetBlipColour(staticBlip, Config.StaticBlip.color)
        SetBlipScale(staticBlip, Config.StaticBlip.scale)
        SetBlipAsShortRange(staticBlip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.StaticBlip.name)
        EndTextCommandSetBlipName(staticBlip)
    end

    vehicleNetId = lib.callback.await('bc_vilmos_heist:server:getVehicleNetId', false)

    exports.ox_target:addGlobalVehicle({
        {
            name = 'bc_vilmos_heist_target',
            icon = 'fa-solid fa-car',
            label = 'Törd fel Vilmos autóját',
            distance = Config.TargetDistance,
            canInteract = function(entity)
                if not entity or entity == 0 or not DoesEntityExist(entity) then
                    return false
                end

                return Entity(entity).state.vilmos_heist == true
            end,
            onSelect = function(data)
                local entity = data.entity

                if not entity or entity == 0 or not DoesEntityExist(entity) then
                    return
                end

                if Entity(entity).state.vilmos_heist ~= true then
                    return
                end

                local netId = NetworkGetNetworkIdFromEntity(entity)
                vehicleNetId = netId
                --TriggerServerEvent('bc_vilmos_heist:server:tryHack', netId)
                local canhack = lib.callback.await('bc_vilmos_heist:server:tryHack', false, netId)

                if not canhack  then
                    return
                end
                if canhack ~= netId then 
                    return
                end 

                local success = lib.skillCheck(
                    Config.HackSkillcheck.difficulties,
                    Config.HackSkillcheck.keys
                )

                TriggerServerEvent('bc_vilmos_heist:server:hackResult', success)
            end
        }
    })
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end

    trackingMission = false
    isMissionOwner = false
    deathReported = false
    missionEndAt = nil
    noExitEndAt = nil
    trackerCoords = nil

    lib.hideTextUI()
    removeHeistBlip()

    if staticBlip and DoesBlipExist(staticBlip) then
        RemoveBlip(staticBlip)
    end
end)