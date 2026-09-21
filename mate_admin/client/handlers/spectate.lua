
local PARK_HEIGHT_OFFSET     = 1000.0
local NEAR_TELEPORT_RADIUS   = 80.0
local TARGET_EYE_HEIGHT      = 0.65

local ORBIT_DISTANCE_DEFAULT = 3.5
local ORBIT_DISTANCE_MIN     = 1.0
local ORBIT_DISTANCE_MAX     = 12.0
local ORBIT_ZOOM_STEP        = 0.5
local ORBIT_LOOK_SPEED       = 2.5

local CAM_FOV                = 50.0

---@type boolean
local _isSpectating    = false

---@type number?
local _spectateTarget   = nil

---@type vector3?
local _spectateBackPos  = nil

---@type boolean
local _wasInvincible    = false

---@param ped integer
local function _securePed(ped)
    _wasInvincible = IsGodModeActive()
    SetEntityCollision(ped, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
end

---@param ped integer
local function _hidePedVisually(ped)
    SetEntityVisible(ped, false, false)
    NetworkSetEntityInvisibleToNetwork(ped, true)
end

---@param ped integer
local function _unhidePed(ped)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    if not _wasInvincible then
        SetEntityInvincible(ped, false)
    end
    NetworkSetEntityInvisibleToNetwork(ped, false)
end

local function _stopSpectateCam()
    if IsFreecamActive() then
        SetFreecamActive(false)
    end
end

---@param ped integer
local function _stopSpectate(ped)
    _stopSpectateCam()

    if DoesEntityExist(ped) then
        _unhidePed(ped)
    end

    if _spectateBackPos then
        SetEntityCoords(ped, _spectateBackPos.x, _spectateBackPos.y, _spectateBackPos.z, false, false, false, true)
    end

    _isSpectating    = false
    _spectateTarget  = nil
    _spectateBackPos = nil
    _wasInvincible   = false

    -- A szerver a nézés idejére tartotta az ElectronAC-mentességet; a visszateleportot még
    -- a lejárati idő fedi (core/ElectronAC.lua).
    Rpc:SendServer('spectate:acstate', { active = false })
end

local function _doStopSpectate()
    if not _isSpectating then return end
    _stopSpectate(PlayerPedId())
    lib.notify({
        title       = locale('spectate.title'),
        description = locale('spectate.disabled'),
        type        = 'inform',
        duration    = 3000,
    })
end

RegisterCommand('___stopSpectate', function()
    _doStopSpectate()
end, false)

RegisterKeyMapping('___stopSpectate', locale('spectate.keymap_stop'), 'keyboard', 'BACK')

---@param targetPed integer
---@param targetServerId number
local function _runOrbitCamera(targetPed, targetServerId)
    local rotX     = -8.0
    local rotZ     = GetEntityHeading(targetPed) + 180.0
    local distance = ORBIT_DISTANCE_DEFAULT

    local function computeCamPos()
        local targetCoords = GetEntityCoords(targetPed) + vector3(0.0, 0.0, TARGET_EYE_HEIGHT)
        local _, forward   = EulerToMatrix(rotX, 0.0, rotZ)
        return targetCoords - (forward * distance)
    end

    SetFreecamActive(true)
    SetFreecamFov(CAM_FOV)

    local camPos = computeCamPos()
    SetFreecamPosition(camPos.x, camPos.y, camPos.z)
    SetFreecamRotation(rotX, 0.0, rotZ)

    while _isSpectating and _spectateTarget == targetServerId do
        if not DoesEntityExist(targetPed) then break end

        local lookX = GetDisabledControlNormal(0, CONTROL_MAPPING.LOOK_X)
        local lookY = GetDisabledControlNormal(0, CONTROL_MAPPING.LOOK_Y)

        rotX = rotX + (-lookY * CONTROL_SETTINGS.LOOK_SENSITIVITY_X * ORBIT_LOOK_SPEED)
        rotZ = rotZ + (-lookX * CONTROL_SETTINGS.LOOK_SENSITIVITY_Y * ORBIT_LOOK_SPEED)
        rotX, _, rotZ = ClampCameraRotation(rotX, 0.0, rotZ)

        if IsDisabledControlJustPressed(0, 241) then
            distance = Clamp(distance - ORBIT_ZOOM_STEP, ORBIT_DISTANCE_MIN, ORBIT_DISTANCE_MAX)
        elseif IsDisabledControlJustPressed(0, 242) then
            distance = Clamp(distance + ORBIT_ZOOM_STEP, ORBIT_DISTANCE_MIN, ORBIT_DISTANCE_MAX)
        end

        camPos = computeCamPos()
        SetFreecamPosition(camPos.x, camPos.y, camPos.z)
        SetFreecamRotation(rotX, 0.0, rotZ)

        Wait(0)
    end
end

---@param data { targetNetId: number, targetServerId: number, targetName: string, targetCoords: { x: number, y: number, z: number } }
handlers['toggleSpectate'] = function(data)
    local ped = PlayerPedId()

    if _isSpectating then
        _doStopSpectate()
        return
    end

    _spectateBackPos = GetEntityCoords(ped)
    _isSpectating    = true
    _spectateTarget  = data.targetServerId

    Rpc:SendServer('spectate:acstate', { active = true })

    local tc     = data.targetCoords
    local angle  = math.random() * 2 * math.pi
    local nearX  = tc.x + math.cos(angle) * NEAR_TELEPORT_RADIUS
    local nearY  = tc.y + math.sin(angle) * NEAR_TELEPORT_RADIUS
    SetEntityCoords(ped, nearX, nearY, tc.z, false, false, false, false)
    _securePed(ped)

    CreateThread(function()
        local targetPed = nil
        local elapsed    = 0
        local timeout     = 5000
        local step        = 100

        while elapsed < timeout do
            targetPed = NetworkGetEntityFromNetworkId(data.targetNetId)
            if DoesEntityExist(targetPed) then break end
            Wait(step)
            elapsed = elapsed + step
        end

        if not _isSpectating or _spectateTarget ~= data.targetServerId then
            return
        end

        if not targetPed or not DoesEntityExist(targetPed) then
            _stopSpectate(PlayerPedId())
            lib.notify({
                title       = locale('spectate.title'),
                description = locale('spectate.ped_timeout'),
                type        = 'error',
                duration    = 4000,
            })
            return
        end

        _hidePedVisually(PlayerPedId())
        local farPos = GetEntityCoords(targetPed)
        SetEntityCoords(PlayerPedId(), farPos.x, farPos.y, farPos.z + PARK_HEIGHT_OFFSET, false, false, false, false)

        lib.notify({
            title       = locale('spectate.title'),
            description = locale('spectate.spectating', data.targetName),
            type        = 'inform',
            duration    = 4000,
        })

        CreateThread(function()
            while _isSpectating and _spectateTarget == data.targetServerId do
                DisableControlAction(0, 200, true)
                if IsDisabledControlJustPressed(0, 200) then
                    _doStopSpectate()
                    break
                end
                Wait(0)
            end
        end)

        _runOrbitCamera(targetPed, data.targetServerId)

        if _isSpectating and _spectateTarget == data.targetServerId then
            _stopSpectate(PlayerPedId())
            lib.notify({
                title       = locale('spectate.title'),
                description = locale('spectate.interrupted'),
                type        = 'error',
                duration    = 4000,
            })
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if _isSpectating then
        _stopSpectate(PlayerPedId())
    end
end)
