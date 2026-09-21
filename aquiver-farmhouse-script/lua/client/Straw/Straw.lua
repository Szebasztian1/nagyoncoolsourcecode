---@class C_Straw : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _entity number
local Straw = lib.class("C_Straw")

---@param id number
---@param position vector3
---@param rotation vector3
function Straw:constructor(id, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation

    self._entity = CreateObject(
        "avp_animal_farm_prop_straw",
        position.x,
        position.y,
        position.z,
        false,
        false,
        false
    )
    FreezeEntityPosition(self._entity, true)
    SetEntityRotation(self._entity, rotation.x, rotation.y, rotation.z, 2, false)
end

function Straw:getInteractionPosition()
    return GetOffsetFromEntityInWorldCoords(
        self._entity,
        0.0,
        -1.35,
        -0.3
    )
end

function Straw:destroy()
    DeleteObject(self._entity)
end

return Straw
