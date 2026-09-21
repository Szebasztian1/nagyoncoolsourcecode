local FillProp = require("lua.client.Fill")

---@class C_Compost : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _entity number
---@field count number
---@field _fill C_Fill
local Compost = lib.class("C_Compost")

function Compost:constructor(id, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation
    self.count = 0

    self._entity = CreateObject(
        "avp_animal_farm_prop_composter_02",
        position.x,
        position.y,
        position.z,
        false,
        false,
        false
    )

    FreezeEntityPosition(self._entity, true)
    SetEntityRotation(self._entity, rotation.x, rotation.y, rotation.z, 2, false)

    self._fill = FillProp:new(
        CreateObject(
            "avp_animal_farm_prop_composter_fill",
            0,
            0,
            0,
            false,
            false,
            false
        ),
        self._entity,
        -0.65,
        0.0
    )
end

function Compost:getInteractionPosition()
    return GetOffsetFromEntityInWorldCoords(
        self._entity,
        0.0,
        1.0,
        0.05
    )
end

function Compost:setPercentage(percentage)
    self.count = percentage

    self._fill:update(percentage)
end

function Compost:getPercentage()
    return math.min(100, self.count)
end

function Compost:destroy()
    DeleteObject(self._entity)
end

return Compost
