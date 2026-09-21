local IsBusy = false
local spawnedVehicles, isInShopMenu = {}, false

function OpenAmbulanceActionsMenu()
	local elements = {
		{ label = _U('cloakroom'), value = 'cloakroom' }
	}

	if Config.EnablePlayerManagement and ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, { label = _U('boss_actions'), value = 'boss_actions' })
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'cloakroom' then
			OpenCloakroomMenu()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
				menu.close()
			end, { wash = false })
		end
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent("bc_amb:targetrevive", function(data)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
		local playerr
		for _, player in ipairs(GetActivePlayers()) do
			local ped = GetPlayerPed(player)
			if ped == data.entity then
				playerr = player
				break
			end
		end
		if not playerr then return end
		local serverid = GetPlayerServerId(playerr)

		IsBusy = true

		ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
			if quantity > 0 then
				local closestPlayerPed = GetPlayerPed(playerr)
				if IsPedDeadOrDying(closestPlayerPed, 1) then
					local playerPed = PlayerPedId()
					ESX.ShowNotification(_U('revive_inprogress'))
					CreateThread(function()
					local libb, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
					for i = 1, 15, 1 do
						Citizen.Wait(900)

						ESX.Streaming.RequestAnimDict(libb, function()
							TaskPlayAnim(PlayerPedId(), libb, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
						end)
					end
					end)
					Wait(10000)
					exports['rota_ammominigame']:openAmmoMinigame(function(success)
						TriggerServerEvent('esx_ambulancejob:removeItem', 'ujmedikit', "revive")
						if success then
							TriggerServerEvent('esx_ambulancejob:revive', serverid)
							ESX.ShowNotification("Sikeresen elláttad a beteget, viszont még nem biztos hogy sikeres az újraélesztés!")
						else
							--TriggerServerEvent('esx_ambulancejob:revive', serverid, true )
							ESX.ShowNotification("Sikertelen újraélesztés")
						end
					end)
					--TriggerServerEvent('esx_ambulancejob:revive', serverid)
					-- Show revive award?
					--if Config.ReviveReward > 0 then
					--	ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(playerr), Config.ReviveReward))
					--else
					--	ESX.ShowNotification(_U('revive_complete', GetPlayerName(playerr)))
					--end
				else
					ESX.ShowNotification(_U('player_not_unconscious'))
				end
			else
				ESX.ShowNotification(_U('not_enough_medikit'))
			end
			IsBusy = false
		end, 'ujmedikit')
	else
		ESX.ShowNotification('Nem vagy mentős!')
	end
end)

function OpenMobileAmbulanceActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_ambulance_actions', {
		title    = _U('ambulance'),
		align    = 'bottom-right',
		elements = {
			{ label = _U('ems_menu'), value = 'citizen_interaction' }
		}
	}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title    = _U('ems_menu_title'),
				align    = 'bottom-right',
				elements = {
					{ label = "Vizsgálat",   value = 'inspect' },
					{ label = _U('ems_menu_revive'),   value = 'revive' },
					{ label = _U('ems_menu_small'),    value = 'small' },
					{ label = _U('ems_menu_big'),      value = 'big' },
					{ label = _U('ems_menu_putincar'), value = 'put_in_vehicle' }
				}
			}, function(data, menu)
				if IsBusy then return end

				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if closestPlayer == -1 or closestDistance > 1.0 then
					ESX.ShowNotification(_U('no_players'))
				else
					if data.current.value == 'inspect' then
						exports["mate-dmgsys"]:OpenDamageMenu(GetPlayerServerId(closestPlayer))
					elseif data.current.value == 'revive' then
						IsBusy = true

						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)

								if IsPedDeadOrDying(closestPlayerPed, 1) then
									local playerPed = PlayerPedId()
									ESX.ShowNotification(_U('revive_inprogress'))
									CreateThread(function()
									local libb, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
									for i = 1, 15, 1 do
										Citizen.Wait(900)

										ESX.Streaming.RequestAnimDict(libb, function()
											TaskPlayAnim(PlayerPedId(), libb, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
										end)
									end
									end)
									Wait(10000)
									exports['rota_ammominigame']:openAmmoMinigame(function(success)
										TriggerServerEvent('esx_ambulancejob:removeItem', 'ujmedikit', "revive")
										if success then
											TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
											ESX.ShowNotification("Sikeresen elláttad a beteget, viszont még nem biztos hogy sikeres az újraélesztés!")
										else
											--TriggerServerEvent('esx_ambulancejob:revive', serverid, true )
											ESX.ShowNotification("Sikertelen újraélesztés")
										end
									end)
									-- Show revive award?
									--if Config.ReviveReward > 0 then
									--	ESX.ShowNotification(_U('revive_complete_award', GetPlayerName(closestPlayer),
									--		Config.ReviveReward))
									--else
									--	ESX.ShowNotification(_U('revive_complete', GetPlayerName(closestPlayer)))
									--end
								else
									ESX.ShowNotification(_U('player_not_unconscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end

							IsBusy = false
						end, 'ujmedikit')
					elseif data.current.value == 'small' then
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = PlayerPedId()

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_bandage'))
							end
						end, 'bandage')
					elseif data.current.value == 'big' then
						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
							if quantity > 0 then
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)

								if health > 0 then
									local playerPed = PlayerPedId()

									IsBusy = true
									ESX.ShowNotification(_U('heal_inprogress'))
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_ambulancejob:removeItem', 'ujmedikit')
									TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
									ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
									IsBusy = false
								else
									ESX.ShowNotification(_U('player_not_conscious'))
								end
							else
								ESX.ShowNotification(_U('not_enough_medikit'))
							end
						end, 'ujmedikit')
					elseif data.current.value == 'put_in_vehicle' then
						TriggerServerEvent('esx_ambulancejob:putInVehicle', GetPlayerServerId(closestPlayer))
					end
				end
			end, function(data, menu)
				menu.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end
RegisterNetEvent("bc_amb:emenu", function()
	OpenMobileAmbulanceActionsMenu()
end)


function FastTravel(coords, heading)
	local playerPed = PlayerPedId()

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Citizen.Wait(500)
	end

	ESX.Game.Teleport(playerPed, coords, function()
		DoScreenFadeIn(800)

		if heading then
			SetEntityHeading(playerPed, heading)
		end
	end)
end

-- A markereket ez a resource sajat rendszere rajzolja (client/markers.lua), a
-- `mate-markers` helyett. Az a felirat es a "kileptunk a markerbol" figyeles ket
-- kulon poll-szalat kivant (750 / 500 ms), amik minden korben resource-hatart
-- leptek at; itt mindketto ugyanabbol a rajzolo szalbol jon, azonnal.
BCMarker.ShowLabel = function(text)
	ESX.ShowHelpNotification(text)
end

---@return nil
local function RegisterMarkers()
	for hospitalNum, hospital in pairs(Config.Hospitals) do
		local m <const> = Config.Marker

		for k, v in ipairs(hospital.AmbulanceActions) do
			BCMarker.Add({
				id             = 'amb_action_' .. hospitalNum .. '_' .. k,
				pos            = v,
				typ            = m.type,
				scale          = vector3(m.x, m.y, m.z),
				color          = { m.r, m.g, m.b, m.a },
				streamDistance = Config.DrawDistance,
				rotate         = m.rotate,
				upDown         = true,
				label          = _U('actions_prompt'),
				canInteract    = function() return ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' end,
				onInteract     = function() OpenAmbulanceActionsMenu() end,
			})
		end

		for k, v in ipairs(hospital.Pharmacies) do
			BCMarker.Add({
				id             = 'pharmacy_' .. hospitalNum .. '_' .. k,
				pos            = v,
				typ            = m.type,
				scale          = vector3(m.x, m.y, m.z),
				color          = { m.r, m.g, m.b, m.a },
				streamDistance = Config.DrawDistance,
				rotate         = m.rotate,
				upDown         = true,
				label          = _U('open_pharmacy'),
				canInteract    = function() return ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' end,
				onInteract     = function() OpenPharmacyMenu() end,
			})
		end

		for k, v in ipairs(hospital.Vehicles) do
			local vm <const> = v.Marker
			BCMarker.Add({
				id             = 'vehicle_' .. hospitalNum .. '_' .. k,
				pos            = v.Spawner,
				typ            = vm.type,
				scale          = vector3(vm.x, vm.y, vm.z),
				color          = { vm.r, vm.g, vm.b, vm.a },
				streamDistance = Config.DrawDistance,
				rotate         = vm.rotate,
				upDown         = true,
				label          = _U('garage_prompt'),
				canInteract    = function() return ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' end,
				onInteract     = function() OpenVehicleSpawnerMenu(hospitalNum, k) end,
			})
		end

		for k, v in ipairs(hospital.Helicopters) do
			local hm <const> = v.Marker
			BCMarker.Add({
				id             = 'helicopter_' .. hospitalNum .. '_' .. k,
				pos            = v.Spawner,
				typ            = hm.type,
				scale          = vector3(hm.x, hm.y, hm.z),
				color          = { hm.r, hm.g, hm.b, hm.a },
				streamDistance = Config.DrawDistance,
				rotate         = hm.rotate,
				upDown         = true,
				label          = _U('helicopter_prompt'),
				canInteract    = function() return ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' end,
				onInteract     = function() OpenHelicopterSpawnerMenu(hospitalNum, k) end,
			})
		end

		for k, v in ipairs(hospital.FastTravels) do
			local fm <const> = v.Marker
			BCMarker.Add({
				id             = 'fast_travel_' .. hospitalNum .. '_' .. k,
				pos            = v.From,
				typ            = fm.type,
				scale          = vector3(fm.x, fm.y, fm.z),
				color          = { fm.r, fm.g, fm.b, fm.a },
				streamDistance = Config.DrawDistance,
				rotate         = fm.rotate,
				upDown         = true,
				onInteract     = function() FastTravel(v.To.coords, v.To.heading) end,
			})
		end

		for k, v in ipairs(hospital.FastTravelsPrompt) do
			local pm <const> = v.Marker
			BCMarker.Add({
				id             = 'fast_travel_prompt_' .. hospitalNum .. '_' .. k,
				pos            = v.From,
				typ            = pm.type,
				scale          = vector3(pm.x, pm.y, pm.z),
				color          = { pm.r, pm.g, pm.b, pm.a },
				streamDistance = Config.DrawDistance,
				rotate         = pm.rotate,
				upDown         = true,
				label          = v.Prompt,
				canInteract    = function() return ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' end,
				onInteract     = function() FastTravel(v.To.coords, v.To.heading) end,
			})
		end
	end
end

Citizen.CreateThread(function()
	RegisterMarkers()
end)

-- A feliratot a marker rendszer rajzolo szala teszi ki (`label`), ezert az a szal, ami
-- 750 ms-enkent kerdezte le a mate-markerstol, hogy allunk-e markerben, megszunt.

local isWatcherRunning = false

local function StartAmbulanceWatcher()
	if isWatcherRunning then return end
	isWatcherRunning = true

	Citizen.CreateThread(function()
		local f6WasPressed = false
		local wasInMarker  = false

		while ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' do
			Citizen.Wait(500)

			local inMarker = BCMarker.Current() ~= nil

			if wasInMarker and not inMarker then
				if not isInShopMenu then
					ESX.UI.Menu.CloseAll()
				end
			end

			wasInMarker = inMarker

			--if not IsDead then
			--	local f6IsDown = IsControlPressed(0, Keys['F6'])
			--	if f6WasPressed and not f6IsDown then
			--		OpenMobileAmbulanceActionsMenu()
			--	end
			--	f6WasPressed = f6IsDown
			--end
		end

		isWatcherRunning = false
	end)
end

AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
		StartAmbulanceWatcher()
	end
end)

AddEventHandler('esx:setJob', function(job, lastJob)
	if job.name == 'ambulance' then
		StartAmbulanceWatcher()
	end
end)

RegisterNetEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i = maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
			end
		end
	end
end)

function OpenCloakroomMenu()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = _U('cloakroom'),
		align    = 'bottom-right',
		elements = {
			{ label = _U('ems_clothes_civil'), value = 'citizen_wear' },
			{ label = _U('ems_clothes_ems'),   value = 'ambulance_wear' },
		}
	}, function(data, menu)
		if data.current.value == 'citizen_wear' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'ambulance_wear' then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				end
			end)
		end

		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function OpenVehicleSpawnerMenu(hospital, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local elements = {
		{ label = _U('garage_storeditem'), action = 'garage' },
		{ label = _U('garage_storeitem'),  action = 'store_garage' },
		{ label = _U('garage_buyitem'),    action = 'buy_vehicle' }
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle', {
		title    = _U('garage_title'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.action == 'buy_vehicle' then
			local shopCoords = Config.Hospitals[hospital].Vehicles[partNum].InsideShop
			local shopElements = {}

			local authorizedVehicles = Config.AuthorizedVehicles[ESX.PlayerData.job.grade_name]

			if #authorizedVehicles > 0 then
				for k, vehicle in ipairs(authorizedVehicles) do
					table.insert(shopElements, {
						label = ('%s - <span style="color:green;">%s</span>'):format(vehicle.label,
							_U('shop_item', ESX.Math.GroupDigits(vehicle.price))),
						name  = vehicle.label,
						model = vehicle.model,
						price = vehicle.price,
						type  = 'car'
					})
				end
			else
				return
			end

			OpenShopMenu(shopElements, playerCoords, shopCoords)
		elseif data.current.action == 'garage' then
			local garage = {}

			ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					for k, v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName,
							props.plate)

						if v.stored then
							label = label .. ('<span style="color:green;">%s</span>'):format(_U('garage_stored'))
						else
							label = label .. ('<span style="color:darkred;">%s</span>'):format(_U('garage_notstored'))
						end

						table.insert(garage, {
							label = label,
							stored = v.stored,
							model = props.model,
							vehicleProps = props
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_garage', {
						title    = _U('garage_title'),
						align    = 'bottom-right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(hospital, 'Vehicles', partNum)

							if foundSpawn then
								menu2.close()

								ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading,
									function(vehicle)
										ESX.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

										TriggerServerEvent('esx_vehicleshop:setJobVehicleState',
											data2.current.vehicleProps.plate, false)
										ESX.ShowNotification(_U('garage_released'))
									end)
							end
						else
							ESX.ShowNotification(_U('garage_notavailable'))
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				else
					ESX.ShowNotification(_U('garage_empty'))
				end
			end, 'car')
		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function StoreNearbyVehicle(playerCoords)
	local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords, 30.0), {}

	if #vehicles > 0 then
		for k, v in ipairs(vehicles) do
			-- Make sure the vehicle we're saving is empty, or else it wont be deleted
			if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				table.insert(vehiclePlates, {
					vehicle = v,
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
				})
			end
		end
	else
		ESX.ShowNotification(_U('garage_store_nearby'))
		return
	end

	ESX.TriggerServerCallback('esx_ambulancejob:storeNearbyVehicle', function(storeSuccess, foundNum)
		if storeSuccess then
			local vehicleId = vehiclePlates[foundNum]
			local attempts = 0
			ESX.Game.DeleteVehicle(vehicleId.vehicle)
			IsBusy = true

			Citizen.CreateThread(function()
				while IsBusy do
					Citizen.Wait(0)
					drawLoadingText(_U('garage_storing'), 255, 255, 255, 255)
				end
			end)

			-- Workaround for vehicle not deleting when other players are near it.
			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1

				-- Give up
				if attempts > 30 then
					break
				end

				vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for k, v in ipairs(vehicles) do
						if ESX.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							ESX.Game.DeleteVehicle(v)
							break
						end
					end
				end
			end

			IsBusy = false
			ESX.ShowNotification(_U('garage_has_stored'))
		else
			ESX.ShowNotification(_U('garage_has_notstored'))
		end
	end, vehiclePlates)
end

function GetAvailableVehicleSpawnPoint(hospital, part, partNum)
	local spawnPoints = Config.Hospitals[hospital][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i = 1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		ESX.ShowNotification(_U('garage_blocked'))
		return false
	end
end

function OpenHelicopterSpawnerMenu(hospital, partNum)
	local playerCoords = GetEntityCoords(PlayerPedId())
	ESX.PlayerData = ESX.GetPlayerData()
	local elements = {
		{ label = _U('helicopter_garage'), action = 'garage' },
		{ label = _U('helicopter_store'),  action = 'store_garage' },
		{ label = _U('helicopter_buy'),    action = 'buy_helicopter' }
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'helicopter_spawner', {
		title    = _U('helicopter_title'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		if data.current.action == 'buy_helicopter' then
			local shopCoords = Config.Hospitals[hospital].Helicopters[partNum].InsideShop
			local shopElements = {}

			local authorizedHelicopters = Config.AuthorizedHelicopters[ESX.PlayerData.job.grade_name]

			if #authorizedHelicopters > 0 then
				for k, helicopter in ipairs(authorizedHelicopters) do
					table.insert(shopElements, {
						label = ('%s - <span style="color:green;">%s</span>'):format(helicopter.label,
							_U('shop_item', ESX.Math.GroupDigits(helicopter.price))),
						name  = helicopter.label,
						model = helicopter.model,
						price = helicopter.price,
						type  = 'helicopter'
					})
				end
			else
				ESX.ShowNotification(_U('helicopter_notauthorized'))
				return
			end

			OpenShopMenu(shopElements, playerCoords, shopCoords)
		elseif data.current.action == 'garage' then
			local garage = {}

			ESX.TriggerServerCallback('esx_vehicleshop:retrieveJobVehicles', function(jobVehicles)
				if #jobVehicles > 0 then
					for k, v in ipairs(jobVehicles) do
						local props = json.decode(v.vehicle)
						local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
						local label = ('%s - <span style="color:darkgoldenrod;">%s</span>: '):format(vehicleName,
							props.plate)

						if v.stored then
							label = label .. ('<span style="color:green;">%s</span>'):format(_U('garage_stored'))
						else
							label = label .. ('<span style="color:darkred;">%s</span>'):format(_U('garage_notstored'))
						end

						table.insert(garage, {
							label = label,
							stored = v.stored,
							model = props.model,
							vehicleProps = props
						})
					end

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'helicopter_garage', {
						title    = _U('helicopter_garage_title'),
						align    = 'bottom-right',
						elements = garage
					}, function(data2, menu2)
						if data2.current.stored then
							local foundSpawn, spawnPoint = GetAvailableVehicleSpawnPoint(hospital, 'Helicopters', partNum)

							if foundSpawn then
								menu2.close()

								ESX.Game.SpawnVehicle(data2.current.model, spawnPoint.coords, spawnPoint.heading,
									function(vehicle)
										ESX.Game.SetVehicleProperties(vehicle, data2.current.vehicleProps)

										TriggerServerEvent('esx_vehicleshop:setJobVehicleState',
											data2.current.vehicleProps.plate, false)
										ESX.ShowNotification(_U('garage_released'))
									end)
							end
						else
							ESX.ShowNotification(_U('garage_notavailable'))
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				else
					ESX.ShowNotification(_U('garage_empty'))
				end
			end, 'helicopter')
		elseif data.current.action == 'store_garage' then
			StoreNearbyVehicle(playerCoords)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenShopMenu(elements, restoreCoords, shopCoords)
	local playerPed = PlayerPedId()
	isInShopMenu = true

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = _U('vehicleshop_title'),
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm', {
			title    = _U('vehicleshop_confirm', data.current.name, data.current.price),
			align    = 'bottom-right',
			elements = {
				{ label = _U('confirm_no'),  value = 'no' },
				{ label = _U('confirm_yes'), value = 'yes' }
			}
		}, function(data2, menu2)
			if data2.current.value == 'yes' then
				local newPlate = exports['villamos_vehshop']:GeneratePlate()
				local vehicle  = GetVehiclePedIsIn(playerPed, false)
				local props    = ESX.Game.GetVehicleProperties(vehicle)
				props.plate    = newPlate

				ESX.TriggerServerCallback('esx_ambulancejob:buyJobVehicle', function(bought)
					if bought then
						ESX.ShowNotification(_U('vehicleshop_bought', data.current.name,
							ESX.Math.GroupDigits(data.current.price)))

						isInShopMenu = false
						ESX.UI.Menu.CloseAll()

						DeleteSpawnedVehicles()
						FreezeEntityPosition(playerPed, false)
						SetEntityVisible(playerPed, true)

						ESX.Game.Teleport(playerPed, restoreCoords)
					else
						ESX.ShowNotification(_U('vehicleshop_money'))
						menu2.close()
					end
				end, props, data.current.type)
			else
				menu2.close()
			end
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		isInShopMenu = false
		ESX.UI.Menu.CloseAll()

		DeleteSpawnedVehicles()
		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)

		ESX.Game.Teleport(playerPed, restoreCoords)
	end, function(data, menu)
		DeleteSpawnedVehicles()

		WaitForVehicleToLoad(data.current.model)
		ESX.Game.SpawnLocalVehicle(data.current.model, shopCoords, 0.0, function(vehicle)
			table.insert(spawnedVehicles, vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
		end)
	end)

	WaitForVehicleToLoad(elements[1].model)
	ESX.Game.SpawnLocalVehicle(elements[1].model, shopCoords, 0.0, function(vehicle)
		table.insert(spawnedVehicles, vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isInShopMenu then
			DisableControlAction(0, 75, true) -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)

			DisableControlAction(0, Keys['TOP'], true)
			DisableControlAction(0, Keys['DOWN'], true)
			DisableControlAction(0, Keys['LEFT'], true)
			DisableControlAction(0, Keys['RIGHT'], true)
			DisableControlAction(0, 176, true) -- ENTER key
			DisableControlAction(0, Keys['BACKSPACE'], true)

			drawLoadingText(_U('vehicleshop_awaiting_model'), 255, 255, 255, 255)
		end
	end
end

function drawLoadingText(text, red, green, blue, alpha)
	SetTextFont(4)
	SetTextScale(0.0, 0.5)
	SetTextColour(red, green, blue, alpha)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)

	BeginTextCommandDisplayText("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(0.5, 0.5)
end

function OpenPharmacyMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pharmacy', {
		title    = _U('pharmacy_menu_title'),
		align    = 'bottom-right',
		elements = {
			{ label = _U('pharmacy_take', _U('ujmedikit')), value = 'ujmedikit' },
			{ label = _U('pharmacy_take', _U('bandage')),   value = 'bandage' }
		}
	}, function(data, menu)
		TriggerServerEvent('esx_ambulancejob:giveItem', data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

function WarpPedInClosestVehicle(ped)
	local coords = GetEntityCoords(ped)

	local vehicle, distance = ESX.Game.GetClosestVehicle(coords)

	if distance ~= -1 and distance <= 5.0 then
		local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

		for i = maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat then
			TaskWarpPedIntoVehicle(ped, vehicle, freeSeat)
		end
	else
		ESX.ShowNotification(_U('no_vehicles'))
	end
end

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(healType, quiet)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
		SetEntityHealth(playerPed, newHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	if not quiet then
		ESX.ShowNotification(_U('healed'))
	end
end)

RegisterNetEvent('esx_ambulancejob:openbandage')
AddEventHandler('esx_ambulancejob:openbandage', function()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bodydamage', {
		title    = "Testkötszer használata",
		align    = 'bottom-right',
		elements = {
			{ label = "Magadon", value = 's' },
			{ label = "Máson",   value = 'o' }
		}
	}, function(data, menu)
		if data.current.value == 's' then
			ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
				if quantity > 0 then
					local closestPlayerPed = PlayerPedId()
					local health = GetEntityHealth(closestPlayerPed)

					if health > 0 then
						local playerPed = PlayerPedId()

						IsBusy = true
						ESX.ShowNotification(_U('heal_inprogress'))
						TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
						Citizen.Wait(10000)
						ClearPedTasks(playerPed)

						TriggerServerEvent('esx_ambulancejob:removeItem', 'bodybandage')
						TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(PlayerId()), 'small')
						ESX.ShowNotification("Elahsználtál magadon egy testkötszert")
						IsBusy = false
					else
						ESX.ShowNotification(_U('player_not_conscious'))
					end
				else
					ESX.ShowNotification(_U('not_enough_bandage'))
				end
			end, 'bodybandage')
		else
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if closestPlayer == -1 or closestDistance > 1.0 then
				ESX.ShowNotification(_U('no_players'))
			else
				ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
					if quantity > 0 then
						local closestPlayerPed = GetPlayerPed(closestPlayer)
						local health = GetEntityHealth(closestPlayerPed)

						if health > 0 then
							local playerPed = PlayerPedId()

							IsBusy = true
							ESX.ShowNotification(_U('heal_inprogress'))
							TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
							Citizen.Wait(10000)
							ClearPedTasks(playerPed)

							TriggerServerEvent('esx_ambulancejob:removeItem', 'bodybandage')
							TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
							ESX.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
							IsBusy = false
						else
							ESX.ShowNotification(_U('player_not_conscious'))
						end
					else
						ESX.ShowNotification(_U('not_enough_bandage'))
					end
				end, 'bodybandage')
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end)
