---@param position vector3
---@param rotation vector3
---@param offset vector3
---@return vector3
local function GetOffsetFromCoord(position, rotation, offset)
    local rX = math.rad(rotation.x)
    local rY = math.rad(rotation.y)
    local rZ = math.rad(rotation.z)

    local cosRx = math.cos(rX)
    local cosRy = math.cos(rY)
    local cosRz = math.cos(rZ)
    local sinRx = math.sin(rX)
    local sinRy = math.sin(rY)
    local sinRz = math.sin(rZ)

    local m11 = (cosRz * cosRy) - (sinRz * sinRx * sinRy)
    local m12 = (cosRy * sinRz) + (cosRz * sinRx * sinRy)
    local m13 = -cosRx * sinRy

    local m21 = -cosRx * sinRz
    local m22 = cosRz * cosRx
    local m23 = sinRx

    local m31 = (cosRz * sinRy) + (cosRy * sinRz * sinRx)
    local m32 = (sinRz * sinRy) - (cosRz * cosRy * sinRx)
    local m33 = cosRx * cosRy

    return vector3(
        offset.x * m11 + offset.y * m21 + offset.z * m31 + position.x,
        offset.x * m12 + offset.y * m22 + offset.z * m32 + position.y,
        offset.x * m13 + offset.y * m23 + offset.z * m33 + position.z
    )
end

return GetOffsetFromCoord
