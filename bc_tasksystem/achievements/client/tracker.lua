-- Sub-flow: samples the player's movement every Config.Tracker.Interval and
-- reports it to the server in one small event a minute, or earlier when the
-- collected distance completes a goal. The server clamps everything again.

-- GTA vehicle classes that are not plain driving. false = not counted at all (trains).
local CLASS_MODE = { [8] = 'moto', [13] = 'bicycle', [14] = 'boat', [15] = 'heli', [16] = 'plane', [21] = false }
local CLASS_SUBSET = { [9] = 'offroad', [10] = 'truck', [18] = 'emergency', [20] = 'truck' }

local pending = {}      -- [stat] = metres or count collected since the last report
local records = {}      -- [stat] = best value since the last report
local earlyGoals = {}   -- [stat] = goal an early report was already spent on
local lastCoords = nil
local lastSampleAt = 0
local lastReportAt = 0
local nextDiscoverAt = 0
local chuteOpen = false
local started = false

local function Collect(stat, amount)
	pending[stat] = (pending[stat] or 0) + amount
end

local function Best(stat, value)
	if value > (records[stat] or 0) then records[stat] = value end
end

-- Farther than the fastest believable speed = teleport, respawn or spawn menu: not a trip.
local function Plausible(stat, moved, dt)
	return moved <= Config.Stats[stat].rate * Config.Sync.Tolerance * dt
end

local function IsNight()
	local hour = GetClockHours()
	return hour >= Config.Tracker.NightHours.from or hour < Config.Tracker.NightHours.to
end

local function IsRaining()
	return GetRainLevel() > Config.Tracker.RainLevel
end

-- Samples ----------------------------------------------------------------------------------------

local function SampleVehicle(vehicle, moved, dt)
	local class = GetVehicleClass(vehicle)
	local mode = CLASS_MODE[class]
	if mode == false then return end
	mode = mode or 'drive'

	local driver = cache.seat == -1
	local stat = driver and mode or 'passenger'
	if not Plausible(stat, moved, dt) then return end

	Collect(stat, moved)
	if not driver or mode ~= 'drive' then return end

	local subset = CLASS_SUBSET[class]
	if subset then Collect(subset, moved) end
	if IsNight() then Collect('drive_night', moved) end

	-- Only with all wheels down: a car rolling off a cliff is not a speed record.
	if IsVehicleOnAllWheels(vehicle) and not IsEntityAttached(vehicle) then
		Best('topspeed', GetEntitySpeed(vehicle) * 3.6)
	end
end

local function SampleOnFoot(ped, coords, moved, dt)
	local chute = GetPedParachuteState(ped)
	local open = chute == 1 or chute == 2
	if open and not chuteOpen then Collect('parachute', 1) end
	chuteOpen = open

	if chute > 0 or IsPedInParachuteFreeFall(ped) or IsPedFalling(ped) or IsPedRagdoll(ped) then return end

	if IsPedSwimming(ped) then
		if Plausible('swim', moved, dt) then Collect('swim', moved) end
		if IsPedSwimmingUnderWater(ped) then
			-- The probe starts above the surface and looks down; 100 m covers every dive we reward.
			local found, surface = GetWaterHeight(coords.x, coords.y, coords.z + 100.0)
			if found then Best('depth', surface - coords.z) end
		end
		return
	end

	if moved < 0.05 or not Plausible('walk', moved, dt) then return end

	Collect('walk', moved)
	if IsRaining() then Collect('walk_rain', moved) end
end

-- Landmarks ----------------------------------------------------------------------------------------

local function ConditionsMet(landmark)
	if landmark.hours then
		local hour = GetClockHours()
		if hour < landmark.hours[1] or hour >= landmark.hours[2] then return false end
	end
	if landmark.rain and not IsRaining() then return false end
	return true
end

local function CheckLandmarks(coords, onFoot)
	local timer = GetGameTimer()
	if timer < nextDiscoverAt then return end

	for _, landmark in ipairs(Config.Landmarks) do
		if not IsLandmarkKnown(landmark)
			and (not landmark.onFoot or onFoot)
			and (not landmark.minZ or coords.z >= landmark.minZ) then
			local dx, dy = coords.x - landmark.coords.x, coords.y - landmark.coords.y
			if dx * dx + dy * dy <= landmark.radius * landmark.radius and ConditionsMet(landmark) then
				-- One per server cooldown, so two landmarks on the same spot both get through.
				nextDiscoverAt = timer + Config.Discover.Cooldown + 500
				MarkLandmarkKnown(landmark)
				TriggerServerEvent('Achievements:Server:Discover', landmark.id)
				return
			end
		end
	end
end

-- Reports ---------------------------------------------------------------------------------------------

local function WouldReachGoal()
	for stat, amount in pairs(pending) do
		local goal = GetNextGoal(stat)
		if goal and earlyGoals[stat] ~= goal and GetLocalStat(stat) + amount >= goal then return stat, goal end
	end
	for stat, value in pairs(records) do
		local goal = GetNextGoal(stat)
		if goal and earlyGoals[stat] ~= goal and value >= goal then return stat, goal end
	end
end

local function Report()
	lastReportAt = GetGameTimer()

	local report = {}
	local any = false

	-- Whole metres travel, the fraction waits for the next report.
	for stat, amount in pairs(pending) do
		local whole = math.floor(amount)
		if whole > 0 then
			report[stat] = whole
			pending[stat] = amount - whole
			AddLocalStat(stat, whole)
			any = true
		end
	end

	for stat, value in pairs(records) do
		report[stat] = math.floor(value * 10) / 10
		SetLocalRecord(stat, value)
		records[stat] = nil
		any = true
	end

	if any then TriggerServerEvent('Achievements:Server:SyncStats', report) end
end

local function MaybeReport()
	local since = GetGameTimer() - lastReportAt
	if since >= Config.Sync.Interval then
		Report()
		return
	end
	if since < Config.Sync.EarlyMinGap then return end

	local stat, goal = WouldReachGoal()
	if not stat then return end

	earlyGoals[stat] = goal
	Report()
end

-- Loop ----------------------------------------------------------------------------------------------------

local function Sample()
	local timer = GetGameTimer()
	local dt = (timer - lastSampleAt) / 1000
	lastSampleAt = timer

	local ped = cache.ped
	local coords = GetEntityCoords(ped)
	local previous = lastCoords
	lastCoords = coords

	if not previous or dt <= 0 or dt > 5 then return end
	if IsEntityDead(ped) or IsEntityPositionFrozen(ped) or not IsScreenFadedIn() then return end
	if LocalPlayer.state.spawnSelecting == true then return end

	local moved = #(coords - previous)
	local vehicle = cache.vehicle
	if vehicle then
		SampleVehicle(vehicle, moved, dt)
	else
		SampleOnFoot(ped, coords, moved, dt)
	end

	CheckLandmarks(coords, not vehicle)
end

function StartTracker()
	if started then return end
	started = true
	lastSampleAt = GetGameTimer()
	lastReportAt = lastSampleAt

	CreateThread(function()
		while true do
			Wait(Config.Tracker.Interval)
			Sample()
			MaybeReport()
		end
	end)
end
