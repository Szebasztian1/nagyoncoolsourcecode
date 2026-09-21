UiLoaded, LoggedIn, PlayerData, LocalPlayer, hunger, thirst, ped, isInVehicle, playerServerId = false, false, {}, PlayerId(), 0, 0, PlayerPedId(), false, nil

local totalPlayers = 20
local maxPlayers = 200

RegisterNetEvent("aty_hud:client:playercount", function(count)
    totalPlayers = count
end)

CreateThread(function()
    --DisplayRadar(false)
    local sleep = 1000

    triggerServerCallback("aty_hud:server:getServerInfo", function(cb)
        totalPlayers = cb.totalPlayers
        maxPlayers = cb.maxPlayers
    end)

    while true do
        ped = PlayerPedId()

        if Config.Framework == "esx" then
			PlayerData = Framework.GetPlayerData()
		else
			PlayerData = Framework.Functions.GetPlayerData()
		end

        if not LoggedIn and UiLoaded and table_size(PlayerData) > 5 then
            sleep = 3000
			LoggedIn = true
            playerServerId = GetPlayerServerId(LocalPlayer)

            while not Framework.IsPlayerLoaded() do 
                Wait(50)
            end 
            Wait(5000)

            loadMap()
            
            SetRadarBigmapEnabled(false, false)
            --DisplayRadar(false)
            SendHudMessage("toggle", { status = true })

            loadMap()
		end

        if LoggedIn then
            --triggerServerCallback("aty_hud:server:getPlayerInfo", function(cb)
                local money = 0
                local bank = 0
                SetRadarZoom(1100)

                if PlayerData.accounts then 
                    for i = 1, #PlayerData.accounts do
                        if PlayerData.accounts[i].name == "money" then
                            money = PlayerData.accounts[i].money
                        elseif PlayerData.accounts[i].name == "bank" then
                            bank = PlayerData.accounts[i].money
                        end
                    end
                end 
                
                local job = ""
                if PlayerData.job then 
                    job = PlayerData.job.label.." - "..PlayerData.job.grade_label
                end 
                local mins = GetClockMinutes() < 10 and "0"..GetClockMinutes() or GetClockMinutes()
                local hours = GetClockHours() < 10 and "0"..GetClockHours() or GetClockHours()

                local frametime = math.floor(1 / GetFrameTime())

                SendNUIMessage({
                    action = "updatePlayerInfo",
                    money = money,
                    bank = bank,
                    ping = frametime,
                    totalPlayers = totalPlayers,
                    maxPlayers = maxPlayers,
                    job = job,
                    id = playerServerId,
                    time = hours..":"..mins
                })
            --end)
        end

		Wait(sleep)
    end
end)

CreateThread(function()
    while not LoggedIn do
        Wait(100)
    end

    if Config.Framework == "esx" then
        AddEventHandler('esx_status:onTick', function(data)
            for i = 1, #data do
                if data[i].name == 'hunger' then
                    hunger = math.floor(data[i].percent)
                end
    
                if data[i].name == 'thirst' then
                    thirst = math.floor(data[i].percent)
                end
            end
        end)
    else
        CreateThread(function()
            while true do
                hunger = next(PlayerData) and PlayerData.metadata["hunger"] or 0
                thirst = next(PlayerData) and PlayerData.metadata["thirst"] or 0

                Wait(500)
            end
        end)
    end
    
    while true do
        if LoggedIn and UiLoaded and next(PlayerData) then
            local health = GetEntityHealth(ped)
            local maxHealth = GetPedMaxHealth(ped)
            health = (health - 100) * 100 / (maxHealth - 100)
            local armor = GetPedArmour(ped)
            local stamina = 100 - GetPlayerSprintStaminaRemaining(LocalPlayer)
            local isTalking = NetworkIsPlayerTalking(LocalPlayer)
            local oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
            local isInWater = IsPedSwimmingUnderWater(ped)

            -- These come back as floats that jitter in the decimals even when the player is stood
            -- still, which would defeat the de-duplication for no gain: the bars are percentages
            -- and cannot show a fraction anyway.
            SendHudMessage("updateStatus", {
                health = math.floor(health),
                armor = armor,
                stamina = math.floor(stamina),
                isTalking = isTalking,
                hunger = hunger,
                thirst = thirst,
                oxygen = math.floor(oxygen),
                isInVehicle = isInVehicle,
                isInWater = isInWater,
            })
        end

        Wait(800)
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        local streetHash, roadHash = GetStreetNameAtCoord(table.unpack(coords))

        SendHudMessage("updateStreet", {
            street = GetStreetNameFromHashKey(streetHash),
            road = GetStreetNameFromHashKey(roadHash)
        })

        Wait(3000)
    end
end)

CreateThread(function()
    local sleep = 1500

    while true do
        local isArmed = IsPedArmed(ped, 4)
        local gunName = ""
        local fullAmmo = 0
        local clipAmmo = 0
        local ammoLeft = 0

        if isArmed then
            local weapon = GetSelectedPedWeapon(ped)
            if weapon and weapon ~= `weapon_unarmed` then
                -- Read ammo from natives for ANY weapon, even if it isn't in
                -- the Weapons table (custom/addon weapons included).
                fullAmmo = GetAmmoInPedWeapon(ped, weapon)
                _, clipAmmo = GetAmmoInClip(ped, weapon)
                ammoLeft = fullAmmo - clipAmmo

                -- Only known weapons have a matching image name; unknown ones
                -- send an empty name and the UI falls back to a placeholder.
                if Weapons[weapon] then
                    gunName = Weapons[weapon].name
                end
            end

            sleep = 200
        else
            sleep = 1500
        end

        SendHudMessage("updateGun", {
            isArmed = isArmed,
            gunName = gunName,
            fullAmmo = ammoLeft,
            clipAmmo = clipAmmo,
        })

        Wait(sleep)
    end
end)

RegisterNetEvent('SaltyChat_VoiceRangeChanged', function(voiceRange, index, availableVoiceRanges)
	index = index + 1
    
	if index >= 4 then
		index = 3
	end

	SendNUIMessage({
		action = "setVoiceMode",
		value = index
	})
end)

RegisterNetEvent('pma-voice:setTalkingMode', function(voiceMode)
	SendNUIMessage({
		action = "setVoiceMode",
		value = voiceMode
	})
end)

RegisterNetEvent('SaltyChat_TalkStateChanged', function(isTalking)
	SendNUIMessage({
		action = "isTalking",
		isTalking = isTalking
	})
end)

RegisterNetEvent("mumble:SetVoiceData", function(player, key, value)
	if GetPlayerServerId(NetworkGetEntityOwner(PlayerPedId())) == player and key == 'mode' then
		SendNUIMessage({
			action = "setVoiceMode",
			value = value
		})
	end
end)

RegisterNetEvent("aty_hud:sendNotify", function(text, icon, color, duration)
    SendNUIMessage({
        action = "notification",
        text = text,
        icon = icon,
        color = color,
        duration = duration,
    })
end)
local psmenu = false 
AddEventHandler("pausemenu", function(s)
    --print("psmenuset", s)
	if s then 
		psmenu = true 
	else 
		psmenu = false 
	end 
end)
local hidehud = false
-- Declared here, not below IsPSMenu(): the hideHud handler assigns to it, and
-- with the local further down that assignment silently created a global while
-- the toggle thread read a different, local variable.
local pausemenu = false
AddEventHandler("hideHud", function(s)
    --print("hidehud")
    if s then 
		hidehud = true
        --print("tgoff")
        pausemenu = true
        SendHudMessage("toggle", { status = false })
	else
		hidehud = false 
	end 
end)

function IsPSMenu()
 if IsPauseMenuActive() or psmenu or hidehud then 
    return true
 end
 return false
end
CreateThread(function()
    

    while true do
        Wait(500)

        if IsPSMenu() then
            pausemenu = true
            --print("tgoff")
            SendHudMessage("toggle", { status = false })
            DisplayRadar(false)
        elseif not IsPSMenu() then
            if pausemenu then
                DisplayRadar(true)
                loadMap()

            end
            pausemenu = false

            SendHudMessage("toggle", { status = true })
        end
    end 
end)

--[[CreateThread(function()
    while true do
        HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(21)
        HideHudComponentThisFrame(22)

        Wait(0)
    end 
end)]]

RegisterCommand(Config.MenuCommand, function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "toggleSettings",
    })
end)

if Config.UseMenuKey then
    RegisterKeyMapping(Config.MenuCommand, 'Open Hud Settings', 'keyboard', Config.MenuKey)
end

RegisterNetEvent("aty_hud:toggle", function(status)
    SendHudMessage("toggle", { status = status })
end)