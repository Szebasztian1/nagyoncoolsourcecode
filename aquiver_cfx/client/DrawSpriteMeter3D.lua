function DrawSpriteMeter3D(dictionary, textureName, x, y, z, width, height, percentage, color)
    local found, screenX, screenY = GetScreenCoordFromWorldCoord(
        x, y, z
    )

    if found then
        DrawSpriteMeter(dictionary, textureName, screenX, screenY, width, height, percentage, color)
    end
end
