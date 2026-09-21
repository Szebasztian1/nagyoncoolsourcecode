-----------------------------------------------------------------
--TakeHostage by Robbster, do not redistrbute without permission--
------------------------------------------------------------------

local takeHostage = {
	allowedWeapons = {
		`WEAPON_PISTOL`,
		`WEAPON_COMBATPISTOL`,
		`WEAPON_heavypistol`,
		`WEAPON_pistol50`,
		`WEAPON_revolver`,
		`WEAPON_pistol_mk2`,
		`WEAPON_APPISTOL`,

		`GROUP_PISTOL`,
		`GROUP_SMG`,
		`GROUP_MG`,
		`GROUP_RIFLE`,
		`GROUP_SHOTGUN`,
		--etc add guns you want
	},
	InProgress = false,
	type = "",
	targetSrc = -1,
	agressor = {
		animDict = "anim@gangops@hostage@",
		anim = "perp_idle",
		flag = 49,
	},
	hostage = {
		animDict = "anim@gangops@hostage@",
		anim = "victim_idle",
		attachX = -0.24,
		attachY = 0.11,
		attachZ = 0.0,
		flag = 49,
	}
}

local function drawNativeNotification(text)
    --[[SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)]]
	TriggerEvent("esx:showNotification", text)
end

local function GetClosestPlayer(radius)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _,playerId in ipairs(players) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords-playerCoords)
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

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end        
    end
    return animDict
end

local function drawNativeText(str)
	SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(1)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentString(str)
            EndTextCommandDisplayText(0.5, 0.9)
end

RegisterCommand("takehostage",function()
	callTakeHostage()
end)

RegisterCommand("th",function()
	callTakeHostage()
end)

function IsHandsUp(ped)
	return IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3)
        or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_enter', 3)
        or IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)
end 

function callTakeHostage()

	--[[if exports["fegyver_tiltas"]:Active() then 
        return 
	end --]]
	if GetResourceState("bc_communityservice") == "started" and exports["bc_communityservice"]:isPlayerOnCommunityservice() then
        return TriggerEvent('esx:showNotification', "Közin vagy!")
    end
	if takeHostage.InProgress then 
		return false 
	end 
	if IsPedInAnyVehicle(PlayerPedId(), true) then 
		return false 
	end 
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)

	local canTakeHostage = false

	local weaponHash = GetSelectedPedWeapon(PlayerPedId())
	local wgroup = GetWeapontypeGroup(weaponHash)

	for i=1, #takeHostage.allowedWeapons do
		if takeHostage.allowedWeapons[i] == weaponHash or takeHostage.allowedWeapons[i] == wgroup then
			if GetAmmoInPedWeapon(PlayerPedId(), weaponHash) > 0 then
				canTakeHostage = true 
				foundWeapon = weaponHash
				break
			end 					
		end
	end
	--[[for i=1, #takeHostage.allowedWeapons do
		if HasPedGotWeapon(PlayerPedId(), takeHostage.allowedWeapons[i], false) then
			if GetAmmoInPedWeapon(PlayerPedId(), takeHostage.allowedWeapons[i]) > 0 then
				canTakeHostage = true 
				foundWeapon = takeHostage.allowedWeapons[i]
				break
			end 					
		end
	end]]
	

	if not canTakeHostage then 
		drawNativeNotification("Vegyél a kezedbe egy betöltött fegyvert!")
	end

	if not takeHostage.InProgress and canTakeHostage then			
		local closestPlayer = GetClosestPlayer(3)
		if closestPlayer then
			local targetSrc = GetPlayerServerId(closestPlayer)
			if targetSrc ~= -1 then
				if IsPedInAnyVehicle(GetPlayerPed(closestPlayer), true) then 
					return false 
				end 
				if not IsEntityVisible(GetPlayerPed(closestPlayer)) then 
					return false 
				end 
				if not lib.callback.await("bc_revive:canRevive", false, targetSrc) then 
					return false 
				end 
				if not IsHandsUp(GetPlayerPed(closestPlayer)) then 
					drawNativeNotification("~r~Nincs feltéve a keze!")
					return false 
				end 
				SetCurrentPedWeapon(PlayerPedId(), foundWeapon, true)
				takeHostage.InProgress = true
				takeHostage.targetSrc = targetSrc
				TriggerServerEvent("TakeHostage:sync",targetSrc)
				ensureAnimDict(takeHostage.agressor.animDict)
				takeHostage.type = "agressor"
			else
				drawNativeNotification("~r~Nincs senki a közeledben!")
			end
		else
			drawNativeNotification("~r~Nincs senki a közeledben!")
		end
	end
end 

RegisterNetEvent("TakeHostage:syncTarget")
AddEventHandler("TakeHostage:syncTarget", function(target)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(targetPed)) > 10 then 
        return 
    end 
	takeHostage.InProgress = true
	ensureAnimDict(takeHostage.hostage.animDict)
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, takeHostage.hostage.attachX, takeHostage.hostage.attachY, takeHostage.hostage.attachZ, 0.5, 0.5, 0.0, false, false, false, false, 2, false)
	takeHostage.type = "hostage" 
end)

RegisterNetEvent("TakeHostage:releaseHostage")
AddEventHandler("TakeHostage:releaseHostage", function()
	takeHostage.InProgress = false 
	takeHostage.type = ""
	DetachEntity(PlayerPedId(), true, false)
	ensureAnimDict("reaction@shove")
	TaskPlayAnim(PlayerPedId(), "reaction@shove", "shoved_back", 8.0, -8.0, -1, 0, 0, false, false, false)
	Wait(250)
	ClearPedSecondaryTask(PlayerPedId())
end)

RegisterNetEvent("TakeHostage:killHostage")
AddEventHandler("TakeHostage:killHostage", function()
	takeHostage.InProgress = false 
	takeHostage.type = ""
	if GetPlayerInvincible(PlayerId()) then 
		return 
	end 
	local hcoords = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(PlayerPedId(), 31086))
	SetEntityHealth(PlayerPedId(),0)
	--ShootSingleBulletBetweenCoords(hcoords+vector3(0.2, 0.2, 0.2), hcoords+vector3(-0.2, -0.2, -0.2), 333, true, `WEAPON_PISTOL`, PlayerPedId(), false, true)
	DetachEntity(PlayerPedId(), true, false)
	ensureAnimDict("anim@gangops@hostage@")
	TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "victim_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
end)

RegisterNetEvent("TakeHostage:cl_stop")
AddEventHandler("TakeHostage:cl_stop", function()
	takeHostage.InProgress = false
	takeHostage.type = "" 
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

Citizen.CreateThread(function()
	while true do
		if takeHostage.type == "agressor" then
			if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 3) then
				TaskPlayAnim(PlayerPedId(), takeHostage.agressor.animDict, takeHostage.agressor.anim, 8.0, -8.0, 100000, takeHostage.agressor.flag, 0, false, false, false)
			end
		elseif takeHostage.type == "hostage" then
			if not IsEntityPlayingAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 3) then
				TaskPlayAnim(PlayerPedId(), takeHostage.hostage.animDict, takeHostage.hostage.anim, 8.0, -8.0, 100000, takeHostage.hostage.flag, 0, false, false, false)
			end
		else 
			Wait(1000)
		end
		Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do 
		if takeHostage.type == "agressor" then
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,21,true) -- disable sprint
			DisablePlayerFiring(PlayerPedId(),true)
			drawNativeText("Nyomja meg a [G] gombot az elengedéshez, a [H] gombot a megöléshez")

			if IsEntityDead(PlayerPedId()) then	
				takeHostage.type = ""
				takeHostage.InProgress = false
				ensureAnimDict("reaction@shove")
				TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
			end 

			if IsDisabledControlJustPressed(0,47) then --release	
				takeHostage.type = ""
				takeHostage.InProgress = false 
				ensureAnimDict("reaction@shove")
				TaskPlayAnim(PlayerPedId(), "reaction@shove", "shove_var_a", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("TakeHostage:releaseHostage", takeHostage.targetSrc)
			elseif IsDisabledControlJustPressed(0,74) then --kill 			
				takeHostage.type = ""
				takeHostage.InProgress = false 		
				ensureAnimDict("anim@gangops@hostage@")
				TaskPlayAnim(PlayerPedId(), "anim@gangops@hostage@", "perp_fail", 8.0, -8.0, -1, 168, 0, false, false, false)
				TriggerServerEvent("TakeHostage:killHostage", takeHostage.targetSrc)
				TriggerServerEvent("TakeHostage:stop",takeHostage.targetSrc)
				Wait(100)
				SetPedShootsAtCoord(PlayerPedId(), 0.0, 0.0, 0.0, 0)
			end
		elseif takeHostage.type == "hostage" then 
			DisableControlAction(0,21,true) -- disable sprint
			DisableControlAction(0,24,true) -- disable attack
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0,47,true) -- disable weapon
			DisableControlAction(0,58,true) -- disable weapon
			DisableControlAction(0,263,true) -- disable melee
			DisableControlAction(0,264,true) -- disable melee
			DisableControlAction(0,257,true) -- disable melee
			DisableControlAction(0,140,true) -- disable melee
			DisableControlAction(0,141,true) -- disable melee
			DisableControlAction(0,142,true) -- disable melee
			DisableControlAction(0,143,true) -- disable melee
			DisableControlAction(0,75,true) -- disable exit vehicle
			DisableControlAction(27,75,true) -- disable exit vehicle  
			DisableControlAction(0,22,true) -- disable jump
			DisableControlAction(0,32,true) -- disable move up
			DisableControlAction(0,268,true)
			DisableControlAction(0,33,true) -- disable move down
			DisableControlAction(0,269,true)
			DisableControlAction(0,34,true) -- disable move left
			DisableControlAction(0,270,true)
			DisableControlAction(0,35,true) -- disable move right
			DisableControlAction(0,271,true)
		else 
			Wait(1000)
		end
		Wait(0)
	end
end)

exports('isActive', function()
	return takeHostage.InProgress
end)