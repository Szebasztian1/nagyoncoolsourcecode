-- Shop name plates — client spine.
-- Holds the plate list the server sent, decides which plates are in range, and
-- only then lets a per-frame loop run. Nothing is drawn and no frame is spent
-- while the player is away from a shop.

NameTags = NameTags or {}

local ESX = exports['es_extended']:getSharedObject()
local cfg = NameTags.Config
local Draw = NameTags.Draw

local plates = {}        -- every plate on the map: { i, x, y, z, t, c } + cached r,g,b
local editable = {}      -- plate index -> true, the shops this player may rename
local unlocked = {}      -- plate index -> true, the ones already paid for
local price = {}         -- { money = '2 000 000 000', currency = 'Ft', pp = 5000|false }
local visible = {}       -- the plates inside cfg.drawDistance right now
local visibleCount = 0
local rendering = false
local hidden = false     -- spawn selector / player switch on screen: plates are not drawn
local editing = false
local current = nil      -- the plate the open panel belongs to
local nextAction = 0     -- ms, mirrors the server cooldown so we do not spam it
local pedTargets = {}    -- plate index -> the ped its ox_target option sits on

local DRAW_SQ = cfg.drawDistance * cfg.drawDistance
local SCAN_SQ = cfg.scanDistance * cfg.scanDistance
local INTERACT_SQ = cfg.interactDistance * cfg.interactDistance

local useTarget = cfg.targeting == 'ox_target'
    or (cfg.targeting == 'auto' and GetResourceState('ox_target') == 'started')

-- ── the editor panel ─────────────────────────────────────────────────────────
-- A BC-design panel inside shops_creator's existing NUI page (a resource only gets
-- one `ui_page`), injected by nametags/ui.js. The cooldown only starts once
-- something is actually saved, so closing the panel costs the player nothing.

local function closeEditor()
    if not editing then return end

    editing = false
    current = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'shopnames:close' })
end

-- `mode` decides which of the panel's two views opens: the editor, or the purchase
-- screen for a plate nobody has paid for yet.
local function sendEditor(plate)
    SendNUIMessage({
        action    = 'shopnames:open',
        mode      = unlocked[plate.i] and 'edit' or 'buy',
        index     = plate.i,
        name      = plate.t or '',
        color     = plate.c or cfg.defaultColor,
        colors    = cfg.colors,
        order     = cfg.colorOrder,
        maxLength = cfg.maxNameLength,
        price     = price,
    })
end

local function openEditor(plate)
    if editing or GetGameTimer() < nextAction then return end

    editing = true
    current = plate
    SetNuiFocus(true, true)
    sendEditor(plate)
end

-- The purchase went through: swap the open panel over to the editor instead of
-- making the player aim at the NPC a second time.
RegisterNetEvent('ShopNames:Client:Unlocked', function(index)
    unlocked[index] = true
    if editing and current and current.i == index then sendEditor(current) end
end)

RegisterNUICallback('shopnames:close', function(_, cb)
    closeEditor()
    cb('ok')
end)

RegisterNUICallback('shopnames:unlock', function(data, cb)
    nextAction = GetGameTimer() + cfg.commandCooldown
    TriggerServerEvent('ShopNames:Server:Unlock', data.index, data.method)
    cb('ok')
end)

RegisterNUICallback('shopnames:save', function(data, cb)
    closeEditor()
    nextAction = GetGameTimer() + cfg.commandCooldown

    TriggerServerEvent('ShopNames:Server:Save', data.index, data.name or '', data.color)
    cb('ok')
end)

-- ── ox_target ────────────────────────────────────────────────────────────────
-- The option is attached to the shop's ped, exactly like shops_creator attaches
-- its own — otherwise two shops standing a metre apart both answer and you get
-- two identical entries with no way to tell which shop you are renaming.
--
-- The peds come from their encrypted code, so we never see the handles; instead
-- each shop point claims the nearest ped standing on it, re-checked on the scan
-- tick as shops_creator spawns and despawns them. `canInteract` reads the access
-- sets live, so a sale or a purchase never has to re-attach anything.

local PED_SEARCH_SQ = cfg.pedSearchDistance * cfg.pedSearchDistance
local PED_MATCH_SQ  = cfg.pedMatchDistance * cfg.pedMatchDistance

local function optionNames(i)
    return { 'shopnames_edit_' .. i, 'shopnames_buy_' .. i }
end

local function attach(i, ped)
    local plate = plates[i]

    exports.ox_target:addLocalEntity(ped, {
        {
            name        = 'shopnames_edit_' .. i,
            icon        = cfg.target.icon,
            label       = cfg.target.label,
            distance    = cfg.interactDistance,
            canInteract = function() return editable[i] == true and unlocked[i] == true end,
            onSelect    = function() openEditor(plate) end,
        },
        {
            name        = 'shopnames_buy_' .. i,
            icon        = cfg.target.lockedIcon,
            label       = cfg.target.lockedLabel,
            distance    = cfg.interactDistance,
            canInteract = function() return editable[i] == true and unlocked[i] ~= true end,
            onSelect    = function() openEditor(plate) end,
        },
    })
end

local function detach(i)
    local ped = pedTargets[i]
    if not ped then return end

    if DoesEntityExist(ped) then
        exports.ox_target:removeLocalEntity(ped, optionNames(i))
    end
    pedTargets[i] = nil
end

local function detachAll()
    for i in pairs(pedTargets) do detach(i) end
end

-- Pairs up nearby shop points with the peds standing on them, one ped per point,
-- and applies only the differences.
local function refreshPedTargets(coords)
    local px, py = coords.x, coords.y
    local nearby, any = {}, false

    for i = 1, #plates do
        local plate = plates[i]
        local dx, dy = px - plate.x, py - plate.y

        if dx * dx + dy * dy < PED_SEARCH_SQ then
            nearby[i] = plate
            any = true
        end
    end

    if not any then
        return detachAll()
    end

    -- One pass over the ped pool, keeping only what could plausibly be a shop ped.
    local candidates = {}
    local pool = GetGamePool('CPed')

    for k = 1, #pool do
        local ped = pool[k]
        if not IsPedAPlayer(ped) then
            local pc = GetEntityCoords(ped)
            local dx, dy = px - pc.x, py - pc.y
            if dx * dx + dy * dy < PED_SEARCH_SQ then
                candidates[#candidates + 1] = { ped = ped, x = pc.x, y = pc.y, z = pc.z }
            end
        end
    end

    -- Nearest ped wins, and a ped can only belong to one shop point.
    local claimed, taken = {}, {}

    for i, plate in pairs(nearby) do
        local shopZ = plate.z - cfg.textOffsetZ
        local best, bestDist

        for c = 1, #candidates do
            local cand = candidates[c]
            if not taken[cand.ped] then
                local dx, dy = cand.x - plate.x, cand.y - plate.y
                local dist = dx * dx + dy * dy

                if dist < PED_MATCH_SQ and math.abs(cand.z - shopZ) < 3.0
                    and (not bestDist or dist < bestDist) then
                    best, bestDist = cand.ped, dist
                end
            end
        end

        if best then
            claimed[i] = best
            taken[best] = true
        end
    end

    for i in pairs(pedTargets) do
        if claimed[i] ~= pedTargets[i] then detach(i) end
    end

    for i, ped in pairs(claimed) do
        if pedTargets[i] ~= ped then
            attach(i, ped)
            pedTargets[i] = ped
        end
    end
end

AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if editing then SetNuiFocus(false, false) end   -- never leave focus stuck
    if useTarget then detachAll() end
end)

-- ── key fallback, used only when ox_target is not running ────────────────────

local function handleInteraction(plate)
    Draw.Help(cfg.interactHelp)

    if IsControlJustReleased(0, cfg.keyName) then
        openEditor(plate)
    end
end

-- ── plate list ───────────────────────────────────────────────────────────────

-- The colour key is resolved to RGB here, once, so the render loop never looks
-- anything up.
local function cacheColor(plate)
    plate.r, plate.g, plate.b = Draw.ResolveColor(plate.c)
end

local function setPlates(list)
    plates = list or {}
    for i = 1, #plates do
        plates[i].i = i
        cacheColor(plates[i])
    end

    for i = #visible, 1, -1 do visible[i] = nil end
    visibleCount = 0

    -- Indices changed, so every attachment is stale; the scan tick re-pairs them.
    if useTarget then detachAll() end
end

local function toSet(list)
    local set = {}
    for i = 1, #(list or {}) do
        set[list[i]] = true
    end
    return set
end

local function setAccess(editableList, unlockedList)
    editable = toSet(editableList)
    unlocked = toSet(unlockedList)
end

local function requestPlates()
    ESX.TriggerServerCallback('ShopNames:GetPlates', function(data)
        if not data then return end
        setPlates(data.plates)
        setAccess(data.editable, data.unlocked)
        price = data.price or {}
    end)
end

RegisterNetEvent('ShopNames:Client:UpdatePlate', function(index, text, color)
    local plate = plates[index]
    if not plate then return end

    plate.t, plate.c = text, color
    cacheColor(plate)
end)

RegisterNetEvent('ShopNames:Client:SetAccess', setAccess)
RegisterNetEvent('ShopNames:Client:Refresh', requestPlates)
RegisterNetEvent('esx:playerLoaded', requestPlates)

-- ── proximity ────────────────────────────────────────────────────────────────

-- Rebuilds `visible`. The flat 2D distance rejects almost every plate before the
-- z term is even touched. Returns whether anything is within scanning range, so
-- the caller knows which tick to use.
local function scan(coords)
    local px, py, pz = coords.x, coords.y, coords.z
    local count, near = 0, false

    for i = 1, #plates do
        local plate = plates[i]
        local dx, dy = px - plate.x, py - plate.y
        local flat = dx * dx + dy * dy

        if flat < SCAN_SQ then
            near = true

            local dz = pz - plate.z
            if flat + dz * dz < DRAW_SQ then
                count = count + 1
                visible[count] = plate
            end
        end
    end

    for i = #visible, count + 1, -1 do visible[i] = nil end
    visibleCount = count

    return near
end

-- While the SpawnSelector is open the ped already stands at its last position but
-- the camera shows the city, and the switch camera then drops straight onto that
-- spot: a plate next to it would float in the middle of the loading overlay.
-- SpawnSelector sets `spawnSelecting` from opening until the switch has ended.
local function platesHidden()
    return LocalPlayer.state.spawnSelecting == true or IsPlayerSwitchInProgress()
end

local function drawVisible()
    local coords = GetEntityCoords(PlayerPedId())
    local px, py, pz = coords.x, coords.y, coords.z
    local target, targetDist

    for i = 1, visibleCount do
        local plate = visible[i]
        local dx, dy, dz = px - plate.x, py - plate.y, pz - plate.z
        local sq = dx * dx + dy * dy + dz * dz

        if sq < DRAW_SQ then
            if plate.t ~= '' then
                Draw.Plate(plate, math.sqrt(sq))
            end

            -- ox_target draws its own prompt, so only the key fallback
            -- needs to know what the player is standing in front of.
            if not useTarget and editable[plate.i] and sq < INTERACT_SQ
                and (not targetDist or sq < targetDist) then
                target, targetDist = plate, sq
            end
        end
    end

    if target then handleInteraction(target) end
end

-- The only Wait(0) here: it exists while a plate is on screen and ends the moment
-- the last one leaves range. While plates are hidden it only waits for the scanner.
local function startRendering()
    if rendering then return end
    rendering = true

    CreateThread(function()
        while visibleCount > 0 do
            if hidden then
                Wait(cfg.scanFastTick)
            else
                drawVisible()
                Wait(0)
            end
        end

        rendering = false
    end)
end

CreateThread(function()
    while not ESX.IsPlayerLoaded() do Wait(500) end
    requestPlates()

    while true do
        local sleep = cfg.scanSlowTick

        if #plates > 0 then
            local coords = GetEntityCoords(PlayerPedId())
            hidden = platesHidden()

            if scan(coords) then sleep = cfg.scanFastTick end
            if visibleCount > 0 then startRendering() end
            if useTarget then refreshPedTargets(coords) end
        end

        Wait(sleep)
    end
end)

TriggerEvent('chat:addSuggestion', '/' .. cfg.commands.setName, 'A közeledben lévő bolt NPC-je fölé kiírt név', {
    { name = 'szöveg', help = ('legfeljebb %d karakter'):format(cfg.maxNameLength) },
})
TriggerEvent('chat:addSuggestion', '/' .. cfg.commands.setColor, 'A bolt nevének színe', {
    { name = 'szín', help = table.concat(cfg.colorOrder, ', ') },
})
TriggerEvent('chat:addSuggestion', '/' .. cfg.commands.clear, 'Az egyedi bolt-név törlése')
