Config = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PRICING (weekly access, PER FARM)
-----------------------------------------------------------------------------------------------------------------------------------------

Config.accessPrice  = 15000000          -- price to unlock the statistics of ONE farm
Config.accessPeriod = 7 * 24 * 60 * 60  -- access duration in seconds (default: 1 week)
Config.paymentAccount = 'bank'          -- 'bank' (ESX bank) or 'money' (cash)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CRITICAL ALERTS (push a RoadPhone notification when something on the farm is critical)
-----------------------------------------------------------------------------------------------------------------------------------------

Config.alerts = {
    enabled       = true,
    checkInterval = 300,    -- seconds between scans (5 min). Big interval = low overhead.
    cooldown      = 1800,   -- seconds before the same farm can be alerted again (30 min)
    notifyStaff   = false,  -- also notify staff with MANAGE_LIVESTOCK permission (not just owner)

    appTitle = 'Farmjaim',
    image    = '/public/img/Apps/light_mode/farm.svg', -- logo shown in the notification

    -- thresholds (0-100)
    healthCritical       = 15,   -- an animal at/below this health is critical
    requirementsCritical = 90,   -- an animal at/above this requirement is starving/thirsty
    dirtinessCritical    = 80,   -- average tile dirtiness at/above this is critical
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PERFORMANCE / CACHE
-----------------------------------------------------------------------------------------------------------------------------------------

Config.farmListCacheTime = 15   -- seconds to cache a player's farm list
Config.statsCacheTime    = 30   -- seconds to cache a farm's statistics
Config.cleanupInterval   = 300  -- seconds between cache/expired-access cleanup passes
Config.buyCooldown       = 3    -- seconds between purchase attempts (anti-spam)

Config.dbDriver = 'auto'        -- 'auto' | 'oxmysql' | 'mysql-async'

-----------------------------------------------------------------------------------------------------------------------------------------
-- USER ID
-- aquiver-farmhouse stores the owner as farmhouse.ownership = xPlayer.identifier (confirmed in bridge/esx.lua).
-- No hashing. We just return the ESX identifier.
-----------------------------------------------------------------------------------------------------------------------------------------

-- Single source of truth for the whole resource: config.lua is a shared_script, so it loads
-- before client.lua/server.lua and they can reuse this instead of resolving their own.
local _esx
function Config.GetCore()
    -- Deliberately NOT pcall-wrapped: if es_extended is unavailable this must fail loudly at
    -- load time, exactly as the original file-scope export call did. Callers that need to
    -- tolerate failure (Config.GetUserId below) pcall around it themselves.
    if not _esx then
        _esx = exports['es_extended']:getSharedObject()
    end
    return _esx
end

function Config.GetUserId(source)
    local ok, id = pcall(function()
        local xPlayer = Config.GetCore().GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    end)
    if ok and type(id) == 'string' and #id > 0 then return id end
    return nil
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- LABELS (Hungarian) — taken from aquiver-farmhouse locales/en.json
-----------------------------------------------------------------------------------------------------------------------------------------

Config.animalLabels = {
    COW           = 'Tehén',
    CATTLE        = 'Szarvasmarha',
    CHICKEN       = 'Csirke',
    PIG_LANDRACE  = 'Landrace sertés',
    PIG_HAMPSHIRE = 'Hampshire sertés',
    PIG_PIETRAIN  = 'Pietrain sertés',
}

Config.animalEmoji = {
    COW = '🐄', CATTLE = '🐂', CHICKEN = '🐔',
    PIG_LANDRACE = '🐖', PIG_HAMPSHIRE = '🐖', PIG_PIETRAIN = '🐖',
}

Config.feedLabels = {
    EMPTY          = 'Üres',
    WATER          = 'Víz',
    CHICKEN_FEED   = 'Csirketáp',
    PIG_FEED       = 'Sertéstáp',
    COW_FEED       = 'Szarvasmarha takarmány',
    UNIVERSAL_FEED = 'Univerzális táp',
    GRAIN_MIX_FEED = 'Gabonakeverék táp',
    PROTEIN_FEED   = 'Fehérjetáp',
}

Config.productLabels = { MILK = 'Tej', EGG = 'Tojás' }

Config.permissionLabels = {
    PERMISSION_CHANGE_LOCK = 'Zár kezelése',
    MANAGE_LIVESTOCK       = 'Állatok kezelése',
    MANAGE_COMPOST         = 'Komposzt kezelése',
    MANAGE_STORAGE         = 'Tároló kezelése',
    CAN_USE_COMPUTER       = 'Számítógép használata',
}

Config.rarityLabels = { [1] = 'Közönséges', [2] = 'Ritka', [3] = 'Legendás', [4] = 'Mítoszi' }

-----------------------------------------------------------------------------------------------------------------------------------------
-- ECONOMY (copied from aquiver-farmhouse Config.lua — used to estimate values; update if you change theirs)
-----------------------------------------------------------------------------------------------------------------------------------------

Config.livestockBasePrice = {
    CATTLE = 1200000, CHICKEN = 800000, COW = 2500000,
    PIG_HAMPSHIRE = 2000000, PIG_LANDRACE = 1500000, PIG_PIETRAIN = 1800000,
}
Config.livestockSellMultiplier = 0.5
Config.productPrice = { MILK = 115000, EGG = 75000 }
Config.compostPrice = 65000
Config.maxStorageCount = 100   -- per storage unit (Milk/Egg)
