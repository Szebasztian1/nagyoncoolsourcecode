-- Entry: marker-based access. Player -> sound shop (buy for PP); mechanic -> full
-- tuning panel. Settings come from / go to the server (per plate).
local Settings = require 'client.modules.settings'
local Detection = require 'client.modules.detection'
local Effects = require 'client.modules.effects'

local ESX = exports['es_extended']:getSharedObject()
local M = Config.Mechanic

local isOpen = false
local currentPlate = nil
local currentUnlocked = {} -- key -> true
local jobName, jobGrade = nil, 0
local textShown = false

-- Must match the server's cleanPlate (upper + trailing spaces trimmed), otherwise the
-- plate comparison in EcuTuning:Client:Bought / :Saved silently misses.
local function trimPlate(plate)
    if not plate then return '' end
    return (plate:upper():gsub('%s+$', ''))
end

-- ---- ESX job cache ----
local function setJob(job) jobName = job and job.name or nil; jobGrade = (job and job.grade) or 0 end
RegisterNetEvent('esx:playerLoaded', function(x) if x then setJob(x.job) end end)
RegisterNetEvent('esx:setJob', function(j) setJob(j) end)
CreateThread(function()
    Wait(1500)
    local pd = ESX.GetPlayerData and ESX.GetPlayerData()
    if pd then setJob(pd.job) end
end)

local function isMechanic() return jobName == M.job and (jobGrade or 0) >= M.grade end

-- ---- NUI data helpers ----
local function stagesForNui()
    local t = {}
    for i = 1, 3 do
        local s = Config.Stages[i]
        if s then t[#t + 1] = { level = i, label = s.label, sub = s.sub } end
    end
    return t
end

-- Only the pop sounds this car has unlocked (bought). Flame = all (mechanic-only).
local function soundListPop()
    local t = {}
    for _, v in ipairs(Config.Sound.pop.variants) do
        if currentUnlocked[v.key] then t[#t + 1] = { key = v.key, label = v.label, native = (v.natives ~= nil) } end
    end
    return t
end

local function soundListFlame()
    local t = {}
    for _, v in ipairs(Config.Sound.flame.variants) do
        t[#t + 1] = { key = v.key, label = v.label }
    end
    return t
end

local function flameColorList()
    local t = {}
    if Config.FlameColors then
        for _, v in ipairs(Config.FlameColors.list) do
            t[#t + 1] = { key = v.key, label = v.label, rgb = v.rgb }
        end
    end
    return t
end

-- Every pop sound for the shop (native flag drives the NATÍV tag).
local function shopSounds()
    local t = {}
    for _, v in ipairs(Config.Sound.pop.variants) do
        t[#t + 1] = { key = v.key, label = v.label, native = (v.natives ~= nil) }
    end
    return t
end

-- Keys unlocked on the current car (array form for the NUI).
local function unlockedKeys()
    local t = {}
    for _, v in ipairs(Config.Sound.pop.variants) do
        if currentUnlocked[v.key] then t[#t + 1] = v.key end
    end
    return t
end

local function vehName(model)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if not name or name == '' or name == 'NULL' then name = GetDisplayNameFromVehicleModel(model) end
    return name
end

-- 1-based indices (into Config.ExhaustBones) of the exhaust pipes this car actually has, so
-- the panel only offers real ones. The flame's exhaust picker uses these.
local function vehicleExhausts(veh)
    local list = {}
    for i, boneName in ipairs(Config.ExhaustBones) do
        local bi = GetEntityBoneIndexByName(veh, boneName)
        if bi and bi ~= -1 then list[#list + 1] = i end
    end
    return list
end

-- Shared NUI payload for both the mechanic panel and the player shop.
local function nuiData(mode, veh, plate)
    return {
        mode = mode,
        settings = Settings:Get(plate),
        vehicle = { name = vehName(GetEntityModel(veh)), plate = plate },
        limits = Config.Limits,
        stages = stagesForNui(),
        sounds = { pop = soundListPop(), flame = soundListFlame() },
        shop = shopSounds(),
        unlocked = unlockedKeys(),
        price = Config.SoundPrice,
        flameColors = flameColorList(),
        availableExhausts = vehicleExhausts(veh),
        defaults = Config.Defaults,
        allowFlamethrower = Config.AllowFlamethrower,
    }
end

-- ---- Vehicle data from the server ----
local function applyData(veh, plate, data)
    currentUnlocked = {}
    if data and data.unlocked then
        for _, k in ipairs(data.unlocked) do currentUnlocked[k] = true end
    end
    Settings:Set(plate, data and data.settings)
    local s = Settings:Get(plate)
    if cache.vehicle == veh and cache.seat == -1 then
        Detection:Attach(veh, s)
    end
    if Config.Debug then
        print(('^3[EcuTuning]^7 apply plate="%s" mentett=%s stage=%s lang=%s'):format(
            plate, tostring(data and data.settings ~= nil), tostring(s.popbang.stage), tostring(s.flame.enabled)))
    end
end

local function refresh()
    local veh = cache.vehicle
    if not (veh and cache.seat == -1) then
        currentPlate, currentUnlocked = nil, {}
        Detection:Detach()
        return
    end
    local plate = trimPlate(GetVehicleNumberPlateText(veh))
    currentPlate = plate
    lib.callback('EcuTuning:Server:GetData', false, function(data)
        if cache.vehicle ~= veh or cache.seat ~= -1 then return end
        -- A later refresh (e.g. the plate settled) superseded us: drop the stale answer,
        -- otherwise it would overwrite the good settings with defaults.
        if plate ~= currentPlate then return end
        applyData(veh, plate, data)
    end, plate)
end

-- ---- Mechanic panel (React NUI) ----
local function closeMenu()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
end

local function openPanel()
    if isOpen then return end
    local veh = cache.vehicle
    if not veh or cache.seat ~= -1 then return end
    local plate = trimPlate(GetVehicleNumberPlateText(veh))

    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'setData', data = nuiData('mechanic', veh, plate) })
    SendNUIMessage({ action = 'setVisible', data = true })
end

RegisterNUICallback('save', function(body, cb)
    -- The server validates job + grade + marker, re-derives the plate from our vehicle when
    -- it can, and enforces that the pop sound is unlocked.
    local veh = cache.vehicle
    if veh and cache.seat == -1 then
        TriggerServerEvent('EcuTuning:Server:MechanicSave', trimPlate(GetVehicleNumberPlateText(veh)), Settings:Sanitize(body))
    end
    closeMenu()
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    closeMenu()
    cb('ok')
end)

RegisterNUICallback('test', function(body, cb)
    local veh = cache.vehicle
    if veh and cache.seat == -1 and DoesEntityExist(veh) then
        -- Always preview at Config.TestVolume, never at the tuned volume: the tester sits in
        -- the car. Ignoring body.volume also means the NUI cannot ask for a louder preview.
        -- localOnly = true: a test stays on the tester — nobody nearby hears or sees it.
        local vol = tonumber(Config.TestVolume) or 15
        if body and body.type == 'flame' and Config.AllowFlamethrower then
            Effects:Flame(veh, tonumber(body.duration) or 300, body.sound, vol, body and body.size, body and body.color, true, body and body.exhausts, body and body.colorStrength)
        else
            local stage = math.max(1, math.floor(tonumber(body and body.stage) or 2))
            Effects:Pop(veh, stage, tonumber(body and body.duration) or 200, body and body.sound, vol, true)
        end
    end
    cb('ok')
end)

-- Shop: buy a pop sound. The server checks PP + marker and re-derives the plate from the
-- vehicle we sit in when it can, so a spoofed plate is overridden there.
RegisterNUICallback('buy', function(body, cb)
    local veh = cache.vehicle
    if veh and cache.seat == -1 and body and type(body.sound) == 'string' then
        TriggerServerEvent('EcuTuning:Server:BuySound', trimPlate(GetVehicleNumberPlateText(veh)), body.sound)
    end
    cb('ok')
end)

-- ---- Player sound shop (same React NUI, shop mode) ----
local function openShop()
    if isOpen then return end
    local veh = cache.vehicle
    if not veh or cache.seat ~= -1 then return end
    local plate = trimPlate(GetVehicleNumberPlateText(veh))

    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'setData', data = nuiData('shop', veh, plate) })
    SendNUIMessage({ action = 'setVisible', data = true })
end

-- ---- Service markers (proximity-optimised) ----
-- textShown holds the message currently on screen, so switching prompts actually redraws it.
local function hideText() if textShown then lib.hideTextUI() textShown = nil end end
local function showText(m) if textShown ~= m then lib.showTextUI(m) textShown = m end end

-- Both spots share one thread. The shop is open to every driver; the mechanic spot only
-- opens the tuning panel for Config.Mechanic.job at >= Config.Mechanic.grade.
local Spots = {
    { marker = Config.Shop.marker,     range = Config.Shop.range,     shop = true,  label = Config.Shop.label },
    { marker = Config.Mechanic.marker, range = Config.Mechanic.range, shop = false, label = Config.Mechanic.label },
}

local function spotText(prefix, label)
    if label and label ~= '' then return prefix .. ' · ' .. label end
    return prefix
end

CreateThread(function()
    while true do
        local wait = 1500
        if not isOpen then
            local coords = GetEntityCoords(cache.ped)
            local active
            for i = 1, #Spots do
                local s = Spots[i]
                local dist = #(coords - s.marker)
                if dist < 40.0 then
                    wait = 0
                    DrawMarker(1, s.marker.x, s.marker.y, s.marker.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        1.6, 1.6, 0.6, 47, 128, 237, 120, false, false, 2, false, nil, nil, false)
                    if dist < s.range then active = s end
                end
            end

            if active then
                local veh = cache.vehicle
                if veh and veh ~= 0 and cache.seat == -1 then
                    if active.shop then
                        showText(spotText('[E] ECU hangbolt', active.label))
                        if IsControlJustReleased(0, 38) then
                            hideText()
                            openShop()
                            Wait(300)
                        end
                    elseif isMechanic() then
                        showText(spotText('[E] ECU beszerelés', active.label))
                        if IsControlJustReleased(0, 38) then
                            hideText()
                            openPanel()
                            Wait(300)
                        end
                    else
                        showText('Ide csak szerelő tud beszerelni')
                    end
                else
                    showText('Ülj be egy jármű volánja mögé')
                end
            else
                hideText()
            end
        else
            hideText()
        end
        Wait(wait)
    end
end)

-- ---- Debug open ----
if Config.DebugOpen then
    RegisterCommand(Config.Command, function()
        currentUnlocked = {}
        for _, v in ipairs(Config.Sound.pop.variants) do currentUnlocked[v.key] = true end
        openPanel()
    end, false)
    if Config.Keybind ~= '' then
        RegisterKeyMapping(Config.Command, 'ECU Tuning (debug)', 'keyboard', Config.Keybind)
    end
end

-- Debug: what does the server actually hold for the car I am sitting in? Prints the plate
-- the client sends, the unlocked sounds and the stored settings. Settings are per PLATE, so
-- a respawned admin car (new random plate) legitimately shows nothing.
if Config.Debug then
    RegisterCommand('ecuinfo', function()
        local veh = cache.vehicle
        if not veh or cache.seat ~= -1 then
            print('^1[EcuTuning]^7 Ülj be egy jármű volánja mögé.')
            return
        end
        local plate = trimPlate(GetVehicleNumberPlateText(veh))
        lib.callback('EcuTuning:Server:GetData', false, function(data)
            local unlocked = (data and data.unlocked) or {}
            print(('^3[EcuTuning]^7 rendszám="%s" | feloldott hang: %d [%s]'):format(
                plate, #unlocked, table.concat(unlocked, ', ')))
            local s = data and data.settings
            if s and s.popbang then
                print(('^3[EcuTuning]^7 mentett: stage=%s sound=%s alloPop=%s | lang=%s'):format(
                    tostring(s.popbang.stage), tostring(s.popbang.sound), tostring(s.popbang.standPops),
                    tostring(s.flame and s.flame.enabled)))
            else
                print('^1[EcuTuning]^7 NINCS mentett beállítás erre a rendszámra.')
            end
        end, plate)
    end, false)
end

-- Debug: audition every native ("Régi") pop one by one — single shot, no burst,
-- 1.2 s apart, name printed to F8. Use it to hear which ones actually differ.
if Config.Debug then
    RegisterCommand('ecunative', function()
        local veh = cache.vehicle
        if not veh or cache.seat ~= -1 then
            print('^1[EcuTuning]^7 Ülj be egy jármű volánja mögé.')
            return
        end
        CreateThread(function()
            for _, v in ipairs(Config.Sound.pop.variants) do
                if v.natives and v.natives[1] then
                    if not DoesEntityExist(veh) then break end
                    print(('^3[EcuTuning]^7 %s -> %s'):format(v.label, v.natives[1]))
                    PlaySoundFromEntity(-1, v.natives[1], veh, 0, true, 0)
                    Wait(1200)
                end
            end
            print('^2[EcuTuning]^7 Natív hangok vége.')
        end)
    end, false)
end

-- ---- Server -> client ----
RegisterNetEvent('EcuTuning:Client:Bought', function(plate, key)
    if plate == currentPlate then
        currentUnlocked[key] = true
        -- Live-update the shop locks while the NUI is open.
        if isOpen then SendNUIMessage({ action = 'setUnlocked', data = unlockedKeys() }) end
    end
end)

RegisterNetEvent('EcuTuning:Client:Saved', function(plate, settings)
    if plate == currentPlate then
        Settings:Set(plate, settings)
        local veh = cache.vehicle
        if veh and cache.seat == -1 then Detection:Attach(veh, Settings:Get(plate)) end
    end
end)

RegisterNetEvent('EcuTuning:Client:PlaySound', function(coords, kind, key, vol)
    if type(coords) ~= 'vector3' then
        if type(coords) == 'table' and coords.x then
            coords = vector3(coords.x, coords.y, coords.z)
        else
            return
        end
    end
    -- The server already clamped `vol` to Config.Limits.volume.max.
    Effects:PlayLocalSound(kind, key, coords, vol)
end)

-- Render a nearby player's exhaust particle locally (non-networked; see effects.lua header).
RegisterNetEvent('EcuTuning:Client:Ptfx', function(netId, kind, scale, bursts, interval, rgb, exhausts)
    Effects:PlayRemotePtfx(netId, kind, scale, bursts, interval, rgb, exhausts)
end)

lib.onCache('vehicle', function() refresh() end)
lib.onCache('seat', function() refresh() end)

-- The plate can settle *after* we are seated: admin/spawned cars are usually given their
-- plate with SetVehicleNumberPlateText once the ped is already inside, and a streamed-in
-- vehicle can hand us its plate late. The cache callbacks above only fire once, so that
-- first read can be a temporary plate the server knows nothing about — the tuning then only
-- appeared after a resource restart. Re-fetch whenever the plate changes under us.
CreateThread(function()
    while true do
        local wait = 5000
        local veh = cache.vehicle
        if veh and cache.seat == -1 then
            wait = 2000
            local plate = trimPlate(GetVehicleNumberPlateText(veh))
            if plate ~= '' and plate ~= currentPlate then refresh() end
        end
        Wait(wait)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if isOpen then SetNuiFocus(false, false) end
    Detection:Detach()
end)

CreateThread(function()
    Wait(500)
    refresh()
end)
