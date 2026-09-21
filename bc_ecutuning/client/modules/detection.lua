-- Watches the local driver's RPM/throttle and fires exhaust effects on lift-off.
-- One lightweight thread runs only while driving a vehicle that has an effect on.
local Effects = require 'client.modules.effects'

local Detection = {}

local vehicle = 0
local settings = nil
local threadActive = false
local lastThrottle = 0.0
local lastRpm = 0.0
local lastPopAt = 0
local lastFlameAt = 0
local COOLDOWN = 120 -- ms between triggers of the same effect, prevents spam

local function isActive(s)
    if not s then return false end
    return (s.popbang and s.popbang.stage > 0)
        or (s.flame and s.flame.enabled and Config.AllowFlamethrower)
end

-- Fire the effects whose RPM window matches. Pop and flame are independent
-- (separate cooldowns), so having the flame enabled no longer suppresses the pop.
local function fire(rpmPct, stationary)
    local now = GetGameTimer()

    local flame = settings.flame
    if flame.enabled and Config.AllowFlamethrower and now - lastFlameAt >= COOLDOWN then
        local allow = stationary and flame.standFlame or (not stationary)
        if allow and rpmPct >= flame.rpmMin and rpmPct <= flame.rpmMax then
            lastFlameAt = now
            Effects:Flame(vehicle, flame.duration, flame.sound, flame.volume, flame.size, flame.color, false, flame.exhausts, flame.colorStrength)
        end
    end

    local pb = settings.popbang
    if pb.stage > 0 and now - lastPopAt >= COOLDOWN then
        local allow = stationary and pb.standPops or (not stationary)
        if allow and rpmPct >= pb.rpmMin and rpmPct <= pb.rpmMax then
            lastPopAt = now
            Effects:Pop(vehicle, pb.stage, pb.popDuration, pb.sound, pb.volume)
        end
    end
end

-- Start the detection thread if one isn't already running.
local function ensureLoop()
    if threadActive or vehicle == 0 or not isActive(settings) then return end
    threadActive = true
    CreateThread(function()
        while vehicle ~= 0 and isActive(settings) do
            if DoesEntityExist(vehicle) then
                local rpm = GetVehicleCurrentRpm(vehicle) * 100.0
                local throttle = GetControlNormal(0, 71) -- INPUT_VEH_ACCELERATE
                local stationary = GetEntitySpeed(vehicle) < 2.0
                -- Lift-off: throttle was held and is now released.
                local liftOff = lastThrottle > 0.6 and throttle < 0.2
                -- Rev-up: throttle held while RPM sweeps up past the threshold (once per sweep).
                local revUp = Config.RevPops and throttle > 0.7
                    and rpm >= Config.RevPopThreshold and lastRpm < Config.RevPopThreshold
                if liftOff or revUp then
                    fire(rpm, stationary)
                end
                lastThrottle = throttle
                lastRpm = rpm
            end
            Wait(Config.Tick)
        end
        threadActive = false
    end)
end

-- Bind detection to a vehicle + its settings (driver entered a car).
function Detection:Attach(veh, s)
    vehicle = veh or 0
    settings = s
    lastThrottle = 0.0
    lastRpm = 0.0
    ensureLoop()
end

-- Stop detecting (left the vehicle).
function Detection:Detach()
    vehicle = 0
    settings = nil
end

-- Apply new settings live (after saving in the menu) and (re)start if needed.
function Detection:Update(s)
    settings = s
    ensureLoop()
end

return Detection
