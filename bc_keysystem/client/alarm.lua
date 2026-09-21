RegisterNetEvent("carkeys:basicAlarm", function(plate, coords)
    TriggerEvent("esx:showNotification", plate.." rendszámű jármű riasztója megszólalt!")
    local blip = AddBlipForCoord(coords)
    SetBlipSprite (blip, 664)
    SetBlipScale  (blip, 1.0)
    SetBlipColour (blip, 1)
    SetBlipAsShortRange(blip, true)
    SetBlipFlashesAlternate(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Autó lopás")
    EndTextCommandSetBlipName(blip)
    Wait(30000)
    RemoveBlip(blip)
end)

RegisterNetEvent("carkeys:gpsAlarm", function(netid, plate)
    TriggerEvent("esx:showNotification", plate.." rendszámű jármű riasztója megszólalt!")
    Wait(2000)
    --print(json.encode(GlobalState))
    if not NetworkDoesNetworkIdExist(netid) then return end 
    local entity = NetworkGetEntityFromNetworkId(netid)
    if not GlobalState["vehiclealarms"..netid] then 
        print("nincs globalstate")
        return 
    end 
    local closeblip
    local blip 
    if DoesEntityExist(entity) and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) < 500 then 
        closeblip = true 
        blip = AddBlipForEntity(entity)
        SetBlipOptions(blip)
    else 
        closeblip = false  
        blip = AddBlipForCoord(GlobalState["vehiclealarms"..netid])
        SetBlipOptions(blip)
    end 
    CreateThread(function()
        while GlobalState["vehiclealarms"..netid] do 
            local entity = NetworkGetEntityFromNetworkId(netid)
            if DoesEntityExist(entity) and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) < 500  then 
                if not closeblip then 
                    RemoveBlip(blip)
                    closeblip = true 
                    blip = AddBlipForEntity(entity)
                    SetBlipOptions(blip)
                end 
            elseif closeblip then 
                RemoveBlip(blip)
                closeblip = false  
                blip = AddBlipForCoord(GlobalState["vehiclealarms"..netid])
                SetBlipOptions(blip)
            else 
                SetBlipCoords(blip, GlobalState["vehiclealarms"..netid])
            end 
            Wait(15000)
        end 
        RemoveBlip(blip)
    end)
end)

function SetBlipOptions(blip)
    SetBlipSprite (blip, 664)
    SetBlipScale  (blip, 1.0)
    SetBlipColour (blip, 1)
    SetBlipAsShortRange(blip, true)
    SetBlipFlashesAlternate(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("Lopott autó")
    EndTextCommandSetBlipName(blip)
end 

RegisterNetEvent("carkeys:removeAlarm", function()
    if not DoesEntityExist(GetVehiclePedIsIn(PlayerPedId(), false)) then 
        return
    end 
    local success = lib.skillCheck({ 'easy', 'easy', 'medium' }, { 'w', 'a', 's', 'd' })
    if not success then 
        TriggerServerEvent("carkeys:alarmRemoved", false)
    end 
    local progbar = lib.progressBar({
        duration = Config.RemoveTime,
        label = 'Nyomkövető eltávolítása',
        useWhileDead = false,
        canCancel = true
    })
    TriggerServerEvent("carkeys:alarmRemoved", progbar)
end)
-- A riaszto megszolaltatasa. A szamlalas szerveroldalon fut (server/alarm.lua).
local ringingAlarms = {}

local function GetAlarmKey(vehicle)
    if NetworkGetEntityIsNetworked(vehicle) then
        local netid = NetworkGetNetworkIdFromEntity(vehicle)
        if netid and netid ~= 0 then
            return "net:" .. netid
        end
    end
    return "ent:" .. vehicle
end

function StartFailedUnlockAlarm(vehicle)
    local cfg = Config.FailedUnlockAlarm
    if not vehicle or not DoesEntityExist(vehicle) then
        return false
    end
    local key = GetAlarmKey(vehicle)
    if ringingAlarms[key] and ringingAlarms[key] > GetGameTimer() then
        BCDbg("[C] StartFailedUnlockAlarm: kliens cooldown, meg %s ms (%s)", ringingAlarms[key] - GetGameTimer(), key)
        return false
    end
    ringingAlarms[key] = GetGameTimer() + (cfg.duration + cfg.cooldown) * 1000
    CreateThread(function()
        local control = GetControl(vehicle)
        BCDbg("[C] StartFailedUnlockAlarm: lejatszas indul (%s), kontroll=%s", key, control)
        if cfg.nativeAlarm and DoesEntityExist(vehicle) then
            SetVehicleAlarm(vehicle, true)
            StartVehicleAlarm(vehicle)
        end
        local endTime = GetGameTimer() + cfg.duration * 1000
        while DoesEntityExist(vehicle) and GetGameTimer() < endTime do
            SetVehicleIndicatorLights(vehicle, 0, true)
            SetVehicleIndicatorLights(vehicle, 1, true)
            SetVehicleLights(vehicle, 2)
            if cfg.horn then
                StartVehicleHorn(vehicle, 350, `HELDDOWN`, false)
            end
            if cfg.nativeAlarm and not IsVehicleAlarmActivated(vehicle) then
                StartVehicleAlarm(vehicle)
            end
            Wait(400)
            if not DoesEntityExist(vehicle) then
                break
            end
            SetVehicleIndicatorLights(vehicle, 0, false)
            SetVehicleIndicatorLights(vehicle, 1, false)
            SetVehicleLights(vehicle, 0)
            Wait(400)
        end
        if DoesEntityExist(vehicle) then
            SetVehicleIndicatorLights(vehicle, 0, false)
            SetVehicleIndicatorLights(vehicle, 1, false)
            SetVehicleLights(vehicle, 0)
            if cfg.nativeAlarm then
                SetVehicleAlarmTimeLeft(vehicle, 0)
                SetVehicleAlarm(vehicle, false)
            end
        end
    end)
    return true
end

exports("StartFailedUnlockAlarm", StartFailedUnlockAlarm)

-- A szerver jelzi, ha valaki tul sokszor probalta kinyitni a jarmuvet.
-- Mindenki megkapja, a tavoli jatekosok eldobjak.
RegisterNetEvent("carkeys:failedUnlockAlarm", function(netid)
    BCDbg("[C] riaszto event beerkezett, netid=%s", netid)
    if not netid or not NetworkDoesNetworkIdExist(netid) then
        BCDbg("[C] riaszto: eldobva, a netid nem letezik ennel a kliensnel")
        return
    end
    local entity = NetworkGetEntityFromNetworkId(netid)
    if not DoesEntityExist(entity) then
        BCDbg("[C] riaszto: eldobva, a jarmu nincs streamelve")
        return
    end
    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) > 150.0 then
        BCDbg("[C] riaszto: eldobva, tul messze")
        return
    end
    BCDbg("[C] riaszto event megjott, netid=%s tavolsag=%s", netid, #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)))
    StartFailedUnlockAlarm(entity)
end)

-- F-nyomas: zart jarmube valo beszallasi kiserlet is probalkozasnak szamit.
-- A ped ilyenkor megrangatja a kilincset, ezt jelzi az IsPedTryingToEnterALockedVehicle.
CreateThread(function()
    local lastReport = 0
    local lastSeen = 0
    while true do
        local sleep = 500
        local cfg = Config.FailedUnlockAlarm
        if cfg and cfg.enabled and cfg.enterAttempts then
            local ped = PlayerPedId()
            if not IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsTryingToEnter(ped)
                if veh ~= 0 and DoesEntityExist(veh) then
                    -- amint elindul a beszallas, surubben nezzuk, hogy elkapjuk a rangatast
                    sleep = 100
                    if GetGameTimer() - lastSeen > 2000 then
                        lastSeen = GetGameTimer()
                        BCDbg("[C] F: beszallas indul veh=%s zart=%s networked=%s", veh, IsPedTryingToEnterALockedVehicle(ped), NetworkGetEntityIsNetworked(veh))
                    end
                    if IsPedTryingToEnterALockedVehicle(ped) and GetGameTimer() - lastReport > 2000 then
                        local state = Entity(veh).state
                        if not NetworkGetEntityIsNetworked(veh) then
                            lastReport = GetGameTimer()
                            BCDbg("[C] F: zart, de a jarmu NEM networked -> nem kuldjuk a szervernek")
                        elseif state and state.hijacked then
                            lastReport = GetGameTimer()
                            BCDbg("[C] F: zart, de state.hijacked=true -> nem szamit")
                        else
                            lastReport = GetGameTimer()
                            BCDbg("[C] F: zart jarmube probal beszallni, netid=%s", NetworkGetNetworkIdFromEntity(veh))
                            TriggerServerEvent("carkeys:tryEnterLocked", NetworkGetNetworkIdFromEntity(veh))
                        end
                    end
                end
            end
        else
            sleep = 2000
        end
        Wait(sleep)
    end
end)

-- Debug: a riaszto lejatszasa a legkozelebbi jarmuvon, szerver nelkul (F8: bcriasztoteszt)
RegisterCommand("bcriasztoteszt", function()
    if not Config.Debug then
        return
    end
    local veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0, 0, 71)
    BCDbg("[C] bcriasztoteszt: legkozelebbi jarmu=%s", veh)
    if veh ~= 0 then
        BCDbg("[C] bcriasztoteszt: eredmeny=%s", StartFailedUnlockAlarm(veh))
    end
end, false)

CreateThread(function()
    BCDbg("[C] client/alarm.lua betoltve, Debug=%s, FailedUnlockAlarm.enabled=%s, enterAttempts=%s", Config.Debug, Config.FailedUnlockAlarm and Config.FailedUnlockAlarm.enabled, Config.FailedUnlockAlarm and Config.FailedUnlockAlarm.enterAttempts)
end)
