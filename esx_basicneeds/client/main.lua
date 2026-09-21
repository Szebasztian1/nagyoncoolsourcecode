local IsDead = false
local IsAnimated = false

AddEventHandler('esx_basicneeds:resetStatus', function()
	TriggerEvent('esx_status:set', 'hunger', 500000)
	TriggerEvent('esx_status:set', 'thirst', 500000)
end)

RegisterNetEvent('esx_basicneeds:healPlayer')
AddEventHandler('esx_basicneeds:healPlayer', function()
	-- restore hunger & thirst
	TriggerEvent('esx_status:set', 'hunger', 1000000)
	TriggerEvent('esx_status:set', 'thirst', 1000000)

	-- restore hp
	local playerPed = PlayerPedId()
	SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
end)

AddEventHandler('esx:onPlayerDeath', function()
	IsDead = true
end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
	if IsDead then
		TriggerEvent('esx_basicneeds:resetStatus')
	end

	IsDead = false	
end)

local isplatina = false 
RegisterNetEvent("bc_vip:vip", function()
	Wait(4000)
	isplatina = false
	if exports["bc_vip"]:IsVIP() == "platina" then 
		isplatina = true
	end
end)

AddEventHandler('esx_status:loaded', function(status)
	TriggerEvent('esx_status:registerStatus', 'hunger', 1000000, '#CFAD0F', function(status)
		return Config.Visible
	end, function(status)
		local r = 120
		if isplatina then 
			r = 105
		end 
		status.remove(r)
	end)

	TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1', function(status)
		return Config.Visible
	end, function(status)
		local r = 150
		if isplatina then 
			r = 126
		end 
		status.remove(r)
	end)
end)

-- Latest hunger/thirst percentages, kept up to date by the esx_status:onTick handler below so
-- nothing has to ask esx_status for them again.
local statusPercent = {}

AddEventHandler('esx_status:onTick', function(data)
	local playerPed  = PlayerPedId()
	local prevHealth = GetEntityHealth(playerPed)
	local health     = prevHealth
	
	for k, v in pairs(data) do
		statusPercent[v.name] = v.percent
		if v.name == 'hunger' and v.percent == 0 then
			if prevHealth <= 150 then
				health = health - 5
			else
				health = health - 1
			end
		elseif v.name == 'thirst' and v.percent == 0 then
			if prevHealth <= 150 then
				health = health - 5
			else
				health = health - 1
			end
		end
		Wait(0)
	end
	
	if health ~= prevHealth then SetEntityHealth(playerPed, health) end
end)

AddEventHandler('esx_basicneeds:isEating', function(cb)
	cb(IsAnimated)
end)

local txd
local loadeditems = {}
CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do 
		Wait(100)
	end 
	Wait(2000)
	txd = CreateRuntimeTxd("bc_eves")
end)

--[[RegisterNetEvent("esx_basicneeds:drawIcon", function(sid, item)
	if not txd then return end 

	local player = GetPlayerFromServerId(sid)
	if player == -1 then 
		return 
	end 
	local ped = GetPlayerPed(player)
	if not DoesEntityExist(ped) then 
		return 
	end 
	local dis = #(GetEntityCoords(ped) - GetEntityCoords(PlayerPedId()))
	if dis > 10 then 
		return 
	end 
	if not loadeditems[item] then 
		exports['image-to-txn']:AddImage("nui://ox_inventory/web/images/"..item..".png", txd, item, function()
			loadeditems[item] = true 
			CreateThread(function()
				local to = GetGameTimer() + 2000
				while to > GetGameTimer() do 
					if not GetTextureResolution("bc_eves", item) then 
						return print("^1SCRIPT ERROR: A texture is missing for item: "..item)
					end 
					Wait(1)
					--local pc = GetOffsetFromEntityInWorldCoords(ped, vector3(0.0, 0.3, 0.2))
					local pc = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, 18905))
					DrawMarker(9, pc, 0.0, 0.0, 0.0, 90.0, 90.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, false, true, 2, false, "bc_eves", item, false)
				end 
			end)
		end)
	else 
		CreateThread(function()
			local to = GetGameTimer() + 2000
			while to > GetGameTimer() do 
				if not GetTextureResolution("bc_eves", item) then 
					return print("^1SCRIPT ERROR: A texture is missing for item: "..item)
				end 
				Wait(1)
				local pc = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, 18905))
				DrawMarker(9, pc, 0.0, 0.0, 0.0, 90.0, 90.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, false, true, 2, false, "bc_eves", item, false)
			end 
		end)
	end 
end)]]

RegisterNetEvent('esx_basicneeds:onUse')
AddEventHandler('esx_basicneeds:onUse', function(type, prop_name, anim)
	if not IsAnimated then
		local anim = anim
		IsAnimated = true
		if type == 'food' then
			prop_name = prop_name or 'prop_cs_burger_01'
			anim = anim
		elseif type == 'drink' then
			prop_name = prop_name or 'prop_ld_flow_bottle'
			anim = anim
		end

		CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			--local prop = CreateObject(joaat(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			--AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict(anim.dict, function()
				TaskPlayAnim(playerPed, anim.dict, anim.name, anim.settings[1], anim.settings[2], anim.settings[3], anim.settings[4], anim.settings[5], anim.settings[6], anim.settings[7], anim.settings[8])
				RemoveAnimDict(anim.dict)

				Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				--DeleteObject(prop)
			end)
		end)
	end
end)



-- Backwards compatibility
RegisterNetEvent('esx_basicneeds:onEat')
AddEventHandler('esx_basicneeds:onEat', function(prop_name)
    local Invoke = GetInvokingResource()

    --print(('[^3WARNING^7] ^5%s^7 used ^5esx_basicneeds:onEat^7, this method is deprecated and should not be used! Refer to ^5https://documentation.esx-framework.org/addons/esx_basicneeds/events/oneat^7 for more info!'):format(Invoke))

    if not prop_name then
        prop_name = 'prop_cs_burger_01'
    end
    TriggerEvent('esx_basicneeds:onUse', 'food', prop_name)
end)

RegisterNetEvent('esx_basicneeds:onDrink')
AddEventHandler('esx_basicneeds:onDrink', function(prop_name)
    local Invoke = GetInvokingResource()

    --print(('[^3WARNING^7] ^5%s^7 used ^5esx_basicneeds:onDrink^7, this method is deprecated and should not be used! Refer to ^5https://documentation.esx-framework.org/addons/esx_basicneeds/events/ondrink^7 for more info!'):format(Invoke))


    if not prop_name then
        prop_name = 'prop_ld_flow_bottle'
    end
    TriggerEvent('esx_basicneeds:onUse', 'drink', prop_name)
end)


RegisterNetEvent("esx_basicneeds:effect", function(effects)
	local notimsg = "A következő hatásokat érezted: "
	for k,v in pairs(effects) do
		if v[1] == "running" then
			notimsg = notimsg .. "Gyors futás, "
			CreateThread(function()
				SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
				Wait(v[2])
				SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
			end)
		elseif v[1] == "armor" then
			notimsg = notimsg .. "Pajzs, "
			SetPedArmour(PlayerPedId(), GetPedArmour(PlayerPedId()) + v[2])
		elseif v[1] == "swimming" then
			notimsg = notimsg .. "Gyors úszás, "
			CreateThread(function()
				SetSwimMultiplierForPlayer(PlayerId(), 1.2)
				Wait(v[2])
				SetSwimMultiplierForPlayer(PlayerId(), 1.0)
			end)
		elseif v[1] == "drunk" then
			CreateThread(function()
                RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
                while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
                    Citizen.Wait(0)
                end
				AnimpostfxPlay("DrugsDrivingIn", 30000, true)
                Wait(15000)
                SetPedMovementClipset(PlayerPedId(), "MOVE_M@DRUNK@VERYDRUNK", true)
				AnimpostfxPlay("DMT_flight_intro", 100000, true)

				Wait(v[2])

				AnimpostfxStop("DMT_flight_intro")
				AnimpostfxStop("DrugsDrivingIn")
				ResetPedMovementClipset(PlayerPedId(), 0)
            end)
		end
	end
	TriggerEvent("esx:showNotification", notimsg)
end)

local isdead = false
local poisoned = false 
AddEventHandler('esx:onPlayerDeath', function(data)
	isdead = true
end)
AddEventHandler('playerSpawned', function(spawn)
	isdead = false
end)
function ScreenEffect()
	while true do
		Wait(5000)
		local me = PlayerId()
		local myped = PlayerPedId()
		local swim = GetPlayerUnderwaterTimeRemaining(me)
		local myhealth = GetEntityHealth(myped)
		local mymaxhealth = GetEntityMaxHealth(myped)
		-- esx_status broadcasts these every Config.TickTime (3s) and this loop runs every 5s, so
		-- read the cached values instead of round-tripping two callback refs into the esx_status
		-- resource on every pass. percent here is the exact same number getPercent() returned.
		local StatusDatas = {}
		if statusPercent.hunger then StatusDatas["hunger"] = math.floor(statusPercent.hunger) end
		if statusPercent.thirst then StatusDatas["thirst"] = math.floor(statusPercent.thirst) end
		if poisoned then 
			ApplyDamageToPed(PlayerPedId(), 17, false)
		end 
		if not isdead then 
			if StatusDatas and  StatusDatas["hunger"] and StatusDatas["thirst"] and (StatusDatas["hunger"] < 5 or StatusDatas["thirst"] < 5 or swim < 5 or tonumber(myhealth/mymaxhealth*100) < 20 or poisoned) then 
				StartScreenEffect('SwitchHUDIn', 300, false)
				Wait(500)
				StopScreenEffect('SwitchHUDIn')
			end 
		end 

	end
	
end
CreateThread(ScreenEffect)

RegisterNetEvent("bc:poisonedfood", function(item)
	poisoned = true 
	TriggerEvent("esx:showNotification", "Ételmérgezést kaptál!")
	Wait(30000)
	poisoned = false
end)

lib.callback.register('bc_food:accept', function(count, price)
    local conf = lib.alertDialog({
		header = 'Etetés/itatás',
		content = 'Elfogadod hogy valaki megetessen/megitasson?',
		centered = true,
		cancel = true
	})
	if conf == "confirm" then 
		return true 
	end 
	return false
end)


CreateThread(function()
	exports.ox_target:addGlobalPlayer({
		{
			name = 'etetes',
			event = 'bc_food:fooding',
			icon = 'fa-solid fa-circle',
			label = 'Etetés/Itatás',
			canInteract = function(entity)
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
               -- if stateBag.ghostShape then return false end
               -- if GetResourceState("mate-ghost") == "started" and exports["mate-ghost"]:IsGhostServerId(targetSrc) then return false end
                return true
            end
		},
	})
end)

AddEventHandler('bc_food:fooding', function(data)
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

	local elements = {}
	local itemNames = {}

	local oxitems = exports.ox_inventory:Items()
        for item, data in pairs(oxitems) do
            itemNames[item] = data.label
        end

	for k, v in pairs(Config.Items) do 
		if k and itemNames[k] then 
			local count = exports.ox_inventory:Search('count', k)
			if count > 0 then 
				elements[#elements+1] = {
					title = itemNames[k],
					onSelect = function()
						TriggerServerEvent("bc_food:giveFood", targetSrc, k)
					end 
				}
			end 
		end 
	end 

	lib.registerContext({
    id = 'kajaval',
    title = 'Étel/Ital választása',
    menu = 'kajaval',
    options = elements
  })
 
  lib.showContext('kajaval')
end)