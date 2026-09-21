lib.registerRadial({
    id = 'veh_menu',
    items = {
        {
            label = 'Zárás/Nyitás',
            icon = 'key',
            onSelect = function()
                ExecuteCommand('vehlock')
            end
        },
        {
            label = 'Motor indítás/leállítás',
            icon = 'car-battery',
            onSelect = function()
                TriggerEvent('vehengine')
            end
        },
    }
})
lib.registerRadial({
    id = 'info_menu',
    items = {
        {
            label = 'Dokumentumok',
            icon = 'print',
            onSelect = function()
                ExecuteCommand('dokumentumok')
            end
        },
        {
            label = 'Számlák',
            icon = 'money-bill',
            onSelect = function()
                ExecuteCommand('számla')
            end
        },
        {
            id = 'main_skills',
            label = 'Skillek',
            icon = 'dumbbell',
            onSelect = function()
                ExecuteCommand("gym")
            end
        },
    }
})
lib.addRadialItem({
    {
        id = 'main_infos',
        label = 'Információk',
        icon = 'file',
        menu = 'info_menu'
    },
    {
        id = 'main_hud',
        label = 'HUD',
        icon = 'pen-nib',
        onSelect = function()
            ExecuteCommand("hud")
        end
    },
    {
        id = 'documents',
        label = 'Dokumentumok',
        icon = 'file',
        onSelect = function()
            ExecuteCommand("documents")
        end
    },
    {
        id = 'main_kez',
        label = 'Kéz felrakás',
        icon = 'handcuffs',
        onSelect = function()
            ExecuteCommand("handsup")
        end
    },
    {
        id = 'mai_haz',
        label = 'Ház Kulcs',
        icon = 'warehouse',
        onSelect = function()
            ExecuteCommand("kulcs")
        end
    },
    {
        id = 'mai_idkibe',
        label = 'ID KI/BE',
        icon = 'fingerprint',
        onSelect = function()
            ExecuteCommand("idk")
        end
    },
    --[[{
        id = 'mai_teljesruhalevetel',
        label = 'T Vetkőzés',
        icon = 'hand',
        onSelect = function()
            ExecuteCommand("cloth")
            --[[ ExecuteCommand("shoes")
			  ExecuteCommand("pants")
			  ExecuteCommand("mask")
			  ExecuteCommand("neck")
			  ExecuteCommand("glasses")
			  ExecuteCommand("ear")
			  ExecuteCommand("watch")
			  ExecuteCommand("shirt")
			  ExecuteCommand("vest")
        end
    },--]]
    {
        id = 'main_vehcontroll',
        label = 'Jármű',
        icon = 'car',
        menu = 'veh_menu'
    },
})

local textuimouth = false
CreateThread(function()
    while true do
        local stateBag = Player(GetPlayerServerId(PlayerId())).state
        if stateBag and stateBag.mouthtape then
            textuimouth = true
            lib.showTextUI('Szájtapasz van rajtad!')
        elseif textuimouth then
            lib.hideTextUI()
            textuimouth = false
        end
        Wait(1000)
    end
end)


local isRobbing = false
local carry = {
    InProgress = false,
    targetSrc = -1,
    type = "",
    personCarrying = {
        animDict = "missfinale_c2mcs_1",
        anim = "fin_c2_mcs_1_camman",
        flag = 49,
    },
    personCarried = {
        animDict = "nm",
        anim = "firemans_carry",
        attachX = 0.27,
        attachY = 0.15,
        attachZ = 0.63,
        flag = 33,
    }
}
exports("IsCarry", function()
    if carry.InProgress then
        return true
    end
    return false
end)

function canOpenTarget(ped)
    return IsPedFatallyInjured(ped)
        or IsEntityPlayingAnim(ped, 'dead', 'dead_a', 3)
        or IsPedCuffed(ped)
        or IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3)
        or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3)
        or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3)
        or IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)
end

RegisterCommand("helikotel", function(s, a, r)
    local ped = PlayerPedId()
    local heli = GetVehiclePedIsIn(ped, false)
    if not DoesEntityExist(heli) then
        return
    end
    if GetVehicleType(heli) ~= "heli" then
        TriggerEvent("esx:showNotification", "Ez nem helikopter!")
        return
    end
    if GetEntityHeightAboveGround(heli) < 3.0 then
        TriggerEvent("esx:showNotification", "nem vagy elég magasan!")
        return
    end
    if GetPedInVehicleSeat(heli, 1) == ped or GetPedInVehicleSeat(heli, 2) == ped or GetPedInVehicleSeat(heli, 3) == ped or GetPedInVehicleSeat(heli, 4) == ped then
        TaskRappelFromHeli(ped, 1)
    else
        TriggerEvent("esx:showNotification", "nem ülsz a megfelelő helyen!")
    end
end)

RegisterCommand("horgony", function(s, a, r)
    local ped = PlayerPedId()
    local boat = GetVehiclePedIsIn(ped, false)
    if not DoesEntityExist(boat) then
        return
    end
    if GetVehicleType(boat) ~= "boat" then
        TriggerEvent("esx:showNotification", "Ez nem hajó!")
        return
    end
    if GetEntitySpeed(boat) > 0.3 then
        TriggerEvent("esx:showNotification", "Csak álló halyón horgonyozhatsz le!")
        return
    end
    if GetPedInVehicleSeat(boat, -1) == ped then
        if IsEntityPositionFrozen(boat) then
            FreezeEntityPosition(boat, false)
            TriggerEvent("esx:showNotification", "Horgony felhúzva!")
        else
            FreezeEntityPosition(boat, true)
            TriggerEvent("esx:showNotification", "Horgony leengedve!")
        end
    else
        TriggerEvent("esx:showNotification", "Nem te vezeted a hajót!")
    end
end)

local inTrunk = false

exports("inTrunk", function()
    return inTrunk
end)

local shouldleavetrunk = false
AddEventHandler('bc_trunk:out', function()
    shouldleavetrunk = true
end)
AddEventHandler('bc_trunk:hide', function(data)
    --print(json.encode(data))
    local vehicle = data.entity

    if exports['bc_kocsitorles']:isPlayerSafe() then return end
    if exports['bc_garage']:isinzone() then return end

    local forced = (data.forced or false)
    if not DoesEntityExist(vehicle) then
        return
    end
    local trunk = GetEntityBoneIndexByName(vehicle, 'boot')
    if trunk ~= -1 then
        --print("trunkok")
        local coords = GetWorldPositionOfEntityBone(vehicle, trunk)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), coords, true) <= 2.0 then
            --print("trunkcoordsok")
            if not inTrunk then
                --print("notintrunkok")
                local player = ESX.Game.GetClosestPlayer()
                local playerPed = GetPlayerPed(player)
                local playerPed2 = GetPlayerPed(-1)
                local lockStatus = GetVehicleDoorLockStatus(vehicle)
                if lockStatus == 1 then     --unlocked
                    --print("localstatusok")
                    if DoesEntityExist(playerPed) then
                        --print("entityexok")
                        if not IsEntityAttached(playerPed) or GetDistanceBetweenCoords(GetEntityCoords(playerPed), GetEntityCoords(PlayerPedId()), true) >= 5.0 then
                            --print("coords2ok")
                            SetCarBootOpen(vehicle)
                            Wait(350)
                            AttachEntityToEntity(PlayerPedId(), vehicle, -1, 0.0, -2.2, 0.5, 0.0, 0.0, 0.0, false, false,
                                false, false, 20, true)
                            loadDict('timetable@floyd@cryingonbed@base')
                            TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0,
                                false, false, false)
                            Wait(50)
                            inTrunk = true

                            Wait(1500)
                            SetVehicleDoorShut(vehicle, 5)
                            if forced then
                                ESX.ShowNotification('Elbújtál a csomagtartóban a kiszálláshoz nyomd meg az E-t!')
                            else
                                ESX.ShowNotification('Elbújtattak a csomagtartóban!')
                            end
                        else
                            ESX.ShowNotification('Valaki már van a csomagtartóban!')
                        end
                    end
                elseif lockStatus == 2 then
                    ESX.ShowNotification('Ez az autó zárva van')
                end
            end
        else
            ESX.ShowNotification('Túl messze vagy  csomagtartótól!')
        end
    else
        ESX.ShowNotification('Ennek az autónak nincs csomagtartója!')
    end

    if not inTrunk then
        return
    end

    CreateThread(function()
        TriggerServerEvent("bc_trunk:state", true)
        while inTrunk do
            local vehicle = GetEntityAttachedTo(PlayerPedId())
            if DoesEntityExist(vehicle) and not IsPedDeadOrDying(PlayerPedId()) and not IsPedFatallyInjured(PlayerPedId()) and #(GetEntityCoords(vehicle) - GetEntityCoords(PlayerPedId())) < 50 then
                local coords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, 'boot'))
                SetEntityCollision(PlayerPedId(), false, false)
                --DrawText3D(coords, '[E] leave Trunk')

                if GetVehicleDoorAngleRatio(vehicle, 5) < 0.9 then
                    SetEntityVisible(PlayerPedId(), false, false)
                else
                    if not IsEntityPlayingAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 3) then
                        loadDict('timetable@floyd@cryingonbed@base')
                        TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0,
                            false, false, false)

                        SetEntityVisible(PlayerPedId(), true, false)
                    end
                end

                if not forced then
                    if IsControlJustReleased(0, 38) and inTrunk then
                        SetCarBootOpen(vehicle)
                        SetEntityCollision(PlayerPedId(), true, true)
                        Wait(750)
                        inTrunk = false
                        DetachEntity(PlayerPedId(), true, true)
                        SetEntityVisible(PlayerPedId(), true, false)
                        ClearPedTasks(PlayerPedId())
                        SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, 0.75))
                        Wait(250)
                        SetVehicleDoorShut(vehicle, 5)
                    end
                end

                if shouldleavetrunk and inTrunk then
                    shouldleavetrunk = false
                    SetCarBootOpen(vehicle)
                    SetEntityCollision(PlayerPedId(), true, true)
                    Wait(750)
                    inTrunk = false
                    DetachEntity(PlayerPedId(), true, true)
                    SetEntityVisible(PlayerPedId(), true, false)
                    ClearPedTasks(PlayerPedId())
                    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, 0.75))
                    Wait(250)
                    SetVehicleDoorShut(vehicle, 5)
                end
            else
                SetEntityCollision(PlayerPedId(), true, true)
                DetachEntity(PlayerPedId(), true, true)
                SetEntityVisible(PlayerPedId(), true, false)
                ClearPedTasks(PlayerPedId())
                SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, 0.75))
                inTrunk = false
            end
            Wait(2)
        end
        TriggerServerEvent("bc_trunk:state", false)
    end)
end)

local First = vector3(0.0, 0.0, 0.0)
local Second = vector3(5.0, 5.0, 5.0)

AddEventHandler("bc_vehpush:push", function(data)
    local veh = data.entity
    local Vehicle = { Vehicle = nil, Dimension = nil, IsInFront = false }
    Vehicle.Dimensions = GetModelDimensions(GetEntityModel(veh), First, Second)
    Vehicle.Vehicle = veh
    if GetDistanceBetweenCoords(GetEntityCoords(veh) + GetEntityForwardVector(veh), GetEntityCoords(PlayerPedId()), true) > GetDistanceBetweenCoords(GetEntityCoords(veh) + GetEntityForwardVector(veh) * -1, GetEntityCoords(PlayerPedId()), true) then
        Vehicle.IsInFront = false
    else
        Vehicle.IsInFront = true
    end

    local ped = PlayerPedId()

    if not IsVehicleSeatFree(Vehicle.Vehicle, -1) or IsEntityAttachedToEntity(ped, Vehicle.Vehicle) or GetVehicleEngineHealth(Vehicle.Vehicle) > 100 then
        return
    end

    NetworkRequestControlOfEntity(Vehicle.Vehicle)
    local coords = GetEntityCoords(ped)
    if Vehicle.IsInFront then
        AttachEntityToEntity(PlayerPedId(), Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y * -1 + 0.1,
            Vehicle.Dimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
    else
        AttachEntityToEntity(PlayerPedId(), Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y - 0.3,
            Vehicle.Dimensions.z + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
    end

    ESX.Streaming.RequestAnimDict('missfinale_c2ig_11')
    TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
    Citizen.Wait(200)

    local currentVehicle = Vehicle.Vehicle

    TriggerEvent("esx:showNotification", "Az autótolás leaállításához, nyomd meg az X-et")

    while true do
        Citizen.Wait(0)
        DisableControlAction(0, 38, true)

        if IsDisabledControlPressed(0, 34) then
            TaskVehicleTempAction(PlayerPedId(), currentVehicle, 11, 1000)
        end

        if IsDisabledControlPressed(0, 9) then
            TaskVehicleTempAction(PlayerPedId(), currentVehicle, 10, 1000)
        end

        local mult = 1.0
        if GetResourceState("vilmos_gym") == "started" then
            local bst = exports["vilmos_gym"]:getSkill("strenght")
            mult = mult + (bst / 100)
            if mult > 2.0 then
                mult = 2.0
            end
        end

        if Vehicle.IsInFront then
            SetVehicleForwardSpeed(currentVehicle, -1.0 * mult)
        else
            SetVehicleForwardSpeed(currentVehicle, 1.0 * mult)
        end

        if HasEntityCollidedWithAnything(currentVehicle) then
            SetVehicleOnGroundProperly(currentVehicle)
        end

        if IsDisabledControlJustReleased(0, 73) then
            DetachEntity(ped, false, false)
            StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
            FreezeEntityPosition(ped, false)
            break
        end
    end
end)

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        RequestAnimDict(dict)
    end
end

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(10)
    end
    Wait(5000)
    exports.ox_target:addGlobalPlayer({
        {
            name = 'bc_carry',
            event = 'bc_carry:carry',
            icon = 'fa-solid fa-user-ninja',
            label = 'Felemelés',
        },
        {
            name = 'bc_revive',
            event = 'bc_revive:revive',
            icon = 'fa-regular fa-truck-medical',
            label = 'Felélesztés/Ellátás',
            item = "ujmedikit",
            distance = 3.0
        },

        {
            name = 'bc_mute',
            event = 'bc_mute:mute',
            icon = 'fa-regular fa-circle',
            label = 'Szájtapasz felragasztása',
            item = "szajtapasz",
            distance = 3.0,
            canInteract = function(entity, distance, coords, name, bone)
                local playerr
                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped == entity then
                        playerr = player
                        break
                    end
                end
                if not playerr then return false end
                local targetSrc = GetPlayerServerId(playerr)

                local stateBag = Player(targetSrc).state
                if not stateBag.muted and not stateBag.mouthtape then
                    return true
                end
                return false
            end
        },

        {
            name = 'bc_mute',
            event = 'bc_mute:unmute',
            icon = 'fa-regular fa-circle',
            label = 'Szájtapasz leszedése',
            distance = 3.0,
            canInteract = function(entity, distance, coords, name, bone)
                local playerr
                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped == entity then
                        playerr = player
                        break
                    end
                end
                if not playerr then return false end
                local targetSrc = GetPlayerServerId(playerr)

                local stateBag = Player(targetSrc).state
                if stateBag.muted and stateBag.mouthtape and not stateBag.esxdead then
                    return true
                end
                return false
            end
        },

        {
            name = 'bc_readradio',
            event = 'bc_radio:read',
            icon = 'fa-regular fa-radio',
            label = 'Rádió frekvencia leolvasása',
            canInteract = function(entity, distance, coords, name, bone)
                return canOpenTarget(entity)
            end
        },
        {
            name = 'bc_discradio',
            event = 'bc_radio:disc',
            icon = 'fa-regular fa-radio',
            label = 'Rádió lecsatlakoztatása',
            canInteract = function(entity, distance, coords, name, bone)
                return canOpenTarget(entity)
            end
        },
        {
            name = 'bc_breakphone',
            event = 'bc_radio:breakphone',
            icon = 'fa-regular fa-radio',
            label = 'Telefon tönkretétele',
            canInteract = function(entity, distance, coords, name, bone)
                return canOpenTarget(entity)
            end
        },

        {
            name = 'bc_review',
            event = 'bc_review:review',
            icon = 'fa-regular fa-circle',
            label = 'Vélemény (OOC)',
        },

        {
            name = 'bc_review',
            event = 'bc_review:viewid',
            icon = 'fa-regular fa-circle',
            label = 'ID leolvasása',
        },

        {
            name = 'bc_emote',
            event = 'bc_emote:copy',
            icon = 'fa-regular fa-circle',
            label = 'Emote másolása',
            canInteract = function(entity, distance, coords, name, bone)
                local playerr
                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped == entity then
                        playerr = player
                        break
                    end
                end
                if not playerr then return end
                local targetSrc = GetPlayerServerId(playerr)

                local stateBag = Player(targetSrc).state
                local playedemote = stateBag.currentEmote
                if playedemote then
                    return true 
                else 
                    return false 
                end 
            end,
        },

        {
            name = 'bc_bodydamages',
            --event = 'bc_bodydamages:start',
            icon = 'fa-regular fa-circle',
            label = 'Vizsgálat',
            job = "ambulance",
            canInteract = function(entity, distance, coords, name, bone)
                if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
                    return true
                end
                return false
            end,
            onSelect = function(data)
            local ped = data.entity

            local playerIndex = NetworkGetPlayerIndexFromPed(ped)
            local serverId = GetPlayerServerId(playerIndex)

            exports["mate-dmgsys"]:OpenDamageMenu(serverId)
        end
        },
        {
            name = 'bc_ambrev',
            event = 'bc_amb:targetrevive',
            icon = 'fa-regular fa-circle',
            label = 'Újraélesztés',
            job = "ambulance",
            canInteract = function(entity, distance, coords, name, bone)
                if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
                    return true
                end
                return false
            end
        },
    })

    exports.ox_target:addGlobalVehicle({
        {
            name = 'bc_trunk',
            event = 'bc_trunk:hide',
            icon = 'fa-solid fa-eye-slash',
            label = 'Elbújás a csomagtartóban',
            bones = { "boot" }
        },
        {
            name = 'bc_vehpush',
            event = 'bc_vehpush:push',
            icon = 'fa-solid fa-circle',
            label = 'Autó tolása',
            canInteract = function(entity, distance, coords, name, bone)
                if IsVehicleSeatFree(entity, -1) and GetVehicleEngineHealth(entity) <= 100 then
                    return true
                end
                return false
            end
        },
    })

    exports.ox_target:addModel(`prop_vend_water_01`, {
        {
            name = 'bc_petpalack',
            icon = 'fa-solid fa-circle',
            label = 'Palackok visszaválátsa',
            onSelect = function(data)
                local alert = lib.alertDialog({
                    header = 'Visszaváltás',
                    content = 'Biztosan visszaváltod az összes nálad lévő palackot? Darabja 100$!',
                    centered = true,
                    cancel = true
                })
                if alert == true or alert == "confirm" then
                    TriggerServerEvent("bc_petpalack:sell")
                end
            end
        }
    })
end)
local canrob = false
exports("canrobother", function()
    return canrob
end)
AddEventHandler("bc_carry:setpermissions", function(data)
    if data.canRob then
        canrob = true
        -- ox_target warns when the same option name is added twice; setpermissions
        -- fires again on every job/duty update, so drop the old one first
        exports.ox_target:removeGlobalPlayer('bc_rob')
        exports.ox_target:addGlobalPlayer({
            {
                name = 'bc_rob',
                event = 'bc_carry:rob',
                icon = 'fa-solid fa-people-robbery',
                label = 'Motozás',
                canInteract = function()
                    return not isRobbing
                end
            }
        })
    else
        canrob = false
        exports.ox_target:removeGlobalPlayer('bc_rob')
    end

    if data.canHandcuff then
        exports.ox_target:removeGlobalPlayer({ 'bc_cuff', 'bc_drag' })
        exports.ox_target:addGlobalPlayer({
            {
                name = 'bc_cuff',
                items = 'bilincs',
                event = 'bc_carry:cuff',
                icon = 'fa-solid fa-handcuffs',
                label = 'Bilincselés',
            },
            {
                name = 'bc_drag',
                event = 'bc_carry:drag',
                icon = 'fa-solid fa-handcuffs',
                label = 'Vonszolás',
            },
        })
    else
        exports.ox_target:removeGlobalPlayer({ 'bc_cuff', 'bc_drag' })
    end

    if data.canCheckIdentity then
        exports.ox_target:removeGlobalPlayer('bc_checkbills')
        exports.ox_target:addGlobalPlayer({
            {
                name = 'bc_checkbills',
                event = 'bc_carry:checkbills',
                icon = 'fa-solid fa-people-robbery',
                label = 'Számlák megtekintése',
            }
        })
    else
        exports.ox_target:removeGlobalPlayer('bc_checkbills')
    end

    if data.canImpoundVehicles then
        exports.ox_target:removeGlobalVehicle('bc_impound')
        exports.ox_target:addGlobalVehicle({
            {
                name = 'bc_impound',
                event = 'bc_jobsys:impound',
                icon = 'fa-solid fa-circle',
                label = 'Autó lefoglalása',
            },
        })
    else
        exports.ox_target:removeGlobalVehicle('bc_impound')
    end
end)

AddEventHandler('bc_emote:copy', function(data)
    --if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    local targetSrc = GetPlayerServerId(playerr)

    local stateBag = Player(targetSrc).state
    local playedemote = stateBag.currentEmote
    if playedemote then
        ExecuteCommand("e " .. playedemote)
    else
        TriggerEvent("esx:showNotification", "Nem játszik le semmi emoteot!")
    end
end)

AddEventHandler('bc_mute:unmute', function(data)
    --print(json.encode(data))
    --[[if not canOpenTarget(PlayerPedId()) then
		return
	end ]]
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    if ESX.PlayerData.dead then
        return TriggerEvent('esx:showNotification', "Halott vagy!")
    end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end


    --data.entity
    local targetSrc = GetPlayerServerId(playerr)
    local targetPed = data.entity
    local ped = PlayerPedId()

    exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_mute:unmute", targetSrc)
end)

AddEventHandler('bc_mute:mute', function(data)
    --print(json.encode(data))
    --[[if not canOpenTarget(PlayerPedId()) then
		return
	end ]]
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    if ESX.PlayerData.dead then
        return TriggerEvent('esx:showNotification', "Halott vagy!")
    end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end


    --data.entity
    local targetSrc = GetPlayerServerId(playerr)
    local targetPed = data.entity
    local ped = PlayerPedId()

    exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_mute:mute", targetSrc)
end)


AddEventHandler('bc_review:viewid', function(data)
    --if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    local targetSrc = GetPlayerServerId(playerr)

    TriggerEvent("esx:showNotification", "A játékos ID-je: " .. targetSrc)
end)

AddEventHandler('bc_review:review', function(data)
    --if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    local targetSrc = GetPlayerServerId(playerr)

    local input = lib.inputDialog('Dialog title', {
        { type = 'select',   label = 'Vélemény típusa',     options = { { value = "negativ", label = "Negatív" }, { value = "pozitiv", label = "Pozitív" } }, required = true },
        { type = 'textarea', label = 'Vélemény (kifejtve)', required = true },
    })

    if not input then return end

    --print(json.encode(input))

    exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_review:review", targetSrc, (input[1] or "?"), (input[2] or "?"))
end)

AddEventHandler('bc_carry:checkbills', function(data)
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    local targetSrc = GetPlayerServerId(playerr)

    ESX.TriggerServerCallback("billing:getTargetBills", function(bills)
        if not bills then return end
        local options = {
            {
                title = 'Számla megnvezése - összeg ',
            }
        }
        for k, v in pairs(bills) do
            options[#options + 1] = {
                title = v.item .. " - " .. v.invoice_value
            }
        end
        lib.registerContext({
            id = 'bc_billings',
            title = 'Számlák a következő ID-hez: ' .. targetSrc,
            menu = 'checkbills',
            options = options
        })

        lib.showContext('bc_billings')
    end, targetSrc)
end)

AddEventHandler('bc_carry:drag', function(data)
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    local targetSrc = GetPlayerServerId(playerr)
    exports["gs_eventprotect"]:GS_TriggerServerEvent('esx_job_creator:dragTarget', targetSrc)
end)

AddEventHandler('bc_carry:cuff', function(data)
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    local targetSrc = GetPlayerServerId(playerr)
    exports["gs_eventprotect"]:GS_TriggerServerEvent('esx_job_creator:handcuffPlayer', targetSrc)
end)

local copList = { "police", "fbiuj", "uss", "irs", "atf", "navi", "fbi", "detective", "guardarmy", "usms", "servicess" }

local function isCop()
    for _, job in pairs(copList) do
        if job == ESX.PlayerData.job.name then
            return true
        end
    end
    return false
end

AddEventHandler('bc_carry:rob', function(data)
    if data.distance > 2 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local isDead = IsEntityDead(data.entity)
    local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
    local tempTable = {}

    if IsEntityPlayingAnim(data.entity, 'random@mugging3', 'handsup_standing_base', 3) or IsEntityPlayingAnim(data.entity, 'mp_arresting', 'idle', 3) or isDead or isCop() then
        isRobbing = true

        if isDead then
            tempTable = {
                scenario = 'CODE_HUMAN_MEDIC_TEND_TO_DEAD'
            }
        elseif isCop() then
            tempTable = {
                dict = 'custom@police',
                clip = 'police'
            }
        else
            tempTable = {
                dict = 'random@shop_robbery',
                clip = 'robbery_action_b'
            }
        end

        --TriggerServerEvent('bc_carry:server:freeze', serverId, true)
        --[[if lib.progressCircle({
				duration = 20000,
				label = isCop() and 'Motozás' or 'Kifosztás',
				position = 'bottom',
				useWhileDead = false,
				canCancel = true,
				disable = {
					move = true,
					car = true,
				},
				anim = tempTable,
			}) then
			isRobbing = false
			TriggerServerEvent('bc_carry:server:freeze', serverId, false)]]
        TriggerEvent("esx_job_creator:actions:searchplayer",
            GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
        --[[else
			isRobbing = false
			TriggerServerEvent('bc_carry:server:freeze', serverId, false)
			TriggerEvent(
				'esx:showNotification', "Abbbahagytad a rablást")
		end]]

        isRobbing = false
    else
        return TriggerEvent(
            'esx:showNotification', "Nem lehet átkutatni a játékost")
    end
end)

AddEventHandler('bc_radio:read', function(data)
    --print(json.encode(data))
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    --data.entity
    local targetSrc = GetPlayerServerId(playerr)
    exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_radio:read", targetSrc)
end)

AddEventHandler('bc_radio:breakphone', function(data)
    --print(json.encode(data))
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    --data.entity
    local targetSrc = GetPlayerServerId(playerr)
    exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_radio:breakphone", targetSrc)
end)

lib.callback.register('bc_radio:getChannel', function(radius)
    return exports["pma-voice"]:getRadioChannel()
end)

lib.callback.register('bc_car:skillC', function()
    return lib.skillCheck({ 'easy', 'hard', 'hard' }, { 'w', 'a', 's', 'd' })
end)

AddEventHandler('bc_radio:disc', function(data)
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end
    local targetSrc = GetPlayerServerId(playerr)
    exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_radio:disc", targetSrc)
end)

function IsAllowedToCarry()
    if GetResourceState("bc_communityservice") == "started" and exports["bc_communityservice"]:isPlayerOnCommunityservice() then
        return false
    end
    local coords = GetEntityCoords(PlayerPedId())
    if #(coords - vector3(3060.8767, -4709.435, 15.261412)) < 300.0 then
        return false
    end
    return true
end

--exports["pma-voice"]:getRadioChannel()
AddEventHandler('bc_carry:carry', function(data)
    --print(json.encode(data))
    if carry.InProgress then return TriggerEvent('esx:showNotification', "Valakit már felvettél!") end
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end
    if not IsAllowedToCarry() then
        return TriggerEvent('esx:showNotification', "Sajnos ezt nem lehet bari!")
    end
    if ESX.PlayerData.dead then return end
    local playerr
    local tped
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            tped = ped
            playerr = player
            break
        end
    end
    if not playerr then return end
    if not tped then return end
    --data.entity
    local targetSrc = GetPlayerServerId(playerr)
    --if exports["bc_afkuj"]:isAfk(targetSrc) then
    --	return TriggerEvent('esx:showNotification',
    --		"AFKoló játékost nem carryzhetsz fel!")
    --Send	
    if not IsEntityVisible(tped) then
        return
    end


    carry.InProgress = true
    carry.targetSrc = targetSrc
    exports["gs_eventprotect"]:GS_TriggerServerEvent("CarryPeople:sync", targetSrc)
    ensureAnimDict(carry.personCarrying.animDict)
    carry.type = "carrying"
end)

AddEventHandler('bc_revive:revive', function(data)
    --print(json.encode(data))
    --[[if not canOpenTarget(PlayerPedId()) then
		return
	end ]]
    if data.distance > 5 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

    if ESX.PlayerData.dead then
        return TriggerEvent('esx:showNotification', "Halott vagy!")
    end

    local playerr
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == data.entity then
            playerr = player
            break
        end
    end
    if not playerr then return end


    --data.entity
    local targetSrc = GetPlayerServerId(playerr)
    local targetPed = data.entity
    local ped = PlayerPedId()

    local canrevive = lib.callback.await('bc_revive:canRevive', false, targetSrc)
    if not canrevive then
        return TriggerEvent("esx:showNotification", "Ő már hívott mentőst, így nem tudsz rajta segíteni!")
    end

    local libb, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
    RequestAnimDict(libb)
    while not HasAnimDictLoaded(libb) do
        Wait(0)
    end

    --[[local success = lib.skillCheck({'easy', 'easy'}, {'w', 'a', 's', 'd'})
	if not success then
		TriggerServerEvent("bc_revive:remmedikit")
		return TriggerEvent("esx:showNotification", "Sikertelen próbálkozás:(")
	end ]]

    --TriggerServerEvent("bc_revive:remmedikit")
    TaskGoToCoordAnyMeans(PlayerPedId(), GetEntityCoords(targetPed), 1.0, 0, 0, 786603, 0xbf800000)
    Wait(1000)
    TaskTurnPedToFaceEntity(PlayerPedId(), targetPed, -1)
    Wait(500)
    local playinganim = true
    CreateThread(function()
        while playinganim do
            if not IsEntityPlayingAnim(PlayerPedId(), libb, anim, 3) then
                TaskPlayAnim(PlayerPedId(), libb, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
            end
            Wait(5)
        end
    end)
    for i = 1, 10 do
        TaskPlayAnim(PlayerPedId(), libb, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
        Wait(900)
    end
    playinganim = false
    ClearPedTasks(PlayerPedId())

    TriggerServerEvent("bc_revive:reviveplayer", targetSrc)
end)

-- A fejsérülés-ellenőrzés maradt kliensoldalon (csak itt olvasható ki a
-- GetPedLastDamageBone), de maga az újraélesztés már nem: a kliens csak
-- visszaigazol, és a szerver dönt -- az is, hogy volt-e egyáltalán kérés.
RegisterNetEvent("bc_carry:requestRevive", function(helper)
    local found, bone = GetPedLastDamageBone(CurrentPed)
    if not found then
        TriggerServerEvent("bc_carry:reviveConfirm")
    else
        if bone == GetPedBoneIndex(PlayerPedId(), 31086) or bone == GetPedBoneIndex(PlayerPedId(), 12844) then
            TriggerEvent("esx:showNotification", "Fejsérülést szenvedtél ezt nem lehet meggyógyítani!")
            TriggerServerEvent("bc_carry:headShot", helper)
        else
            TriggerServerEvent("bc_carry:reviveConfirm")
        end
    end
end)

--RegisterCommand("rablassegit", function(s,a,r)
--local alert = lib.alertDialog({
--    header = 'Rablás segítség',
--    content = [[
--1 tusz:
--- Sima tuszért 350 000 dollar (csak kez penzbe oldhato meg!)
--- Renvédelmis tuszért 450 000 dollar (csak kez penzbe oldhato meg!)
--- Jarmu nyomkoveto eltavolitasa
--- Élmény kep
--- Fair uldozes
--- Egy szerelo lada
--
--2 tusz
--- Szabad ut egy iranyba
--- Egy auto megforditasa 180 fokban
--- Rablashoz szukseges eszkoz ide rendelese
--- Maxos benzines kanna
--- Elkovetok mondjak meg h hol legyen a kihallgatas
--
--3 tusz:
--- Egy auto elhadja a helyezint ( vagy helikopter )
--- 3 masodperc elony
--- Fegyver ( max pisztoly: max: 5 darab )
--- Loszer ( max pisztolyloszer: max 500 darab )
--- Drogok
--- Helikopter elkuldese ( ne is johessen vissza )
--
--4 tusz
--- Sport vagy Terep auto kerese
--
--5 tusz
--- Ne legyen rabszallitss ha elkapnak csak csekk
--- Ne legyen kihallgatas, hanem csak rabszallitas
--- Minden rendvedelmis szalljon ki a kocsibol es szirenara ulljenek csak be
--- Helicopter kerese
--	]],
--    centered = true,
--    cancel = false
--})
--
--end)


local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    if closestDistance ~= -1 and closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
    return animDict
end

RegisterCommand("carry", function(source, args)
    --[[if not carry.InProgress then
		local closestPlayer = GetClosestPlayer(3)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				carry.InProgress = true
				carry.targetSrc = targetSrc
				TriggerServerEvent("CarryPeople:sync",targetSrc)
				ensureAnimDict(carry.personCarrying.animDict)
				carry.type = "carrying"
			else
				drawNativeNotification("~r~No one nearby to carry!")
			end
		else
			drawNativeNotification("~r~No one nearby to carry!")
		end
	else]]
    if carry.InProgress then
        carry.InProgress = false
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("CarryPeople:stop", carry.targetSrc)
        carry.targetSrc = 0
    end
end, false)

RegisterNetEvent("CarryPeople:syncTarget")
AddEventHandler("CarryPeople:syncTarget", function(targetSrc)
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(targetPed)) > 10 then
        return
    end
    exports["rpemotes-reborn"]:CancelEmote()
    carry.InProgress = true
    ensureAnimDict(carry.personCarried.animDict)
    AttachEntityToEntity(PlayerPedId(), targetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY,
        carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
    carry.type = "beingcarried"
end)

-- A szerver carry+teleport ellenorzese kerdezi: interiorban (garazs, lakas,
-- MLO) allunk-e? Ezek a helyek tavol vannak a terkepen, ezert a belepes a
-- szervernek teleportnak latszik -- a valasz nelkul a garazsba beallo jatekos
-- kapna bant.
RegisterNetEvent("CarryPeople:tpInteriorQuery", function(token)
    if type(token) ~= "string" then return end

    local ped = PlayerPedId()
    local interior = GetInteriorFromEntity(ped)

    if interior == 0 then
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            interior = GetInteriorFromEntity(veh)
        end
    end

    if interior ~= 0 and not IsValidInterior(interior) then
        interior = 0
    end

    TriggerServerEvent("CarryPeople:tpInteriorAnswer", token, interior)
end)

RegisterNetEvent("CarryPeople:cl_stop")
AddEventHandler("CarryPeople:cl_stop", function()
    carry.InProgress = false
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
    while true do
        if carry.InProgress then
            if carry.type == "beingcarried" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000,
                        carry.personCarried.flag, 0, false, false, false)
                end
            elseif carry.type == "carrying" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0,
                        100000, carry.personCarrying.flag, 0, false, false, false)
                end
            end

            if carry.InProgress and not IsAllowedToCarry() then
                TriggerServerEvent("CarryPeople:stop", (carry.targetSrc or 0))
                Wait(2000)
            end
        else
            Wait(1000)
        end
        Wait(500)
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if carry.InProgress then
            --DisableAllControlActions(0)
            DisableControlAction(0, 38, true)
            DisableControlAction(0, 26, true)
            DisableControlAction(0, 20, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 257, true)
            DisablePlayerFiring(PlayerId(), true)
        else
            Wait(1000)
        end
    end
end)

RegisterNetEvent("bc_practi:shop", function()
    local can = lib.callback.await('bc_practi:pay', false)
    if not can then
        return TriggerEvent("esx:showNotification", "Nincs elég pénzed!")
    end
    if lib.skillCheck({ 'easy', 'easy', 'easy', 'easy', 'easy', 'easy', }, { 'W', 'A', 'S', 'D' }) then
        return true
    end
end)

RegisterNetEvent("bc_practi:bank", function()
    local can = lib.callback.await('bc_practi:pay', false)
    if not can then
        return TriggerEvent("esx:showNotification", "Nincs elég pénzed!")
    end
    local has_succeeded = exports.exp_hack:StartHack({
        rounds = 2,
        squares = 3
    }, nil, function()
    end)
end)

RegisterNetEvent("bc_practi:pac", function()
    local can = lib.callback.await('bc_practi:pay', false)
    if not can then
        return TriggerEvent("esx:showNotification", "Nincs elég pénzed!")
    end
    local success = exports.bl_ui:KeyCircle(3, 30, 3)
end)

RegisterNetEvent("bc_practi:orig", function()
    local can = lib.callback.await('bc_practi:pay', false)
    if not can then
        return TriggerEvent("esx:showNotification", "Nincs elég pénzed!")
    end
    if lib.skillCheck({ 'easy', 'easy', 'easy', 'hard' }, { 'w', 'a', 's', 'd' }) then
        return true
    end
end)

RegisterNetEvent("bc:repairweapon", function(wep)
    if not wep then return end

    local items = exports.ox_inventory:GetPlayerItems()
    local item = items[wep]
    if not item then 
        return print("no item")
    end     

    TriggerServerEvent("bc_weaponrepair:repair", wep)
end)