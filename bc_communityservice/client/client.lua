local actionsRemaring = 0
isInAnim = false

local serviceThread = false 
local deactiveServices = {}

CreateThread(function()
    AddTextEntry('bc_communityservice', Translate("clean"))
end)

CreateThread(function()
    while true do 
        if actionsRemaring ~= 0 and actionsRemaring ~= false and actionsRemaring ~= nil then 
            Wait(1000)
            TriggerEvent('esx_status:set', 'hunger', 500000)
	        TriggerEvent('esx_status:set', 'thirst', 500000)
        else 
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            if #(coords - Config.ServiceLocation.coords) < Config.ServiceLocation.radius then 
                local timewaited = 0
                Notify("Ez közmunka terület, ha nem mész ki 2 perc múlva, te is közmunkát fogsz kapni")
                while #(coords - Config.ServiceLocation.coords) < Config.ServiceLocation.radius  do  
                    if actionsRemaring ~= 0 and actionsRemaring ~= false and actionsRemaring ~= nil then 
                        break 
                    end 
                    
                    Notify("Ez közmunka terület, ha nem mész ki 2 perc múlva, te is közmunkát fogsz kapni")
                    if timewaited > 120 then 
                        TriggerServerEvent("bc_communityservice:timeonfield")
                        break 
                    end 
                    Wait(3000)
                    timewaited = timewaited + 3
                    ped = PlayerPedId()
                    coords = GetEntityCoords(ped)
                end 
            end 
        end 
        Wait(500)
    end 
end)

RegisterNetEvent('bc_communityservice:sendToService', function(data)
    if not data then 
        actionsRemaring = 0 
        if serviceThread then 
            return 
        end 
        SetEntityCoords(PlayerPedId(), Config.ReleaseLocation, true, false, false, false)
        TriggerServerEvent("bc_communityservice:onRealse")
    end 

    SendNUIMessage({
        type = "show",
        enable = true,
        actions = data.remaining,
        allactions = data.allactions,
        alltime = data.alltime,
        reason = data.reason,
        admin = data.admin,
        time = data.time
    })

    if type(data.remaining) ~= "number" then 
        TriggerServerEvent("bc_communityservice:onRealse")
        return 
    end 
    actionsRemaring = data.remaining
    

    OnActionChange(data)

    exports["pma-voice"]:removePlayerFromRadio()

    if serviceThread then return end 

    SetEntityCoords(PlayerPedId(), Config.ServiceLocation.coords, true, false, false, false)

    CreateThread(function()
        while actionsRemaring > 0 do 
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisablePlayerFiring(PlayerId(), true)
            Wait(0)
        end 
        DisableControlAction(0, 24, false)
        DisableControlAction(0, 257, false)
        DisableControlAction(0, 140, false)
        DisableControlAction(0, 141, false)
        DisableControlAction(0, 142, false)
        DisableControlAction(0, 263, false)
        DisableControlAction(0, 264, false)

        EnableControlAction(0, 24, true)
        EnableControlAction(0, 257, true)
        EnableControlAction(0, 140, true)
        EnableControlAction(0, 141, true)
        EnableControlAction(0, 142, true)
        EnableControlAction(0, 263, true)
        EnableControlAction(0, 264, true)
        DisablePlayerFiring(PlayerId(), false)
    end)

    CreateThread(function()
        serviceThread = true 
        --LocalPlayer.state.muted = true
        while actionsRemaring > 0 do 
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

            SetLocalPlayerAsGhost(true)

            DrawMarker(1, Config.ServiceLocation.coords, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, Config.ServiceLocation.radius,Config.ServiceLocation.radius,4.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)

            if #(coords - Config.ServiceLocation.coords) > Config.ServiceLocation.radius then 
                SetEntityCoords(PlayerPedId(), Config.ServiceLocation.coords, true, false, false, false)
                Notify(Translate("try_escape"))
                if Config.ServiceExtensionOnEscape then 
                    ESX.TriggerServerCallback("bc_communityservice:tryToEscape", function(actions) 
                        actionsRemaring = actions
                    end)
                end 
            end 

            for i = 1, #Config.ServiceLocations do
                if not deactiveServices[i] then 
                    local dis = #(coords - Config.ServiceLocations[i])
                    if dis < 20 then 
                        DrawMarker(6, Config.ServiceLocations[i], 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 187, 255, 100, true, true, 2, false, false, false, false)
                        DrawMarker(21, Config.ServiceLocations[i]+vector3(0.0, 0.0, 0.6), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 187, 255, 100, true, true, 2, false, false, false, false)
                        if dis < 1.7 then 
                            DisplayHelpTextThisFrame('bc_communityservice')
                            if IsControlJustReleased(0, 38) then
                                local objhash = `prop_tool_broom`

                                while not HasModelLoaded(objhash) do
                                    RequestModel(objhash)
                                    Wait(10)
                                end
                                local obj = CreateObject(objhash, coords, true, true, true)
                                -- bc_kocsitorles: legalis spawn jelolese
                                if obj and obj ~= 0 and NetworkGetEntityIsNetworked(obj) then Entity(obj).state:set('bc_spawned', true, true) end
                                AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 28422), -0.005, 0.0, 0.0, 360.0, 360.0, 0.0, 1, 1, 0, 1, 0, 1)

                                while not HasAnimDictLoaded("amb@world_human_janitor@male@idle_a") do
                                    RequestAnimDict("amb@world_human_janitor@male@idle_a")
                                    Wait(10)
                                end
                                TaskPlayAnim(ped, "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false)

                                isInAnim = true 
                                DisableAllControlActions(0)
                                EnableControlAction(0, 1, true)
                                EnableControlAction(0, 2, true)
                                FreezeEntityPosition(ped, true)
                                CreateThread(function() 
                                    while isInAnim do 
                                        ped = PlayerPedId()
                                        if not IsEntityPlayingAnim(ped, "amb@world_human_janitor@male@idle_a", "idle_a", 3) then 
                                            ClearPedTasksImmediately(ped)
                                            while not HasAnimDictLoaded("amb@world_human_janitor@male@idle_a") do
                                                RequestAnimDict("amb@world_human_janitor@male@idle_a")
                                                Wait(1)
                                            end
                                            TaskPlayAnim(ped, "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false)
                                        else 
                                            Wait(50)
                                        end 
                                        Wait(1)
                                    end 
                                end)
                                local success = HandleMinigame()
                                if success then 
                                    Wait(Config.AnimTimeAfterMinigame)
                                    ESX.TriggerServerCallback('bc_communityservice:endedAction', function(actions)
                                        actionsRemaring = actions
                                        if actions > 1 then 
                                            SetUniform()
                                        end 
                                        SendNUIMessage({
                                            type = "actions",
                                            actions = actionsRemaring
                                        })
                                    end)
                                    Wait(1300)
                                end 
                                ped = PlayerPedId()
                                isInAnim = false 
                                EnableAllControlActions(0)
                                ClearPedTasksImmediately(ped)
                                FreezeEntityPosition(ped, false)
                                DeleteEntity(obj)
                                deactiveServices[i] = true 

                                SetTimeout(Config.DeactiveServiceTime, function()
                                    deactiveServices[i] = nil 
                                end)
                            end 
                        end 
                    end 
                end 
            end 
            Wait(2)
        end 
        serviceThread = false 
        SendNUIMessage({
            type = "show",
            enable = false
        })
        --LocalPlayer.state.muted = false
        RemoveAnimDict("amb@world_human_janitor@male@idle_a")
        SetModelAsNoLongerNeeded(`prop_tool_broom`)
        SetEntityCoords(PlayerPedId(), Config.ReleaseLocation, true, false, false, false)
        Wait(3000)
        OnActionChange(false)

        TriggerServerEvent("bc_communityservice:onRealse")

        SetLocalPlayerAsGhost(false)
    end)
end)

local isInGame = false
function BCMinigame()
    if isInGame then return false end 
    local ended = false
    local success = false
    isInGame = true
    local startTime = GetGameTimer()
    local timeall = 0
    local target = (math.random(70, 110) / 1000)
    local width = (math.random(35, 55) / 1000)
    local pressed = false
    CreateThread(function()
        while timeall < 4700 do
            Wait(1)

            local time = 250 * (timeall / 4500)
            if time > 250 then
                time = 250
            end

            DrawRect(0.5, 0.6, 0.27 + 0.006, 0.03 + 0.006, 0, 0, 0, 150)
            DrawRect(0.5 + target, 0.6, width, 0.03 + 0.006, 156, 0, 0, 150)

            if ((0.5 + target) - (width / 2)) + 0.01 < 0.5 - 0.125 + (time / 1000) + 0.01 and ((0.5 + target) + (width / 2)) - 0.01 > 0.5 - 0.125 + (time / 1000) - 0.01 then
                DrawRect(0.5 - 0.125 + (time / 1000), 0.6, 0.02, 0.03, 0, 180, 0, 190)
            else
                DrawRect(0.5 - 0.125 + (time / 1000), 0.6, 0.02, 0.03, 0, 100, 0, 190)
            end

            SetTextFont(4)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(1)
            SetTextEntry("STRING")
            AddTextComponentString(Translate("minigame"))
            DrawText(0.5, 0.63)

            if not pressed and IsControlJustReleased(0, 38) then
                pressed = true
                if ((0.5 + target) - (width / 2)) < 0.5 - 0.125 + (time / 1000) + 0.01 and ((0.5 + target) + (width / 2)) > 0.5 - 0.125 + (time / 1000) - 0.01 then
                    success = true
                end
            end
            timeall = GetGameTimer() - startTime
        end
        isInGame = false
        ended = true
    end)

    while not ended do
        Wait(10)
    end

    return success
end

exports("isPlayerOnCommunityservice", function()
    return actionsRemaring > 0
end)

exports("isPlayerInAnim", function()
    return isInAnim
end)