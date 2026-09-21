--[[
    bc_radio - client playback engine

    Your OWN radio plays as a flat 2D sound (constant, full personal volume, like
    the car's built-in radio) so it never wobbles as you drive. EVERYONE ELSE's
    radio plays as a positional xsound at their ped, kept in place by a light
    proximity loop, so passengers and nearby players hear it in 3D with falloff.
    Your personal slider sets your OWN radio's loudness; others play at a fixed
    Config.OthersVolume base so their radio carries outward the same for everyone.
]]

local Playback = {}

local others = {}        -- [src] = stationId  (broadcasters other than us)
local playing = {}       -- [src] = stationId  (positional instances we hold)
local selfStation = nil  -- our own station id (nil = off)
local volume = Config.DefaultVolume
local loopRunning = false

local SELF_SOUND = 'bc_radio_self'

local function hasX() return GetResourceState('xsound') == 'started' end
local function mySrc() return GetPlayerServerId(PlayerId()) end
local function posName(src) return ('bc_radio_%s'):format(src) end

-- Volume ceiling (xsound value at slider 100%); guards a bad config value.
local function ceil()
    local m = Config.MaxVolume
    if not m or m <= 0 then return 1.0 end
    return m
end

-- Base volume other players' radios play at (before 3D falloff). Not tied to the
-- personal slider, so a car radio carries outward regardless of listener setting.
local function othersVol()
    local v = Config.OthersVolume
    if not v then return 1.0 end
    return math.max(0.0, math.min(1.0, v))
end

local function xDestroy(name)
    if hasX() and exports.xsound:soundExists(name) then exports.xsound:Destroy(name) end
end

local function stopSound(src)
    xDestroy(posName(src))
    playing[src] = nil
end

-- Own radio: flat 2D, constant, full personal volume (no positional wobble).
local function applySelf()
    if not hasX() then return end
    xDestroy(SELF_SOUND)
    if selfStation then
        local st = Config.StationById[selfStation]
        if st then exports.xsound:PlayUrl(SELF_SOUND, st.url, volume) end
    end
end

-- Positional pass for other players' radios. Returns true if any is in range.
local function tick()
    local myCoords = GetEntityCoords(PlayerPedId())
    local manageDist = Config.MaxDistance + 6.0
    local anyInRange = false

    for src, stationId in pairs(others) do
        local station = Config.StationById[stationId]
        local plyId = GetPlayerFromServerId(src)
        local ped = plyId ~= -1 and GetPlayerPed(plyId) or 0

        if station and ped > 0 and DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            if #(myCoords - coords) <= manageDist then
                anyInRange = true
                local name = posName(src)
                if playing[src] ~= stationId then
                    xDestroy(name)
                    if hasX() then
                        -- Full base volume + falloff so it carries outward.
                        exports.xsound:PlayUrlPos(name, station.url, othersVol(), coords)
                        exports.xsound:Distance(name, Config.MaxDistance)
                        playing[src] = stationId
                    end
                elseif hasX() then
                    exports.xsound:Position(name, coords) -- follow the source
                end
            elseif playing[src] then
                stopSound(src) -- left range
            end
        elseif playing[src] then
            stopSound(src) -- out of scope / invalid ped
        end
    end

    return anyInRange
end

local function ensureLoop()
    if loopRunning then return end
    loopRunning = true
    CreateThread(function()
        while loopRunning do
            local inRange = false
            if next(others) ~= nil then inRange = tick() end
            Wait(inRange and Config.UpdateInterval or 1000)
        end
    end)
end

--======================================================================
-- Public interface
--======================================================================

function Playback.Available()
    return hasX()
end

-- Personal volume affects your OWN (2D) radio only; other players' radios play
-- at Config.OthersVolume so they carry outward regardless of your setting.
function Playback.SetVolume(v)
    volume = math.max(0.0, math.min(ceil(), (v or 0) + 0.0))
    if hasX() and exports.xsound:soundExists(SELF_SOUND) then
        exports.xsound:setVolume(SELF_SOUND, volume)
    end
end

function Playback.GetVolume()
    return volume
end

-- Server delta: one broadcaster started/changed/stopped.
function Playback.OnSync(src, stationId)
    local st = (stationId and Config.StationById[stationId]) and stationId or nil
    if src == mySrc() then
        if selfStation ~= st then selfStation = st; applySelf() end
    elseif st then
        others[src] = st
    else
        others[src] = nil
        stopSound(src)
    end
end

-- Server snapshot: full broadcaster map (join / resource restart).
function Playback.OnSyncAll(map)
    local me = mySrc()
    local incoming, newSelf = {}, nil
    for src, stationId in pairs(map or {}) do
        if Config.StationById[stationId] then
            if src == me then newSelf = stationId else incoming[src] = stationId end
        end
    end
    for src in pairs(others) do
        if incoming[src] == nil then stopSound(src) end
    end
    others = incoming
    if selfStation ~= newSelf then selfStation = newSelf; applySelf() end
end

-- Destroy every active radio sound (resource stop / full reset).
function Playback.StopAll()
    for src in pairs(playing) do xDestroy(posName(src)) end
    playing = {}
    others = {}
    xDestroy(SELF_SOUND)
    selfStation = nil
end

function Playback.Init(initialVolume)
    if initialVolume ~= nil then
        volume = math.max(0.0, math.min(ceil(), initialVolume + 0.0))
    end
    ensureLoop()
end

return Playback
