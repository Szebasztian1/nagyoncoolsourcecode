-- Entry point: the local mirror of the player's progress, the popups and the NUI
-- catalog. Movement tracking lives in tracker.lua, the panel in panel.lua.

local state = {
	ready = false,
	unlocked = {},    -- [achievement] = unix time
	stats = {},       -- [stat] = the server's last word plus what this client reported since
	landmarks = {},   -- [landmark] = true
	secrets = {},     -- [landmark] = true
}

local byId = {}
local byStat = {}      -- [stat] = definitions, ascending goal
local landmarks = {}   -- [landmark] = definition
local nextGoals = {}   -- [stat] = cached lowest locked goal, false when none is left

local pendingToasts = {}
local toastWorker = false
local nuiReady = false   -- the page asked for its catalog; a message sent before that is lost

-- Catalog -------------------------------------------------------------------------------------

local function IndexCatalog()
	local visibleLandmarks = 0
	for _, landmark in ipairs(Config.Landmarks) do
		landmarks[landmark.id] = landmark
		if not landmark.hidden then visibleLandmarks = visibleLandmarks + 1 end
	end

	for _, def in ipairs(Config.Achievements) do
		if def.goal == 'all' then def.goal = visibleLandmarks end
		byId[def.id] = def
		if def.stat then
			byStat[def.stat] = byStat[def.stat] or {}
			table.insert(byStat[def.stat], def)
		end
	end

	for _, defs in pairs(byStat) do
		table.sort(defs, function(a, b) return a.goal < b.goal end)
	end
end

IndexCatalog()

-- The NUI asks for this once its page is up, so nothing is lost to a slow load.
local function BuildNuiCatalog()
	local places = {}
	for i, landmark in ipairs(Config.Landmarks) do
		places[i] = { id = landmark.id, label = landmark.label, x = landmark.coords.x, y = landmark.coords.y, hidden = landmark.hidden == true }
	end

	local sound = Config.Toast.Sound
	return {
		tiers = Config.Tiers,
		categories = Config.Categories,
		stats = Config.Stats,
		statGroups = Config.StatGroups,
		achievements = Config.Achievements,
		landmarks = places,
		toast = {
			position = Config.Toast.Position,
			duration = Config.Toast.Duration,
			sound = sound and { file = sound.File, volume = sound.Volume } or false,
		},
		serverFirstTier = Config.ServerFirst.MinTier,
		rewards = Config.Reward and Config.Reward.Tiers or false,
	}
end

-- After a resource restart the server unlocks for online players at once, while the page is still
-- loading; popups and the panel wait for this.
RegisterNUICallback('ready', function(_, cb)
	nuiReady = true
	cb(BuildNuiCatalog())
end)

-- State ------------------------------------------------------------------------------------------

local function ToSet(list)
	local set = {}
	if type(list) ~= 'table' then return set end
	for _, key in ipairs(list) do set[key] = true end
	return set
end

function IsAchievementReady()
	return state.ready and nuiReady
end

-- The page is up; the task pages need nothing more.
function IsNuiReady()
	return nuiReady
end

function FindLandmarkDefinition(id)
	return landmarks[id]
end

function GetLocalStat(stat)
	return state.stats[stat] or 0
end

function AddLocalStat(stat, amount)
	state.stats[stat] = GetLocalStat(stat) + amount
end

function SetLocalRecord(stat, value)
	if value > GetLocalStat(stat) then state.stats[stat] = value end
end

-- Lowest goal of `stat` that is still locked, or nil.
function GetNextGoal(stat)
	local cached = nextGoals[stat]
	if cached ~= nil then return cached or nil end

	local goal = false
	for _, def in ipairs(byStat[stat] or {}) do
		if not state.unlocked[def.id] then
			goal = def.goal
			break
		end
	end

	nextGoals[stat] = goal
	return goal or nil
end

function IsLandmarkKnown(landmark)
	local set = landmark.hidden and state.secrets or state.landmarks
	return set[landmark.id] == true
end

-- Optimistic: the server almost always agrees with a client that saw itself inside.
function MarkLandmarkKnown(landmark)
	local set = landmark.hidden and state.secrets or state.landmarks
	set[landmark.id] = true
end

local function ApplyState(view)
	state.unlocked = view.unlocked or {}
	state.stats = view.stats or {}
	state.landmarks = ToSet(view.landmarks)
	state.secrets = ToSet(view.secrets)
	nextGoals = {}
	state.ready = true
end

CreateThread(function()
	while not LocalPlayer.state.identifier do Wait(1000) end

	for _ = 1, 6 do
		local view = lib.callback.await('Achievements:GetState', false)
		if type(view) == 'table' then
			ApplyState(view)
			StartTracker()
			return
		end
		Wait(10000)
	end
end)

-- Popups --------------------------------------------------------------------------------------------

local function CanShowToast()
	return nuiReady and IsScreenFadedIn() and not IsPlayerSwitchInProgress() and LocalPlayer.state.spawnSelecting ~= true
end

-- The NUI plays the sound when the popup really appears, and merges a burst of one stat.
local function ShowToast(toast)
	SendNUIMessage({ action = 'toast', data = toast })
end

-- Held back while the screen is black or the spawn selector is up, then shown together.
local function QueueToast(toast)
	if CanShowToast() then
		ShowToast(toast)
		return
	end

	pendingToasts[#pendingToasts + 1] = toast
	if toastWorker then return end
	toastWorker = true

	CreateThread(function()
		while not CanShowToast() do Wait(500) end

		local toasts = pendingToasts
		pendingToasts = {}
		toastWorker = false
		for _, pending in ipairs(toasts) do ShowToast(pending) end
	end)
end

RegisterNetEvent('Achievements:Client:Unlocked', function(data)
	if type(data) ~= 'table' then return end
	local def = byId[data.id]
	if not def then return end

	state.unlocked[def.id] = data.at
	if def.stat then nextGoals[def.stat] = nil end

	-- reward: the dollars the server is paying for it, 0 for a grant or an achievement paid before
	local reward = tonumber(data.reward) or 0
	SendNUIMessage({ action = 'unlocked', data = { id = def.id, at = data.at, first = data.first == true, reward = reward } })
	QueueToast({ kind = 'unlock', id = def.id, first = data.first == true, reward = reward })
end)

-- Somebody else's server first or legendary unlock. The achiever already has their own popup.
RegisterNetEvent('Achievements:Client:Announce', function(data)
	if type(data) ~= 'table' or data.src == cache.serverId or not byId[data.id] then return end

	QueueToast({ kind = 'news', id = data.id, name = tostring(data.name or ''), first = data.first == true })
end)

-- Notices ---------------------------------------------------------------------------------------------

-- A bc_notyp notice sits in the top-centre slot, so the popups step below it while it is up.
-- bc_notyp drops a notice that arrives while another is still shown; the same guard here keeps
-- the two in step.
local noticeUntil = 0

local function OnNotice(title, message, time)
	local notice = Config.Toast.Notice
	if GetResourceState(notice.Resource) ~= 'started' then return end

	local timer = GetGameTimer()
	if timer < noticeUntil then return end

	local duration = tonumber(time) or notice.Time
	-- bc_notyp frees its slot at +600 ms; freeing ours a little sooner never misses a shown notice.
	noticeUntil = timer + duration + 500

	SendNUIMessage({ action = 'notice', data = { title = tostring(title or ''), message = tostring(message or ''), duration = duration } })
end

if Config.Toast.Notice and Config.Toast.Position == 'top-center' then
	RegisterNetEvent(Config.Toast.Notice.Event, OnNotice)

	-- The aty_hud VIP EXP bar takes the very top band for ~6 s on an XP gain, so
	-- bc_notyp slides its notice down to the second band. Our measuring probe has
	-- to move with it, otherwise the popups would stand on top of the notice.
	AddEventHandler('bc_vipxp:visible', function(ms)
		SendNUIMessage({ action = 'noticeband', data = { time = tonumber(ms) or 6300 } })
	end)
end
