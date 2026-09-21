--[[local robobj = {
    id = 0,
    level = 'mid',
    shellcoords = vector3(0.0, 0.0, 0.0),
    crates = {[1]=true, [2]=false},
    alarm = false,
}]]
local robobj
local inGarage
local silent = 0
local gases = {}
local blip = 0
local needwait = false
lockpicking = false

local loaded = false
AddEventHandler('playerSpawned', function()
    loaded = true
end)

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(500)
    end
    loaded = true
end)

SetMillisecondsPerGameMinute(60000)
RegisterNetEvent("realtime:event", function(h, m, s)
    NetworkOverrideClockTime(h, m, s)
end)

Citizen.CreateThread(function()
    while not loaded do
        Wait(10)
    end

    Wait(2000)
    for k, v in pairs(Config.Garages) do
        local blip = AddBlipForCoord(v.coords)
        SetBlipSprite(blip, 357)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garázs rablás")
        EndTextCommandSetBlipName(blip)
    end

    AddTextEntry('garagerob_entergarage', '~INPUT_PICKUP~ hogy bemenj a garázsba')
    AddTextEntry('garagerob_lockpickgarage', '~INPUT_PICKUP~ hogy feltörd a garázst')
    AddTextEntry('garagerob_alredyrob', 'Már éppen másik garázsrablás van folyamatban')

    AddTextEntry('garagerob_exitgarage', '~INPUT_PICKUP~ hogy kimenj')
    AddTextEntry('garagerob_grabcrate', '~INPUT_PICKUP~ a láda kipakolásához')

    AddTextEntry('lockpicking_help',
        '~INPUT_MOVE_DOWN_ONLY~ a befejezéshez ~INPUT_MOVE_UP_ONLY~ a zár töréséhez ~INPUT_MOVE_LEFT_ONLY~/~INPUT_MOVE_RIGHT_ONLY~ a jobbra/balra forgatáshoz')

    ESX.TriggerServerCallback("bc_garagerob:getClientRobObj", function(obj)
        if type(obj) == "table" and obj ~= {} then
            if type(obj) == "table" and obj ~= {} and not robobj or robobj == {} then
                robobj = obj
                local robcoords = Config.Garages[robobj.id].coords
                blip = AddBlipForCoord(robcoords.x, robcoords.y, robcoords.z)
                SetBlipSprite(blip, 161)
                SetBlipScale(blip, 1.4)
                SetBlipColour(blip, 3)
                PulseBlip(blip)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Garázs rablás folyamatban")
                EndTextCommandSetBlipName(blip)
            end

            robobj = obj
        end
    end)

    RequestAnimDict('anim@amb@business@cfid@cfid_desk_no_work_bgen_chair_no_work@')
    while not HasAnimDictLoaded('anim@amb@business@cfid@cfid_desk_no_work_bgen_chair_no_work@') do
        Wait(10)
    end

    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local sleep = 500
        for k, v in pairs(Config.Garages) do
            local dis = #(coords - v.coords)
            if dis < 14 then
                DrawMarker(6, v.coords, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 117, 23, 23, false, true, 2,
                    false, false, false, false)
                DrawMarker(21, v.coords + vector3(0.0, 0.0, 0.4), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, 0, 117, 23,
                    23, true, false, 2, true, false, false, false)
                DrawText3D(v.coords.x, v.coords.y, v.coords.z + 0.35, v.label)
                sleep = 2
                if dis < 1.2 and not lockpicking and not needwait then
                    if robobj and robobj.id == k then
                        DisplayHelpTextThisFrame('garagerob_entergarage')
                        if IsControlJustReleased(0, 38) then
                            EnterGarage()
                        end
                    elseif robobj then
                        DisplayHelpTextThisFrame('garagerob_alredyrob')
                    else
                        DisplayHelpTextThisFrame('garagerob_lockpickgarage')
                        if IsControlJustReleased(0, 38) then
                            TryStartRob(k)
                            sleep = 2000
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent("bc_garagerob:setClientObj")
AddEventHandler("bc_garagerob:setClientObj", function(obj)
    if robobj and not robobj.alarm and obj and obj.alarm then
        robobj = obj
        StartGas()
    end
    if type(obj) == "table" and obj ~= {} and not robobj or robobj == {} then
        robobj = obj
        local robcoords = Config.Garages[robobj.id].coords
        blip = AddBlipForCoord(robcoords.x, robcoords.y, robcoords.z)
        SetBlipSprite(blip, 161)
        SetBlipScale(blip, 1.4)
        SetBlipColour(blip, 3)
        PulseBlip(blip)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garázs rablás")
        EndTextCommandSetBlipName(blip)
    elseif type(robobj) == "table" and robobj ~= {} and not obj or obj == {} then
        RemoveBlip(blip)
    end

    robobj = obj
end)

RegisterNetEvent("bc_garagerob:notifyBeforeClose")
AddEventHandler("bc_garagerob:notifyBeforeClose", function()
    if inGarage then
        Config.Notify("Fegyelem a garázs " .. Config.TimeNotify .. "mp múlva bezár!")
    end
end)

RegisterNetEvent("bc_garagerob:close")
AddEventHandler("bc_garagerob:close", function()
    if inGarage then
        ExitGarage()
        Config.Notify("A garázs bezárt!")
    end
end)

function TryStartRob(id)
    ESX.TriggerServerCallback("bc_garagerob:tryStart", function(time, police, lockpick)
        if time == 0 then
            if police then
                if (not Config.NeedLockPick) or lockpick > 0 then
                    StartLockPick(id)
                else
                    Config.Notify(_U('nolockpick'))
                end
            else
                Config.Notify(_U('notenoughpolice'))
            end
        else
            Config.Notify(_U('wait', time))
        end
    end)
end

function StartLockPick(id)
    local garagelevel = Config.Garages[id].level
    local success = LockPick(Config.Levels[garagelevel].locks)
    if success then
        TriggerServerEvent("bc_garagerob:startRob", id)
        needwait = true
        Wait(3000)
        needwait = false
    end
end

function StartGas()
    Citizen.CreateThread(function()
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(10)
        end
        while robobj and inGarage == robobj.id and robobj.alarm do
            if Config.Levels[robobj.level].gas.damage ~= 0 then
                ApplyDamageToPed(PlayerPedId(), Config.Levels[robobj.level].gas.damage, false)
            end

            for _, v in pairs(Config.Levels[robobj.level].gas.points) do
                SetPtfxAssetNextCall("core")
                local gas = StartParticleFxNonLoopedAtCoord("veh_respray_smoke", robobj.shellcoords + v.offset, 0.0, 0.0,
                    0.0, v.scale, false, false, false, false)
                gases[#gases + 1] = gas
            end

            Wait(5000)

            for _, gas in pairs(gases) do
                StopParticleFxLooped(gas, 0)
            end
            gases = {}
        end
    end)
end

function EnterGarage()
    if robobj and robobj.id then
        inGarage = robobj.id
        SetEntityCoordsNoOffset(PlayerPedId(), robobj.insidespawn, true, true, false)
        if GetResourceState("rota_loading") == "started" then 
            exports["rota_loading"]:LoadingShow(700, "Betöltés a garázsba...")
        end 
        Wait(3000)

        if GetResourceState("rota_loading") == "started" then 
            exports["rota_loading"]:LoadingHide(500)
        end 
        if robobj.alarm then
            StartGas()
        end
        TriggerServerEvent("bc_garagerob:enterGarage", robobj.id)
        Citizen.CreateThread(function()
            while inGarage do
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local sleep = 500
                local dis = #(coords - robobj.insidespawn)
                if dis < 20 then
                    DrawMarker(6, robobj.insidespawn, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 117, 23, 23,
                        false, true, 2, false, false, false, false)
                    DrawMarker(21, robobj.insidespawn + vector3(0.0, 0.0, 0.4), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6,
                        0.6, 0, 117, 23, 23, true, false, 2, true, false, false, false)
                    sleep = 2
                    if dis < 1.2 and not lockpicking then
                        DisplayHelpTextThisFrame('garagerob_exitgarage')
                        if IsControlJustReleased(0, 38) then
                            ExitGarage()
                        end
                    end
                end



                for k, v in pairs(robobj.crates) do
                    if v then
                        local cratecoord = robobj.shellcoords + Config.Levels[robobj.level].crates[k].offset
                        local dis = #(coords - cratecoord)
                        if dis < Config.Levels[robobj.level].crates[k].range then
                            DisplayHelpTextThisFrame('garagerob_grabcrate')
                            if IsControlJustReleased(0, 38) then
                                local cratemodel = Config.Levels[robobj.level].crates[k].model
                                local crateobj = GetClosestObjectOfType(cratecoord, 1.2, cratemodel, false)
                                TaskTurnPedToFaceEntity(ped, crateobj, 1000)
                                Wait(1000)
                                local success = LockPick(Config.Levels[robobj.level].crates[k].locks)
                                if success then
                                    RequestAnimDict('rcmepsilonism8')
                                    while not HasAnimDictLoaded('rcmepsilonism8') do
                                        Wait(10)
                                    end
                                    TaskPlayAnim(ped, 'rcmepsilonism8', 'bag_handler_grab_walk_right', 8.0, 8.0, -1, 16,
                                        0, false, false, false)
                                    Wait(4000)
                                    ClearPedTasksImmediately(ped)
                                    TriggerServerEvent("bc_garagerob:lootCrate", k)
                                    RemoveAnimDict('rcmepsilonism8')
                                end
                            end
                        end
                    end
                end

                if dis > 250 then
                    inGarage = nil
                end
                Wait(sleep)
            end
        end)

        Citizen.CreateThread(function()
            Wait(2000)
            silent = 0
            while inGarage and not robobj.alarm do
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                if IsPedShooting(ped) then
                    silent = silent + 90
                end
                if GetEntitySpeed(ped) > 1.7 then
                    silent = silent + 28
                elseif GetEntitySpeed(ped) > 2.5 then
                    silent = silent + 36
                elseif GetEntitySpeed(ped) > 3.0 then
                    silent = silent + 46
                else
                    silent = silent - 2
                    if silent < 0 then
                        silent = 0
                    end
                end
                if IsPedInMeleeCombat(ped) then
                    silent = silent + 70
                end
                for k, v in pairs(Config.Levels[robobj.level].peds) do
                    local pedcoords = robobj.shellcoords + v.offset
                    local dis = #(coords - pedcoords)
                    if dis < 1.5 then
                        silent = silent + 80
                    end
                end
                Wait(1000)
                if silent > 100 then
                    TriggerServerEvent("bc_garagerob:triggerAlarm")
                    Config.Notify("Felkeltetted az őröket!")
                end
            end
        end)

        Citizen.CreateThread(function()
            while inGarage and not robobj.alarm do
                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextCentre(1)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentString("Hang szint: ~r~" .. silent .. "%")
                EndTextCommandDisplayText(0.5, 0.9)
                Wait(1)
            end
        end)
    end
end

function ExitGarage()
    if inGarage then
        local outsidecoords = Config.Garages[inGarage].coords
        SetEntityCoordsNoOffset(PlayerPedId(), outsidecoords, true, true, false)
        if GetResourceState("rota_loading") == "started" then 
            exports["rota_loading"]:LoadingShow(700, "Kilépés...")
        end 
        inGarage = nil
        TriggerServerEvent("bc_garagerob:leaveGarage")
        Wait(2000)
        if GetResourceState("rota_loading") == "started" then 
            exports["rota_loading"]:LoadingHide(500)
        end
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0, 0.4 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
        local factor = (string.len(text)) / 500
        DrawRect(_x, _y + 0.0125, (0.016 + factor) * scale, 0.027 * scale, 0, 0, 0, 80)
    end
end

--[[
function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end
]]
