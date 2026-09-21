---@class C_Storage : OxClass
---@field id eStorageUnit
---@field position vector3
---@field rotation vector3
---@field private _entity number
---@field private _isPickedUp boolean
---@field private _count number
local Storage = lib.class("C_Storage")

---@param id eStorageUnit
---@param modelHash string
---@param position vector3
---@param rotation vector3
function Storage:constructor(id, modelHash, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation
    self._isPickedUp = false
    self._count = 0

    self._entity = CreateObject(
        modelHash,
        position.x,
        position.y,
        position.z,
        false,
        false,
        false
    )

    SetEntityRotation(self._entity, rotation.x, rotation.y, rotation.z, 2, false)
    FreezeEntityPosition(self._entity, true)
end

function Storage:setIsPickedUp(newState)
    self._isPickedUp = newState

    SetEntityVisible(self._entity, not newState, false)
end

function Storage:getIsPickedUp()
    return self._isPickedUp
end

function Storage:getCount()
    return self._count
end

function Storage:setCount(count)
    self._count = count
end

function Storage:getPercentage()
    return math.min(100, self._count)
end

function Storage:destroy()
    DeleteObject(self._entity)
end

return Storage
