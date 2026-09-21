local HANDCUFFPICKITEM = "lockpick"

local isHandcuffed = false
local isDragged = false

local isTryingToArrestAnybody = false

AddEventHandler('esx:onPlayerDeath', function(data)
    isHandcuffed = false
end)

exports('isCuffed', function()
    return isHandcuffed
end)

local function arrested(target)
    TriggerEvent("esx:showNotification",
        "Megbilincseltek! Kiszabadulni a /bilincsszokes paranccsal lehetséges, zártörő szükséges!")
    Citizen.CreateThread(function()
        local targetPed = PlayerPedId()

        local animDict = "mp_arresting"

        RequestAnimDict(animDict)

        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(0)
        end



        SetCurrentPedWeapon(targetPed, GetHashKey("WEAPON_UNARMED"), true)

        local arresterPed = GetPlayerPed(GetPlayerFromServerId(target))
        if DoesEntityExist(arresterPed) then
            RequestAnimDict("mp_arrest_paired")

            while not HasAnimDictLoaded("mp_arrest_paired") do
                Citizen.Wait(10)
            end

            AttachEntityToEntity(targetPed, arresterPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false,
                false, 20, false)
            TaskPlayAnim(targetPed, "mp_arrest_paired", "crook_p2_back_left", 8.0, -8.0, 5500, 33, 0, false, false, false)

            Citizen.Wait(950)
            DetachEntity(targetPed, true, false)
        else
            local arrestedAnimName = "arrested_spin_r_0"
            TaskPlayAnim(targetPed, animDict, arrestedAnimName, 4.0, -4.0, -1, 0, 0.0, 0, 0, 0)

            local animDuration = GetAnimDuration(animDict, arrestedAnimName)
            Citizen.Wait(animDuration * 1000)
        end



        SetEnableHandcuffs(targetPed, true)
        SetPedCanPlayGestureAnims(targetPed, false)

        LocalPlayer.state.invBusy = true
        -- replikált, hogy a szerver is lássa (Panel2 bilincs-küldetés számláló)
        LocalPlayer.state:set('handcuff', true, true)

        local handcuffedAnimName = "idle"

        while isHandcuffed do
            Citizen.Wait(0)

            DisablePlayerFiring(targetPed, true)

            DisableControlAction(0, 23, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 36, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            SetCurrentPedWeapon(targetPed, GetHashKey("WEAPON_UNARMED"), true)

            if (not IsEntityPlayingAnim(targetPed, animDict, handcuffedAnimName, 3)) then
                TaskPlayAnim(targetPed, animDict, handcuffedAnimName, 8.0, -8, -1, 49, 0, 0, 0, 0)
            end
        end

        ClearPedTasks(targetPed)

        LocalPlayer.state.invBusy = false
        LocalPlayer.state:set('handcuff', false, true)

        local arrestedAnimName = "b_uncuff"

        TaskPlayAnim(targetPed, animDict, arrestedAnimName, 4.0, -4.0, -1, 0, 0.0, 0, 0, 0)

        local animDuration = GetAnimDuration(animDict, arrestedAnimName)

        Citizen.Wait(animDuration * 1000)

        SetPedCanPlayGestureAnims(targetPed, true)
        SetEnableHandcuffs(targetPed, false)
    end)
end
local lasttry = 0
RegisterCommand("bilincsszokes", function()
    if not isHandcuffed then return end
    local count = exports.ox_inventory:Search('count', HANDCUFFPICKITEM)
    if count < 1 then
        TriggerEvent("esx:showNotification", "Nincs nálad zárfeltörő.")
        return
    end
    if lasttry + 1000 * 60 * 2 > GetGameTimer() then
        TriggerEvent("esx:showNotification", "Csak 2 percenként próbálhatod kiszabadítani magad!")
        return
    end
    lasttry = GetGameTimer()
    local suc = lib.skillCheck({ 'easy', 'easy', 'easy' }, { 'w', 'a', 's', 'd' })
    if suc then
        isHandcuffed = false
    end
end)

local function arrestAnimation(targetId, targetPed)
    isTryingToArrestAnybody = true

    local offset = vector3(0.0, -0.9, 0.0)

    local plyPed = PlayerPedId()

    local targetCoords = GetOffsetFromEntityInWorldCoords(targetPed, offset)
    local targetHeading = GetEntityHeading(targetPed)

    TaskGoStraightToCoordRelativeToEntity(plyPed, targetPed, offset, 0.0, 5000)

    local startTime = GetGameTimer()

    while not (#(GetEntityCoords(plyPed) - GetOffsetFromEntityInWorldCoords(targetPed, offset)) < 0.5) do
        Citizen.Wait(200)

        if (GetGameTimer() - startTime > 5000) then
            ClearPedTasks(plyPed)
            isTryingToArrestAnybody = false
            return
        end
    end

    ClearPedTasks(plyPed)

    SetPedDesiredHeading(plyPed, targetHeading)

    local startTime = GetGameTimer()

    while not (math.abs(GetEntityHeading(plyPed) - targetHeading) < 1.0) do
        Citizen.Wait(200)

        if (GetGameTimer() - startTime > 5000) then
            ClearPedTasks(plyPed)
            isTryingToArrestAnybody = false
            return
        end
    end

    ClearPedTasks(plyPed)

    --[[local animDict = "mp_arresting"

    RequestAnimDict(animDict)

    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end

    local animName = "a_uncuff"]]
    RequestAnimDict("mp_arrest_paired")

    while not HasAnimDictLoaded("mp_arrest_paired") do
        Wait(0)
    end

    SetCurrentPedWeapon(plyPed, "WEAPON_UNARMED", true)

    --TaskPlayAnim(plyPed, animDict, animName, 4.0, -4.0, -1, 0, 0.0, 0, 0, 0)

    TaskPlayAnim(plyPed, "mp_arrest_paired", "cop_p2_back_left", 8.0, -8.0, 5500, 33, 0, false, false, false)

    exports["gs_eventprotect"]:GS_TriggerServerEvent('esx_job_creator:handcuffTarget', targetId)
    --TriggerServerEvent('esx_job_creator:handcuffTarget', targetId)

    Wait(3000)

    isTryingToArrestAnybody = false
end

RegisterNetEvent('esx_job_creator:arrestConfirmed')
AddEventHandler('esx_job_creator:arrestConfirmed', function(targetId)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetId))

    if (targetPed > 0) then
        if (IsEntityAttached(targetPed)) then
            notifyClient(getLocalizedText('cant_while_dragging'))
        else
            arrestAnimation(targetId, targetPed)
        end
    end
end)

local function handcuffPlayer(targetId)
    exports["gs_eventprotect"]:GS_TriggerServerEvent('esx_job_creator:handcuffPlayer', targetId)
    --TriggerServerEvent('esx_job_creator:handcuffPlayer', targetId)
end

RegisterNetEvent('esx_job_creator:handcuffPlayer')
AddEventHandler('esx_job_creator:handcuffPlayer', function(src)
    isHandcuffed = not isHandcuffed

    if (isDragged) then
        DetachEntity(PlayerPedId(), true, true)
    end

    if (isHandcuffed) then
        arrested(src)
    end
end)

local function dragged(playerId)
    local plyPed = GetPlayerPed(GetPlayerFromServerId(playerId))

    if (plyPed > 0) then
        local targetPed = PlayerPedId()

        if #(GetEntityCoords(targetPed) - GetEntityCoords(plyPed)) > 50 then
            isDragged = false
            return
        end

        AttachEntityToEntity(targetPed, plyPed, 11816, 0.35, 0.34, 0.0, 0.0, 0.0, 0.0, false, false, false, true, 2, true)
    end
end

RegisterNetEvent('esx_job_creator:dragTarget')
AddEventHandler('esx_job_creator:dragTarget', function(playerId)
    if (isHandcuffed) then
        isDragged = not isDragged

        if (isDragged) then
            dragged(playerId)
            CreateThread(function()
                while isDragged do
                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                        isDragged = false
                        return
                    end
                    if not IsEntityAttachedToAnyPed(PlayerPedId()) and isDragged then
                        dragged(playerId)
                    end
                    Wait(5000)
                end
            end)
        else
            DetachEntity(PlayerPedId(), true, true)
        end
    end
end)

RegisterNetEvent('esx_job_creator:putincar')
AddEventHandler('esx_job_creator:putincar', function(vehNetId)
    local plyPed = PlayerPedId()

    if (isDragged) then
        DetachEntity(plyPed, true, true)
    end

    if (isHandcuffed) then
        local vehicle = NetToVeh(vehNetId)

        if DoesEntityExist(vehicle) then
            local seats = GetVehicleMaxNumberOfPassengers(vehicle)

            local finalSeat = nil

            for currentSeat = seats - 1, 0, -1 do
                if IsVehicleSeatFree(vehicle, currentSeat) then
                    finalSeat = currentSeat
                    break
                end
            end

            if finalSeat then
                TaskEnterVehicle(plyPed, vehicle, -1, finalSeat, 1.0, 1, 0)
            end
        end
    end
end)

RegisterNetEvent('esx_job_creator:takefromcar')
AddEventHandler('esx_job_creator:takefromcar', function()
    local plyPed = PlayerPedId()

    if (isDragged) then
        DetachEntity(plyPed, true, true)
    end

    if (isHandcuffed) then
        TriggerEvent("bc:beltoff")
        Wait(1000)
        TaskLeaveAnyVehicle(plyPed, 0, 256)
    end
end)


RegisterNetEvent('esx_job_creator:putintrunk')
AddEventHandler('esx_job_creator:putintrunk', function(vehNetId)
    local plyPed = PlayerPedId()

    if (isDragged) then
        DetachEntity(plyPed, true, true)
    end

    if (isHandcuffed) then
        local vehicle = NetToVeh(vehNetId)

        if DoesEntityExist(vehicle) then
            TriggerEvent('bc_trunk:hide', { entity = vehicle, forced = true })
        end
    end
end)

RegisterNetEvent('esx_job_creator:takefromtrunk')
AddEventHandler('esx_job_creator:takefromtrunk', function()
    local plyPed = PlayerPedId()
    if (isDragged) then
        DetachEntity(plyPed, true, true)
    end
    TriggerEvent("bc_trunk:out")
end)

local function handcuff()
    local targetId = GetPlayerServerId(getClosestPlayerId())

    if (targetId > 0 and not isTryingToArrestAnybody) then
        handcuffPlayer(targetId)
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:handcuff', handcuff)

local function drag()
    local targetId = GetPlayerServerId(getClosestPlayerId())

    if (targetId > 0) then
        exports["gs_eventprotect"]:GS_TriggerServerEvent('esx_job_creator:dragTarget', targetId)
       -- TriggerServerEvent('esx_job_creator:dragTarget', targetId)
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:drag', drag)

local function putInCar()
    local targetId = GetPlayerServerId(getClosestPlayerId())
    local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle()

    if (targetId > 0 and closestVehicle > 0) then
        if (closestDistance < 10.0) then
            TriggerServerEvent('esx_job_creator:putincar', targetId, VehToNet(closestVehicle))
        else
            notifyClient(getLocalizedText('no_vehicles_nearby'))
        end
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:putInCar', putInCar)

local function takeFromCar()
    local targetId = GetPlayerServerId(getClosestPlayerId(10.0))

    if (targetId > 0) then
        TriggerServerEvent('esx_job_creator:takefromcar', targetId)
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:takeFromCar', takeFromCar)


local function putInTrunk()
    local targetId = GetPlayerServerId(getClosestPlayerId())
    local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle()

    if (targetId > 0 and closestVehicle > 0) then
        if (closestDistance < 10.0) then
            TriggerServerEvent('esx_job_creator:putintrunk', targetId, VehToNet(closestVehicle))
        else
            notifyClient(getLocalizedText('no_vehicles_nearby'))
        end
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:putInTrunk', putInTrunk)

local function takeFromTrunk()
    local targetId = GetPlayerServerId(getClosestPlayerId(10.0))

    if (targetId > 0) then
        TriggerServerEvent('esx_job_creator:takefromtrunk', targetId)
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:takeFromTrunk', takeFromTrunk)
