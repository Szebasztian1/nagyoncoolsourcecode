---@type table<string, fun(data: table)>
handlers = {}

RegisterFontFile('BebasNeueOtf')
---@type integer
BebasNeueFont = RegisterFontId('BebasNeueOtf')

---@param ped integer
---@return vector3
function GetPedHeadCoords(ped)
    local coords = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, 31086))
    coords = coords == vector3(0, 0, 0) and GetEntityCoords(ped) + vector3(0, 0, 0.9) or coords + vector3(0, 0, 0.35)

    local frameTime <const> = GetFrameTime()
    local vel <const> = GetEntityVelocity(ped)

    return vector3(
        coords.x + vel.x * frameTime,
        coords.y + vel.y * frameTime,
        coords.z + vel.z * frameTime
    )
end

---@type table<string, string>
local pendingGrants = {}

local isPanelOpen = false
local isOnDuty = false
local onDutyCount = 0

local function sendDutyCount()
    Rpc:Send('widget:dutyCount', { count = onDutyCount })
end

RegisterNetEvent('mate-admin:tag:onDuty')
AddEventHandler('mate-admin:tag:onDuty', function(adminSrc)
    onDutyCount = onDutyCount + 1
    if adminSrc == GetPlayerServerId(PlayerId()) then
        isOnDuty = true
        LocalPlayer.state:set('isOnDuty', true, false)
        Rpc:Send('widget:dutyChanged', { onDuty = true })
    end
    sendDutyCount()
end)

RegisterNetEvent('mate-admin:tag:offDuty')
AddEventHandler('mate-admin:tag:offDuty', function(adminSrc)
    onDutyCount = math.max(0, onDutyCount - 1)
    if adminSrc == GetPlayerServerId(PlayerId()) then
        isOnDuty = false
        LocalPlayer.state:set('isOnDuty', false, false)
        Rpc:Send('widget:dutyChanged', { onDuty = false })
    end
    sendDutyCount()
end)

---@class ToggleState
---@field godMode   boolean
---@field invisible boolean
---@field fastRun   boolean
---@field superJump boolean
---@field noclip    boolean
---@field tognames  boolean

---@type ToggleState
local toggleState = {
    godMode   = false,
    invisible = false,
    fastRun   = false,
    superJump = false,
    noclip    = false,
    togtag    = true,
    -- Off by default; the name tag render loop is what costs frame time on duty.
    tognames  = false,
    inspect   = false,
}

---@return boolean
function IsGodModeActive()
    return toggleState.godMode
end

-- Az adminoknak nincs teljes ElectronAC Bypass-uk: a kapcsolók idejére a szerver ad
-- modulonkénti mentességet (core/ElectronAC.lua), de csak duty-ban lévő adminnak.
-- Bekapcsoláskor a hatás ELŐTT szólunk, hogy a mentesség már éljen, mire az Electron mér.
---@type string[]
local AC_TOGGLES <const> = { 'godMode', 'invisible', 'fastRun', 'superJump', 'noclip' }

---@type table<string, boolean>
local lastAcState = {}

local function syncAcToggles()
    local state, changed = {}, false

    for i = 1, #AC_TOGGLES do
        local key = AC_TOGGLES[i]
        state[key] = toggleState[key] == true
        if lastAcState[key] ~= state[key] then changed = true end
    end

    if not changed then return end

    lastAcState = state
    Rpc:SendServer('toggle:acstate', state)
end

---@type table<string, string>
local DefaultKeybinds <const> = {
    godMode   = 'F9',
    invisible = 'F9',
    fastRun   = 'F9',
    superJump = 'F9',
    noclip    = 'F9',
    togtag    = 'F9',
    tognames  = 'F9',
}

---@type table<string, string>
local toggleKeybinds = {}

for k, def in pairs(DefaultKeybinds) do
    local saved = GetResourceKvpString('keybind_' .. k)
    toggleKeybinds[k] = (saved and saved ~= '') and saved or def
end

---@param key string
local function applyToggle(key)
    Rpc:Send('toggle:keybind', { key = key })
end

for toggleKey, _ in pairs(DefaultKeybinds) do
    RegisterCommand('admin_toggle_' .. toggleKey, function()
        if not isOnDuty then return end
        applyToggle(toggleKey)
    end, false)
    RegisterKeyMapping('admin_toggle_' .. toggleKey, 'Admin Toggle ' .. toggleKey, 'keyboard', toggleKeybinds[toggleKey])
end

RegisterNUICallback('keybind:set', function(data, cb)
    local key     = data.key
    local keyName = data.keyName
    if not DefaultKeybinds[key] then
        cb({ success = false })
        return
    end
    toggleKeybinds[key] = keyName
    SetResourceKvp('keybind_' .. key, keyName)
    cb({ success = true })
end)

Rpc:Register('toggle:godMode', function(data)
    toggleState.godMode = data.value
    syncAcToggles()

    local playerId = PlayerId()
    local ped = PlayerPedId()
    local enabled = toggleState.godMode

    SetPlayerInvincible(playerId, enabled)
    SetEntityInvincible(ped, enabled)

    SetEntityProofs(
        ped,
        enabled,
        enabled,
        enabled,
        enabled,
        enabled,
        enabled,
        enabled,
        enabled
    )

    SetPedDiesWhenInjured(ped, not enabled)
    SetPedCanRagdoll(ped, not enabled)

    SetPoliceIgnorePlayer(playerId, enabled)
    SetEveryoneIgnorePlayer(playerId, enabled)

    SetPedCanBeTargetted(ped, not enabled)

    SetPedCanBeDraggedOut(ped, not enabled)
    SetPedCanBeKnockedOffVehicle(ped, enabled and 1 or 0)

    if enabled then
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedLastWeaponDamage(ped)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        StartRagdollBlocker()
    end

    return {
        value = toggleState.godMode
    }
end)
-- Ragdoll suppression only matters while noclip or godmode is on, so the thread is
-- spawned on demand instead of polling forever on every player's client.
local ragdollBlockerRunning = false

function StartRagdollBlocker()
    if ragdollBlockerRunning then return end
    ragdollBlockerRunning = true

    CreateThread(function()
        while toggleState.noclip or toggleState.godMode do
            SetPedCanRagdoll(PlayerPedId(), false)
            Wait(0)
        end

        SetPedCanRagdoll(PlayerPedId(), true)
        ragdollBlockerRunning = false
    end)
end

Rpc:Register("toggle:togtag", (function(data)
    toggleState.togtag = data.value
    Rpc:SendServer("toggle:togtag", { value = data.value })
end))

Rpc:Register('toggle:tognames', function(data)
    toggleState.tognames = data.value
    local handler = handlers['mate-admin:nameTags:toggle']
    if handler then handler({ value = data.value }) end
    return { value = toggleState.tognames }
end)

Rpc:Register('toggle:inspect', function(data)
    toggleState.inspect = data.value
    local handler = handlers['mate-admin:inspect:toggle']
    if handler then handler({}) end
    return { value = toggleState.inspect }
end)

-- Invisibility is deliberately NOT done with SetEntityVisible any more: that flag is
-- replicated through the ped's sync node, so it hides the admin from every client at
-- once - including the colleague who is supposed to see where they are. The ped stays
-- network-visible and the server tells each client individually what to do with it
-- (see core/Duty.lua + client/events.lua). Locally we only ghost our own ped so the
-- admin still gets feedback that the toggle is on.

local lastHiddenSent = false
local selfAlphaRunning = false

---@return boolean
local function isSelfHidden()
    return toggleState.invisible or toggleState.noclip
end

local function applySelfAlpha()
    local ped = PlayerPedId()

    -- Nothing is hidden from here on purpose. Every owner-side hide is all-or-nothing:
    -- SetEntityVisible replicates to everyone including the colleagues, and
    -- NetworkSetEntityInvisibleToNetwork is ignored on a player ped (tested live). The
    -- hide is done per viewer in client/events.lua; here we only ghost our own ped so the
    -- admin gets feedback that the toggle is on.
    if toggleState.invisible then
        SetEntityAlpha(ped, Config.Invisible.selfAlpha, false)
    else
        ResetEntityAlpha(ped)
    end
end

-- Alpha and the network flag are lost on respawn / model change, so keep re-applying them
-- while either toggle is on.
local function startSelfAlphaThread()
    if selfAlphaRunning then return end
    selfAlphaRunning = true

    CreateThread(function()
        while isSelfHidden() do
            applySelfAlpha()
            Wait(1000)
        end

        ResetEntityAlpha(PlayerPedId())
        selfAlphaRunning = false
    end)
end

---Tell the server whether this admin should be hidden from ordinary players. Noclip
---counts too: the freecam used to hide the ped with the networked SetEntityVisible,
---which would undo the whole point of this.
function SyncAdminHidden()
    local hidden <const> = isSelfHidden()

    if hidden == lastHiddenSent then return end

    lastHiddenSent = hidden
    Rpc:SendServer('toggle:invisible:notify', { value = hidden })
end

Rpc:Register('toggle:invisible', function(data)
    toggleState.invisible = data.value == true
    syncAcToggles()

    applySelfAlpha()

    if isSelfHidden() then
        startSelfAlphaThread()
    end

    SyncAdminHidden()

    return { value = toggleState.invisible }
end)

Rpc:Register('toggle:fastRun', function(data)
    toggleState.fastRun = data.value
    syncAcToggles()
    SetRunSprintMultiplierForPlayer(PlayerId(), toggleState.fastRun and 1.49 or 1.0)
    return { value = toggleState.fastRun }
end)

RegisterNUICallback('toggle:superJump', function(data, cb)
    toggleState.superJump = data.value
    syncAcToggles()
    if toggleState.superJump then
        CreateThread(function()
            while toggleState.superJump do
                SetSuperJumpThisFrame(PlayerId())
                Wait(0)
            end
        end)
    end
    cb({ success = true, data = { value = toggleState.superJump } })
end)

RegisterNUICallback('toggle:noclip', function(data, cb)
    toggleState.noclip = data.value == true
    syncAcToggles()

    if toggleState.noclip then StartRagdollBlocker() end

    local noclipHandler = handlers['mate-admin:noclip:toggle']
    if noclipHandler then
        noclipHandler({
            value          = toggleState.noclip,
            keepInvincible = toggleState.godMode,
            keepInvisible  = toggleState.invisible,
        })
    end

    applySelfAlpha()

    if isSelfHidden() then
        startSelfAlphaThread()
    end

    SyncAdminHidden()

    cb({ success = true, data = { value = toggleState.noclip } })
end)

local _commandsCache = nil

RegisterNUICallback('overview:init', function(_, cb)
    if _commandsCache then
        Rpc:Send('overview:data', {
            commands = _commandsCache,
            toggles  = toggleState,
            keybinds = toggleKeybinds,
        })
        cb({ success = true })
        return
    end
    CreateThread(function()
        local ok, cmds = pcall(function()
            return Rpc:CallServer('mate-admin:getCommands', {})
        end)
        _commandsCache = ok and cmds or {}
        Rpc:Send('overview:data', {
            commands = _commandsCache,
            toggles  = toggleState,
            keybinds = toggleKeybinds,
        })
        cb({ success = true })
    end)
end)

RegisterNUICallback('overview:getToggles', function(_, cb)
    Rpc:Send('overview:toggles', {
        toggles  = toggleState,
        keybinds = toggleKeybinds,
    })
    cb({ success = true })
end)

---@param page string?
local function openPanel(page)
    isPanelOpen = true
    SetNuiFocus(true, true)
    Rpc:Send('open', { page = page })
    CreateThread(function()
        local ok, adminData = pcall(function()
            return Rpc:CallServer('mate-admin:getAdminData', {})
        end)
        if ok and adminData then
            Rpc:Send('setAdminData', adminData)
        end
    end)
end

---@return nil
local function closePanel()
    isPanelOpen = false
    SetNuiFocus(false, false)
    Rpc:Send('close', {})
end

Rpc:Register('locale:get', function()
    return lib.getLocales()
end)

AddEventHandler('ox_lib:setLocale', function()
    Wait(0)
    Rpc:Send('locale:set', lib.getLocales())
end)

Rpc:Register('uiReady', function()
    CreateThread(function()
        local ok, adminData = pcall(function()
            return Rpc:CallServer('mate-admin:getAdminData', {})
        end)
        if ok and adminData then
            Rpc:Send('setAdminData', adminData)
        end
        local ok2, countData = pcall(function()
            return Rpc:CallServer('widget:getOnDutyCount', {})
        end)
        if ok2 and countData then
            onDutyCount = countData.count or 0
            sendDutyCount()
        end
    end)
    return {}
end)

Rpc:Register('exit', function()
    closePanel()
    return {}
end)

RegisterCommand('adminpanel', function()
    if PlayerActiveReportId ~= nil and not isOnDuty then
        if not isPanelOpen then
            SetNuiFocus(true, true)
        end
        Rpc:Send('chatwidget:focus', {})
        return
    end

    if not isOnDuty then
        local isAdmin = lib.callback.await('mate-admin:isAdmin', false)
        if not isAdmin then return end
        SetNuiFocus(true, true)
        Rpc:Send('widget:moveMode', { enabled = true })
        Rpc:Send('open:dutyPrompt', {})
        return
    end

    local canOpen = lib.callback.await('mate-admin:panel:requestOpen', false)
    if not canOpen then return end

    if isPanelOpen then
        closePanel()
    else
        openPanel(nil)
    end
end, false)

RegisterKeyMapping('adminpanel', locale('keymap.adminpanel'), 'keyboard', 'M')

---@param page string
local function openAdminPage(page)
    local canOpen = lib.callback.await('mate-admin:panel:requestOpen', false)
    if not canOpen then return end
    if isPanelOpen then
        Rpc:Send('open', { page = page })
    else
        openPanel(page)
    end
end


---@return nil
local function cleanupToggles()
    local pid = PlayerId()
    local ped = PlayerPedId()

    toggleState.godMode = false

    SetPlayerInvincible(pid, false)
    SetEntityInvincible(ped, false)

    SetEntityProofs(ped, false, false, false, false, false, false, false, false)

    SetPedDiesWhenInjured(ped, true)
    SetPedCanRagdoll(ped, true)

    SetPoliceIgnorePlayer(pid, false)
    SetEveryoneIgnorePlayer(pid, false)

    SetPedCanBeTargetted(ped, true)

    SetPedCanBeDraggedOut(ped, true)
    SetPedCanBeKnockedOffVehicle(ped, 0)

    SetEntityCollision(ped, true, true)

    toggleState.invisible = false
    SetEntityVisible(ped, true, false)
    ResetEntityAlpha(ped)

    toggleState.fastRun = false
    SetRunSprintMultiplierForPlayer(pid, 1.0)

    toggleState.superJump = false

    toggleState.noclip = false
    local noclipHandler = handlers['mate-admin:noclip:toggle']
    if noclipHandler then noclipHandler({ value = false }) end

    toggleState.tognames = false
    local nameTagsHandler = handlers['mate-admin:nameTags:toggle']
    if nameTagsHandler then nameTagsHandler({ value = false }) end

    SyncAdminHidden()
    syncAcToggles()
end

RegisterNetEvent("mate-admin:tag:offDuty", function(serverId, name, group)
    if serverId == GetPlayerServerId(PlayerId()) then
        Wait(1000)
        cleanupToggles()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    cleanupToggles()
end)

Rpc:Register("duty:toggle", function(_)
    ExecuteCommand('duty')
    return true
end)
Rpc:Register("dutyPrompt:close", function(_)
    SetNuiFocus(false, false)
    Rpc:Send('widget:moveMode', { enabled = false })
    return true
end)

RegisterCommand('reports', function() openAdminPage('reports') end, false)
RegisterCommand('players', function() openAdminPage('players') end, false)
RegisterCommand('admins', function() openAdminPage('admins') end, false)
RegisterCommand('events', function() openAdminPage('events') end, false)

local isTeamPanelOpen = false

local function openTeamPanel()
    isTeamPanelOpen = true
    SetNuiFocus(true, true)
    Rpc:Send('open:eventTeam', {})
end

local function closeTeamPanel()
    isTeamPanelOpen = false
    SetNuiFocus(false, false)
    Rpc:Send('close:eventTeam', {})
end

RegisterCommand('eventteam', function()
    if isTeamPanelOpen then
        closeTeamPanel()
        return
    end

    CreateThread(function()
        local ok, state = pcall(function()
            return Rpc:CallServer('eventteam:getState', {})
        end)

        if not ok or not state or not state.teamPvpActive then
            lib.notify({
                title       = locale('eventteam.title'),
                description = locale('eventteam.no_active_teampvp'),
                type        = 'error',
                duration    = 4000,
            })
            return
        end

        openTeamPanel()
    end)
end, false)

RegisterKeyMapping('eventteam', locale('keymap.eventteam'), 'keyboard', 'F10')

Rpc:Register('eventteam:closePanel', function(_)
    closeTeamPanel()
    return {}
end)

AddEventHandler('mate-admin:eventteam:openWithInvite', function()
    if not isTeamPanelOpen then
        openTeamPanel()
    end
end)

Rpc:Register('eventgrid:start', function(data)
    if isPanelOpen then
        closePanel()
    end
    StartRaceGridMode(data.model)
    return {}
end)

RegisterNetEvent('mate-admin:secure:dispatch')
AddEventHandler('mate-admin:secure:dispatch', function(nonce, eventName)
    if source == '' then return end

    pendingGrants[nonce] = eventName

    TriggerServerEvent('mate-admin:secure:validate', nonce, eventName)

    SetTimeout(6000, function()
        pendingGrants[nonce] = nil
    end)
end)

RegisterNetEvent('mate-admin:secure:grant')
AddEventHandler('mate-admin:secure:grant', function(nonce, data)
    if source == '' then return end

    local eventName = pendingGrants[nonce]
    if not eventName then return end

    pendingGrants[nonce] = nil

    local handler = handlers[eventName]
    if handler then
        handler(data or {})
    end
end)
