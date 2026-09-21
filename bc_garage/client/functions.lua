function SetVehicleData(vehicle, data)
    ESX.Game.SetVehicleProperties(vehicle, data)
   -- if data.damages and type(data.damages) == "table" then 
   --     SetVehicleDeformation(vehicle, data.damages)
   -- end 
	--[[if data.damagedwindows and type(data.damagedwindows) == "table" then 
		for _, windowid in pairs(data.damagedwindows) do 
			SmashVehicleWindow(vehicle, windowid)
		end 
	end ]]

	if data.tyrehealts and type(data.tyrehealts) == "table" then 
		for tyreid, health in pairs(data.tyrehealts) do 
			SetTyreHealth(vehicle, tyreid, health)
		end 
	end 

	if data.fuelLevel then
		SetVehicleFuelLevel(vehicle, data.fuelLevel + 0.0)
		TriggerEvent("ox_fuel:setfuel", vehicle, data.fuelLevel + 0.0)
		DecorSetFloat(vehicle, "FUEL_LEVEL", data.fuelLevel + 0.0)
		if GetResourceState("rcore_fuel") == "started" then 
			exports["rcore_fuel"]:SetFuel(vehicle, data.fuelLevel + 0.0)
		end 
	end 
	--[[if data.fullydamagedtyres and type(data.fullydamagedtyres) == "table" then 
		for _, tyreid in pairs(data.fullydamagedtyres) do 
			SetVehicleTyreBurst(vehicle, tyreid, true, 1000)
		end 
	end
	if data.damageddoors and type(data.damageddoors) == "table" then 
		for _, doorid in pairs(data.damageddoors) do 
			SetVehicleDoorBroken(vehicle, doorid, true)
		end 
	end  ]]
end 
AddEventHandler("bc:setvehdata", function(vehicle, data)
	SetVehicleData(vehicle, data)
end)

function GetVehicleData(vehicle)
    local data = ESX.Game.GetVehicleProperties(vehicle)
    --local damages = GetVehicleDeformation(vehicle)
    --data.damages = damages 
	local damagedwindows = {}
	for windowid = 0, 7 do
		if IsVehicleWindowIntact(vehicle, windowid) then
			damagedwindows[#damagedwindows+1] = windowid
		end
	end
	data.damagedwindows = damagedwindows 
	local fullydamagedtyres = {}
	for tyreid = 0, 7 do
		if DoesVehicleTyreExist(vehicle, tyreid) and IsVehicleTyreBurst(vehicle, tyreid, true) then
			fullydamagedtyres[#fullydamagedtyres+1] = tyreid
		end
	end
	data.fullydamagedtyres = fullydamagedtyres 
	local tyrehealts = {}
	for tyreid = 0, 7 do
		if DoesVehicleTyreExist(vehicle, tyreid) then
			tyrehealts[tyreid] = GetTyreHealth(vehicle, tyreid)
		end
	end
	data.tyrehealts = tyrehealts 
	local damageddoors = {}
	for doorid = 0, 5 do
		if GetIsDoorValid(vehicle, doorid) and IsVehicleDoorDamaged(vehicle, doorid) then
			damageddoors[#damageddoors + 1] = doorid
		end
	end
	data.damageddoors = damageddoors 
    return data 
end 


function GetVehicleDeformation(vehicle)
	-- check vehicle size and pre-calc values for offsets
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = (max.x - min.x) * 0.5
	local Y = (max.y - min.y) * 0.5
	local Z = (max.z - min.z) * 0.5
	local halfY = Y * 0.5

	-- offsets for deformation check
	local positions = {
		vector3(max.x, max.y, 0.0),
		vector3(min.x, max.y, 0.0),
		vector3(min.x, min.y, 0.0),
		vector3(max.x, min.y, 0.0),

		vector3(max.x*0.5, max.y, 0.0),
		vector3(min.x*0.5, max.y, 0.0),
		vector3(max.x*0.5, min.y, 0.0),
		vector3(min.x*0.5, min.y, 0.0),

		vector3(max.x, max.y*0.5, 0.0),
		vector3(min.x, max.y*0.5, 0.0),
		vector3(max.x, min.y*0.5, 0.0),
		vector3(min.x, min.y*0.5, 0.0),

		vector3(max.x, 0.0, 0.0),
		vector3(min.x, 0.0, 0.0),
		vector3(0.0, min.y, 0.0),
		vector3(0.0, min.y, 0.0),


		vector3(max.x, max.y, min.z),
		vector3(min.x, max.y, min.z),
		vector3(min.x, min.y, min.z),
		vector3(max.x, min.y, min.z),

		vector3(max.x*0.5, max.y, min.z),
		vector3(min.x*0.5, max.y, min.z),
		vector3(max.x*0.5, min.y, min.z),
		vector3(min.x*0.5, min.y, min.z),

		vector3(max.x, max.y*0.5, min.z),
		vector3(min.x, max.y*0.5, min.z),
		vector3(max.x, min.y*0.5, min.z),
		vector3(min.x, min.y*0.5, min.z),

		vector3(max.x, 0.0, min.z),
		vector3(min.x, 0.0, min.z),
		vector3(0.0, min.y, min.z),
		vector3(0.0, min.y, min.z),


		vector3(max.x, max.y, max.z),
		vector3(min.x, max.y, max.z),
		vector3(min.x, min.y, max.z),
		vector3(max.x, min.y, max.z),

		vector3(max.x*0.5, max.y, max.z),
		vector3(min.x*0.5, max.y, max.z),
		vector3(max.x*0.5, min.y, max.z),
		vector3(min.x*0.5, min.y, max.z),

		vector3(max.x, max.y*0.5, max.z),
		vector3(min.x, max.y*0.5, max.z),
		vector3(max.x, min.y*0.5, max.z),
		vector3(min.x, min.y*0.5, max.z),

		vector3(max.x, 0.0, max.z),
		vector3(min.x, 0.0, max.z),
		vector3(0.0, min.y, max.z),
		vector3(0.0, min.y, max.z),


		vector3(max.x*0.5, min.y*0.5, max.z),
		vector3(max.x*0.5, min.y*0.5, max.z),
		vector3(min.x*0.5, max.y*0.5, max.z),
		vector3(max.x*0.5, max.y*0.5, max.z),
		vector3(0.0, 0.0, max.z),


		vector3(max.x*0.5, min.y*0.5, min.z),
		vector3(max.x*0.5, min.y*0.5, min.z),
		vector3(min.x*0.5, max.y*0.5, min.z),
		vector3(max.x*0.5, max.y*0.5, min.z),
		vector3(0.0, 0.0, min.z),
		
		--[[vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),

		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),

		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),


		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),

		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),

		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),


		vector3(-X, 0.0,  0.0),
		vector3(-X, 0.0,  Z),

		vector3(0.0, 0.0,  0.0),
		vector3(0.0, 0.0,  Z),

		vector3(X, 0.0,  0.0),
		vector3(X, 0.0,  Z),


		vector3(-X, -halfY,  0.0),
		vector3(-X, -halfY,  Z),

		vector3(0.0, -halfY,  0.0),
		vector3(0.0, -halfY,  Z),

		vector3(X, -halfY,  0.0),
		vector3(X, -halfY,  Z),


		vector3(-X, -Y,  0.0),
		vector3(-X, -Y,  Z),

		vector3(0.0, -Y,  0.0),
		vector3(0.0, -Y,  Z),

		vector3(X, -Y,  0.0),
		vector3(X, -Y,  Z),]]
	}

	-- get deformation from vehicle
	local deformationPoints = {}
	for i, pos in ipairs(positions) do
		-- translate damage from vector3 to a float
		local dmg = #(GetVehicleDeformationAtPos(vehicle, pos))
		print('check', json.encode(pos))
		if (dmg > 0.03) then
			print('found', json.encode(pos), dmg)
			table.insert(deformationPoints, { pos, dmg })
		end
	end

	return deformationPoints
end

-- sets deformation on a vehicle
function SetVehicleDeformation(vehicle, deformationPoints)

	Citizen.CreateThread(function()
		-- set radius and damage multiplier
		local min, max = GetModelDimensions(GetEntityModel(vehicle))
		local radius = #(max - min) * 30.0			-- might need some more experimentation
		local damageMult = #(max - min) * 40.0		-- might need some more experimentation
        
        local printMsg = false

		for i, def in ipairs(deformationPoints) do
			def[1] = vector3(def[1].x, def[1].y, def[1].z)
		end

		-- iterate over all deformation points and check if more than one application is necessary
		-- looping is necessary for most vehicles that have a really bad damage model or take a lot of damage (e.g. neon, phantom3)
		local deform = true
		local iteration = 0
		while (deform and iteration < 50) do
			if (not DoesEntityExist(vehicle)) then
				return
			end

			deform = false

			-- apply deformation if necessary
			for i, def in ipairs(deformationPoints) do
				if (#(GetVehicleDeformationAtPos(vehicle, def[1])) < def[2]) then
					print("apply", json.encode(def[1]), def[2])
					SetVehicleDamage(
						vehicle, 
						def[1] * 2.0, 
						def[2] * damageMult, 
						radius, 
						true
					)

					deform = true
				end
			end

			iteration = iteration + 1

			Citizen.Wait(100)
		end

	end)
end

function round(num, numDecimalPlaces)
	local mult = 100^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

local TRACKERS = {}
function CreateTracker(plate)
	if TRACKERS[plate] then 
		return false 
	end 
	local c = GetVehicleCoords(plate)
	if not c then 
		return false 
	end 
	TRACKERS[plate] = AddBlipForCoord(c.x, c.y, c.z)
	SetUpBlip(TRACKERS[plate], plate.." ("..GetClockHours()..":"..GetClockMinutes()..")")

	CreateThread(function()
		while true do 
			Wait(60000*5)
			c = GetVehicleCoords(plate)
			if not c then 
				RemoveBlip(TRACKERS[plate])
				TRACKERS[plate] = nil 
				return  
			end 

			SetBlipCoords(TRACKERS[plate], c.x, c.y, c.z)
			SetUpBlip(TRACKERS[plate], plate.." ("..GetClockHours()..":"..GetClockMinutes()..")")
		end 
	end)
end 

function GetVehicleCoords(plate)
	plate = ESX.Math.Trim(plate)

	local vehList = GetGamePool('CVehicle')
	for k,v in pairs(vehList) do
		if DoesEntityExist(v) then
            local plt = ESX.Math.Trim(GetVehicleNumberPlateText(v))
            if plt == plate then 
				return GetEntityCoords(v)
            end 
        end 
    end

	local ret = nil 
	ESX.TriggerServerCallback("villamos_garage:getCoordsByPlate", function(d)
		ret = d
	end, plate)
	while ret == nil do 
		Wait(100)
	end 
	return ret 
end 

function SetUpBlip(blip, name)
    SetBlipAsShortRange(blip, false)
    SetBlipSprite(blip, 225)
	SetBlipDisplay(blip, 2)
	SetBlipScale(blip, 0.8)
	SetBlipColour(blip, 5)
    SetBlipFlashes(blip, false)
    SetBlipShowCone(blip, true)
    SetBlipCategory(blip, 7)
	BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
	EndTextCommandSetBlipName(blip)
end 

function GetAvailableVehicleSpawnPoint(coords)
	local spawnPoints = {coords, coords+vector4(2.0, 0.0, 0.0, 0.0), coords+vector4(-2.0, 0.0, 0.0, 0.0), coords+vector4(0.0, 2.0, 0.0, 0.0), coords+vector4(0.0, -2.0, 0.0, 0.0)}
	local foundSpawnPoint = nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(vector3(spawnPoints[i].x, spawnPoints[i].y, spawnPoints[i].z), 1.0) then
			foundSpawnPoint = spawnPoints[i]
			break
		end
	end

	if foundSpawnPoint then
		return foundSpawnPoint
	else
		return coords+vector4(0.0, 0.0, 1.5, 0.0)
	end
end