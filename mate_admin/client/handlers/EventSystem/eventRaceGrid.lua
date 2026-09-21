local FallbackSpacing  <const> = 4.0
local GapRight         <const> = 1.5
local GapForward        <const> = 2.0
local MaxAxis           <const> = 10
local RotationStep      <const> = 15.0
local RotationFineStep  <const> = 1.0

local active          = false
local model           = ''
local perRow          = 1
local rows            = 1
local gridHeading     = 0.0
local spacingRight    = FallbackSpacing
local spacingForward  = FallbackSpacing
local previewVehicles = {}
local loadedModelHash = nil

---@param hash number
local function updateSpacingFromModel(hash)
    local min, max = GetModelDimensions(hash)
    if not min or not max then return end

    local width  = max.x - min.x
    local length = max.y - min.y

    spacingRight   = width + GapRight
    spacingForward = length + GapForward
end

---@param anchorPos vector3
---@param heading   number
---@param col       number 0-based
---@param row       number 0-based
---@return number, number, number
local function computeCell(anchorPos, heading, col, row)
    local headingRad     = math.rad(heading)
    local rightX, rightY = math.cos(headingRad), math.sin(headingRad)
    local fwdX, fwdY     = -math.sin(headingRad), math.cos(headingRad)

    local offsetRight   = (col - (perRow - 1) / 2) * spacingRight
    local offsetForward = row * spacingForward

    return anchorPos.x + rightX * offsetRight + fwdX * offsetForward,
        anchorPos.y + rightY * offsetRight + fwdY * offsetForward,
        anchorPos.z
end

local function clearPreview()
    for _, veh in ipairs(previewVehicles) do
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
        end
    end
    previewVehicles = {}
end

local function rebuildPreview()
    clearPreview()

    if model == '' then return end

    local ped       = PlayerPedId()
    local anchorPos = GetEntityCoords(ped)
    local heading    = gridHeading
    local hash       = GetHashKey(model)

    if not HasModelLoaded(hash) then
        RequestModel(hash)
        local deadline = GetGameTimer() + 3000
        while not HasModelLoaded(hash) and GetGameTimer() < deadline do
            Wait(0)
        end
    end

    if not HasModelLoaded(hash) then return end

    loadedModelHash = hash
    updateSpacingFromModel(hash)

    for row = 0, rows - 1 do
        for col = 0, perRow - 1 do
            local x, y, z = computeCell(anchorPos, heading, col, row)
            local veh = CreateVehicle(hash, x, y, z, heading, false, false)
            -- bc_kocsitorles: legalis spawn jelolese
            if veh and veh ~= 0 then Entity(veh).state:set('bc_spawned', true, true) end
            if veh and veh ~= 0 then TriggerEvent("bc:localVehSpawn", veh) end

            SetEntityAlpha(veh, 120, false)
            SetEntityCollision(veh, false, false)
            FreezeEntityPosition(veh, true)
            SetVehicleDoorsLocked(veh, 2)

            previewVehicles[#previewVehicles + 1] = veh
        end
    end
end

local function repositionPreview()
    local ped       = PlayerPedId()
    local anchorPos = GetEntityCoords(ped)
    local heading    = gridHeading

    local idx = 1
    for row = 0, rows - 1 do
        for col = 0, perRow - 1 do
            local veh = previewVehicles[idx]
            if veh and DoesEntityExist(veh) then
                local x, y, z = computeCell(anchorPos, heading, col, row)
                SetEntityCoords(veh, x, y, z, false, false, false, false)
                SetEntityHeading(veh, heading)
            end
            idx = idx + 1
        end
    end
end

local function exitGridMode()
    if not active then return end
    active = false
    clearPreview()

    if loadedModelHash then
        SetModelAsNoLongerNeeded(loadedModelHash)
        loadedModelHash = nil
    end
end

---@param newModel string
function StartRaceGridMode(newModel)
    if active then
        exitGridMode()
        return
    end

    if not newModel or newModel == '' then
        lib.notify({
            title       = locale('racegrid.title'),
            description = locale('racegrid.no_model'),
            type        = 'error',
            duration    = 4000,
        })
        return
    end

    model       = newModel
    perRow      = 1
    rows        = 1
    gridHeading = 0.0
    active      = true
    rebuildPreview()
end

---@return boolean
function IsRaceGridModeActive()
    return active
end

CreateThread(function()
    while true do
        if active then
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 15, true)

            local altHeld   = IsControlPressed(0, 19)
            local ctrlHeld  = IsControlPressed(0, 36)
            local shiftHeld = IsControlPressed(0, 21)
            local scrollUp   = IsDisabledControlJustPressed(0, 15)
            local scrollDown = IsDisabledControlJustPressed(0, 14)
            local changed    = false

            if scrollUp or scrollDown then
                local dir = scrollUp and 1 or -1

                if altHeld then
                    gridHeading = (gridHeading + dir * RotationFineStep) % 360
                    changed     = true
                elseif ctrlHeld then
                    gridHeading = (gridHeading + dir * RotationStep) % 360
                    changed     = true
                elseif shiftHeld then
                    rows    = math.max(1, math.min(MaxAxis, rows + dir))
                    changed = true
                else
                    perRow  = math.max(1, math.min(MaxAxis, perRow + dir))
                    changed = true
                end
            end

            if changed then
                rebuildPreview()
            else
                repositionPreview()
            end

            local hudScale = 0.90
            local hudLines = {
                locale('racegrid.hud_line1', perRow, rows, perRow * rows, gridHeading),
                locale('racegrid.hud_line2'),
                locale('racegrid.hud_line3'),
            }

            for i, line in ipairs(hudLines) do
                local widthNormalized = GetTextWidth(line, BebasNeueFont, hudScale)
                DrawText({
                    value   = line,
                    font    = BebasNeueFont,
                    scale   = hudScale,
                    outline = true,
                    color   = { r = 255, g = 255, b = 255, a = 220 },
                    pos     = {
                        x = (0.5 - widthNormalized / 2) * screenX,
                        y = (0.92 + (i - 1) * 0.022) * screenY,
                    },
                })
            end

            Wait(0)
        else
            -- Grid mode is off almost always; no reason to wake up twice a second.
            Wait(2000)
        end
    end
end)

RegisterCommand('bceventgrid', function()
    if active then
        exitGridMode()
        return
    end

    CreateThread(function()
        local ok, state = pcall(function()
            return Rpc:CallServer('events:getState', {})
        end)

        if ok and state and state.success == false then
            lib.notify({
                title       = locale('racegrid.title'),
                description = state.message or locale('racegrid.no_model'),
                type        = 'error',
                duration    = 4000,
            })
            return
        end

        if not ok or not state or not state.raceVehicleModel or state.raceVehicleModel == '' then
            lib.notify({
                title       = locale('racegrid.title'),
                description = locale('racegrid.no_model'),
                type        = 'error',
                duration    = 4000,
            })
            return
        end

        StartRaceGridMode(state.raceVehicleModel)
    end)
end, false)

RegisterKeyMapping('bceventgrid', locale('racegrid.keymap_toggle'), 'keyboard', 'F12')

RegisterCommand('eventgridconfirm', function()
    if not active then return end

    local ped        = PlayerPedId()
    local pos         = GetEntityCoords(ped)
    local heading     = gridHeading
    local requestPerRow, requestRows = perRow, rows
    local requestSpacingRight, requestSpacingForward = spacingRight, spacingForward

    exitGridMode()

    CreateThread(function()
        local ok, result = pcall(function()
            return Rpc:CallServer('events:spawnRaceGrid', {
                anchor         = { x = pos.x, y = pos.y, z = pos.z, heading = heading },
                perRow         = requestPerRow,
                rows           = requestRows,
                spacingRight   = requestSpacingRight,
                spacingForward = requestSpacingForward,
            })
        end)

        lib.notify({
            title       = locale('racegrid.title'),
            description = (ok and result and result.message) or locale('racegrid.request_failed'),
            type        = (ok and result and result.success) and 'success' or 'error',
            duration    = 5000,
        })
    end)
end, false)

RegisterKeyMapping('eventgridconfirm', locale('racegrid.keymap_confirm'), 'keyboard', 'RETURN')

RegisterCommand('eventgridcancel', function()
    if not active then return end
    exitGridMode()
    lib.notify({
        title       = locale('racegrid.title'),
        description = locale('racegrid.cancelled'),
        type        = 'inform',
        duration    = 3000,
    })
end, false)

RegisterKeyMapping('eventgridcancel', locale('racegrid.keymap_cancel'), 'keyboard', 'BACK')

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    clearPreview()
    if loadedModelHash then
        SetModelAsNoLongerNeeded(loadedModelHash)
    end
end)
