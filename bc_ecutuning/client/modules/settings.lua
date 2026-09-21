-- Per-vehicle tuning settings, cached client-side from the server. The mechanic
-- edits them; the server stores them per plate (DB) so they follow the car.
local Settings = {}

local store = {} -- plate -> settings

local function clamp(v, lo, hi)
    if v < lo then return lo elseif v > hi then return hi end
    return v
end

-- Keep only a known sound variant key; otherwise fall back to that side's default.
local function validSound(kind, key)
    local group = Config.Sound and Config.Sound[kind]
    if not group then return key end
    for _, v in ipairs(group.variants) do
        if v.key == key then return key end
    end
    return group.default
end

-- Keep only a known flame colour key; otherwise fall back to the default.
local function validFlameColor(key)
    local c = Config.FlameColors
    if not c then return key end
    for _, v in ipairs(c.list) do
        if v.key == key then return key end
    end
    return c.default
end

-- Fresh copy of the defaults so cached entries never share tables.
local function freshDefaults()
    local d = Config.Defaults
    return {
        popbang = {
            stage = d.popbang.stage, rpmMin = d.popbang.rpmMin, rpmMax = d.popbang.rpmMax,
            popDuration = d.popbang.popDuration, standPops = d.popbang.standPops, sound = d.popbang.sound,
            volume = d.popbang.volume,
        },
        flame = {
            enabled = d.flame.enabled, standFlame = d.flame.standFlame, rpmMin = d.flame.rpmMin,
            rpmMax = d.flame.rpmMax, duration = d.flame.duration, sound = d.flame.sound,
            volume = d.flame.volume, size = d.flame.size, color = d.flame.color,
            colorStrength = d.flame.colorStrength, exhausts = {},
        },
    }
end

-- Keep only valid exhaust indices (1..#Config.ExhaustBones), deduped. Empty = all pipes.
local function sanitizeExhausts(arr)
    if type(arr) ~= 'table' then return {} end
    local maxIdx = #Config.ExhaustBones
    local seen, out = {}, {}
    for _, v in ipairs(arr) do
        local i = math.floor(tonumber(v) or 0)
        if i >= 1 and i <= maxIdx and not seen[i] then
            seen[i] = true
            out[#out + 1] = i
        end
    end
    return out
end

-- Clamp every value into its configured bounds (defensive against bad input).
local function sanitize(s)
    local L = Config.Limits
    local pb, fl = s.popbang or {}, s.flame or {}

    pb.stage = clamp(math.floor(tonumber(pb.stage) or 0), 0, 3)
    pb.rpmMin = clamp(tonumber(pb.rpmMin) or 0, L.rpmMin.min, L.rpmMin.max)
    pb.rpmMax = clamp(tonumber(pb.rpmMax) or 100, L.rpmMax.min, L.rpmMax.max)
    -- A collapsed/inverted window would never trigger while driving; widen it.
    if pb.rpmMax <= pb.rpmMin then pb.rpmMax = math.min(L.rpmMax.max, pb.rpmMin + 40) end
    pb.popDuration = clamp(tonumber(pb.popDuration) or 200, L.popDuration.min, L.popDuration.max)
    pb.standPops = pb.standPops == true
    pb.sound = validSound('pop', pb.sound)
    pb.volume = clamp(tonumber(pb.volume) or 100, L.volume.min, L.volume.max)

    fl.enabled = fl.enabled == true
    fl.standFlame = fl.standFlame == true
    fl.rpmMin = clamp(tonumber(fl.rpmMin) or 0, L.rpmMin.min, L.rpmMin.max)
    fl.rpmMax = clamp(tonumber(fl.rpmMax) or 100, L.rpmMax.min, L.rpmMax.max)
    if fl.rpmMax <= fl.rpmMin then fl.rpmMax = math.min(L.rpmMax.max, fl.rpmMin + 40) end
    fl.duration = clamp(tonumber(fl.duration) or 300, L.flameDuration.min, L.flameDuration.max)
    fl.sound = validSound('flame', fl.sound)
    fl.volume = clamp(tonumber(fl.volume) or 100, L.volume.min, L.volume.max)
    fl.size = clamp(tonumber(fl.size) or 100, L.flameSize.min, L.flameSize.max)
    fl.color = validFlameColor(fl.color)
    local csMax = (L.colorStrength and L.colorStrength.max) or 5
    -- Not floored: the strength slider allows fractions (0.5, 1.5, …) for a fine, subtle tint.
    fl.colorStrength = clamp(tonumber(fl.colorStrength) or csMax, (L.colorStrength and L.colorStrength.min) or 0, csMax)
    fl.exhausts = sanitizeExhausts(fl.exhausts)
    if not Config.AllowFlamethrower then fl.enabled = false end

    s.popbang, s.flame = pb, fl
    return s
end

-- Public sanitize (used before sending mechanic edits to the server).
function Settings:Sanitize(s)
    return sanitize(s)
end

-- Cache settings received from the server (nil / bad = defaults).
function Settings:Set(plate, s)
    if s and type(s) == 'table' and s.popbang and s.flame then
        store[plate] = sanitize(s)
    else
        store[plate] = freshDefaults()
    end
end

function Settings:Get(plate)
    return store[plate] or freshDefaults()
end

return Settings
