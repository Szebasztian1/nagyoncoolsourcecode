ESX                     = nil
local Licenses          = {}
local CurrentTest       = nil
local CurrentTestType   = nil
local CurrentVehicle    = nil
local CurrentCheckPoint, DriveErrors = 0, 0
local LastCheckPoint    = -1
local CurrentBlip       = nil
local CurrentZoneType   = nil
local IsAboveSpeedLimit = false
local LastVehicleHealth = nil
MenuIsOpen              = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function DrawMissionText(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end

function StartTheoryTest()
	ESX.TriggerServerCallback('esx_dmvschool:pay', function(suc)
		if not suc then 
			TriggerEvent("esx:showNotification", "Nincs elég pénzed erre!")
			return 
		end 
		CurrentTest = 'theory'

		SendNUIMessage({
			openQuestion = true
		})

		ESX.SetTimeout(200, function()
			SetNuiFocus(true, true)
		end)
	end, Config.Prices['dmv'])

	--TriggerServerEvent('esx_dmvschool:pay', Config.Prices['dmv'])
end

function StopTheoryTest(success)
	CurrentTest = nil

	SendNUIMessage({
		openQuestion = false
	})

	SetNuiFocus(false)

	if success then
		TriggerServerEvent('esx_dmvschool:addLicense', 'dmv')
		ESX.ShowNotification(_U('passed_test'))
	else
		ESX.ShowNotification(_U('failed_test'))
	end
end

function StartDriveTest(type)

	ESX.TriggerServerCallback('esx_dmvschool:pay', function(suc)
		if not suc then 
			TriggerEvent("esx:showNotification", "Nincs elég pénzed erre!")
			return 
		end 
		
		
		ESX.Game.SpawnVehicle(Config.VehicleModels[type], Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Pos.h, function(vehicle)
			CurrentTest       = 'drive'
			CurrentTestType   = type
			CurrentCheckPoint = 0
			LastCheckPoint    = -1
			CurrentZoneType   = 'residence'
			DriveErrors       = 0
			IsAboveSpeedLimit = false
			CurrentVehicle    = vehicle
			LastVehicleHealth = GetEntityHealth(vehicle)
	
			local playerPed   = PlayerPedId()
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			SetVehicleFuelLevel(vehicle, 1000.0)
			TriggerEvent("ox_fuel:setfuel", vehicle, 100.0)
			DecorSetFloat(vehicle, "FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
			local netid = NetworkGetNetworkIdFromEntity(vehicle)
			TriggerServerEvent("esx_dmvschool:vehSpawned", netid)
		end)
	end, Config.Prices[type])
	

	--TriggerServerEvent('esx_dmvschool:pay', Config.Prices[type])
end

function StopDriveTest(success)
	if success then
		TriggerServerEvent('esx_dmvschool:addLicense', CurrentTestType)
		ESX.ShowNotification(_U('passed_test'))
	else
		ESX.ShowNotification(_U('failed_test'))
	end

	CurrentTest     = nil
	CurrentTestType = nil
end

function SetCurrentZoneType(type)
CurrentZoneType = type
end

function OpenDMVSchoolMenu()
	MenuIsOpen = true

	ESX.TriggerServerCallback('esx_license:getLicenses', function(lic)
		Licenses = lic
	end, GetPlayerServerId(PlayerId()))
	Wait(1000)
	local ownedLicenses = {}

	for i=1, #Licenses, 1 do
		ownedLicenses[Licenses[i].type] = true
	end

	local options = {}

	if not ownedLicenses['dmv'] then
		table.insert(options, {
			label = _U('theory_test'),
			price = _U('school_item', ESX.Math.GroupDigits(Config.Prices['dmv'])),
			value = 'theory_test'
		})
	end

	if ownedLicenses['dmv'] then
		if not ownedLicenses['drive'] then
			table.insert(options, {
				label = _U('road_test_car'),
				price = _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive'])),
				value = 'drive_test',
				type  = 'drive'
			})
		end

		if not ownedLicenses['drive_bike'] then
			table.insert(options, {
				label = _U('road_test_bike'),
				price = _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive_bike'])),
				value = 'drive_test',
				type  = 'drive_bike'
			})
		end

		if not ownedLicenses['drive_truck'] then
			table.insert(options, {
				label = _U('road_test_truck'),
				price = _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive_truck'])),
				value = 'drive_test',
				type  = 'drive_truck'
			})
		end
	end

	SendNUIMessage({
		openMenu = true,
		title    = _U('driving_school'),
		options  = options
	})

	SetNuiFocus(true, true)
end

RegisterNUICallback('dmvSelect', function(data, cb)
	MenuIsOpen = false
	SendNUIMessage({ openMenu = false })
	SetNuiFocus(false, false)

	if data.value == 'theory_test' then
		StartTheoryTest()
	elseif data.value == 'drive_test' then
		StartDriveTest(data.type)
	end

	cb('ok')
end)

RegisterNUICallback('dmvClose', function(data, cb)
	MenuIsOpen = false
	SendNUIMessage({ openMenu = false })
	SetNuiFocus(false, false)

	cb('ok')
end)

RegisterNUICallback('question', function(data, cb)
	SendNUIMessage({
		openSection = 'question'
	})

	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

RegisterNetEvent('esx_dmvschool:loadLicenses')
AddEventHandler('esx_dmvschool:loadLicenses', function(licenses)
	Licenses = licenses
end)

-- A blipet csak a jatekos spawnja utan (+1-2 mp) hozzuk letre: a betolteskori
-- torlodasban a blip neve elveszhet a terkep jelmagyarazatabol. A firstName-et az
-- ESX a karakter betoltesekor allitja be; a spawn es a SpawnSelector alatt a kep el
-- van sotetitve, vagy player switch / spawnSelecting fut. Az 1-2 mp resource-onkent mas.
local function WaitForSpawnBeforeBlips()
	while LocalPlayer.state.firstName == nil
		or not IsScreenFadedIn()
		or IsPlayerSwitchInProgress()
		or LocalPlayer.state.spawnSelecting == true do
		Wait(500)
	end
	Wait(1000 + GetHashKey(GetCurrentResourceName()) % 1000)
end

-- Create Blips
Citizen.CreateThread(function()
	WaitForSpawnBeforeBlips()

	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)

	SetBlipSprite (blip, 408)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.2)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('driving_school_blip'))
	EndTextCommandSetBlipName(blip)
end)

-- Register the DMV marker with this resource's own marker system (client/markers.lua).
-- No export hop and no separate poll thread: it draws, watches E and puts the help text
-- out from one loop that only exists while somebody is standing near it.
function RegisterDMVMarker()
	local zone = Config.Zones.DMVSchool

	BCMarker.Add({
		id             = 'DMVSchool',
		pos            = vector3(zone.Pos.x, zone.Pos.y, zone.Pos.z),
		typ            = zone.Type,
		scale          = vector3(zone.Size.x, zone.Size.y, zone.Size.z),
		color          = { zone.Color.r, zone.Color.g, zone.Color.b, 100 },
		streamDistance = Config.DrawDistance,
		upDown         = true,   -- mate-markers bobbed every marker regardless of the flag; kept as it looked
		canInteract    = function()
			-- called every frame while the player stands on the marker
			if MenuIsOpen then return false end
			if ESX then ESX.ShowHelpNotification(_U('press_open_menu')) end
			return true
		end,
		onInteract     = function()
			OpenDMVSchoolMenu()
		end
	})
end

Citizen.CreateThread(function()
	RegisterDMVMarker()
end)

-- Block UI
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		if CurrentTest == 'theory' then
			local playerPed = PlayerPedId()

			DisableControlAction(0, 1, true) -- LookLeftRight
			DisableControlAction(0, 2, true) -- LookUpDown
			DisablePlayerFiring(playerPed, true) -- Disable weapon firing
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		else
			Citizen.Wait(1000)
		end
	end
end)

-- Drive test
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentTest == 'drive' then
			local playerPed      = PlayerPedId()
			local coords         = GetEntityCoords(playerPed)
			local nextCheckPoint = CurrentCheckPoint + 1

			if Config.CheckPoints[nextCheckPoint] == nil then
				if DoesBlipExist(CurrentBlip) then
					RemoveBlip(CurrentBlip)
				end

				CurrentTest = nil

				ESX.ShowNotification(_U('driving_test_complete'))

				if DriveErrors < Config.MaxErrors then
					StopDriveTest(true)
				else
					StopDriveTest(false)
				end
			else

				if CurrentCheckPoint ~= LastCheckPoint then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end

					CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
					SetBlipRoute(CurrentBlip, 1)

					LastCheckPoint = CurrentCheckPoint
				end

				local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)

				if distance <= 100.0 then
					DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
				end

				if distance <= 3.0 then
					Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
					CurrentCheckPoint = CurrentCheckPoint + 1
				end
			end
		else
			-- not currently taking driver test
			Citizen.Wait(1000)
		end
	end
end)

-- Speed / Damage control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if CurrentTest == 'drive' then

			local playerPed = PlayerPedId()

			if IsPedInAnyVehicle(playerPed, false) then

				local vehicle      = GetVehiclePedIsIn(playerPed, false)
				local speed        = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
				local tooMuchSpeed = false

				for k,v in pairs(Config.SpeedLimits) do
					if CurrentZoneType == k and speed > v then
						tooMuchSpeed = true

						if not IsAboveSpeedLimit then
							DriveErrors       = DriveErrors + 1
							IsAboveSpeedLimit = true

							ESX.ShowNotification(_U('driving_too_fast', v))
							ESX.ShowNotification(_U('errors', DriveErrors, Config.MaxErrors))
						end
					end
				end

				if not tooMuchSpeed then
					IsAboveSpeedLimit = false
				end

				local health = GetEntityHealth(vehicle)
				if health < LastVehicleHealth then

					DriveErrors = DriveErrors + 1

					ESX.ShowNotification(_U('you_damaged_veh'))
					ESX.ShowNotification(_U('errors', DriveErrors, Config.MaxErrors))

					-- avoid stacking faults
					LastVehicleHealth = health
					Citizen.Wait(1500)
				end
			end
		else
			-- not currently taking driver test
			Citizen.Wait(1000)
		end
	end
end)
