local FillProp = require("lua.client.Fill")

---@class C_WaterTrough : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _percentage number
---@field private _entity number
---@field private _fill C_Fill
local WaterTrough = lib.class("C_WaterTrough")

function WaterTrough:constructor(id, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation
    self._percentage = 0

    self._entity = CreateObject(
        "avp_animal_farm_prop_water_trough",
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
            "avp_animal_farm_prop_water_trough_fill",
            0,
            0,
            0,
            false,
            false,
            false
        ),
        self._entity,
        -0.08469,
        0.27
    )
end

function WaterTrough:getInteractPosition()
    return GetOffsetFromEntityInWorldCoords(
        self._entity,
        0.75,
        0,
        0.05
    )
end

function WaterTrough:getPercentage()
    return self._percentage
end

function WaterTrough:setPercentage(percentage)
    self._percentage = percentage

    self._fill:update(percentage)
end

function WaterTrough:destroy()
    DeleteObject(self._entity)
end

return WaterTrough
