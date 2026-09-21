---@param model string|number
local function applyModel(model)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    if HasModelLoaded(model) then
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
    end
end

---@param ped number
---@return table
local function snapshotPedAppearance(ped)
    local components = {}
    for _, slot in ipairs(Config.DutyPed.clothesComponents) do
        components[tostring(slot.id)] = {
            drawable = GetPedDrawableVariation(ped, slot.id),
            texture  = GetPedTextureVariation(ped, slot.id),
        }
    end

    local props = {}
    for _, slot in ipairs(Config.DutyPed.clothesProps) do
        local drawable = GetPedPropIndex(ped, slot.id)
        props[tostring(slot.id)] = {
            drawable = drawable,
            texture  = drawable >= 0 and GetPedPropTextureIndex(ped, slot.id) or 0,
        }
    end

    return { model = GetEntityModel(ped), components = components, props = props }
end

---@param ped number
---@param appearance table
local function applyPedAppearance(ped, appearance)
    if not appearance then return end

    for componentIdStr, comp in pairs(appearance.components or {}) do
        local componentId = tonumber(componentIdStr)
        if componentId and comp and comp.drawable ~= nil then
            SetPedComponentVariation(ped, componentId, comp.drawable, comp.texture or 0, 0)
        end
    end

    for propIdStr, prop in pairs(appearance.props or {}) do
        local propId = tonumber(propIdStr)
        if propId and prop and prop.drawable ~= nil then
            if prop.drawable >= 0 then
                SetPedPropIndex(ped, propId, prop.drawable, prop.texture or 0, true)
            else
                ClearPedProp(ped, propId)
            end
        end
    end
end

local dutyOriginalSnapshot = nil
local dutyHasCached        = false

local function cacheDutyOriginalIfNeeded()
    if dutyHasCached then return end
    dutyOriginalSnapshot = snapshotPedAppearance(PlayerPedId())
    dutyHasCached        = true
end

Rpc:Register('ped:applySavedDutySkin', function(data)
    if not data or not data.mode then return { success = false } end

    cacheDutyOriginalIfNeeded()

    if data.mode == 'clothes' and data.appearance then
        if data.appearance.model then applyModel(data.appearance.model) end
        applyPedAppearance(PlayerPedId(), data.appearance)
    elseif data.mode == 'model' and data.model then
        applyModel(data.model)
    end

    return { success = true }
end)

Rpc:Register('ped:restoreOriginalPed', function(data)
    if not dutyHasCached then return { success = true } end

    if dutyOriginalSnapshot then
        applyModel(dutyOriginalSnapshot.model)
        applyPedAppearance(PlayerPedId(), dutyOriginalSnapshot)
    end

    dutyHasCached        = false
    dutyOriginalSnapshot = nil

    return { success = true }
end)

local CAM_DIR <const>             = (function()
    local dx, dy = 1.4, 2.4
    local len = math.sqrt(dx * dx + dy * dy)
    return vector2(dx / len, dy / len)
end)()

local STUDIO_FOV <const>          = 35.0
local STUDIO_FRAME_MARGIN <const> = 1.0

local studioPed                   = nil
local studioCam                   = nil
local studioHeading               = 0.0
local studioAnchor                = nil ---@type vector3?

local function destroyStudioPed()
    if studioPed and DoesEntityExist(studioPed) then
        DeleteEntity(studioPed)
    end
    studioPed = nil
end

---@return vector3
local function ensureStudioAnchor()
    if not studioAnchor then
        local loc = Config.DutyPed.studioLocation
        studioAnchor = vector3(loc.x, loc.y, loc.z)
    end
    return studioAnchor
end

local function clearStudioFocus()
    ClearFocus()
end

local function ensureStudioCam()
    if studioCam then return end

    studioCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamFov(studioCam, STUDIO_FOV)
    SetCamActive(studioCam, true)
end

---@param model string
local function frameStudioCam(model)
    if not studioCam then return end

    local anchor       = ensureStudioAnchor()
    local minV, maxV   = GetModelDimensions(model)
    local height       = maxV.z - minV.z
    local centerZ      = (minV.z + maxV.z) / 2.0

    local framedHeight = height * STUDIO_FRAME_MARGIN
    local distance     = (framedHeight / 2.0) / math.tan(math.rad(STUDIO_FOV) / 2.0)

    SetCamCoord(
        studioCam,
        anchor.x + CAM_DIR.x * distance,
        anchor.y + CAM_DIR.y * distance,
        anchor.z + centerZ
    )

    if studioPed then
        PointCamAtEntity(studioCam, studioPed, 0.0, 0.0, centerZ, true)
    end
end

local studioSpawnGen = 0

---@param model string
---@return boolean
local function spawnStudioPed(model)
    studioSpawnGen = studioSpawnGen + 1
    local gen = studioSpawnGen

    destroyStudioPed()

    local anchor = ensureStudioAnchor()
    SetFocusPosAndVel(anchor.x, anchor.y, anchor.z, 0.0, 0.0, 0.0)
    RequestCollisionAtCoord(anchor.x, anchor.y, anchor.z)

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(model) then return false end
    if gen ~= studioSpawnGen then return false end

    local facingHeading = GetHeadingFromVector_2d(CAM_DIR.x, CAM_DIR.y)
    studioPed = CreatePed(4, model, anchor.x, anchor.y, anchor.z, facingHeading, false, true)
    SetModelAsNoLongerNeeded(model)

    if not DoesEntityExist(studioPed) then return false end

    if model == 'mp_m_freemode_01' or model == 'mp_f_freemode_01' then
        SetPedDefaultComponentVariation(studioPed)
        SetPedHeadBlendData(studioPed, 1, 1, 1, 1, 1, 1, 1, 1, 1, false)
    end

    FreezeEntityPosition(studioPed, true)
    SetEntityInvincible(studioPed, true)
    SetBlockingOfNonTemporaryEvents(studioPed, true)
    studioHeading = facingHeading

    local ped = studioPed
    local collisionTimeout = GetGameTimer() + 2000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < collisionTimeout do
        RequestCollisionAtCoord(anchor.x, anchor.y, anchor.z)
        Wait(50)
    end

    if gen ~= studioSpawnGen then return false end

    local found, groundZ = GetGroundZFor_3dCoord(anchor.x, anchor.y, anchor.z + 1.0, false)
    if found then
        local minV = GetModelDimensions(model)
        local feetZ = groundZ - minV.z
        SetEntityCoordsNoOffset(ped, anchor.x, anchor.y, feetZ, false, false, false)
        studioAnchor = vector3(anchor.x, anchor.y, feetZ)
    end

    return true
end

local function beginStudioView()
    if not studioCam or not studioPed then return end

    DisplayHud(false)
    DisplayRadar(false)
    RenderScriptCams(true, false, 0, true, false)
    SetEntityVisible(PlayerPedId(), false, 0)
end

local function endStudioView()
    RenderScriptCams(false, false, 0, true, false)
    DisplayHud(true)
    DisplayRadar(true)
    SetEntityVisible(PlayerPedId(), true, 0)
end

---@param ped number
---@return table
local function buildComponentState(ped)
    local state = {}
    for _, slot in ipairs(Config.DutyPed.clothesComponents) do
        local drawable = GetPedDrawableVariation(ped, slot.id)
        state[tostring(slot.id)] = {
            drawable     = drawable,
            texture      = GetPedTextureVariation(ped, slot.id),
            maxDrawables = GetNumberOfPedDrawableVariations(ped, slot.id),
            maxTextures  = GetNumberOfPedTextureVariations(ped, slot.id, drawable),
        }
    end
    return state
end

---@param ped number
---@return table
local function buildPropState(ped)
    local state = {}
    for _, slot in ipairs(Config.DutyPed.clothesProps) do
        local drawable = GetPedPropIndex(ped, slot.id)
        state[tostring(slot.id)] = {
            drawable     = drawable,
            texture      = drawable >= 0 and GetPedPropTextureIndex(ped, slot.id) or 0,
            maxDrawables = GetNumberOfPedPropDrawableVariations(ped, slot.id),
            maxTextures  = drawable >= 0 and GetNumberOfPedPropTextureVariations(ped, slot.id, drawable) or 1,
        }
    end
    return state
end

Rpc:Register('ped:openPedStudio', function(data)
    local model = data and data.model
    if not model then return { success = false, message = 'Missing model.' } end

    if not spawnStudioPed(model) then
        return { success = false, message = 'Failed to spawn the preview ped.' }
    end

    ensureStudioCam()
    frameStudioCam(model)
    beginStudioView()

    return { success = true }
end)

Rpc:Register('ped:setStudioModel', function(data)
    local model = data and data.model
    if not model then return { success = false, message = 'Missing model.' } end
    if not studioCam then return { success = false, message = 'Studio is not open.' } end

    if not spawnStudioPed(model) then
        return { success = false, message = 'Failed to spawn the preview ped.' }
    end

    frameStudioCam(model)

    return { success = true }
end)

Rpc:Register('ped:openClothesStudio', function(data)
    local model = data and data.model
    if not model then return { success = false, message = 'Missing model.' } end

    if not spawnStudioPed(model) then
        return { success = false, message = 'Failed to spawn the preview ped.' }
    end

    for _, slot in ipairs(Config.DutyPed.clothesComponents) do
        local saved = data.components and data.components[tostring(slot.id)]
        if saved and saved.drawable ~= nil then
            SetPedComponentVariation(studioPed, slot.id, saved.drawable, saved.texture or 0, 0)
        end
    end

    for _, slot in ipairs(Config.DutyPed.clothesProps) do
        local saved = data.props and data.props[tostring(slot.id)]
        if saved and saved.drawable ~= nil and saved.drawable >= 0 then
            SetPedPropIndex(studioPed, slot.id, saved.drawable, saved.texture or 0, true)
        end
    end


    ensureStudioCam()
    frameStudioCam(model)
    beginStudioView()

    return {
        success    = true,
        components = buildComponentState(studioPed),
        props      = buildPropState(studioPed),
    }
end)

Rpc:Register('ped:setClothesBaseModel', function(data)
    local model = data and data.model
    if not model then return { success = false, message = 'Missing model.' } end
    if not studioCam then return { success = false, message = 'Studio is not open.' } end

    if not spawnStudioPed(model) then
        return { success = false, message = 'Failed to spawn the preview ped.' }
    end

    frameStudioCam(model)

    return {
        success    = true,
        components = buildComponentState(studioPed),
        props      = buildPropState(studioPed),
    }
end)

Rpc:Register('ped:cycleClothesComponent', function(data)
    if not studioPed or not DoesEntityExist(studioPed) then
        return { success = false, message = 'Studio is not open.' }
    end

    local componentId = tonumber(data and data.componentId)
    local field       = data and data.field
    local direction   = tonumber(data and data.direction) or 1

    if not componentId or (field ~= 'drawable' and field ~= 'texture') then
        return { success = false, message = 'Invalid component cycle request.' }
    end

    local drawable = GetPedDrawableVariation(studioPed, componentId)
    local texture  = GetPedTextureVariation(studioPed, componentId)

    if field == 'drawable' then
        local maxD = GetNumberOfPedDrawableVariations(studioPed, componentId)
        if maxD <= 0 then return { success = false, message = 'No variations available.' } end
        drawable = (drawable + direction) % maxD
        texture  = 0
    else
        local maxT = GetNumberOfPedTextureVariations(studioPed, componentId, drawable)
        if maxT <= 0 then return { success = false, message = 'No variations available.' } end
        texture = (texture + direction) % maxT
    end

    SetPedComponentVariation(studioPed, componentId, drawable, texture, 0)

    return {
        success      = true,
        drawable     = drawable,
        texture      = texture,
        maxDrawables = GetNumberOfPedDrawableVariations(studioPed, componentId),
        maxTextures  = GetNumberOfPedTextureVariations(studioPed, componentId, drawable),
    }
end)

Rpc:Register('ped:cycleClothesProp', function(data)
    if not studioPed or not DoesEntityExist(studioPed) then
        return { success = false, message = 'Studio is not open.' }
    end

    local propId    = tonumber(data and data.propId)
    local direction = tonumber(data and data.direction) or 1

    if not propId then return { success = false, message = 'Invalid prop cycle request.' } end

    local maxD        = GetNumberOfPedPropDrawableVariations(studioPed, propId)
    local current     = GetPedPropIndex(studioPed, propId)

    local total       = maxD + 1
    local idx         = ((current + 1 + direction) % total + total) % total
    local newDrawable = idx - 1

    if newDrawable < 0 then
        ClearPedProp(studioPed, propId)
    else
        SetPedPropIndex(studioPed, propId, newDrawable, 0, true)
    end

    local finalDrawable = GetPedPropIndex(studioPed, propId)
    local finalTexture  = finalDrawable >= 0 and GetPedPropTextureIndex(studioPed, propId) or 0

    return {
        success      = true,
        drawable     = finalDrawable,
        texture      = finalTexture,
        maxDrawables = maxD,
        maxTextures  = finalDrawable >= 0
            and GetNumberOfPedPropTextureVariations(studioPed, propId, finalDrawable)
            or 1,
    }
end)

Rpc:Register('ped:rotateStudioPed', function(data)
    if not studioPed or not DoesEntityExist(studioPed) then
        return { success = false, message = 'Studio is not open.' }
    end

    local delta = tonumber(data and data.delta) or 45.0
    studioHeading = (studioHeading + delta) % 360.0
    SetEntityHeading(studioPed, studioHeading)

    return { success = true }
end)

Rpc:Register('ped:closePedStudio', function(data)
    destroyStudioPed()

    if studioCam then
        SetCamActive(studioCam, false)
        DestroyCam(studioCam, true)
        studioCam = nil
    end

    studioAnchor = nil
    clearStudioFocus()

    endStudioView()

    return { success = true }
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    destroyStudioPed()
    clearStudioFocus()
end)
