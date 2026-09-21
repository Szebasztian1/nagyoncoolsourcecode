Config = {}

-- How the tuning panel opens. Must be driving a vehicle.
Config.Command = 'ecu'         -- /ecu opens the panel
Config.Keybind = ''            -- optional default key (e.g. 'F7'); empty = command only

-- Diagnostics: server logs getdata/buy/save/apply lines and enables the /ecuinfo,
-- /ecunative debug commands. Leave OFF in production — on a full server the getdata log
-- (one line per player entering a vehicle) floods the console. That log is NOT tied to the
-- marker: every driver fetches their plate's tuning on entry, everywhere on the map.
Config.Debug = false

-- Global feature switch. When false the Flammenwerfer tab is locked for everyone.
Config.AllowFlamethrower = true

-- Two separate spots. Both need the player to sit in a driver seat.
--
-- SHOP: any player tests pop sounds and buys them for PP (unlocked per plate, forever).
-- MECHANIC: only Config.Mechanic.job at >= Config.Mechanic.grade opens the full tuning
-- panel here and installs the bought sound into the car.
--
-- Own proximity-optimised markers. To use MateHUN's AddMarker, send me its signature and
-- I'll swap the DrawMarker call in client/main.lua.
Config.Shop = {
    label  = 'Bennys Telep', -- shown in the [E] prompt
    marker = vector3(-781.7675, -2448.591, 14.570721),
    range  = 3.0, -- interaction distance (metres)
}

Config.Mechanic = {
    job    = 'bennysservice',
    grade  = 3, -- >= this grade may install/tune at the mechanic marker
    label  = 'Autós Piac', -- shown in the [E] prompt + the "go get it installed" notify
    marker = vector3(-196.8511, -1328.493, 30.586997),
    range  = 3.0,
}

-- Discord webhook that logs every mechanic install (plate, mechanic, player, sound, time).
-- Leave empty ('') to disable logging.
Config.LogWebhook = 'https://discord.com/api/webhooks/1525206563088760925/ADEIFIrY9mKZb402BEePGeI7jyKOfVfznsLrYsdNOrejhSrPWGSaFUtTCU9Ur58Zl1iy'

-- PP charged per pop sound the player buys (unlocked on the plate, kept forever).
Config.SoundPrice = 2500

-- PP economy, backed by `bc_ppshop`.
--   getpp(src)            -> READS the balance. It never grants PP (granting would be
--                            addpp); it exists only so we can check the player can afford it.
--   removepp(src, amount) -> deducts. Returns NOTHING and does NOT reject a broke player
--                            (confirmed in-game), so the balance MUST be checked first.
-- Both are pcall-guarded server-side, so a missing bc_ppshop reports an error instead of
-- silently failing — or silently granting — the purchase.
Config.PP = {
    get = function(src)
        return exports['bc_ppshop']:getpp(src) or 0
    end,
    remove = function(src, amount)
        return exports['bc_ppshop']:removepp(src, amount) ~= false
    end,
}

-- Debug: /ecu opens the mechanic panel with all sounds unlocked (bypasses the
-- marker + job) so you can test the UI. MUST be false in production — otherwise any
-- player can open the panel and trigger effects/sounds with the TEST button.
Config.DebugOpen = false

-- Detection tick in ms while actively driving. Lower = snappier pops, higher = cheaper.
Config.Tick = 50

-- Also fire pops when you rev up hard (RPM crosses this % while on throttle),
-- not only on gas release. Set RevPops = false for lift-off-only (realistic) feel.
Config.RevPops = true
Config.RevPopThreshold = 80 -- percent of max RPM

-- Particle assets. Override if your server ships custom exhaust ptfx.
Config.Ptfx = {
    asset = 'core',
    pop   = 'veh_backfire', -- small backfire pop
    flame = 'veh_backfire', -- flamethrower reuses the asset with a larger scale
    -- Cap on exhaust spawn points. Keep this at 6 so EVERY exhaust flames (a quad-exhaust
    -- car needs all 4). FPS is controlled by scale + wave count instead — capping bones just
    -- left some pipes without a flame. Only lower this if a specific car misbehaves.
    maxBones = 6,
}

-- Exhaust bones probed in order; a particle is spawned from every bone that exists.
Config.ExhaustBones = { 'exhaust', 'exhaust_2', 'exhaust_3', 'exhaust_4', 'exhaust_5', 'exhaust_6' }

-- Local-space offset used when a vehicle has no exhaust bone at all (rear of the car).
Config.FallbackOffset = vector3(0.0, 0.0, 0.35)

-- Pop & Bang stage presets. Stage 0 = off.
-- scale = particle size, bursts = pops per trigger, interval = ms between bursts.
Config.Stages = {
    [1] = { label = 'Halk',      sub = 'Civil',   scale = 0.6, bursts = 1, interval = 90 },
    [2] = { label = 'Normál',    sub = 'Sport',   scale = 1.0, bursts = 2, interval = 80 },
    [3] = { label = 'Agresszív', sub = 'Verseny', scale = 1.5, bursts = 4, interval = 70 },
}

-- Flammenwerfer: big GTR-style flame.
-- PERF: `scale` is the #1 FPS cost (huge overlapping alpha particles = overdraw). 2.4 still
-- reads as a big flame; drop toward 1.8 if it's heavy. `bursts` × Config.Ptfx.maxBones is how
-- many particles a flame spawns — kept modest on purpose.
Config.Flame = {
    scale    = 2.4,
    bursts   = 3,
    interval = 80,
    -- Flame colour: GTA fire particles (veh_backfire) are baked orange and ignore
    -- SetParticleFxNonLoopedColour. So the chosen colour rides on a TINTABLE SMOKE particle
    -- layered over the flame. Set smokeAsset = '' to disable it (plain orange flame).
    -- smokeAlpha is the opacity at MAX colour strength (Config.Limits.colorStrength.max); the
    -- per-car "Szín erőssége" slider scales it down from there. Keep it low or the colour
    -- swamps the flame ("everything pure green"). smokeScale keeps the tint near the pipe.
    smokeAsset = 'scr_recartheft',
    smokeName  = 'scr_wheel_burnout',
    smokeScale = 0.4,  -- small tint near the pipe, not a big cloud (user: "valamikor mindig nagy")
    smokeAlpha = 0.15, -- opacity when colour is ON (fixed strength); lower this if still too much
}

-- Selectable flame colours (applied with SetParticleFxNonLoopedColour). `rgb` is
-- 0-255. The player picks one per vehicle in the NUI.
Config.FlameColors = {
    default = 'orange',
    list = {
        { key = 'orange', label = 'Narancs', rgb = { 255, 110, 20 } },
        { key = 'red',    label = 'Piros',   rgb = { 255, 40, 30 } },
        { key = 'blue',   label = 'Kék',     rgb = { 40, 130, 255 } },
        { key = 'cyan',   label = 'Cián',    rgb = { 40, 230, 230 } },
        { key = 'green',  label = 'Zöld',    rgb = { 60, 220, 60 } },
        { key = 'purple', label = 'Lila',    rgb = { 170, 60, 240 } },
        { key = 'pink',   label = 'Rózsa',   rgb = { 255, 80, 200 } },
        { key = 'white',  label = 'Fehér',   rgb = { 255, 240, 230 } },
    },
}

-- Optional pop/flame sound. Requires the `xsound` resource (3D, heard by nearby
-- players). If xsound is missing or `enabled = false`, the effects stay silent.
-- Each side offers selectable variants (picked per vehicle in the NUI). `key` is
-- what settings store, `label` shows in the picker. Files are resource-relative
-- (served over cfx-nui) or a full https:// URL. Volume: 0.0-1.0.
Config.Sound = {
    enabled  = true,
    resource = 'xsound', -- exact name of your installed xSound-compatible resource
    distance = 20.0, -- max hearing distance in metres (also the server's relay fan-out radius)
    -- Pop sound source: 'xsound' = the .wav files (used now, sounds distinct);
    -- 'native' = built-in GTA exhaust pops. Per-variant: a variant with `natives`
    -- uses native audio, a file-only variant always uses xSound.
    popMode = 'xsound',
    nativeBurst = 3, -- native pops per trigger when a variant uses `natives`
    pop = {
        default = 'v1',
        -- Pop options are your turbo/blow-off wavs, filled from the named list at
        -- the very bottom of this file (all play via xSound, so they're distinct).
        variants = {},
    },
    flame = {
        default = 'deep',
        variants = {
            { key = 'deep',  label = 'Mély',  file = 'sounds/flame_deep.wav',  volume = 0.60 },
            { key = 'roar',  label = 'Roar',  file = 'sounds/flame_roar.wav',  volume = 0.60 },
            { key = 'jet',   label = 'Jet',   file = 'sounds/flame_jet.wav',   volume = 0.55 },
            { key = 'burst', label = 'Burst', file = 'sounds/flame_burst.wav', volume = 0.60 },
        },
    },
}

-- UI slider bounds. RPM values are percent of max RPM (0-100); durations in ms.
-- `volume` caps at 30%: the effects were too loud at full scale. Saved settings above the
-- cap are clamped down on load (client/modules/settings.lua), and the server clamps the
-- relayed volume to it too, so a modded NUI cannot ask for a louder sound.
Config.Limits = {
    rpmMin        = { min = 0,   max = 100 },
    rpmMax        = { min = 0,   max = 100 },
    popDuration   = { min = 50,  max = 600 },
    flameDuration = { min = 100, max = 800 },
    volume        = { min = 0,   max = 10 },
    flameSize     = { min = 50,  max = 100 },
    -- Flame COLOUR: fixed subtle strength, not a slider — the panel only offers an on/off
    -- toggle now (user found any adjustable value too strong). `max` is the ON value; the actual
    -- opacity is Config.Flame.smokeAlpha. 0 = colour off.
    colorStrength = { min = 0,   max = 0.1 },
}

-- Volume (%) the panel's TEST button plays at, regardless of the tuned volume — you sit
-- right on top of the exhaust while testing. Native "Régi" pops ignore it (GTA gives native
-- sounds no volume control).
Config.TestVolume = 10

-- Settings applied to a vehicle that has never been tuned.
Config.Defaults = {
    popbang = { stage = 0, rpmMin = 30, rpmMax = 95, popDuration = 200, standPops = false, sound = 'v1', volume = 10 },
    flame   = { enabled = false, standFlame = false, rpmMin = 70, rpmMax = 90, duration = 300, sound = 'deep', volume = 10, size = 100, color = 'orange', colorStrength = 0.1, exhausts = {} },
}

-- Pop sounds = your wavs in sounds/<n>.wav. `PopLabels` gives named files a Hungarian
-- label; every other file is numbered sequentially "Hang 1", "Hang 2", … in list order
-- (not by file number). Add/remove numbers in `PopFiles`.
local PopLabels = {
    [1] = 'Gyári', [2] = 'Sport', [4] = 'Verseny', [5] = 'Utcai', [6] = 'Mély',
    [7] = 'Csapkodó', [9] = 'Pattogós', [11] = 'Ütős', [12] = 'Morgó', [13] = 'Sziszegő',
    [14] = 'Sípoló', [15] = 'Töltő', [16] = 'Durranó', [17] = 'Ropogó', [18] = 'Lökés',
    [19] = 'Végfordulat', [20] = 'Agresszív', [21] = 'Turbó',
}
local PopFiles = {
    1, 2, 4, 5, 6, 7, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
    69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88,
    89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100,
}
local hangIndex = 0
for _, n in ipairs(PopFiles) do
    local v = Config.Sound.pop.variants
    local label = PopLabels[n]
    if not label then
        hangIndex = hangIndex + 1
        label = 'Hang ' .. hangIndex
    end
    v[#v + 1] = { key = 'v' .. n, label = label, file = ('sounds/%d.wav'):format(n), volume = 1.0 }
end

-- The remaining named pop wavs (the old synth set + WASTE_GATE). Remove any you
-- don't want. The 4 flame_*.wav are flame sounds (Config.Sound.flame), not here.
local ExtraPops = {
    { 'x_deep',   'Basszus',    'sounds/pop_deep.wav' },
    { 'x_v8',     'V8+',        'sounds/pop_v8.wav' },
    { 'x_turbo',  'Pörgős',     'sounds/pop_turbo.wav' },
    { 'x_burble', 'Bugás',      'sounds/pop_burble.wav' },
    { 'x_sport',  'Sportos',    'sounds/pop_sport.wav' },
    { 'x_race',   'Versenyző',  'sounds/pop_race.wav' },
    { 'wg',       'Lefúvó',     'sounds/WASTE_GATE.wav' },
}
for _, e in ipairs(ExtraPops) do
    local v = Config.Sound.pop.variants
    v[#v + 1] = { key = e[1], label = e[2], file = e[3], volume = 1.0 }
end

-- Native GTA exhaust pops (from unifried_tunning) — no files, played via
-- PlaySoundFromEntity (auto-networked, and with NO volume control).
--
-- Passed with audioRef = 0 (no soundset) these names cannot resolve to per-car audio,
-- so every one of them falls back to the same generic pop. The original script hid this
-- by picking a random name per backfire. We therefore expose them as ONE "Régi" entry
-- whose `natives` list holds all names — `Effects:PlayNativePop` picks a random one per
-- pop, reproducing the original behaviour without selling 40 identical sounds.
local OldNatives = {
    'zr350_exhaust_pops', 'calico_exhaust_pops', 'comet6_exhaust_pops', 'cypher_exhaust_pops',
    'dominator7_exhaust_pops', 'futo2_exhaust_pops', 'jester4_exhaust_pops', 'remus_exhaust_pops',
    'rt3000_exhaust_pops', 'tailgater2_exhaust_pops', 'tuner_hatch01_exhaust_pops', 'tuner_hatch02_exhaust_pops',
    'tuner_hatch03_exhaust_pops', 'tuner_hatch04_exhaust_pops', 'tuner_muscle01_exhaust_pops', 'vectre_exhaust_pops',
    'warrener2_exhaust_pops', 'calico_exhaust_pops_upgrade', 'comet6_exhaust_pops_upgrade', 'cypher_exhaust_pops_upgraded',
    'dominator7_exhaust_pops_upgrade', 'jester4_exhaust_pops_upgrade', 'remus_exhaust_pops_upgraded', 'rt3000_exhaust_pops_upgrade',
    'tailgater2_exhaust_pops_upgraded', 'tuner_hatch02_exhaust_pops_upgraded', 'tuner_hatch03_exhaust_pops_upgrade', 'tuner_hatch04_exhaust_pops_upgraded',
    'vectre_exhaust_pops_upgrade', 'zr350_exhaust_pops_upgraded', 'cypher_limiter_pops', 'remus_limiter_pops',
    'tailgater2_limiter_pops', 'tuner_hatch02_limiter_pops', 'tuner_hatch04_limiter_pops', 'tuner_muscle01_limiter_pops',
    'vectre_limiter_pops', 'warrener2_limiter_pops', 'rt3000_upgraded_limiter_pops', 'tuner_hatch03_upgraded_limiter_pops',
}
do
    local v = Config.Sound.pop.variants
    v[#v + 1] = { key = 'old', label = 'Régi', natives = OldNatives }
end
