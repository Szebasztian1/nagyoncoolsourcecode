GameplayCamera = {}

function GameplayCamera:getPosition()
    return GetGameplayCamCoord()
end

function GameplayCamera:getRotation()
    return GetGameplayCamRot(2)
end

function GameplayCamera:getRelativePitch()
    return GetGameplayCamRelativePitch()
end

function GameplayCamera:getRelativeHeading()
    return GetGameplayCamRelativeHeading()
end

function GameplayCamera:getDirection()
    local rotation = self:getRotation()

    local adjustedRotation = vector3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )

    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )

    return direction
end

function GameplayCamera:getForwardVector()
    local rotation = self:getRotation()

    local pitch = math.rad(rotation.x)
    local yaw = math.rad(rotation.z)

    local x = -math.sin(yaw) * math.cos(pitch)
    local y = math.cos(yaw) * math.cos(pitch)
    local z = math.sin(pitch)

    return vector3(x, y, z)
end

return GameplayCamera
