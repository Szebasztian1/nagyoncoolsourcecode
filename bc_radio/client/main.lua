--[[
    bc_radio - client entry

    Orchestration only: the Q keybind, the NUI panel (open/close + callbacks),
    personal volume persistence (KVP) and wiring the server sync into the
    positional playback engine. Audio lives in client/modules/playback.lua.
]]

local Playback = require 'client.modules.playback'

local KVP_VOLUME = 'bc_radio_volume'
local uiOpen = false
local myStation = nil   -- station id we are currently broadcasting (nil = off)

local function myId()
    return GetPlayerServerId(PlayerId())
end

local function inVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

-- True while the player is inside any interior (building/MLO). 0 = outside.
local function inInterior()
    return GetInteriorFromEntity(PlayerPedId()) ~= 0
end

-- True while something else owns the camera: admin noclip and spectate (freecam),
-- or a cutscene. Admin noclip flies UP on the very key this panel listens on, so
-- without this gate every press up there lands in tryOpen() - on foot that is the
-- "get in a vehicle" notice, in a car it would even steal NUI focus mid-flight.
local function inScriptedCam()
    return not IsGameplayCamRendering()
end

-- Stop our own broadcast (server-authoritative; others stop hearing us too).
local function stopRadio()
    if myStation == nil then return end
    myStation = nil
    TriggerServerEvent('Radio:Server:SetStation', false)
end

-- Minimum gap (ms) between two IDENTICAL notices. Anything that can fire the
-- keybind in a burst (a held key that re-arms, a key shared with another script)
-- then shows one line instead of a stack of them.
local NOTIFY_GAP <const> = 4000
local lastNotifyAt = {}

local function notify(msg)
    local now = GetGameTimer()
    local prev = lastNotifyAt[msg]
    if prev and now - prev < NOTIFY_GAP then return end
    lastNotifyAt[msg] = now

    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(msg)
    else
        TriggerEvent('esx:showNotification', msg)
    end
end

--======================================================================
-- Volume persistence (per client, KVP)
--======================================================================
-- Effective ceiling (guards a bad config value).
local function maxVol()
    local m = Config.MaxVolume
    if not m or m <= 0 then return 1.0 end
    return m
end

-- xsound value (0..maxVol) -> slider percent (0..100)
local function volToPct(v)
    return math.floor(math.min(1.0, (v or 0) / maxVol()) * 100 + 0.5)
end

local function loadVolume()
    local raw = GetResourceKvpString(KVP_VOLUME)
    local v = raw and tonumber(raw) or nil
    if not v then v = Config.DefaultVolume end
    return math.max(0.0, math.min(maxVol(), v))
end

local function saveVolume(v)
    SetResourceKvp(KVP_VOLUME, tostring(v))
end

--======================================================================
-- NUI panel
--======================================================================
local function buildStationPayload()
    local list = {}
    for i, s in ipairs(Config.Stations) do
        list[i] = { id = s.id, name = s.name, genre = s.genre, icon = s.icon }
    end
    return list
end

local function openUI()
    if uiOpen or IsNuiFocused() then return end
    if Config.VehicleOnly and not inVehicle() then return end
    if Config.BlockInInterior and inInterior() then return end
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        stations = buildStationPayload(),
        current = myStation or false,
        volume = volToPct(Playback.GetVolume()),
        xsound = Playback.Available(),
        key = Config.OpenKey, -- so the panel can close on the same key
    })
end

local function closeUI()
    if not uiOpen then return end
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('select', function(data, cb)
    local id = data and data.id
    if id and Config.StationById[id] then
        myStation = id
        TriggerServerEvent('Radio:Server:SetStation', id)
        if not Playback.Available() then
            notify('~y~A rádió hang (xsound) nem fut a szerveren.')
        end
    end
    cb({ ok = true })
end)

RegisterNUICallback('stop', function(_, cb)
    stopRadio()
    cb({ ok = true })
end)

RegisterNUICallback('volume', function(data, cb)
    local pct = data and tonumber(data.value) or nil
    if pct then
        pct = math.max(0, math.min(100, pct))
        local v = (pct / 100) * maxVol() -- percent -> capped xsound volume
        Playback.SetVolume(v)
        saveVolume(v)
    end
    cb({ ok = true })
end)

RegisterNUICallback('close', function(_, cb)
    closeUI()
    cb({ ok = true })
end)

--======================================================================
-- Keybind (rebindable in FiveM settings)
--======================================================================
-- Registered as a +command/-command pair so we see key down and key up.
-- The key is only contested where bc_siren reacts to it: the DRIVER of an
-- emergency-class vehicle, where a tap is its police lights. Only there do we
-- demand a hold; anywhere else a tap opens the panel straight away. Closing is
-- always a plain tap, handled inside the NUI (the keymapping cannot fire while
-- the panel holds focus).
local holdId = 0
local holding = false

local function needsHold()
    if not Config.HoldInEmergencyOnly then return true end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or GetVehicleClass(veh) ~= 18 then return false end

    return GetPedInVehicleSeat(veh, -1) == ped -- only the driver clashes
end

local function tryOpen()
    if inScriptedCam() then return end -- silent: the key belongs to noclip/spectate there
    if Config.VehicleOnly and not inVehicle() then
        notify('~y~Ülj be egy járműbe a rádió használatához.')
        return
    end
    openUI() -- interior gate lives (silently) in openUI
end

RegisterCommand('+bcradio', function()
    if uiOpen then return end
    -- Admin noclip (mate_admin freecam) flies up on this key and re-arms the
    -- mapping while it is held, so the press has to die here, not in tryOpen().
    if inScriptedCam() then return end

    if not needsHold() then
        tryOpen() -- no clash here: open on the tap
        return
    end

    holding = true
    holdId = holdId + 1
    local id = holdId
    CreateThread(function()
        Wait(Config.HoldTime or 600)
        -- released early, or a newer press superseded this one
        if not holding or holdId ~= id then return end
        holding = false
        tryOpen()
    end)
end, false)

RegisterCommand('-bcradio', function()
    holding = false
end, false)

RegisterKeyMapping('+bcradio', 'BC Rádió megnyitása', 'keyboard', Config.OpenKey)

--- Hold duration (ms) needed to open the panel. Exposed so a resource sharing
--- this key (e.g. bc_siren's police lights on Q) can treat anything shorter as
--- its own tap and stay out of the way of the hold.
exports('GetHoldTime', function()
    return Config.HoldTime or 600
end)

--======================================================================
-- Server sync -> playback engine
--======================================================================
RegisterNetEvent('Radio:Client:Sync', function(src, stationId)
    Playback.OnSync(src, stationId)
    if src == myId() then
        myStation = stationId or nil
        -- Reconcile an open panel with the authoritative state (covers the
        -- coalesced/trailing server broadcast so optimistic UI can never stick).
        if uiOpen then SendNUIMessage({ action = 'current', current = myStation or false }) end
    end
end)

RegisterNetEvent('Radio:Client:SyncAll', function(map)
    Playback.OnSyncAll(map)
    myStation = (map and map[myId()]) or nil
    if uiOpen then SendNUIMessage({ action = 'current', current = myStation or false }) end
end)

--======================================================================
-- Lifecycle
--======================================================================
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    Playback.Init(loadVolume())
    if Config.DisableGtaRadio then
        SetUserRadioControlEnabled(false) -- stop the player scrolling GTA stations
    end
    -- Pull the current broadcaster picture (we may have joined mid-session).
    CreateThread(function()
        Wait(1500)
        TriggerServerEvent('Radio:Server:RequestSync')
    end)
    -- Vehicle watch: mute GTA's radio while driving, and auto-close the panel
    -- when the player leaves the car. Single low-rate thread (event rules).
    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                if Config.DisableGtaRadio then
                    SetVehicleRadioEnabled(GetVehiclePedIsIn(ped, false), false)
                end
                Wait(500)
            else
                if uiOpen then closeUI() end
                if Config.StopOnExit then stopRadio() end
                Wait(1200)
            end
        end
    end)
end)

AddEventHandler('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if uiOpen then SetNuiFocus(false, false) end
    Playback.StopAll()
end)
