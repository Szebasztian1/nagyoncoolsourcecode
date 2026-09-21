function DrawSpriteMeter(dictionary, textureName, x, y, width, height, percentage, color)
    percentage = math.clamp(percentage, 0.0, 1.0)

    local aspectRatio = GetAspectRatio(true)
    local clippedHeight = height * percentage
    local adjustedWidth = width * (1 / aspectRatio)

    local centerY = y - clippedHeight / 2 + height / 2

    local r, g, b, a = table.unpack(color)

    RequestStreamedTextureDict(dictionary, false)

    DrawSprite(
        dictionary,
        textureName,
        x,
        y,
        adjustedWidth,
        height,
        0.0,
        20,
        20,
        20,
        125
    )

    DrawSpriteUv(
        dictionary,
        textureName,
        x,
        centerY,
        adjustedWidth,
        clippedHeight,
        0.0,
        1.0 - percentage,
        1.0,
        1.0,
        0.0,
        r,
        g,
        b,
        a
    )
end
