local FillProp = require("lua.client.Fill")
local eWarehouseUnit = require("lua.shared.enums.eWarehouseUnit")

---@param content eWarehouseUnit
local function getPropByContent(content)
    if content == eWarehouseUnit.CHICKEN_FEED then

    elseif content == eWarehouseUnit.PIG_FEED then
        return "avp_animal_farm_prop_food_trough_pig"
    elseif content == eWarehouseUnit.COW_FEED then
        return "avp_animal_farm_prop_food_trough_cow"
    elseif content == eWarehouseUnit.UNIVERSAL_FEED then
        return "avp_animal_farm_prop_food_trough_universal"
    elseif content == eWarehouseUnit.GRAIN_MIX_FEED then
        return "avp_animal_farm_prop_food_trough_grainmix"
    elseif content == eWarehouseUnit.PROTEIN_FEED then
        return "avp_animal_farm_prop_food_trough_protein"
    end

    return "avp_animal_farm_prop_food_trough_protein"
end

---@class C_FoodTrough : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _percentage number
---@field private _content string
---@field private _entity number
---@field private _fill C_Fill
---@field private _target number
local FoodTrough = lib.class("C_FoodTrough")

function FoodTrough:constructor(id, position, rotation)
    self.id          = id
    self.position    = position
    self.rotation    = rotation
    self._percentage = 0

    self._entity     = CreateObject(
        "avp_animal_farm_prop_food_trough",
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
            "avp_animal_farm_prop_food_trough_pig",
            0,
            0,
            0,
            false,
            false,
            false
        ),
        self._entity,
        -0.25,
        0.0
    )

    self._target = exports["ox_target"]:addSphereZone(
        {
            coords = position + vector3(0, 0, 0.25),
            radius = 0.5,
            drawSprite = true,
            options = {
                {
                    label = locale("OX_FOOD_TROUGH_EMPTY", self.id),
                    icon = "fas fa-hand",
                    distance = 2.0,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::FoodTrough::Clear", self.id)
                    end
                }
            }
        }
    )
end

function FoodTrough:getInteractPosition()
    return GetOffsetFromEntityInWorldCoords(
        self._entity,
        -1.0,
        0.0,
        0.05
    )
end

function FoodTrough:getContent()
    return self._content
end

function FoodTrough:setContent(id)
    self._content = id

    local modelName = getPropByContent(self._content)
    local modelHash = GetHashKey(modelName)

    if GetEntityModel(self._fill:getEntity()) ~= modelHash then
        self._fill:changeEntity(
            CreateObject(
                modelHash,
                0,
                0,
                0,
                false,
                false,
                false
            )
        )
    end
end

function FoodTrough:getPercentage()
    return self._percentage
end

function FoodTrough:setPercentage(percentage)
    self._percentage = percentage

    self._fill:update(percentage)
end

function FoodTrough:destroy()
    DeleteObject(self._entity)

    self._fill:destroy()

    exports["ox_target"]:removeZone(self._target)
end

return FoodTrough
