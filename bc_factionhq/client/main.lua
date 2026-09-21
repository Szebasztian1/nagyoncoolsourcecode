--[[
    FactionHQ - client entry

    Orchestration only: spot cache + sync, the distance-gated visual
    loop (floating house icon, occupancy text, E), login rescue and the
    panel export. Everything else lives in client/modules/*.
]]

local HQMarker = require 'client.modules.marker'
local HQPlacement = require 'client.modules.placement'
local HQShell = require 'client.modules.shell'
local Menus = require 'client.modules.menus'

local SpotsById = {}  -- [spotId] = { id, coords = {x,y,z,h}, job = string|nil, label = string|nil }
local myAccess = {}   -- [jobName] = true (guest access + allied faction HQs)
local myJob = nil
local nearSpotId = nil

local WhitelistSet = {}
for _, job in ipairs(Config.WhitelistedJobs) do WhitelistSet[job] = true end

Menus.Init({
    getMyJob = function() return myJob end,
})

local function notify(msg)
    if ESX and ESX.ShowNotification then ESX.ShowNotification(msg) else
        TriggerEvent('esx:showNotification', msg) end
end

-- Native DrawText cannot render the Hungarian double acute (o/u)
local function stripAccents(s)
    return (tostring(s or ''):gsub('ő', 'o'):gsub('Ő', 'O'):gsub('ű', 'u'):gsub('Ű', 'U'))
end

local function isBossClient()
    local job = ESX.GetPlayerData() and ESX.GetPlayerData().job
    return job and job.grade_name == 'boss'
end

--======================================================================
-- Spot cache + blips
--======================================================================
local function refreshBlips()
    local entries = {}
    for _, s in pairs(SpotsById) do
        if s.job and (s.job == myJob or myAccess[s.job]) and Config.Blip.enabled then
            entries[#entries + 1] = {
                coords = s.coords, label = ('%s HQ'):format(s.label),
                blip = Config.Blip,
            }
        elseif not s.job and Config.VacantBlip.enabled then
            entries[#entries + 1] = {
                coords = s.coords, label = 'Eladó Frakció HQ',
                blip = Config.VacantBlip,
            }
        end
    end
    HQMarker.RefreshBlips(entries)
end

local function setSpots(list)
    SpotsById = {}
    for _, e in ipairs(list or {}) do
        SpotsById[e.id] = { id = e.id, coords = e.coords, job = e.job, label = e.label }
    end
    refreshBlips()
end

--======================================================================
-- Interaction gate + dispatch
--======================================================================
-- Who may even SEE a spot's world marker. Vacant spots are visible to
-- everyone (so bosses can find & buy them). An OWNED HQ is a hidden base:
-- only its members, invited guests, allied factions, and (optionally)
-- whitelisted law enforcement see it up close - never random players.
local function canSeeSpot(s)
    if not s.job then return true end
    if s.job == myJob or myAccess[s.job] == true then return true end
    return Config.RaidJobsSeeHQ == true and WhitelistSet[myJob] == true
end

local function interactAllowed(s)
    if HQShell.IsBusy() or HQShell.RecentlyExited() then return false end
    if not canSeeSpot(s) then return false end
    if s.job then
        return s.job == myJob or myAccess[s.job] == true
            or (WhitelistSet[myJob] and s.job ~= myJob)
    end
    -- Vacant spot: only bosses get the E prompt (server re-validates)
    return isBossClient()
end

local function spotInteract(s)
    if HQShell.IsBusy() or HQShell.RecentlyExited() then return end
    if s.job then
        if s.job == myJob or myAccess[s.job] then
            Menus.OpenEntry(s)
        elseif WhitelistSet[myJob] and s.job ~= myJob then
            Menus.OpenCop(s)
        end
    elseif isBossClient() then
        Menus.OpenBuy(s)
    end
end

--======================================================================
-- Visual loop for the nearest spot: floating house icon (bobbing),
-- compact white text block directly above it (name / [E] Menu /
-- occupancy or price), optional ground ring, E handling. Frame rate
-- only inside the icon draw distance; beyond it the loop idles at
-- 250 ms, and only the 1 s control thread runs while nobody is near a
-- spot. Strings are cached, nothing is allocated per frame.
--======================================================================
local PRICE_LINE = ('Ara: %s $'):format(ESX.Math.GroupDigits(Config.HQPrice))

local function startSpotVisuals(spotId)
    CreateThread(function()
        local propSet = false
        -- Rebuilt only when the spot changes (e.g. bought while standing there)
        local lastSpot, entryVec, title = nil, nil, nil
        local lastShowE, lines = nil, nil

        while nearSpotId == spotId do
            local s = SpotsById[spotId]
            if not s or HQShell.IsBusy() or not canSeeSpot(s) then break end
            if not IsScreenFadedIn() or IsPlayerSwitchInProgress() then break end

            if s ~= lastSpot then
                lastSpot = s
                entryVec = vector3(s.coords.x, s.coords.y, s.coords.z)
                title = s.job and (stripAccents(s.label) .. ' HQ') or 'Elado Frakcio HQ'
                lastShowE, lines = nil, nil
            end

            local pc = GetEntityCoords(PlayerPedId())
            local dist = #(pc - entryVec)
            if dist > (Config.EntryDrawDistance + 10.0) then break end

            if not propSet then
                HQMarker.EnsureEntryProp(s.coords)
                propSet = true
            end

            local wait = 250
            if dist <= Config.HouseIcon.drawDistance then
                wait = 0
                local color = s.job and Config.HouseIcon.ownedColor or Config.HouseIcon.vacantColor
                if Config.ShowGroundRing then
                    HQMarker.DrawEntry(s.coords, s.job and Config.Marker or Config.VacantMarker)
                end

                -- Cached text lines: name / [E] Menu (owned) or name / [E] Menu / price (vacant)
                local showE = dist <= Config.EntryMenuDistance and interactAllowed(s)
                if dist <= Config.EntryText.drawDistance then
                    if showE ~= lastShowE or not lines then
                        lastShowE = showE
                        if s.job then
                            lines = showE and { title, '[E] Menu' } or { title }
                        else
                            lines = showE and { title, '[E] Menu', PRICE_LINE } or { title, PRICE_LINE }
                        end
                    end
                else
                    lines, lastShowE = nil, nil
                end

                HQMarker.DrawEntryComposite(s.coords, color, dist, lines)

                if showE and IsControlJustReleased(0, 38) then
                    spotInteract(s)
                end
            end

            Wait(wait)
        end

        HQMarker.ClearEntryProp()
        if nearSpotId == spotId then nearSpotId = nil end
    end)
end

CreateThread(function()
    while true do
        -- No visuals during loading/switch cam (the ped may sit on a
        -- spot while the spawn camera is still flying)
        if not nearSpotId and not HQShell.IsBusy() and next(SpotsById)
            and IsScreenFadedIn() and not IsPlayerSwitchInProgress() then
            local pc = GetEntityCoords(PlayerPedId())
            local best, bestDist = nil, Config.EntryDrawDistance
            for id, s in pairs(SpotsById) do
                if canSeeSpot(s) then
                    local d = #(pc - vector3(s.coords.x, s.coords.y, s.coords.z))
                    if d < bestDist then best, bestDist = id, d end
                end
            end
            if best then
                nearSpotId = best
                startSpotVisuals(best)
            end
        end
        Wait(1000)
    end
end)

--======================================================================
-- Init / sync
--======================================================================
local function init()
    while not (ESX.GetPlayerData() and ESX.GetPlayerData().job) do Wait(500) end
    myJob = ESX.GetPlayerData().job.name

    ESX.TriggerServerCallback('FactionHQ:Server:GetHQList', setSpots)
    ESX.TriggerServerCallback('FactionHQ:Server:GetMyAccess', function(jobs)
        myAccess = {}
        for _, job in ipairs(jobs or {}) do myAccess[job] = true end
        refreshBlips()
    end)

    -- Logged out inside the HQ band? The server decides what happens.
    SetTimeout(3000, HQShell.RescueCheck)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    CreateThread(init)
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateThread(init)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    myJob = job and job.name or myJob
    refreshBlips()
end)

RegisterNetEvent('FactionHQ:Client:HQUpdated')
AddEventHandler('FactionHQ:Client:HQUpdated', function(list)
    setSpots(list)
end)

RegisterNetEvent('FactionHQ:Client:AccessChanged')
AddEventHandler('FactionHQ:Client:AccessChanged', function(jobs)
    myAccess = {}
    for _, job in ipairs(jobs or {}) do myAccess[job] = true end
    refreshBlips()
end)

RegisterNetEvent('FactionHQ:Client:OpenAdminMenu')
AddEventHandler('FactionHQ:Client:OpenAdminMenu', function(list)
    if type(list) ~= 'table' or #list == 0 then
        return notify('Nincs meg HQ pont. Lerakas: /' .. Config.Commands.place)
    end
    Menus.OpenAdmin(list)
end)

--======================================================================
-- Panel export (bc_fonokipanel HQ tab): entry CP relocation flow.
-- Fires the local FlowFinished event at the end so the panel reopens.
--======================================================================
local function finishFlow()
    SetTimeout(300, function()
        TriggerEvent('FactionHQ:Client:FlowFinished')
    end)
end

exports('StartEntryMove', function()
    if not Config.AllowFactionEntryMove then
        notify('A HQ-t csak admin helyezheti at.')
        return finishFlow()
    end
    if HQShell.IsBusy() then return finishFlow() end
    HQPlacement.Start('HQ belepo CP (athelyezes)', function(coords)
        if not coords then return finishFlow() end
        ESX.TriggerServerCallback('FactionHQ:Server:MoveEntry', function(_, msg)
            if msg then notify(msg) end
            finishFlow()
        end, coords)
    end)
end)
