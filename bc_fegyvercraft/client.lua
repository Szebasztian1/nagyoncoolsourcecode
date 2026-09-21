local craftPed = nil
local uiOpen = false

-- Fields forwarded per action; anything else the NUI sends is dropped.
local ACTION_FIELDS = {
    craft        = { 'model' },
    help         = { 'hid' },
    pickup       = { 'model', 'count' },
    share        = { 'model', 'target' },
    addHelper    = { 'model', 'target' },
    removeHelper = { 'hid' },
}

local function closeUI()
    if not uiOpen then return end

    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openUI()
    if uiOpen then return end

    ESX.TriggerServerCallback('Fegyvercraft:Server:GetData', function(data)
        if not data then
            return ESX.ShowNotification('A craftoló most nem érhető el.')
        end

        uiOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'open', data = data })
    end)
end

--- Spawns the craft NPC only while a player is nearby.
CreateThread(function()
    Wait(1000) -- let the player spawn and ox_target register before the zone runs

    lib.zones.sphere({
        coords = vec3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z),
        radius = 50.0,
        debug = false,
        onEnter = function()
            if craftPed then return end

            if not IsModelInCdimage(Config.NPC.model) then
                return print(('[bc_fegyvercraft] Invalid ped model hash: %s'):format(Config.NPC.model))
            end

            RequestModel(Config.NPC.model)
            while not HasModelLoaded(Config.NPC.model) do
                Wait(10)
            end

            craftPed = CreatePed(1, Config.NPC.model, Config.NPC.coords, false, false)
            PlaceObjectOnGroundProperly(craftPed)
            FreezeEntityPosition(craftPed, true)
            SetEntityInvincible(craftPed, true)
            SetBlockingOfNonTemporaryEvents(craftPed, true)
            TaskStartScenarioInPlace(craftPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
            SetModelAsNoLongerNeeded(Config.NPC.model)

            exports.ox_target:addLocalEntity(craftPed, {
                {
                    onSelect = openUI,
                    icon = 'fas fa-gun',
                    label = 'Fegyver Craft',
                }
            })
        end,
        onExit = function()
            if not craftPed then return end

            exports.ox_target:removeLocalEntity(craftPed)
            DeleteEntity(craftPed)
            craftPed = nil
            closeUI()
        end
    })
end)

RegisterNUICallback('action', function(data, cb)
    cb(true)

    local fields = type(data) == 'table' and ACTION_FIELDS[data.action]
    if not fields then return end

    -- forward only the known fields, so the payload stays minimal
    local payload = {}
    for i = 1, #fields do
        payload[fields[i]] = data[fields[i]]
    end

    TriggerServerEvent('Fegyvercraft:Server:Action', data.action, payload)
end)

RegisterNUICallback('close', function(_, cb)
    cb(true)
    closeUI()
end)

--- Result of an action + the refreshed panel data.
RegisterNetEvent('Fegyvercraft:Client:Update', function(data, msg, ok)
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
end)
