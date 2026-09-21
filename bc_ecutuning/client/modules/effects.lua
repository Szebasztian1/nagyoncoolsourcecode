-- Exhaust particle effects: pop & bang bursts and the flamethrower flame.
-- Particles are rendered LOCALLY (non-networked) and relayed to nearby players via our own
-- server event — the same path as the sound. Networked ptfx (StartNetworkedParticleFx...)
-- allocates a rage netGameEvent per burst; sustained popping fills the NETWORK_PTFX_EVENT
-- pool (~508) and crashes the game. Local render + relay avoids that pool entirely.
local Effects = {}

local ASSET = Config.Ptfx.asset
local RES = GetCurrentResourceName()
-- Tintable smoke that carries the flame colour (GTA fire particles can't be tinted).
local SMOKE_ASSET = (Config.Flame and Config.Flame.smokeAsset) or ''
local SMOKE_NAME = (Config.Flame and Config.Flame.smokeName) or ''

-- Load a named particle asset (retry-safe).
local function ensureAsset(asset)
    if not asset or asset == '' then return false end
    if HasNamedPtfxAssetLoaded(asset) then return true end
    RequestNamedPtfxAsset(asset)
    local tries = 0
    while not HasNamedPtfxAssetLoaded(asset) and tries < 100 do
        Wait(10)
        tries = tries + 1
    end
    return HasNamedPtfxAssetLoaded(asset)
end

-- Collect local-space offsets for every exhaust bone the vehicle has.
-- Networked particles take an entity offset (not a bone index), so bone world
-- positions are converted back into vehicle-local space.
-- Convert a stored exhaust-index array to a lookup set. Empty/nil = all exhausts (default).
local function exhaustSet(arr)
    if type(arr) ~= 'table' or #arr == 0 then return nil end
    local set = {}
    for _, i in ipairs(arr) do set[i] = true end
    return set
end

-- `enabled` (a set of 1-based indices into Config.ExhaustBones) filters which pipes emit;
-- nil = all. Index i matches Config.ExhaustBones[i], so the selection is stable per model.
function Effects:GetExhaustOffsets(vehicle, enabled)
    local offsets = {}
    for i, boneName in ipairs(Config.ExhaustBones) do
        if not enabled or enabled[i] then
            local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
            if boneIndex and boneIndex ~= -1 then
                local world = GetWorldPositionOfEntityBone(vehicle, boneIndex)
                offsets[#offsets + 1] = GetOffsetFromEntityGivenWorldCoords(vehicle, world.x, world.y, world.z)
            end
        end
    end
    if #offsets == 0 then
        -- No exhaust bone at all: fall back to a point behind the model.
        local min = GetModelDimensions(GetEntityModel(vehicle))
        offsets[1] = vector3(0.0, min.y + 0.1, Config.FallbackOffset.z)
    end
    -- PERF: cap the number of spawn points (some cars expose many exhaust bones → far too
    -- many particles). Fewer points = fewer overlapping particles = far cheaper to render.
    local cap = (Config.Ptfx and Config.Ptfx.maxBones) or #offsets
    while #offsets > cap do offsets[#offsets] = nil end
    return offsets
end

-- Spawn one burst from every exhaust offset. `rgb` (0-255) optionally tints it.
-- NON-networked on purpose (see the file header): nearby players get their own copy via relay.
local function burst(vehicle, offsets, name, scale, rgb)
    for i = 1, #offsets do
        local o = offsets[i]
        -- Orange fire. veh_backfire's colour is baked, so tinting it does nothing.
        UseParticleFxAssetNextCall(ASSET)
        StartParticleFxNonLoopedOnEntity(name, vehicle, o.x, o.y, o.z, 0.0, 0.0, 0.0, scale, false, false, false)
        -- Colour layer (flame only, i.e. rgb set): the chosen colour rides on a TINTABLE smoke
        -- particle over the flame, since fire particles ignore SetParticleFxNonLoopedColour.
        if rgb and SMOKE_ASSET ~= '' and HasNamedPtfxAssetLoaded(SMOKE_ASSET) then
            UseParticleFxAssetNextCall(SMOKE_ASSET)
            SetParticleFxNonLoopedColour(rgb[1] / 255.0, rgb[2] / 255.0, rgb[3] / 255.0)
            SetParticleFxNonLoopedAlpha(rgb[4] or Config.Flame.smokeAlpha or 0.28) -- rgb[4] = strength
            StartParticleFxNonLoopedOnEntity(SMOKE_NAME, vehicle, o.x, o.y, o.z, 0.0, 0.0, 0.0, Config.Flame.smokeScale or 1.2, false, false, false)
        end
    end
end

-- Play a sequence of bursts spanning the effect duration.
local function play(vehicle, name, scale, bursts, interval, rgb, enabled)
    if not DoesEntityExist(vehicle) then return end
    if not ensureAsset(ASSET) then return end
    -- Colour layer needs its own (tintable) asset loaded.
    if rgb and SMOKE_ASSET ~= '' then ensureAsset(SMOKE_ASSET) end
    local offsets = Effects:GetExhaustOffsets(vehicle, enabled)
    for i = 1, bursts do
        burst(vehicle, offsets, name, scale, rgb)
        if i < bursts then Wait(interval) end
    end
end

-- Resolve a flame colour key to its rgb (0-255), falling back to the default.
local function resolveFlameColor(key)
    local c = Config.FlameColors
    if not c then return nil end
    local fallback
    for _, v in ipairs(c.list) do
        if v.key == key then return v.rgb end
        if v.key == c.default then fallback = v.rgb end
    end
    return fallback or (c.list[1] and c.list[1].rgb)
end

-- ---- Sound (optional, requires the xsound resource) ----------------------

local function dbg(...)
    if Config.Debug then print('^3[EcuTuning]^7', ...) end
end

local function soundResource()
    return (Config.Sound and Config.Sound.resource) or 'xsound'
end

local function soundReady()
    if not (Config.Sound and Config.Sound.enabled) then return false end
    local state = GetResourceState(soundResource())
    if state ~= 'started' then
        dbg('sound resource "' .. soundResource() .. '" is not started (state=' .. tostring(state) .. ')')
        return false
    end
    return true
end

-- Resolve a variant's file/volume from config, falling back to that side's default.
local function resolveVariant(kind, key)
    local group = Config.Sound and Config.Sound[kind]
    if not group then return nil end
    local fallback
    for _, v in ipairs(group.variants) do
        if v.key == key then return v end
        if v.key == group.default then fallback = v end
    end
    return fallback or group.variants[1]
end

-- Play the chosen variant at world coords for THIS client (3D via xSound).
function Effects:PlayLocalSound(kind, key, coords, volPct)
    if not soundReady() then return end
    local v = resolveVariant(kind, key)
    if not v then dbg('no sound variant for', kind, key); return end
    -- Accept a full URL or a resource-relative path served over cfx-nui.
    local url = v.file:find('^https?://') and v.file or ('https://cfx-nui-%s/%s'):format(RES, v.file)
    local id = ('ecu_%s_%d'):format(kind, GetGameTimer())
    local res = soundResource()
    local vol = (v.volume or 0.8) * ((tonumber(volPct) or 100) / 100)
    if vol > 1.0 then vol = 1.0 elseif vol < 0.0 then vol = 0.0 end
    dbg('play ' .. kind .. '/' .. tostring(key) .. ' vol=' .. string.format('%.2f', vol) .. ' -> ' .. url)
    local ok, err = pcall(function()
        exports[res]:PlayUrlPos(id, url, vol, coords, false)
        exports[res]:Distance(id, Config.Sound.distance)
    end)
    if not ok then dbg('xSound export error: ' .. tostring(err)) end
    SetTimeout(4000, function()
        pcall(function()
            if exports[res]:soundExists(id) then exports[res]:Destroy(id) end
        end)
    end)
end

-- Server ids of players within `dist` of `coords`. Only a hint for the relay — the server
-- re-checks every target — but pre-filtering here keeps the payload and the server's re-check
-- small even in a dense OneSync area where GetActivePlayers can return 100+ ids.
local function nearbyTargets(coords, dist)
    local targets, me = {}, PlayerId()
    for _, p in ipairs(GetActivePlayers()) do
        if p ~= me then
            local ped = GetPlayerPed(p)
            if ped and ped ~= 0 and #(GetEntityCoords(ped) - coords) <= dist then
                local sid = GetPlayerServerId(p)
                if sid and sid > 0 then targets[#targets + 1] = sid end
            end
        end
    end
    return targets
end

local function soundDist()
    return (Config.Sound and Config.Sound.distance) or 30.0
end

-- Emit a sound locally and (unless localOnly) ask the server to relay it to nearby players.
-- localOnly is used by the panel's TEST button so a preview stays private to the tester.
local function emitSound(vehicle, kind, key, volPct, localOnly)
    if not soundReady() then return end
    local coords = GetEntityCoords(vehicle)
    Effects:PlayLocalSound(kind, key, coords, volPct)
    if localOnly then return end
    local targets = nearbyTargets(coords, soundDist())
    if targets[1] then
        TriggerServerEvent('EcuTuning:Server:PlaySound', kind, key, targets, volPct)
    end
end

-- Render the particle locally (non-networked) and (unless localOnly) ask the server to have
-- nearby players render it too, keyed by the vehicle's network id. `kind` maps to Config.Ptfx.
local function emitPtfx(vehicle, kind, scale, bursts, interval, rgb, localOnly, exhausts)
    local set = exhaustSet(exhausts)
    CreateThread(function()
        play(vehicle, Config.Ptfx[kind], scale, bursts, interval, rgb, set)
    end)
    if localOnly then return end
    if not (NetworkGetEntityIsNetworked and NetworkGetEntityIsNetworked(vehicle)) then return end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then return end
    local targets = nearbyTargets(GetEntityCoords(vehicle), soundDist())
    if targets[1] then
        TriggerServerEvent('EcuTuning:Server:Ptfx', netId, kind, scale, bursts, interval, rgb, targets, exhausts)
    end
end

-- Render a relayed particle on a remote vehicle (resolved from its network id). Params are
-- clamped defensively — the server already validates, this is belt-and-suspenders.
function Effects:PlayRemotePtfx(netId, kind, scale, bursts, interval, rgb, exhausts)
    if kind ~= 'pop' and kind ~= 'flame' then return end
    if type(netId) ~= 'number' or not NetworkDoesNetworkIdExist(netId) then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 or not DoesEntityExist(veh) then return end
    scale = math.min(math.max(tonumber(scale) or 1.0, 0.1), 6.0)
    bursts = math.min(math.max(math.floor(tonumber(bursts) or 1), 1), 20)
    interval = math.min(math.max(math.floor(tonumber(interval) or 70), 30), 500)
    -- rgb may be {r,g,b} or {r,g,b,alpha}; clamp the optional alpha.
    if type(rgb) ~= 'table' or (#rgb ~= 3 and #rgb ~= 4) then
        rgb = nil
    elseif rgb[4] then
        rgb[4] = math.min(math.max(tonumber(rgb[4]) or 0.28, 0.0), 1.0)
    end
    local set = exhaustSet(exhausts)
    CreateThread(function()
        play(veh, Config.Ptfx[kind], scale, bursts, interval, rgb, set)
    end)
end

-- Play native GTA exhaust-pops on the vehicle as a short burst (fuller/louder
-- "braap"). Auto-networked; needs no xsound, files, or audio-bank loading.
function Effects:PlayNativePop(vehicle, key, localOnly)
    local variant = resolveVariant('pop', key)
    if not variant or not variant.natives or not variant.natives[1] then return end
    local names = variant.natives
    local count = (Config.Sound and Config.Sound.nativeBurst) or 3
    local networked = not localOnly -- localOnly test previews stay on the tester
    dbg('native pop', variant.key, 'x' .. count)
    CreateThread(function()
        for i = 1, count do
            if not DoesEntityExist(vehicle) then break end
            PlaySoundFromEntity(-1, names[math.random(#names)], vehicle, 0, networked, 0)
            if i < count then Wait(math.random(30, 60)) end
        end
    end)
end

-- ---- Public API ----------------------------------------------------------

-- A pop & bang burst for a stage preset, scaled by the tuned duration.
-- localOnly = true keeps the effect private to this client (the TEST button).
function Effects:Pop(vehicle, stage, duration, soundKey, volPct, localOnly)
    local preset = Config.Stages[stage]
    if not preset then return end
    -- Per-variant source: a variant with `natives` plays native game audio; a
    -- file variant plays its .wav via xSound.
    local variant = resolveVariant('pop', soundKey)
    if variant and variant.natives and variant.natives[1] then
        Effects:PlayNativePop(vehicle, soundKey, localOnly)
    else
        emitSound(vehicle, 'pop', soundKey, volPct, localOnly)
    end
    local bursts = math.min(preset.bursts * 2, math.max(1, math.floor(duration / preset.interval)))
    emitPtfx(vehicle, 'pop', preset.scale, bursts, preset.interval, nil, localOnly)
end

-- A big GTR-style flamethrower flame. localOnly = true keeps it private (the TEST button).
-- `exhausts` = enabled pipe indices (empty/nil = all). `colorStrength` (0..colorStrength.max)
-- scales the tinted-smoke opacity; 0 = no colour (plain orange). rgb is passed as {r,g,b,alpha}.
function Effects:Flame(vehicle, duration, soundKey, volPct, sizePct, colorKey, localOnly, exhausts, colorStrength)
    local f = Config.Flame
    emitSound(vehicle, 'flame', soundKey, volPct, localOnly)
    local scale = f.scale * ((tonumber(sizePct) or 100) / 100)

    local maxCs = (Config.Limits.colorStrength and Config.Limits.colorStrength.max) or 5
    local cs = tonumber(colorStrength)
    if cs == nil then cs = maxCs end
    if cs < 0 then cs = 0 elseif cs > maxCs then cs = maxCs end
    local rgb = nil
    if cs > 0 then
        rgb = resolveFlameColor(colorKey)
        if rgb then rgb = { rgb[1], rgb[2], rgb[3], (f.smokeAlpha or 0.28) * (cs / maxCs) } end
    end

    -- PERF: a FIXED, small number of waves (f.bursts) keeps the simultaneous particle count
    -- low even on a quad-exhaust car (every pipe still flames). The tuned duration just spaces
    -- the waves out, so a longer flame doesn't mean more particles at once.
    local bursts = f.bursts
    local interval = math.max(f.interval, math.floor((tonumber(duration) or 300) / bursts))
    emitPtfx(vehicle, 'flame', scale, bursts, interval, rgb, localOnly, exhausts)
end

return Effects
