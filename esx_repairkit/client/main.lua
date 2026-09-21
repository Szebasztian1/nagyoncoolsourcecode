ESX                 = nil
local CurrentAction = nil
local PlayerData    = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


-- ─── Halozatos jarmu-javitas ────────────────────────────────────────────────
-- A SetVehicleFixed lokalis nativ: csak azon a kliensen hat, amelyik az entitas
-- tulajdonosa. A szerelo szinte soha nem az (a jarmuben ulo jatekos az), ezert a
-- javitas nala elveszik. Emiatt maradt sertult a tank health a vezeto gepen, es
-- ment tovabb az ox_fuel benzinfolyasa (client.lua: tank health < 700) hiaba
-- javitott a szerelo. Ezert a javitast a szerveren keresztul minden kliensre
-- kikuldjuk -- a tulajdonosnal fog tenylegesen ervenyre jutni.
local function applyVehicleRepair(vehicle)
	if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end

	SetVehicleFixed(vehicle)
	SetVehicleDeformationFixed(vehicle)
	SetVehiclePetrolTankHealth(vehicle, 1000.0)
	SetVehicleBodyHealth(vehicle, 1000.0)
	SetVehicleEngineHealth(vehicle, 1000.0)
	SetVehicleUndriveable(vehicle, false)

	return true
end

function RepairVehicleNetworked(vehicle)
	if not applyVehicleRepair(vehicle) then return false end

	if NetworkGetEntityIsNetworked(vehicle) then
		TriggerServerEvent('bc_repair:fix', NetworkGetNetworkIdFromEntity(vehicle))
	end

	return true
end

exports('RepairVehicleNetworked', RepairVehicleNetworked)

RegisterNetEvent('bc_repair:doFix', function(netId)
	netId = tonumber(netId)
	if not netId or not NetworkDoesNetworkIdExist(netId) then return end

	applyVehicleRepair(NetworkGetEntityFromNetworkId(netId))
end)


repaired = false

Citizen.CreateThread(function()
	while true do
		if repaired then
			Wait(10 * 60000)
			repaired = false
		end
		Wait(1000)
	end
end)

washed = false

Citizen.CreateThread(function()
	while true do
		if washed then
			Wait(10 * 60000)
			washed = false
		end
		Wait(1000)
	end
end)


flipped = false

Citizen.CreateThread(function()
	while true do
		if flipped then
			Wait(10 * 60000)
			flipped = false
		end
		Wait(1000)
	end
end)

local mejobs = {"mechanic", "ms13", "kingmaffia", "lifthouse", "blackmamba","umechanic", "exotic", "lostmc", "ujfrakciodawe3", "themetalshop", "bennysservice", "alkaida", "exotic", "topgear", "sonsofanarchy", "umechanic"}

--print('loaded')
exports.ox_target:addGlobalVehicle({
	{
		label = 'Jármű Megszerelése',
		distance = 2.0,
		icon = 'fa-solid fa-wrench',
		items = 'ujrepairkit',
		onSelect = function(data)
			repaired = true

			local isme = false 
			for _,job in pairs(mejobs) do 
				if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == job then 
					isme = true
				end 
			end 
			if not exports["bc_tax"]:hasMechanicalClearance() and not isme then 
				repaired = false 
				return ESX.ShowNotification("Nincs szerelőengedélyed!!")
			end 
			ESX.TriggerServerCallback('esx_repairkit:timeCB', function(timeok, itemok)
				if not itemok then 
					repaired = false 
					return ESX.ShowNotification("Nincs nálad használható szerelőláda!!")
				end 
				if not timeok then 
					repaired = false 
					return ESX.ShowNotification("18 és 22 óra között nem használható a szerelőláda!")
				end 
				FreezeEntityPosition(PlayerPedId(), true)
				if lib.progressCircle({
						duration = Config.RepairTime * 1000,
						position = 'bottom',
						useWhileDead = false,
						canCancel = true,
						disable = {
							move = true,
							car = true,
						},
						anim = {
							scenario = 'PROP_HUMAN_BUM_BIN'
						},
					}) then
					repaired = false 
					ESX.TriggerServerCallback('esx_repairkit:removeKitCb', function(res)
						if not res then return end 
						RepairVehicleNetworked(data.entity)
						SetVehicleFuelLevel(data.entity, GetVehicleFuelLevel(data.entity))
						SetVehicleEngineOn(data.entity, true, true)
						ClearPedTasksImmediately(data.entity)
					end)

					--TriggerServerEvent('esx_repairkit:removeKit')
				else
					repaired = false 
					ESX.ShowNotification('Abbahagytad a javítást')
				end
				FreezeEntityPosition(PlayerPedId(), false)
			end)
		end,
		canInteract = function()
			return not repaired
		end
	},
	{
		label = 'Jármű Megszerelése prémium szerelőládával',
		distance = 2.0,
		icon = 'fa-solid fa-wrench',
		items = 'ujrepairkitpremium',
		onSelect = function(data)
			repaired = true
			local isme = false 
			for _,job in pairs(mejobs) do 
				if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == job then 
					isme = true
				end 
			end 
			if not exports["bc_tax"]:hasMechanicalClearance() and not isme then 
				repaired = false 
				return ESX.ShowNotification("Nincs szerelőengedélyed!!")
			end 
				FreezeEntityPosition(PlayerPedId(), true)
				if lib.progressCircle({
						duration = Config.RepairTime * 1000,
						position = 'bottom',
						useWhileDead = false,
						canCancel = true,
						disable = {
							move = true,
							car = true,
						},
						anim = {
							scenario = 'PROP_HUMAN_BUM_BIN'
						},
					}) then
					repaired = false 
					ESX.TriggerServerCallback('esx_repairkit:removeKitCbPrem', function(res)
						if not res then return end 
						RepairVehicleNetworked(data.entity)
						SetVehicleFuelLevel(data.entity, GetVehicleFuelLevel(data.entity))
						SetVehicleEngineOn(data.entity, true, true)
						ClearPedTasksImmediately(data.entity)
					end)

					--TriggerServerEvent('esx_repairkit:removeKit')
				else
					repaired = false 
					ESX.ShowNotification('Abbahagytad a javítást')
				end
				FreezeEntityPosition(PlayerPedId(), false)
		end,
		canInteract = function()
			return not repaired
		end
	},
	{
		label = 'Jármű Visszaborítása',
		distance = 2.0,
		icon = 'fa-solid fa-wrench',
		items = 'emelo',
		onSelect = function(data)
			flipped = true
			if lib.progressCircle({
					duration = Config.RepairTime * 1000,
					position = 'bottom',
					useWhileDead = false,
					canCancel = true,
					disable = {
						move = true,
						car = true,
					},
					anim = {
						scenario = 'PROP_HUMAN_BUM_BIN'
					},
				}) then
				flipped = false 
				ESX.TriggerServerCallback('esx_repairkit:removeemeloCb', function(res)
					if not res then return end 
					local carCoords = GetEntityRotation(data.entity, 2)
					SetEntityRotation(data.entity, carCoords[1], 0, carCoords[3], 2, true)
					SetVehicleOnGroundProperly(data.entity)
				end )
				
				--TriggerServerEvent('esx_repairkit:removeKit')
			else
				flipped = false 
				ESX.ShowNotification('Abbahagytad az emelést')
			end
		end,
		canInteract = function()
			return not repaired
		end
	},
	{
		label = 'Jármű Lemosása',
		distance = 2.0,
		icon = 'fa-solid fa-sponge',
		items = 'cleaningkit',
		onSelect = function(data)
			local price = ESX.Math.GroupDigits(Config.CleaningPrice)

			local confirm = lib.alertDialog({
				header = 'Jármű Lemosása',
				content = ('Biztos szeretnéd? A lemosás **%s $**-ba kerül.'):format(price),
				centered = true,
				cancel = true,
				labels = {
					confirm = 'Igen',
					cancel = 'Nem'
				}
			})

			if confirm ~= 'confirm' then return end

			if lib.progressCircle({
					duration = 15 * 1000,
					position = 'bottom',
					useWhileDead = false,
					canCancel = true,
					disable = {
						move = true,
						car = true,
					},
					anim = {
						scenario = 'PROP_HUMAN_BUM_BIN'
					},
				}) then
				ESX.TriggerServerCallback('esx_repairkit:removeCleaningkitCb', function(res)
					if not res then return end
					washed = true
					SetVehicleDirtLevel(data.entity, 0.0)
				end)
			else
				ESX.ShowNotification('Abbahagytad a mosást')
			end
		end,
		canInteract = function()
			return not washed
		end
	},
})
