--[[
    FactionHQ - local shell handling (client)

    The interior is a LOCAL, non-networked frozen object spawned only for
    the player who is inside (loaf_housing pattern) - no routing buckets,
    players inside see each other because they share world coordinates.

    Includes: enter/exit teleport with collision wait, an inside guard
    (bounds breach / death cleanup), login rescue resume and a purchase
    preview mode.
]]

local HQMarker = require 'client.modules.marker'
local HQPlacement = require 'client.modules.placement'
local HQMenu = require 'client.modules.menu'
local HQFurniture = require 'client.modules.furniture'

local HQShell = {
    insideJob = nil,
    busy      = false,
    previewing = false,
}

local shellObject = nil
local spawnPos = nil     -- where the player actually landed (exit menu spot)
local anchorVec = nil
local bossMarkerId = nil -- the faction's auto-placed jobcreator boss CP

local function notify(msg)
    if ESX and ESX.ShowNotification then ESX.ShowNotification(msg) else
        TriggerEvent('esx:showNotification', msg) end
end

-- rota_loading screen during the teleports (same wiring as loaf_housing)
local function loadingHide()
    if GetResourceState('rota_loading') == 'started' then
        pcall(function() exports['rota_loading']:LoadingHide(500) end)
    end
end

local loadingToken = 0
local function loadingShow(text)
    if GetResourceState('rota_loading') == 'started' then
        pcall(function() exports['rota_loading']:LoadingShow(700, text, true) end)
        -- Failsafe: never leave the loading screen stuck (nothing here
        -- legitimately runs longer than ~10 s)
        loadingToken = loadingToken + 1
        local token = loadingToken
        SetTimeout(15000, function()
            if token == loadingToken then loadingHide() end
        end)
    end
end

--======================================================================
-- Internals
--======================================================================
local function loadModel(modelName)
    local model = joaat(modelName)
    if not IsModelValid(model) then
        print(('[bc_factionhq] shell model "%s" is INVALID - is the shell asset pack ensured on this server?'):format(modelName))
        return nil
    end
    RequestModel(model)
    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(50) end
    if not HasModelLoaded(model) then
        print(('[bc_factionhq] shell model "%s" did not load in 10s'):format(modelName))
        return nil
    end
    return model
end

local function spawnShell(interiorDef, anchor)
    local model = loadModel(interiorDef.model)
    if not model then return false end

    shellObject = CreateObject(model, anchor.x, anchor.y, anchor.z, false, false, false)
    SetEntityHeading(shellObject, 0.0)
    FreezeEntityPosition(shellObject, true)
    SetModelAsNoLongerNeeded(model)

    anchorVec = vector3(anchor.x, anchor.y, anchor.z)
    spawnPos = anchorVec + interiorDef.entrance
    return true
end

local function despawnShell()
    HQFurniture.Clear()
    if shellObject and DoesEntityExist(shellObject) then
        DeleteEntity(shellObject)
    end
    shellObject, spawnPos, anchorVec, bossMarkerId = nil, nil, nil, nil
end

-- Teleport that holds the FROZEN ped at the target while the local
-- shell's collision streams in, then stands it EXACTLY on the real
-- floor. Two synchronous raycasts:
--   1) below the target (normal case)
--   2) up to 8 m ABOVE it - catches a miscalibrated entrance offset
--      that points under the interior slab (the "spawn under the
--      rooms, walk and fall" bug); the diff is logged so the offset
--      can be fixed in Config.Interiors.
-- If neither reports a floor in 6 s, fall back to a loaf-style fixed
-- settle; the inside-guard's snap-back covers the rare remaining fall.
local function tpWithCollision(x, y, z, heading)
    local ped = PlayerPedId()
    RequestCollisionAtCoord(x, y, z)
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, x, y, z, false, false, false, false)

    local deadline = GetGameTimer() + 6000
    local floorZ, snappedUp = nil, false
    while GetGameTimer() < deadline do
        SetEntityCoords(ped, x, y, z, false, false, false, false)
        -- 1 = world, 16 = objects (the frozen local shell counts here)
        local probe = StartExpensiveSynchronousShapeTestLosProbe(
            x, y, z + 1.0, x, y, z - 4.0, 17, ped, 4)
        local _, hit, hitCoords = GetShapeTestResult(probe)
        if hit == 1 or hit == true then
            floorZ = hitCoords.z
            break
        end

        probe = StartExpensiveSynchronousShapeTestLosProbe(
            x, y, z + 8.0, x, y, z + 0.9, 17, ped, 4)
        local _, hitUp, upCoords = GetShapeTestResult(probe)
        if hitUp == 1 or hitUp == true then
            floorZ = upCoords.z
            snappedUp = true
            break
        end

        Wait(50)
    end

    if floorZ then
        local corrected = floorZ + 1.0
        if snappedUp or math.abs(corrected - z) > 0.4 then
            print(('[bc_factionhq] floor snap %.2f -> %.2f (diff %.2f)%s - adjust the entrance offset in Config.Interiors')
                :format(z, corrected, corrected - z, snappedUp and ' [UP]' or ''))
        end
        z = corrected
        SetEntityCoords(ped, x, y, z, false, false, false, false)
        Wait(150) -- settle on the corrected spot
    else
        print(('[bc_factionhq] no floor found around %.1f %.1f %.1f - using fixed settle'):format(x, y, z))
        for _ = 1, 30 do -- hold 1.5 s more, like loaf's flat wait
            SetEntityCoords(ped, x, y, z, false, false, false, false)
            Wait(50)
        end
    end

    if heading then SetEntityHeading(ped, heading + 0.0) end
    FreezeEntityPosition(ped, false)
end

local function fadeOut()
    DoScreenFadeOut(400)
    local deadline = GetGameTimer() + 1500
    while not IsScreenFadedOut() and GetGameTimer() < deadline do Wait(50) end
end

local lastExitAt = 0

-- Exit lands ~2 m IN FRONT of the entry CP (never exactly on it), so
-- the entry interaction cannot instantly re-trigger
local function exitPoint(entry)
    local h = math.rad(entry.h or 0.0)
    return entry.x - math.sin(h) * 2.0, entry.y + math.cos(h) * 2.0, entry.z
end

-- Exit with server cleanup. When the guard detects the player already
-- left the band (death -> hospital respawn), no teleport is done.
local function finishExit(teleport)
    ESX.TriggerServerCallback('FactionHQ:Server:RequestExit', function(entry)
        if teleport and entry then
            loadingShow('Kilépés a HQ-ból...')
            fadeOut()
            despawnShell()
            local ex, ey, ez = exitPoint(entry)
            tpWithCollision(ex, ey, ez, entry.h)
            loadingHide()
            DoScreenFadeIn(400)
        else
            despawnShell()
        end
        HQShell.insideJob = nil
        HQShell.busy = false
        lastExitAt = GetGameTimer()
    end)
end

-- Short grace after leaving: the entry E stays inactive meanwhile
function HQShell.RecentlyExited()
    return (GetGameTimer() - lastExitAt) < 1500
end

--======================================================================
-- Inside menu at the landing spot: exit, fonoki panel (via the auto
-- boss CP), furniture placing and managing
--======================================================================
local openExitMenu -- forward declaration (furniture menus return to it)

local function openFurnishMenu()
    ESX.TriggerServerCallback('FactionHQ:Server:GetMyFurniture', function(list)
        if not list or #list == 0 then
            notify('Nincs lerakhato butorod (IKEA-ban vehetsz).')
            return openExitMenu()
        end
        local items = {}
        for _, f in ipairs(list) do
            items[#items + 1] = {
                id = f.model, label = f.label, right = f.amount .. ' db', icon = 'house',
            }
        end
        HQMenu.Open({
            title = 'Bútor lerakása',
            subtitle = 'A saját bútoraid (IKEA)',
            items = items,
        }, function(model)
            if not model then return openExitMenu() end
            local label
            for _, f in ipairs(list) do
                if f.model == model then label = f.label break end
            end
            HQPlacement.Start(label or 'Butor', function(coords)
                if not coords then return end
                ESX.TriggerServerCallback('FactionHQ:Server:PlaceFurniture', function(ok, msg)
                    if msg then notify(msg) end
                end, model, { x = coords.x, y = coords.y, z = coords.z }, coords.h)
            end, model)
        end)
    end)
end

local function openFurnitureManage()
    ESX.TriggerServerCallback('FactionHQ:Server:GetFurnitureList', function(list)
        if not list or #list == 0 then
            notify('Nincs lerakott butor a HQ-ban.')
            return openExitMenu()
        end
        local items = {}
        for _, f in ipairs(list) do
            items[#items + 1] = {
                id = tostring(f.id),
                label = ('%s #%d'):format(f.label, f.id),
                desc = f.canPickup and 'Felvétel (vissza a készletedbe)' or 'Csak a lerakója vagy boss veheti fel',
                icon = 'house',
                disabled = not f.canPickup,
            }
        end
        HQMenu.Open({
            title = 'Bútorok kezelése',
            subtitle = ('%d lerakott bútor'):format(#list),
            items = items,
        }, function(id)
            if not id then return openExitMenu() end
            ESX.TriggerServerCallback('FactionHQ:Server:PickupFurniture', function(ok, msg)
                if msg then notify(msg) end
                if ok then openFurnitureManage() end
            end, tonumber(id))
        end)
    end)
end

openExitMenu = function()
    local items = {
        { id = 'exit', label = 'Kilépés', desc = 'Vissza a bejárathoz', icon = 'back' },
    }
    if bossMarkerId then
        items[#items + 1] = { id = 'panel', label = 'Főnöki panel', desc = 'HQ kezelése (boss/coboss)', icon = 'access' }
    end
    items[#items + 1] = { id = 'furnish', label = 'Bútor lerakása', desc = 'Saját bútor elhelyezése a HQ-ban', icon = 'house' }
    items[#items + 1] = { id = 'furniture', label = 'Bútorok kezelése', desc = 'Lerakott bútorok felvétele', icon = 'preview' }

    HQMenu.Open({
        title = 'Frakció HQ',
        subtitle = 'Főhadiszállás',
        items = items,
    }, function(id)
        if id == 'exit' and HQShell.insideJob and not HQShell.busy then
            HQShell.busy = true
            finishExit(true)
        elseif id == 'panel' and bossMarkerId then
            TriggerEvent('bc_fonokipanel:open', bossMarkerId)
        elseif id == 'furnish' then
            openFurnishMenu()
        elseif id == 'furniture' then
            openFurnitureManage()
        end
    end)
end

--======================================================================
-- Inside loop: bounds guard + exit marker + E (frame rate only while
-- standing near the door, otherwise 500 ms ticks)
--======================================================================
local function startInsideLoop()
    CreateThread(function()
        -- Grace period: never eject while the shell is still settling in
        local graceUntil = GetGameTimer() + 6000
        local retryUsed = false
        while HQShell.insideJob do
            local wait = 500
            local ped = PlayerPedId()
            local pc = GetEntityCoords(ped)

            -- Bounds guard: glitched/knocked out of the shell or died
            if GetGameTimer() > graceUntil and anchorVec and #(pc - anchorVec) > Config.InteriorRadius then
                -- Fell through a late-loading floor? One snap-back retry
                -- before giving up (catches slow collision streaming).
                if not retryUsed and spawnPos and pc.z < anchorVec.z and pc.z > (anchorVec.z - 500.0) then
                    retryUsed = true
                    HQShell.busy = true
                    tpWithCollision(spawnPos.x, spawnPos.y, spawnPos.z)
                    HQShell.busy = false
                    graceUntil = GetGameTimer() + 6000
                else
                    local wasHigh = pc.z > (anchorVec.z - 800.0)
                    HQShell.busy = true
                    finishExit(wasHigh) -- fell out -> back to the door; died -> just clean up
                    break
                end
            end

            if spawnPos then
                local dist = #(pc - spawnPos)
                if dist < 15.0 then
                    wait = 0
                    HQMarker.DrawEntry(spawnPos, Config.ExitMarker)
                    if dist < 1.8 then
                        HQMarker.DrawText3D(vector3(spawnPos.x, spawnPos.y, spawnPos.z + (Config.ExitMarker.textZOffset or 0.9)), '[E] Menu')
                        if IsControlJustReleased(0, 38) and not HQShell.busy and not HQMenu.open then
                            openExitMenu()
                        end
                    end
                end
            end

            Wait(wait)
        end
    end)
end

--======================================================================
-- Public API
--======================================================================
function HQShell.IsBusy()
    return HQShell.busy or HQShell.insideJob ~= nil or HQShell.previewing or HQPlacement.active
end

function HQShell.Enter(jobName)
    if HQShell.IsBusy() then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        return notify('Jarmubol nem lephetsz be.')
    end
    HQShell.busy = true

    ESX.TriggerServerCallback('FactionHQ:Server:RequestEnter', function(data, msg)
        if not data then
            HQShell.busy = false
            if msg then notify(msg) end
            return
        end

        local interiorDef = Config.GetInterior(data.interior)
        if not interiorDef then
            HQShell.busy = false
            ESX.TriggerServerCallback('FactionHQ:Server:RequestExit', function() end)
            return notify('Ismeretlen interior, szolj egy adminnak.')
        end

        loadingShow('Betöltés a HQ-ba...')
        fadeOut()
        if not spawnShell(interiorDef, data.anchor) then
            -- Asset pack missing -> roll back the server-side inside state
            ESX.TriggerServerCallback('FactionHQ:Server:RequestExit', function() end)
            loadingHide()
            DoScreenFadeIn(400)
            HQShell.busy = false
            return notify('Az interior modell nem toltheto be (asset pack hianyzik).')
        end

        tpWithCollision(spawnPos.x, spawnPos.y, spawnPos.z)
        -- The exit menu lives where the player actually landed (the
        -- floor snap may have corrected the configured offset)
        spawnPos = GetEntityCoords(PlayerPedId())
        bossMarkerId = data.bossMarkerId
        HQFurniture.SpawnAll(anchorVec, data.furniture)
        loadingHide()
        DoScreenFadeIn(400)

        HQShell.insideJob = jobName
        HQShell.busy = false
        startInsideLoop()
    end, jobName)
end

-- Login rescue: the server already re-registered us as inside; just
-- rebuild the local shell around the current position.
function HQShell.ResumeInside(jobName, anchor, interiorKey, bossId, furniture)
    if HQShell.IsBusy() then return end
    local interiorDef = Config.GetInterior(interiorKey)
    if not interiorDef then return end
    HQShell.busy = true

    loadingShow('Betöltés a HQ-ba...')
    fadeOut()
    if not spawnShell(interiorDef, anchor) then
        ESX.TriggerServerCallback('FactionHQ:Server:RequestExit', function() end)
        loadingHide()
        DoScreenFadeIn(400)
        HQShell.busy = false
        return
    end
    tpWithCollision(spawnPos.x, spawnPos.y, spawnPos.z)
    spawnPos = GetEntityCoords(PlayerPedId())
    bossMarkerId = bossId
    HQFurniture.SpawnAll(anchorVec, furniture)
    loadingHide()
    DoScreenFadeIn(400)

    HQShell.insideJob = jobName
    HQShell.busy = false
    startInsideLoop()
end

-- Server-initiated eject (access revoked / job change while inside)
RegisterNetEvent('FactionHQ:Client:ForceExit')
AddEventHandler('FactionHQ:Client:ForceExit', function(entry)
    if not HQShell.insideJob then return end
    HQShell.insideJob = nil -- stops the inside loop
    HQShell.busy = true
    loadingShow('Kilépés a HQ-ból...')
    fadeOut()
    despawnShell()
    if entry then
        local ex, ey, ez = exitPoint(entry)
        tpWithCollision(ex, ey, ez, entry.h)
    end
    loadingHide()
    DoScreenFadeIn(400)
    HQShell.busy = false
    lastExitAt = GetGameTimer()
    notify('Kikerultel a HQ-bol.')
end)

--======================================================================
-- Purchase preview: client-only walk-in, no server state, own band
--======================================================================
function HQShell.Preview(interiorKey)
    if HQShell.IsBusy() then return end
    local interiorDef = Config.GetInterior(interiorKey)
    if not interiorDef then return end
    HQShell.previewing = true

    CreateThread(function()
        local ped = PlayerPedId()
        local returnPos = GetEntityCoords(ped)
        local returnHeading = GetEntityHeading(ped)

        loadingShow('Betöltés a HQ-ba...')
        fadeOut()
        -- Preview band: 150 below the HQ band at this location
        local anchor = {
            x = returnPos.x, y = returnPos.y,
            z = math.min(returnPos.z, Config.InteriorGroundCap) + Config.PreviewHeightOffset,
        }
        if not spawnShell(interiorDef, anchor) then
            loadingHide()
            DoScreenFadeIn(400)
            HQShell.previewing = false
            notify('Az interior modell nem toltheto be (asset pack hianyzik).')
            return
        end

        tpWithCollision(spawnPos.x, spawnPos.y, spawnPos.z)
        loadingHide()
        DoScreenFadeIn(400)

        local graceUntil = GetGameTimer() + 6000
        local retryUsed = false
        local deadline = GetGameTimer() + 120000
        while GetGameTimer() < deadline do
            Wait(0)
            HQMarker.DrawText2D(0.5, 0.08, ('Megtekintes: ~b~%s~s~  |  ~r~Backspace~s~: vissza'):format(interiorDef.label), 0.42, true)
            if IsControlJustPressed(0, 202) or IsControlJustPressed(0, 177) then break end
            -- Fell through a late-loading floor? One snap-back retry.
            local pc = GetEntityCoords(PlayerPedId())
            if GetGameTimer() > graceUntil and #(pc - anchorVec) > Config.InteriorRadius then
                if not retryUsed and pc.z < anchorVec.z then
                    retryUsed = true
                    tpWithCollision(spawnPos.x, spawnPos.y, spawnPos.z)
                    graceUntil = GetGameTimer() + 6000
                else
                    break
                end
            end
        end

        loadingShow('Kilépés a HQ-ból...')
        fadeOut()
        despawnShell()
        tpWithCollision(returnPos.x, returnPos.y, returnPos.z, returnHeading)
        loadingHide()
        DoScreenFadeIn(400)
        HQShell.previewing = false
    end)
end

--======================================================================
-- Login / resource-restart rescue check
--======================================================================
function HQShell.RescueCheck()
    if HQShell.IsBusy() then return end
    local pc = GetEntityCoords(PlayerPedId())
    if pc.z < Config.RescueMinZ then return end

    ESX.TriggerServerCallback('FactionHQ:Server:Rescue', function(res)
        if not res then return end
        if res.action == 'enter' then
            HQShell.ResumeInside(res.job, res.anchor, res.interior, res.bossMarkerId, res.furniture)
        elseif res.action == 'eject' and res.coords then
            fadeOut()
            local ex, ey, ez = exitPoint(res.coords)
            tpWithCollision(ex, ey, ez, res.coords.h)
            DoScreenFadeIn(400)
        end
    end)
end

-- Safety: clean up the local object if the resource stops
AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        despawnShell()
    end
end)

return HQShell
