Graphics = {}

---@param position vector2
---@param text string
---@param scale number
---@param center boolean
---@param color? [number, number, number, number]
function Graphics:drawTextThisFrame2D(position, text, scale, center, color)
    color = color and color or { 255, 255, 255, 255 }

    local r, g, b, a = table.unpack(color)

    SetTextScale(0.0, scale)
    SetTextProportional(true)
    SetTextColour(r, g, b, a)
    SetTextCentre(center)

    SetTextOutline()
    SetTextDropShadow()

    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(position.x, position.y)
end

---@param position vector3
---@param text string
---@param scale number
---@param center boolean
---@param color? [number, number, number, number]
function Graphics:drawTextThisFrame3D(position, text, scale, center, color)
    color = color and color or { 255, 255, 255, 255 }

    local r, g, b, a = table.unpack(color)

    SetTextScale(0.0, scale)
    SetTextProportional(true)
    SetTextColour(r, g, b, a)
    SetTextCentre(center)

    SetTextOutline()
    SetTextDropShadow()

    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(position.x, position.y, position.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

---@param type number
---@param position vector3
---@param scale? vector3
---@param color? [number, number, number, number]
---@param rotation? vector3
---@param direction? vector3
---@param bobUpAndDown? boolean
---@param faceCamera? boolean
---@param rotate? boolean
function Graphics:drawMarker(type, position, scale, color, rotation, direction, bobUpAndDown, faceCamera, rotate)
    scale = scale or vector3(1.0, 1.0, 1.0)
    color = color or { 255, 255, 255, 255 }
    rotation = rotation or vector3(0, 0, 0)
    direction = direction or vector(0, 0, 0)
    bobUpAndDown = bobUpAndDown or false
    faceCamera = faceCamera or false
    rotate = rotate or false

    local r, g, b, a = table.unpack(color)

    DrawMarker(
        type,
        position.x,
        position.y,
        position.z,
        direction.x,
        direction.y,
        direction.z,
        rotation.x,
        rotation.y,
        rotation.z,
        scale.x,
        scale.y,
        scale.z,
        r,
        g,
        b,
        a,
        bobUpAndDown,
        faceCamera,
        2,
        rotate,
        nil,
        nil,
        false
    )
end

---@param textureDict string
---@param textureName string
---@param position vector3
---@param scale number
---@param color [number, number, number, number]
---@param heading? number
function Graphics:drawSprite3D(textureDict, textureName, position, scale, color, heading)
    local result, screenX, screenY = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)

    if not result then return end

    local camPos = GetFinalRenderedCamCoord()

    local distance = #(camPos - position)

    scale = (scale / distance) * 5;
    scale = math.min(math.max(scale, 0.15), 3.5);

    self:drawSprite2D(textureDict, textureName, vector2(screenX, screenY), scale, color, heading)
end

---@param textureDict string
---@param textureName string
---@param position vector2
---@param scale number
---@param color [number, number, number, number]
---@param heading? number
function Graphics:drawSprite2D(textureDict, textureName, position, scale, color, heading)
    heading = heading and heading or 0

    local textureResolution = GetTextureResolution(textureDict, textureName)
    local screenX, screenY = GetScreenActiveResolution()
    local baseSize = 32

    local scaleWidth = (baseSize / textureResolution.x) * scale
    local scaleHeight = (baseSize / textureResolution.y) * scale

    local screenScaleWidth = scaleWidth * (textureResolution.x / screenX)
    local screenScaleHeight = scaleHeight * (textureResolution.y / screenY)

    if HasStreamedTextureDictLoaded(textureDict) then
        DrawSprite(
            textureDict,
            textureName,
            position.x,
            position.y,
            screenScaleWidth,
            screenScaleHeight,
            heading,
            color[1],
            color[2],
            color[3],
            color[4]
        )
    else
        RequestStreamedTextureDict(textureDict, true)
    end
end

---@param position vector3
---@param percentage number
---@param width? number
---@param height? number
---@param border? number
---@param color? [number, number, number, number]
---@param bgColor? [number, number, number, number]
function Graphics:drawBar3D(position, percentage, width, height, border, color, bgColor)
    local result, screenX, screenY = GetScreenCoordFromWorldCoord(
        position.x,
        position.y,
        position.z
    )

    if result then
        self:drawBar2D(
            vector2(screenX, screenY),
            percentage,
            width,
            height,
            border,
            color,
            bgColor
        )
    end
end

---@param position vector2
---@param percentage number
---@param width? number
---@param height? number
---@param border? number
---@param color? [number,number,number,number]
---@param bgColor? [number, number, number, number]
function Graphics:drawBar2D(position, percentage, width, height, border, color, bgColor)
    width                    = width and width or 0.03
    height                   = height and height or 0.0065
    border                   = border and border or 0.001
    color                    = color and color or { 255, 255, 255, 255 }
    bgColor                  = bgColor and bgColor or { 50, 50, 50, 200 }
    percentage               = percentage or 0

    local aspectRatio        = GetScreenAspectRatio(false)

    local x, y               = table.unpack(position)
    local r, g, b, a         = table.unpack(color)
    local bgR, bgG, bgB, bgA = table.unpack(bgColor)

    width                    = width / aspectRatio

    -- Border
    DrawRect(x, y, width + border * 2, height + border * 2, bgR, bgG, bgB, bgA);

    -- Background
    DrawRect(x, y, width, height, 15, 15, 15, a);

    -- Content
    DrawRect(
        x - (width / 2) * (1 - percentage / 100),
        y,
        (width * percentage) / 100,
        height,
        r,
        g,
        b,
        a
    );
end

---@param position vector3
---@param scale number
---@param cb fun()
---@param sprite? [string, string, number, [number, number, number, number]]
---@param text? string
function Graphics:drawInteractive3D(position, scale, cb, sprite, text)
    local response, screenX, screenY = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)

    if response then
        self:drawInteractive2D(
            vector2(screenX, screenY),
            scale,
            cb,
            sprite,
            text
        )
    end
end

-- [dictionary, name, scale, color]

---@param position vector2
---@param scale number
---@param cb fun()
---@param sprite? [string, string, number, [number, number, number, number]]
---@param text? string
function Graphics:drawInteractive2D(position, scale, cb, sprite, text)
    local aspectRatio = GetScreenAspectRatio(false)
    local width = scale / aspectRatio
    local height = scale

    local cursorX, cursorY = GetNuiCursorPosition()
    local screenX, screenY = GetActiveScreenResolution()

    cursorX = cursorX / screenX
    cursorY = cursorY / screenY

    local isHovering =
        cursorX >= position.x - width / 2 and
        cursorX <= position.x + width / 2 and
        cursorY >= position.y - height / 2 and
        cursorY <= position.y + height / 2

    local drawColor = isHovering and { 50, 50, 50, 225 } or { 25, 25, 25, 225 }

    DrawRect(
        position.x,
        position.y,
        width,
        height,
        drawColor[1],
        drawColor[2],
        drawColor[3],
        drawColor[4]
    )

    if sprite then
        local textureDict, textureName, spriteScale, spriteColor = table.unpack(sprite)

        self:drawSprite2D(textureDict, textureName, position, spriteScale, spriteColor)
    end

    if isHovering then
        if text then
            self:drawTextThisFrame2D(
                position + vector2(0, -0.035),
                text,
                0.2,
                true
            )
        end

        if IsDisabledControlJustPressed(0, 24) then
            cb()
        end
    end
end

return Graphics
