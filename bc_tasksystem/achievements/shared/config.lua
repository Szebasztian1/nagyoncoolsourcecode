-- The achievement settings share bc_tasksystem's Config table (config/shared.lua loads first);
-- none of these keys exists there. What exists (tiers, categories, stats, landmarks,
-- achievements) lives in achievements/shared/catalog.lua. This file decides how it behaves.
Config = Config or {}

Config.Debug = false   -- prints unlocks and rejected reports to the server console

-- Client sampling ---------------------------------------------------------------

Config.Tracker = {
	Interval   = 1000,                    -- ms between two movement samples
	NightHours = { from = 21, to = 6 },   -- in-game hours that count as night
	RainLevel  = 0.15,                    -- GetRainLevel() above this counts as rain
}

-- Client -> server reports ---------------------------------------------------------

Config.Sync = {
	Interval     = 60 * 1000,   -- ms, regular report of the collected movement
	EarlyMinGap  = 15 * 1000,   -- ms, a report that completes a goal may go early, but not sooner than this
	ServerMinGap = 8 * 1000,    -- ms, the server ignores reports arriving faster than this
	MaxCredit    = 180,         -- secs, the most elapsed time a single report is credited with
	Tolerance    = 1.3,         -- headroom over the physical limits (lag, sampling jitter)
}

Config.Discover = {
	Tolerance = 25.0,       -- metres the server adds to a landmark radius
	Cooldown  = 3 * 1000,   -- ms between two landmark reports of one player
}

-- Framework events the server listens to. Each one is rate limited per player.
Config.HookCooldowns = {
	vehicle = 2 * 1000,    -- ms, esx:enteredVehicle
	jump    = 700,         -- ms, esx:playerJumping
	death   = 15 * 1000,   -- ms, esx:onPlayerDeath
	work    = 2 * 1000,    -- ms, bc:legalQuestDoProgress (some jobs report on a client-fired sale)
	robbery = 15 * 60 * 1000,   -- ms per robbery script: some report every grab of the same heist
	refuel  = 10 * 1000,   -- ms, ox_fuel:vehicleRefueled
}

-- Persistence -----------------------------------------------------------------------

Config.SaveInterval = 5 * 60      -- secs, changed progress rows are written in one batch
Config.WriteDelay   = 750         -- ms, rows queue up this long, then leave in one query
Config.LoadTimeout  = 30 * 1000   -- ms a client state request waits for the player's rows
Config.StartDelay   = 1500        -- ms, lets the writes of a previous run land before reloading

-- Popups ------------------------------------------------------------------------------

Config.Toast = {
	Position = 'top-center',   -- top-center | top-left | top-right | bottom-center
	Duration = 6500,           -- ms one popup stays on screen

	-- Played by the NUI when an unlock popup appears (news popups stay silent). File is relative
	-- to html/ and has to be listed in fxmanifest files. false = no sound.
	Sound = {
		File   = 'sounds/unlock.mp3',
		Volume = 0.25,  -- 0.0 - 1.0; the file peaks at -1.7 dBFS. 0.5 was too loud in game (2026-09-15)
	},

	-- The bc_notyp notice (police, government, hospital "Felhívás") uses the same top-centre slot.
	-- While one is on screen the top-center popups step below it, then move back. false = off.
	Notice = {
		Resource = 'bc_notyp',
		Event    = 'bc_renvedelem:notify',
		Time     = 5000,   -- ms bc_notyp shows a notice when the sender gives no time
	},
}

-- Money for every unlock, into the bank, once per player and achievement ever (bc_achievements_rewards).
-- Admin grants (/achadmin give) never pay. false = no money.
-- 130 achievements: 35 bronze, 36 silver, 45 gold, 14 legendary = 10 675 000 $ for all of them.
Config.Reward = {
	Account = 'bank',
	Reason  = 'Teljesítmény-jutalom',
	Delay   = 1000,   -- ms; unlocks of the same moment leave as one transfer
	Tiers   = { bronze = 25000, silver = 50000, gold = 100000, legend = 250000 },
}

Config.ServerFirst = {
	MinTier = 'silver',   -- lowest tier that can be a server first; bronze tasks are too trivial to race for
}

-- Unlocks every player hears about, as a small news popup. Both go to everybody, so keep them rare.
Config.Announce = {
	ServerFirsts = true,              -- a server first: once per achievement, ever
	Tiers        = { legend = true }, -- every unlock of these tiers (admin grants never)
}

-- Panel ----------------------------------------------------------------------------------

-- The one BC Küldetések panel: /taskmenu (client/client.lua) opens it on the daily tasks,
-- these commands open it on the achievements.
Config.Panel = {
	Command  = 'teljesitmenyek',
	Aliases  = { 'achi' },
	Key      = '',     -- default key mapping, empty = every player binds it in the FiveM settings
	Cooldown = 1500,   -- ms between two panel requests of one player
}

Config.Leaderboard = {
	Size      = 25,
	CacheTime = 120,   -- secs the database part of the list is reused
	RankTime  = 60,    -- secs a player's own rank is reused
}

-- Jobs -----------------------------------------------------------------------------------

Config.Jobs = {
	Unemployed = { 'unemployed' },
	BossGrade  = 'boss',   -- grade_name of the highest rank in a faction

	-- Off-duty copies are the same job, they never count as a new one.
	IgnorePatterns = { '^off', 'off$', 'offduty' },

	-- Referenced by the `jobs` field of an achievement.
	Groups = {
		law      = { 'police', 'detective', 'fbi', 'fbiuj', 'atf', 'irs', 'guardarmy', 'navi', 'usms', 'uss', 'servicess' },
		ems      = { 'ambulance' },
		fire     = { 'fired' },
		legal    = { 'gov', 'ugyved' },
		mechanic = {
			'acabmechanic', 'alkaidaoff', 'bennysservice', 'exotic', 'lifthouse', 'metamechanic', 'moscar',
			'offluxduty', 'sipsics', 'sonsofanarchy', 'themetalshop', 'topgear', 'umechanic', 'wsqcustoms',
		},
	},
}

-- Money --------------------------------------------------------------------------------

Config.Money = {
	Account        = 'bank',
	PaycheckReason = 'Paycheck',   -- reason es_extended/server/paycheck.lua passes for a real salary
}

-- Real time ----------------------------------------------------------------------------

-- Server clock. Every loaded player online at that minute gets +1 on the stat.
Config.Clock = {
	{ stat = 'midnights', hour = 0, minute = 0, newYear = 'newyears' },   -- newYear: extra stat on January 1st
	{ stat = 'dawns',     hour = 4, minute = 0 },
}

-- Admin ----------------------------------------------------------------------------------

Config.AdminCommand = 'achadmin'
Config.AdminGroups  = { 'owner', 'coowner', 'serverdirector', 'superadmin', 'developer', 'admincontroller', 'admin' }
