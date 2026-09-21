if Config.EnableCommands then
	CreateThread(function()
		TriggerEvent('chat:addSuggestion', '/'..Config.PutInCommand, Translate('put_command'), {
			{ name="player", help=Translate('command_help_player') },
			{ name="count", help=Translate('command_help_count') },
			{ name="reason", help=Translate('command_help_reason') },
		})
		TriggerEvent('chat:addSuggestion', '/'..Config.RealseCommand, Translate('realse_command'), {
			{ name="player", help=Translate('command_help_player') }
		})
	end)
end 

function SetUniform()
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.male)
		else
			TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.female)
		end
	end)
end 

function RestoreClothes()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
		TriggerEvent('esx:restoreLoadout')
	end)
end 

function OnActionChange(data)
	if data then 
		SetUniform()
		RemoveAllPedWeapons(PlayerPedId(), true)
	else 
		RestoreClothes()
	end 
end 

function HandleMinigame()
	if not Config.Minigame then return true end 
	if Config.OxLib then 
		return lib.skillCheck({'medium', 'medium'}, {'w', 'a', 's', 'd'})
	else 
		return BCMinigame()
	end 
end 

function Notify(msg)
    ESX.ShowNotification(msg)
end 

lib.callback.register('bc_communityservice:vasarlas', function(count, price)
    if isInAnim then
        Notify("Miközben animációba vagy ez nem lehetséges!") 
        return false 
    end
    local conf = lib.alertDialog({
		header = 'Közi kiváltás',
		content = 'Kiváltod magad ' .. count .. ' köziről ' .. price .. '$ ért?',
		centered = true,
		cancel = true
	})
	if conf == "confirm" then 
		return true 
	end 
	return false
end)

lib.callback.register('bc_communityservice:question', function(question, answers)
	local elements = {}
	local ans = 0
	for k, v in pairs(answers) do 
		elements[#elements+1] = {
			title = v,
			icon = 'circle',
			onSelect = function()
				ans = k
			end,
		}
	end 
    lib.registerContext({
		id = 'bc_communityservice:question',
		title = 'Válaszolj 8 mp-n belül és leveszünk 5 közit! '..question,
		menu = 'bc_communityservice:question',
		options = elements
	})
	lib.showContext('bc_communityservice:question')
  	while ans == 0 do 
		Wait(10)
	end 
	return ans
end)


CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(10)
    end
    Wait(5000)
    exports.ox_target:addGlobalPlayer({


        {
            name = 'bc_cm:unmute',
            event = 'bc_cm:unmute',
            icon = 'fa-regular fa-circle',
            label = 'Némítás feloldása',
            distance = 3.0,
            canInteract = function(entity, distance, coords, name, bone)
				if not LocalPlayer.state.isOnDuty then return false end 
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
                if stateBag.muted and stateBag.cmservice then
                    return true
                end
                return false
            end
        },

        {
            name = 'bc_cm:mute',
            event = 'bc_cm:mute',
            icon = 'fa-regular fa-circle',
            label = 'Némítás bekapcsolása',
            distance = 3.0,
            canInteract = function(entity, distance, coords, name, bone)
				if not LocalPlayer.state.isOnDuty then return false end 
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
                if not stateBag.muted and stateBag.cmservice then
                    return true
                end
                return false
            end
        },
	})
end)

AddEventHandler('bc_cm:unmute', function(data)
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

    TriggerServerEvent("bc_communityservice:unmute", targetSrc)
end)
AddEventHandler('bc_cm:mute', function(data)
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

    TriggerServerEvent("bc_communityservice:mute", targetSrc)
end)