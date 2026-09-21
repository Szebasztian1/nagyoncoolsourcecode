Config = {}

--======================================================================
-- Prices
--======================================================================
Config.HQPrice          = 6000000000 -- society money, one-time interior purchase (6 milliárd)
Config.EntryMovePPPrice = 10000    -- PP, relocating the entry CP anywhere on the map

--======================================================================
-- Admin (HQ spots are placed by admins, factions buy at the spot)
--======================================================================
-- Either grants access: the ace permission OR the player's ESX group
-- (users.group). Commands must be typed in the CHAT (/fkhq), the F8
-- console is client-side and cannot run server commands.
Config.AdminAce    = 'group.owner'
Config.AdminGroups = { 'owner' }
Config.Commands = {
    place = 'fkhq',      -- places a buyable HQ spot at the admin's position
    admin = 'fkhqadmin', -- opens the admin spot list (teleport / free / delete)
}

--======================================================================
-- Interior placement - SAME band as the loaf_housing houses:
-- Anchor XY = the spot position at purchase time.
-- Anchor Z  = spot ground + InteriorHeightOffset + slot * InteriorZStep
-- (loaf spawns its shells 1000-2000 above the door; the per-faction
-- slot step replaces its random offset). Helis (~800 ceiling) cannot
-- reach it. IMPORTANT: above ~2600 GTA stops handling prop collision
-- reliably, so the spot ground is capped at InteriorGroundCap.
-- The anchor NEVER moves after purchase, so jobcreator markers placed
-- inside keep working even when the entry CP is relocated.
--======================================================================
Config.InteriorHeightOffset = 1000.0 -- above the spot, like the houses
Config.InteriorZStep        = 40.0
Config.InteriorGroundCap    = 900.0  -- mountain spots: band base capped here
Config.InteriorRadius       = 120.0  -- bounds guard + login rescue search radius
Config.PreviewHeightOffset  = 850.0  -- preview band, 150 below the HQ band
Config.RescueMinZ           = 850.0  -- above this the login rescue kicks in

-- Entry CP relocation limits (10k PP move)
Config.MaxEntryZ        = 1500.0 -- entry CP must stay on the map, not in the HQ band
Config.PlaceMaxDistance = 60.0   -- max distance between player and placed CP (anti-abuse)

-- Can the FACTION (boss) relocate its own HQ entry from the fonoki panel?
-- false = only admins move it (/fkhqadmin -> "Áthelyezés ide"); the panel
-- button is hidden and the server rejects the move.
Config.AllowFactionEntryMove = false

--======================================================================
-- Entry CP interaction
--======================================================================
Config.EntryDrawDistance = 30.0 -- interaction loop activation range
Config.EntryMenuDistance = 2.0  -- E menu range (fallback drawer)
Config.EnterMaxDistance  = 6.0  -- server-side re-check for entering/buying
Config.InviteMaxDistance = 8.0  -- server-side max distance inviter <-> invitee

--======================================================================
-- Allied factions: the boss can add ANOTHER FACTION (job) to the HQ, so
-- every member of that faction may enter - no per-player invite needed.
-- The alliance is ONE-WAY: it only opens OUR door. If both sides want
-- mutual access, both bosses must add the other faction.
--======================================================================
Config.Allies = {
    max                 = 1,     -- max allied factions per HQ
    excludeWhitelisted  = true,  -- law-enforcement jobs (WhitelistedJobs) cannot be allies
    -- Jobs that never show up in the picker (side jobs, not factions).
    -- The boss can still type any valid job name manually.
    excludeJobs         = { 'unemployed' },
    -- true = only factions that OWN a HQ can be added (shorter list)
    onlyFactionsWithHQ  = false,
}

--======================================================================
-- Police raid (breach the entry CP -> raid window while it lasts)
--======================================================================
Config.WhitelistedJobs = { 'police', 'fbiuj', 'uss', 'irs', 'atf', 'navi', 'fbi', 'detective', 'guardarmy', 'usms', 'servicess' }

-- Who SEES an owned HQ entry marker (house icon + name) up close? Members
-- and invited guests always do; random players NEVER do (it is a hidden
-- base). This toggles whether whitelisted law-enforcement jobs also see it
-- up close, which they need to find and breach a base. false = cops must
-- find the door some other way.
Config.RaidJobsSeeHQ = true
Config.Raid = {
    -- Anti-cheat floor: the server rejects a RaidFinish that arrives sooner
    -- than this. The real challenge is the minigame below; this only stops a
    -- cheater from instantly claiming a breach. Keep it below the typical
    -- minigame length so a skilled cop is never forced to wait.
    breakTime = 15,
    -- Raid window: after the breach the whitelisted jobs may enter for this
    -- long. When it expires the entrance LOCKS again and they must breach
    -- once more to get back in (Raid.Active -> false -> RequestEnter denies).
    duration  = 600, -- 10 minutes
    -- Serious breach minigame (self-contained NUI - the live server has no
    -- ox_lib). The cop must secure every pin: an indicator sweeps a bar and
    -- has to be locked inside the shrinking success zone. Difficulty ramps up
    -- per pin; running out of strikes fails the whole breach (must retry).
    minigame = {
        pins       = 6,   -- pins (rounds) to secure to open the door
        strikes    = 2,   -- misses allowed before the breach fails
        zoneStart  = 26,  -- success-zone width on pin 1 (% of the bar)
        zoneEnd    = 12,  -- success-zone width on the last pin (shrinks)
        speedStart = 105, -- indicator speed on pin 1 (% of bar per second)
        speedEnd   = 215, -- indicator speed on the last pin (faster)
    },
}

--======================================================================
-- Visuals ("house look": house blip icon + ground marker + 3D text;
-- DrawMarker has no house shape).
--======================================================================
-- BC brand colors (bc_fonokipanel --accent): blue #2f80ed, green #4cdb28
-- Owned HQ blip: only the own faction + guests see it
Config.Blip = { enabled = true, sprite = 40, color = 3, scale = 0.8 } -- 40 = house icon, 3 = blue
-- Vacant (buyable) spot blip: visible to everyone so bosses can find them
Config.VacantBlip = { enabled = false, sprite = 40, color = 2, scale = 0.8 } -- off since 2026-09-14: vacant HQs are not shown on the map

Config.Marker = { -- placement ghost + optional ground ring (owned)
    type = 25, size = 1.6, height = 0.5,
    color = { r = 47, g = 128, b = 237, a = 120 },
}
Config.VacantMarker = { -- optional ground ring (buyable spot)
    type = 25, size = 1.6, height = 0.5,
    color = { r = 80, g = 220, b = 120, a = 110 },
}
Config.ShowGroundRing = false -- ring under the floating house icon

-- Floating house icon at the entry (runtime texture from html/img/house.png,
-- billboard sprite that slowly bobs up and down)
Config.HouseIcon = {
    height       = -0.45, -- relative to the CP point (ped center) -> hovers just above the ground
    bobAmount    = 0.10,  -- bob amplitude (m)
    bobSpeed     = 1100,  -- ms per cycle segment (higher = slower)
    size         = 0.016, -- base sprite width (screen fraction), distance-scaled
    drawDistance = 20.0,  -- icon only shows up close, not across the street
    ownedColor  = { r = 47, g = 128, b = 237, a = 235 }, -- BC blue
    vacantColor = { r = 76, g = 219, b = 40,  a = 235 }, -- BC green (elado)
}

-- Compact white text lines stacked directly above the house icon
-- (same draw origin as the icon, so they can never overlap it):
-- name / [E] Menu (owned) or name / [E] Menu / price (vacant)
Config.EntryText = {
    scale        = 0.30,  -- text size (distance-scaled with the icon)
    lineHeight   = 0.034, -- screen-space distance between lines
    gap          = 0.012, -- gap between the icon top and the lowest line
    drawDistance = 14.0,
}
Config.ExitMarker = { -- inside the shell, at the door offset
    -- Type 20 = downward arrow (not a flat ring). The arrow itself floats
    -- well above its coordinate, so zOffset is kept low (even slightly
    -- negative) to bring it down near head height instead of the ceiling.
    -- zOffset = arrow anchor height, textZOffset = "[E] Menu" text height,
    -- both relative to the landing point (raise/lower to taste in-game).
    type = 20, size = 0.5, height = 0.5, zOffset = -0.85, bob = true,
    textZOffset = -0.5,
    color = { r = 255, g = 80, b = 60, a = 160 },
}

-- Optional local prop spawned at the entry CP (nil = off)
Config.EntryProp = nil

--======================================================================
-- Faction chat announcements (standard chat:addMessage -> shows up in
-- okokChat too, no extra dependency). Entry + raid messages.
--======================================================================
Config.ChatPrefix = 'Frakció HQ'
Config.ChatColor  = { 47, 128, 237 }  -- entry announcements (BC blue)
Config.RaidColor  = { 219, 40, 40 }   -- police raid announcement (BC red)
Config.NotifyOnEnter = true           -- chat message to members on every entry

-- Where to eject a player stuck in the HQ band when no HQ matches anymore
Config.FallbackSpawn = { x = 215.76, y = -810.12, z = 30.73, h = 340.0 }

--======================================================================
-- HQ furniture: shares the loaf_housing furniture inventory
-- (users.loaf_furniture) at DB level - a piece is either in a house or
-- in the HQ, never both. Storage furniture is excluded.
--======================================================================
Config.Furniture = {
    max = 60, -- placed pieces per HQ
}

--======================================================================
-- Purchasable interiors. entrance = door offset relative to the shell
-- origin (heading 0), taken from loaf_housing Config.ShellOffsets.
-- Required asset packs must be ensured (see fxmanifest note).
-- avp_hs_shell_03_03 has no known entrance offset -> not listed.
--======================================================================
Config.Interiors = {
    -- avp03_01 z: measured in-game via the floor-snap log (loaf's 3.05
    -- pointed at the hull bottom on this pack, real floor is +5.61)
    { key = 'avp03_01',  label = 'Modern Villa I.',   model = 'avp_hs_shell_03_01_prop', entrance = vector3(0.44, -15.80, 8.66) },
    { key = 'avp03_02',  label = 'Modern Villa II.',  model = 'avp_hs_shell_03_02_prop', entrance = vector3(-7.92, -17.70, -1.90) },
    { key = 'pata5',     label = 'Luxusvilla',        model = 'pata_shell5',             entrance = vector3(-0.2953, -6.3107, 1.3177) },
    { key = 'highend',   label = 'High-end Penthouse', model = 'shell_highend',          entrance = vector3(-22.3571, -0.3636, 6.2174) },
    { key = 'highend2',  label = 'High-end Lakás',    model = 'shell_highendv2',         entrance = vector3(-10.4724, 0.8254, 0.9453) },
    { key = 'michael',   label = 'Rockford Villa',    model = 'shell_michael',           entrance = vector3(-9.3758, 5.6485, -5.0532) },
    { key = 'lester',    label = 'Régi Családi Ház',  model = 'shell_lester',            entrance = vector3(-1.6512, -6.0126, -1.3599) },
    { key = 'frankaunt', label = 'Külvárosi Ház',     model = 'shell_frankaunt',         entrance = vector3(-0.3333, -5.9446, -1.5599) },
    { key = 'apart1',    label = 'Apartman I.',       model = 'shell_apartment1',        entrance = vector3(-2.2138, 8.9556, 2.2123) },
    { key = 'apart2',    label = 'Apartman II.',      model = 'shell_apartment2',        entrance = vector3(-2.2559, 8.9858, 2.2122) },
    { key = 'apart3',    label = 'Apartman III.',     model = 'shell_apartment3',        entrance = vector3(11.4305, 4.4892, 1.0190) },
    { key = 'medium3',   label = 'Középkategóriás Ház', model = 'shell_medium3',         entrance = vector3(-2.5240, 7.7714, 0.1993) },
}

-- Shared lookup by key (used on both sides)
function Config.GetInterior(key)
    for i = 1, #Config.Interiors do
        if Config.Interiors[i].key == key then
            return Config.Interiors[i]
        end
    end
    return nil
end
