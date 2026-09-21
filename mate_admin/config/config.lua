---@class AdminGroup
---@field name        string   ACE group name (FiveM ACL)
---@field rank        string   Rank key identifier used throughout the system
---@field label       string   Display name shown in the panel
---@field priority    number   ACE priority — higher number means more powerful
---@field color       integer  Discord embed color (0xRRGGBB decimal integer)
---@field uiColor     string   Hex color string for the UI panel (#rrggbb)
---@field permissions string[] Default permission keys for this rank

local _pLow = {
    'WARN_PLAYER', 'FREEZE_PLAYER', 'SPECTATE_PLAYER', 'TELEPORT_PLAYER',
    'VIEW_REPORTS', 'MANAGE_REPORTS', 'CLOSE_REPORTS',
    'VIEW_PLAYERS', 'VIEW_PLAYER_DETAIL', 'MANAGE_PLAYER_NOTES',
}

local _pMid = {
    'BAN_PLAYER', 'KICK_PLAYER', 'WARN_PLAYER', 'FREEZE_PLAYER', 'SPECTATE_PLAYER', 'TELEPORT_PLAYER',
    'VIEW_REPORTS', 'MANAGE_REPORTS', 'CLOSE_REPORTS',
    'VIEW_PLAYERS', 'VIEW_PLAYER_DETAIL', 'VIEW_ADMINS', 'MANAGE_PLAYER_NOTES',
}

local _pHigh = {
    'BAN_PLAYER', 'KICK_PLAYER', 'WARN_PLAYER', 'FREEZE_PLAYER', 'SPECTATE_PLAYER', 'TELEPORT_PLAYER',
    'VIEW_REPORTS', 'MANAGE_REPORTS', 'CLOSE_REPORTS',
    'VIEW_PLAYERS', 'VIEW_PLAYER_DETAIL', 'VIEW_ADMINS', 'MANAGE_ADMINS', 'MANAGE_PLAYER_NOTES',
    'VIEW_METRICS', 'VIEW_AUDIT_LOGS',
    'VIEW_PLAYER_LOGS', 'MANAGE_EVENTS', 'VIEW_ITEMLIST', 'VIEW_VEHICLELIST', 'MANAGE_DUTY_SKIN',
}

local _pSuper = {
    'BAN_PLAYER', 'KICK_PLAYER', 'WARN_PLAYER', 'FREEZE_PLAYER', 'SPECTATE_PLAYER', 'TELEPORT_PLAYER',
    'VIEW_REPORTS', 'MANAGE_REPORTS', 'CLOSE_REPORTS',
    'VIEW_PLAYERS', 'VIEW_PLAYER_DETAIL', 'VIEW_ADMINS', 'MANAGE_ADMINS', 'MANAGE_PLAYER_NOTES',
    'VIEW_METRICS', 'VIEW_AUDIT_LOGS', 'MANAGE_SETTINGS', 'MANAGE_COMMANDS', 'VIEW_ALL', 'MANAGE_JOBS',
    'VIEW_PLAYER_LOGS', 'MANAGE_EVENTS', 'VIEW_ITEMLIST', 'VIEW_VEHICLELIST', 'MANAGE_DUTY_SKIN',
}

local _pAll = {
    'BAN_PLAYER', 'KICK_PLAYER', 'WARN_PLAYER', 'FREEZE_PLAYER', 'SPECTATE_PLAYER', 'TELEPORT_PLAYER',
    'VIEW_REPORTS', 'MANAGE_REPORTS', 'CLOSE_REPORTS',
    'VIEW_PLAYERS', 'VIEW_PLAYER_DETAIL', 'VIEW_ADMINS', 'MANAGE_ADMINS', 'MANAGE_PLAYER_NOTES',
    'VIEW_METRICS', 'VIEW_AUDIT_LOGS', 'MANAGE_SETTINGS', 'MANAGE_COMMANDS', 'VIEW_ALL', 'MANAGE_JOBS',
    'VIEW_PLAYER_LOGS', 'MANAGE_EVENTS', 'VIEW_ITEMLIST', 'VIEW_VEHICLELIST', 'MANAGE_DUTY_SKIN',
}

Config = {}

---@type boolean
Config.Debug = false

---@type AdminGroup[]
Config.AdminGroups = {
    { name = 'admin',           rank = 'ADMIN',           label = 'Moderator',        priority = 1,  color = 0x866dd6, uiColor = '#866dd6', permissions = _pMid },
    { name = 'admin1',          rank = 'ADMIN1',          label = 'Admin 1',          priority = 2,  color = 0xdbde1b, uiColor = '#dbde1b', permissions = _pMid },
    { name = 'admin2',          rank = 'ADMIN2',          label = 'Admin 2',          priority = 3,  color = 0xdbde1b, uiColor = '#dbde1b', permissions = _pMid },
    { name = 'admin3',          rank = 'ADMIN3',          label = 'Admin 3',          priority = 4,  color = 0xdbde1b, uiColor = '#dbde1b', permissions = _pMid },
    { name = 'admin4',          rank = 'ADMIN4',          label = 'Admin 4',          priority = 5,  color = 0xdbde1b, uiColor = '#dbde1b', permissions = _pMid },
    { name = 'superadmin',      rank = 'SUPERADMIN',      label = 'Superadmin',       priority = 6,  color = 0x16cc1c, uiColor = '#16cc1c', permissions = _pSuper },
    { name = 'admincontroller', rank = 'ADMINCONTROLLER', label = 'Admin Controller', priority = 7,  color = 0x0038fd, uiColor = '#0038fd', permissions = _pHigh },
    { name = 'operator',        rank = 'OPERATOR',        label = 'Operator',         priority = 8,  color = 0x4b4b4d, uiColor = '#4b4b4d', permissions = _pLow },
    { name = 'manager',         rank = 'MANAGER',         label = 'Server Manager',   priority = 9,  color = 0xf7be4a, uiColor = '#f7be4a', permissions = _pHigh },
    { name = 'coowner',         rank = 'COOWNER',         label = 'Server Manager',   priority = 10, color = 0xf7be4a, uiColor = '#f7be4a', permissions = _pHigh },
    { name = 'developer',       rank = 'DEVELOPER',       label = 'Developer',        priority = 11, color = 0xcc0e11, uiColor = '#cc0e11', permissions = _pAll },
    { name = 'serverdirector',  rank = 'SERVERDIRECTOR',  label = 'Server Director',  priority = 12, color = 0xcc0eb9, uiColor = '#cc0eb9', permissions = _pHigh },
    { name = 'owner',           rank = 'OWNER',           label = 'Owner',            priority = 13, color = 0xffffff, uiColor = '#ffffff', permissions = _pAll },
}

Config.Duty = {
    notifyOnDutyAdmins = true,
}

---@class InvisibleConfig
---@field adminAlpha number  Alpha an invisible admin's ped is drawn at for on-duty colleagues
---@field selfAlpha  number  Alpha an invisible admin sees their own ped at
---@field showTagToAdmins boolean  Keep the floating admin tag visible for on-duty colleagues

-- The engine quantises entity alpha to steps of 51 (0/51/102/153/204/255), so pick one of
-- those values or it will be rounded anyway.
---@type InvisibleConfig
Config.Invisible = {
    adminAlpha      = 102,
    selfAlpha       = 102,
    showTagToAdmins = true,
    -- Beyond this the hide render loop stops running: the game does not draw another
    -- player that far out anyway, so there is nothing left to hide. Keep it comfortably
    -- above the distance at which you can actually make out a player - raise it if an
    -- invisible admin ever becomes visible as a speck in the distance.
    hideRange       = 200.0,
}

---@type vector3
Config.PublicCoords = vec3(195.17, -933.77, 30.68)

---@class AdminTagConfig
---@field renderDistance number Maximum world-unit distance at which admin tags are visible
---@field iconScale      vector3 Scale of the PNG icon marker

---@type AdminTagConfig
Config.AdminTag = {
    renderDistance = 30.0,
    iconScale      = vector3(0.65, 0.65, 0.0),
    useImage       = true
}

Config.SpawnCar = {
    Upgrades = {
        modEngine       = 3,
        modBrakes       = 2,
        modTransmission = 2,
        modSuspension   = 3,
        modArmor        = true,
        windowTint      = 1,
    },
}

---@class AdminZoneConfig
---@field radius          number
---@field visibleDistance number
---@field markerHeight    number
---@field markerColor     { r: integer, g: integer, b: integer, a: integer }

---@type AdminZoneConfig
Config.AdminZone = {
    radius          = 15.0,
    visibleDistance = 50.0,
    markerHeight    = 4.0,
    markerColor     = { r = 64, g = 160, b = 255, a = 180, },
}


---@class NameTagSlots
---@field serverId  boolean Show [ID] badge prefix
---@field job       boolean Show job label
---@field armed     boolean Show [ARMED] when the player is holding a weapon
---@field role      boolean Show [DRIVER] / [PASSENGER] in vehicle tags
---@field healthBar boolean Show the health progress bar
---@field armorBar  boolean Show the armor progress bar

---@class NameTagsConfig
---@field renderDistance number   Distance at which name tags are drawn above players
---@field blipRange      number   Radius in which player blips appear on the map
---@field slots          NameTagSlots Default enabled state for each nametag slot (overridden per-admin via KVP)

---@type NameTagsConfig
Config.NameTags = {
    renderDistance = 150.0,
    blipRange      = 300.0,
    slots          = {
        serverId  = true,
        job       = true,
        armed     = true,
        role      = true,
        healthBar = true,
        armorBar  = true,
    },
}

---@class AntiDutyAfkConfig
---@field enabled       boolean  Master switch
---@field checkInterval number   Scheduler interval in seconds
---@field graceMinutes  number   Minutes of inactivity before first warning
---@field autoOffDuty   boolean  Force off-duty after 3 warnings
---@field immuneGroups  string[] ACE group names that are never flagged

---@type AntiDutyAfkConfig
Config.AntiDutyAfk = {
    enabled       = true,
    checkInterval = 1 * 60,
    graceMinutes  = 5,
    autoOffDuty   = true,
    immuneGroups  = { 'admincontroller', 'manager', 'coowner', 'developer', 'serverdirector', 'owner' },
}

---@class AdminAbuseThreshold
---@field selfLimit   number  Max uses on self within the window before flagging
---@field targetLimit number  Max uses on the same target within the window before flagging
---@field totalLimit  number? Max uses across all targets within the window before flagging
---@field windowSecs  number  Rolling window size in seconds
---@field sumArg      string? Command argument to sum up (e.g. 'amount')
---@field sumLimit    number? Flag when the summed argument reaches this within the window

---@class AdminAbuseCrossAction
---@field limit      number  Combined tracked actions on the same target before flagging
---@field windowSecs number  Rolling window size in seconds

---@class AdminAbuseConfig
---@field enabled            boolean
---@field immuneGroups       string[]
---@field notifyGroups       string[]
---@field escalateAfter      number  Flags within the escalate window after which a flag is escalated
---@field escalateWindowSecs number  Window for counting repeat flags (survives reconnects and restarts)
---@field crossAction        AdminAbuseCrossAction Combined-actions-per-target detector across all tracked commands
---@field thresholds         table<string, AdminAbuseThreshold> Keyed by function name; every listed command is tracked automatically (chat and panel)

---@type AdminAbuseConfig
Config.AdminAbuse = {
    enabled            = true,
    immuneGroups       = { 'manager', 'coowner', 'developer', 'serverdirector', 'owner' },
    notifyGroups       = { 'admincontroller', 'manager', 'coowner', 'owner' },
    escalateAfter      = 3,
    escalateWindowSecs = 6 * 3600,
    crossAction        = { limit = 8, windowSecs = 10 * 60 },
    thresholds         = {
        heal          = { selfLimit = 3, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        fix           = { selfLimit = 3, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        clean         = { selfLimit = 3, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        revive        = { selfLimit = 3, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        setarmor      = { selfLimit = 3, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        bring         = { selfLimit = 3, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        bringtomarker = { selfLimit = 3, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        pub           = { selfLimit = 5, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        kill          = { selfLimit = 5, targetLimit = 3, totalLimit = 10, windowSecs = 10 * 60 },
        freeze        = { selfLimit = 5, targetLimit = 4, totalLimit = 12, windowSecs = 10 * 60 },
        kick          = { selfLimit = 3, targetLimit = 3, totalLimit = 8, windowSecs = 10 * 60 },
        warn          = { selfLimit = 3, targetLimit = 3, totalLimit = 10, windowSecs = 30 * 60 },
        setjob        = { selfLimit = 2, targetLimit = 4, totalLimit = 10, windowSecs = 30 * 60 },
        changename    = { selfLimit = 2, targetLimit = 2, totalLimit = 5, windowSecs = 30 * 60 },
        setdimension  = { selfLimit = 5, targetLimit = 5, totalLimit = 15, windowSecs = 10 * 60 },
        skin          = { selfLimit = 4, targetLimit = 3, totalLimit = 10, windowSecs = 10 * 60 },
        accountmoney  = { selfLimit = 3, targetLimit = 3, totalLimit = 6, windowSecs = 30 * 60, sumArg = 'amount', sumLimit = 10000000 },
        car           = { selfLimit = 8, targetLimit = 8, totalLimit = 16, windowSecs = 10 * 60 },
        bringvehicle  = { selfLimit = 6, targetLimit = 6, totalLimit = 12, windowSecs = 10 * 60 },
        dv            = { selfLimit = 10, targetLimit = 10, totalLimit = 20, windowSecs = 10 * 60 },
        maxtuning     = { selfLimit = 3, targetLimit = 3, totalLimit = 8, windowSecs = 30 * 60 },
        reviveall     = { selfLimit = 2, targetLimit = 2, totalLimit = 4, windowSecs = 10 * 60 },
        nearrevive    = { selfLimit = 4, targetLimit = 4, totalLimit = 8, windowSecs = 10 * 60 },
        -- Our own radius commands (server/editable/range_commands.lua).
        healrange     = { selfLimit = 4, targetLimit = 4, totalLimit = 8, windowSecs = 10 * 60 },
        setarmorrange = { selfLimit = 4, targetLimit = 4, totalLimit = 8, windowSecs = 10 * 60 },
    },
}

Config.BypassDuty = {
    duty          = true,
    forceduty     = true,
    licensecsere  = true,
    licensetorles = true,
    blip          = true,
}

-- Minimum rankPriority required to force-close any report (regardless of who claimed it).
-- Matches SUPERADMIN (priority 6) and every rank above it.
Config.ForceCloseMinPriority = 6

---@class SpectateConfig
---@field enabled boolean Lets admins pull a live game view from players on the spectate wall.
---                       Disabling it stops clients from registering, so no feed can be opened.

---@type SpectateConfig
Config.Spectate = {
    enabled = true,
}

---@class ReportLimitsConfig
---@field maxSubject     integer  Character limit, matches maxLength in ReportCreateModal.tsx
---@field maxDescription integer  Character limit, matches maxLength in ReportCreateModal.tsx
---@field maxMessage     integer  Character limit for a single chat message
---@field types          string[] Accepted report types, matches ReportType in web/src/types/report.ts

---@type ReportLimitsConfig
Config.ReportLimits = {
    maxSubject     = 120,
    maxDescription = 1000,
    maxMessage     = 1000,
    -- Az 'ai' egy privát AI beszélgetés: nem jelenik meg az adminoknál (lásd ServerConfig.ReportAI).
    types          = { 'player', 'question', 'bug', 'ai' },
}

Config.ForceDuty = {
    minGroupName = 'admincontroller',
}

---@class DutyPedComponentSlot
---@field id    number GTA ped component id (see SetPedComponentVariation)
---@field key   string Stable key used in saved appearance JSON
---@field label string Display label shown in the panel

---@class DutyPedPropSlot
---@field id    number GTA ped prop id (see SetPedPropIndex)
---@field key   string Stable key used in saved appearance JSON
---@field label string Display label shown in the panel

---@class DutyPedConfig
---@field enabled           boolean  Master switch for the on-duty group skin system
---@field studioLocation    vector4  World position (and heading) the preview ped/camera studio is anchored to
---@field allowedModels     string[] Curated ped model allow-list selectable for "Ped mode" uniforms
---@field clothesBaseModels string[] Base ped models selectable as the starting point for "Clothes mode" uniforms
---@field clothesComponents DutyPedComponentSlot[] Clothing component slots exposed in the "Clothes mode" editor
---@field clothesProps      DutyPedPropSlot[] Prop slots (hat, glasses, ...) exposed in the "Clothes mode" editor

---@type DutyPedConfig
Config.DutyPed = {
    enabled           = true,
    studioLocation    = vector4(-75.024, -818.888, 326.176, 237.4976),
    allowedModels     = {
        'mp_m_freemode_01',
        'mp_f_freemode_01',
        's_m_y_cop_01',
        's_f_y_cop_01',
        's_m_y_sheriff_01',
        's_m_y_swat_01',
        's_m_m_security_01',
    },
    clothesBaseModels = {
        'mp_m_freemode_01',
        'mp_f_freemode_01',
    },
    clothesComponents = {
        { id = 3,  key = 'torso',      label = 'Torso' },
        { id = 4,  key = 'legs',       label = 'Legs' },
        { id = 6,  key = 'shoes',      label = 'Shoes' },
        { id = 8,  key = 'undershirt', label = 'Undershirt' },
        { id = 11, key = 'torso2',     label = 'Jacket' },
        { id = 7,  key = 'accessory',  label = 'Accessory' },
        { id = 9,  key = 'armor',      label = 'Body Armor' },
        { id = 5,  key = 'bag',        label = 'Bag' },
        { id = 10, key = 'decals',     label = 'Decals' },
        { id = 2,  key = 'hair',       label = 'Hair' },
    },
    clothesProps      = {
        { id = 0, key = 'hat',     label = 'Hat' },
        { id = 1, key = 'glasses', label = 'Glasses' },
    },
}

---@class LicenseRewriteFile
---@field resource string Resource name that owns the data file.
---@field file     string Path inside the resource (as SaveResourceFile expects it).

---@class LicenseRewriteConfig
---@field skipTables     string[]              Tables the license rewrite never touches.
---@field scanResources  boolean               Probe every resource for data files holding a license.
---@field files          LicenseRewriteFile[]  Data files that are always checked.
---@field fileNames      string[]              File names probed in each resource when scanResources is on.
---@field restartTouched boolean               Restart a resource whose data file was rewritten, so its
---                                            in-memory copy cannot save the old license back.
---@field neverRestart   string[]              Resources that are never restarted automatically.

--- /licensecsere and /licensetorles walk the whole database schema, so this list only exists
--- for tables that must keep the old identifier (nothing by default). Resource data files are
--- not covered by the schema walk, hence the file list below.
---@type LicenseRewriteConfig
Config.LicenseRewrite = {
    skipTables     = {},
    scanResources  = true,
    files          = {
        { resource = 'bc_carry',        file = 'data.json' },
        { resource = 'bc_radioanim',    file = 'data.json' },
        { resource = 'hobby_banyaszat', file = 'leaderboard.json' },
        { resource = 'hobby_banyaszat', file = 'tournament.json' },
        { resource = 'bc_garage',       file = 'custominteriors.json' },
        { resource = 'bc_garage',       file = 'favorites.json' },
        { resource = 'bc_garage',       file = 'usage.json' },
        { resource = 'bc_garage',       file = 'vehnicknames.json' },
        { resource = 'bc_garage',       file = 'imagetotake.json' },
    },
    fileNames      = {
        'data.json', 'leaderboard.json', 'tournament.json', 'players.json', 'player_data.json',
        'stats.json', 'usage.json', 'favorites.json', 'vehnicknames.json', 'imagetotake.json',
        'custominteriors.json', 'saves.json', 'storage.json', 'database.json', 'users.json',
    },
    -- Ugyanaz a webhook, amit az esx_adminplus hasznalt: az adminok itt kovetik a parancsot.
    discordWebhook = 'https://discord.com/api/webhooks/909002065848717332/U8h04Qm9in5Spj8q36Q8qGlQL3tcbC5K5lg61ZYpavnJjVE5N4radjgzX8UIK3xuCGxm',
    restartTouched = true,
    neverRestart   = {
        'mate_admin', 'esx_adminplus', 'es_extended', 'oxmysql', 'ox_lib', 'ox_inventory',
        'ox_target', 'spawnmanager', 'sessionmanager', 'chat',
    },
}
