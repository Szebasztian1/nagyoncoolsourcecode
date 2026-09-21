local antispam = 0
-- FIGYELEM: a lib.callback.await 2. parametere NEM timeout, hanem "delay":
-- ennyi ideig tiltja az esemeny ujboli hivasat, es kozben azonnal nil-lel ter vissza.
-- Ezert false-t adunk at (nincs fojtas), a duplazast a vehlockBusy/antispam intezi.
local ACCESS_DELAY = false
-- amig egy nyitas/zaras valaszra varunk, ne induljon masodik keres
local vehlockBusy = false

function HaceAccessToCar(vehicle, action)
    if not NetworkGetEntityIsNetworked(vehicle) then
        BCDbg("[C] HaveAccess: a jarmu NEM networked -> true, szerver nem kerdezve, nem szamol")
        return true
    end
    local state = Entity(vehicle).state
    if state and state.hijacked then
        BCDbg("[C] HaveAccess: state.hijacked=true -> true, szerver nem kerdezve, nem szamol")
        return true
    end
    local netid = NetworkGetNetworkIdFromEntity(vehicle)
    if not netid then
        BCDbg("[C] HaveAccess: nincs netid -> true, szerver nem kerdezve")
        return true
    end
    BCDbg("[C] HaveAccess: szerver kerdezese netid=%s action=%s", netid, action)
    local access = lib.callback.await('carkeys:haveAccess', ACCESS_DELAY, netid, action)
    BCDbg("[C] HaveAccess: szerver valasz=%s", access)
    return access == true
end

exports("HaveAccess", HaceAccessToCar)

function SetVehLockStatus(vehicle, status)
    if not vehicle or not DoesEntityExist(vehicle) then
        BCDbg("[C] SetVehLockStatus: jarmu nem letezik (%s)", vehicle)
        return false, false
    end
    if type(status) ~= "boolean" then
        status = true
        if GetVehicleDoorLockStatus(vehicle) == 2 then
            status = false
        end
    end
    local access = HaceAccessToCar(vehicle, (status and "lock" or "unlock"))
    BCDbg("[C] SetVehLockStatus: veh=%s zarstatusz=%s muvelet=%s access=%s", vehicle, GetVehicleDoorLockStatus(vehicle), (status and "lock" or "unlock"), access)
    if not access then
        return false, false
    end
    GetControl(vehicle)
    if status then
        for i = 0, 5 do
            if GetIsDoorValid(vehicle, i) then
                SetVehicleDoorShut(vehicle, i, true)
            end
        end
    end
    SetVehicleDoorsLocked(vehicle, (status and 2 or 1))

    CreateThread(function()
        local prop = GetHashKey('p_car_keys_01')
        local animDict = 'anim@mp_player_intmenu@key_fob@'
        local animLib = 'fob_click'
        lib.requestModel(prop)
        lib.requestAnimDict(animDict)
        local keyFob = CreateObject(prop, 1.0, 1.0, 1.0, 1, 1, 0)
        -- bc_kocsitorles: legalis spawn jelolese
        if keyFob and keyFob ~= 0 and NetworkGetEntityIsNetworked(keyFob) then Entity(keyFob).state:set('bc_spawned', true, true) end
        AttachEntityToEntity(keyFob, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.09, 0.04, 0.0, 0.0, 0.0, 0.0, true,
            true, false, true, 1, true)
        TaskPlayAnim(cache.ped, animDict, animLib, 15.0, -10.0, 1500, 49, 0, false, false, false)
        PlaySoundFromEntity(-1, "Remote_Control_Fob", ped, "PI_Menu_Sounds", 1, 0)
        Wait(1500)
        DeleteEntity(keyFob)
    end)
    CreateThread(function()
        for i = 0, 5 do
            if GetIsDoorValid(vehicle, i) then
                if status then
                    PlayVehicleDoorCloseSound(vehicle, i)
                else
                    PlayVehicleDoorOpenSound(vehicle, i)
                end
            end
        end
        if status then
            PlaySoundFromEntity(-1, "Remote_Control_Close", vehicle, "PI_Menu_Sounds", 1, 0)
        else
            PlaySoundFromEntity(-1, "Remote_Control_Open", vehicle, "PI_Menu_Sounds", 1, 0)
        end
        SetVehicleLights(vehicle, 2)
        Wait(200)
        SetVehicleLights(vehicle, 0)
        Wait(200)
        SetVehicleLights(vehicle, 2)
        Wait(400)
        SetVehicleLights(vehicle, 0)
    end)
    return true, status
end

exports("SetVehLockStatus", SetVehLockStatus)

function SetVehEngine(vehicle, status)
    if not vehicle or not DoesEntityExist(vehicle) then
        return false, false
    end 
    if type(status) ~= "boolean" then
        status = not GetIsVehicleEngineRunning(vehicle)
    end
    local access = HaceAccessToCar(vehicle)
    if not access then
        return false, false
    end
    GetControl(vehicle)
    SetVehicleEngineOn(vehicle, status, false, true)
    SetVehicleKeepEngineOnWhenAbandoned(vehicle, status)
    return true, status
end


Citizen.CreateThread(function()
    while true do
        local sleep = 250
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		local engineStatus
		
		if IsPedGettingIntoAVehicle(ped) then
			engineStatus = (GetIsVehicleEngineRunning(vehicle)) -- will either be true or false.
			if not (engineStatus) then 
				SetVehicleEngineOn(vehicle, false, true, true) -- ensures engine is off.
				DisableControlAction(2, 71, true) -- ensures that the player doesn't auto-start the car when entering.
			end
            
		end
		
		if DoesEntityExist(vehicle) and (not GetIsVehicleEngineRunning(vehicle)) then
			DisableControlAction(2, 71, true) -- general script to disable player auto-starting the car when already in car.
            sleep = 0
        end

        Citizen.Wait(sleep)
    end 
end)

exports("SetVehEngine", SetVehEngine)

function GetControl(ent)
    if not DoesEntityExist(ent) then return false end 
    NetworkRequestControlOfEntity(ent)
    local tout = 3000
    while tout > 0 do 
        Wait(100)
        tout = tout - 100
        if NetworkHasControlOfEntity(ent) then 
            tout = 0 
        end 
    end 
    return NetworkHasControlOfEntity(ent)
end 

RegisterCommand("vehlock", function(s, a, r)
    BCDbg("[C] vehlock: G lenyomva")
    if vehlockBusy or antispam + 2000 > GetGameTimer() then
        BCDbg("[C] vehlock: eldobva (busy=%s, antispam meg %s ms)", vehlockBusy, antispam + 2000 - GetGameTimer())
        return
    end
    antispam = GetGameTimer()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then
        local playerCoords = GetEntityCoords(ped)
        local inDirection = GetOffsetFromEntityInWorldCoords(ped, 0.0, 7.0, 0.0)
        local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(playerCoords, inDirection, 10, ped, 0)
        local _, hit, _, _, entityHit = GetShapeTestResult(rayHandle)
        BCDbg("[C] vehlock: raycast hit=%s entity=%s tipus=%s", hit, entityHit, entityHit and entityHit ~= 0 and GetEntityType(entityHit))
        if (hit == true or hit == 1) and entityHit and entityHit ~= 0 and GetEntityType(entityHit) == 2 then
            veh = entityHit
        else
            veh = 0
        end
    end
    if veh == 0 or not DoesEntityExist(veh) then
        local playerCoords = GetEntityCoords(ped) 
        veh = GetClosestVehicle(playerCoords, 10.0, 0, 71)
        BCDbg("[C] vehlock: raycast nem talalt, GetClosestVehicle=%s", veh)
    end
    if not DoesEntityExist(veh) then
        BCDbg("[C] vehlock: nincs jarmu a kozelben")
        return TriggerEvent("esx:showNotification", "Nincs a közeledben jármű! (Próbáld meg 3. szemmel)")
    end 
    BCDbg("[C] vehlock: talalt jarmu=%s letezik=%s networked=%s rendszam='%s' zarstatusz=%s", veh, DoesEntityExist(veh), NetworkGetEntityIsNetworked(veh), GetVehicleNumberPlateText(veh), GetVehicleDoorLockStatus(veh))
    vehlockBusy = true
    local ok, success, state = pcall(SetVehLockStatus, veh)
    vehlockBusy = false
    antispam = GetGameTimer()
    if not ok then
        print(("[bc_keysystem] vehlock hiba: %s"):format(success))
        return
    end
    BCDbg("[C] vehlock: eredmeny success=%s state=%s", success, state)
    if success then 
        TriggerEvent("esx:showNotification", "A jármű " .. (state == true and "bezárva" or "kinyitva"))
    end
end, false)
RegisterKeyMapping('vehlock', 'Autó zárása/nyitása', 'keyboard', 'g')
CreateThread(function()
    exports.ox_inventory:displayMetadata({
        plate = 'Rendszám',
        keyid = 'Kulcs id-je'
    })
    exports.ox_target:addGlobalVehicle({{
        label = "Autó nyitása/zárása",
        name = "car_openlock",
        icon = "fa-solid fa-key",
        distance = 5,
        onSelect = function(data)
            local success, state = SetVehLockStatus(data.entity)
            if success then
                TriggerEvent("esx:showNotification", "A jármű " .. (state == true and "bezárva" or "kinyitva"))
            end
        end
    }})
end)

AddEventHandler("vehengine", function()
    if antispam + 2000 > GetGameTimer() then
        return
    end
    antispam = GetGameTimer()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        return
    end
    local success, state = SetVehEngine(veh)
    if success then
        TriggerEvent("esx:showNotification", "A motorja " .. (state == true and "elindítva" or "leállítva"))
    end
end)

--[[RegisterCommand("vehengine", function(s, a, r)
    if antispam + 2000 > GetGameTimer() then
        return
    end
    antispam = GetGameTimer()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        return
    end
    local success, state = SetVehEngine(veh)
    if success then
        TriggerEvent("esx:showNotification", "A motorja " .. (state == true and "elindítva" or "leállítva"))
    end
end, false)
RegisterKeyMapping('vehengine', 'Motor indítása/leállítása', 'keyboard', 'u')
]]
AddEventHandler("esx:enteringVehicle", function(vehicle, plate, seat, netId)
    if GetEntityPopulationType(vehicle) > 5 then
        return
    end
    local state = Entity(vehicle).state
    if state and state.isnpc then
        return
    end
    TriggerServerEvent("carkeys:addNpcVehicle", netId)
    --ClearPedTasksImmediately(PlayerPedId())
end)

RegisterNetEvent("carkeys:setlock", function(netid, state)
    if not NetworkDoesNetworkIdExist(netid) then return end 
    local entity = NetworkGetEntityFromNetworkId(netid)
    if DoesEntityExist(entity) then 
        SetVehicleDoorsLocked(entity, state)
    end 
end)