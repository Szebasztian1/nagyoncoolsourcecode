local allowed = false   -- is this identifier on the whitelist at all
local inZone = false    -- is the player near the NPC
local craftPed = nil
local stashZone = nil
local uiOpen = false

local function closeUI()
    if not uiOpen then return end

    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openUI()
    if uiOpen then return end

    ESX.TriggerServerCallback('FegyvercraftWL:Server:GetData', function(data)
        if not data then
            return ESX.ShowNotification('A craftoló most nem érhető el.')
        end

        uiOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'open', data = data })
    end)
end

--- ---------------------------------------------------------------- NPC + stash

local spawning = false
local wanted -- forward declaration: is the ped supposed to exist right now

--- Loading the model yields, so it runs in its own thread — sync() may be called from a
--- server callback, and the flag keeps a second call from spawning a second ped.
local function spawnPed()
    if craftPed or spawning then return end

    if not IsModelInCdimage(Config.NPC.model) then
        return print(('[bc_fegyvercraft_wl] Invalid ped model hash: %s'):format(Config.NPC.model))
    end

    spawning = true

    CreateThread(function()
        RequestModel(Config.NPC.model)

        local tries = 0
        while not HasModelLoaded(Config.NPC.model) and tries < 200 do
            tries = tries + 1
            Wait(10)
        end

        spawning = false

        -- the state may have changed while the model was loading
        if not HasModelLoaded(Config.NPC.model) or not wanted() or craftPed then return end

        craftPed = CreatePed(1, Config.NPC.model, Config.NPC.coords, false, false)
        PlaceObjectOnGroundProperly(craftPed)
        FreezeEntityPosition(craftPed, true)
        SetEntityInvincible(craftPed, true)
        SetBlockingOfNonTemporaryEvents(craftPed, true)
        TaskStartScenarioInPlace(craftPed, Config.NPC.scenario or 'WORLD_HUMAN_CLIPBOARD', 0, true)
        SetModelAsNoLongerNeeded(Config.NPC.model)

        exports.ox_target:addLocalEntity(craftPed, {
            {
                onSelect = openUI,
                icon = 'fas fa-gun',
                label = Config.NPC.label or 'Fegyver Craft',
            }
        })
    end)
end

local function removePed()
    if not craftPed then return end

    exports.ox_target:removeLocalEntity(craftPed)
    DeleteEntity(craftPed)
    craftPed = nil
    closeUI()
end

local function addStash()
    if stashZone or not Config.Stash or not Config.Stash.enabled then return end

    stashZone = exports.ox_target:addSphereZone({
        coords = Config.Stash.coords,
        radius = Config.Stash.radius or 1.2,
        debug = false,
        options = {
            {
                icon = Config.Stash.targetIcon or 'fas fa-box-open',
                label = Config.Stash.targetLabel or 'Raktár megnyitása',
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', Config.Stash.id)
                end,
            }
        }
    })
end

local function removeStash()
    if not stashZone then return end

    exports.ox_target:removeZone(stashZone)
    stashZone = nil
end

wanted = function()
    return allowed and inZone
end

--- The NPC and the stash point exist only for a whitelisted player — nobody else sees them.
local function sync()
    if wanted() then spawnPed() else removePed() end
    if allowed then addStash() else removeStash() end
end

local function requestAccess()
    ESX.TriggerServerCallback('FegyvercraftWL:Server:GetAccess', function(state)
        allowed = state == true
        sync()
    end)
end

RegisterNetEvent('esx:playerLoaded', function()
    requestAccess()
end)

CreateThread(function()
    Wait(2000) -- let ESX and ox_target come up (also covers a resource restart mid-session)
    requestAccess()

    lib.zones.sphere({
        coords = vec3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z),
        radius = 50.0,
        debug = false,
        onEnter = function()
            inZone = true
            sync()
        end,
        onExit = function()
            inZone = false
            sync()
        end
    })
end)

--- ---------------------------------------------------------------- NUI

RegisterNUICallback('craft', function(data, cb)
    cb(true)

    if type(data) ~= 'table' then return end

    TriggerServerEvent('FegyvercraftWL:Server:Craft', { model = data.model, count = data.count })
end)

RegisterNUICallback('close', function(_, cb)
    cb(true)
    closeUI()
end)

--- Result of a craft + the refreshed panel data.
RegisterNetEvent('FegyvercraftWL:Client:Update', function(data, msg, ok)
    if uiOpen then
        SendNUIMessage({ action = 'update', data = data, msg = msg, ok = ok })
    elseif msg then
        ESX.ShowNotification(msg)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if uiOpen then
        SetNuiFocus(false, false)
    end

    if craftPed then
        DeleteEntity(craftPed)
    end

    removeStash()
end)
