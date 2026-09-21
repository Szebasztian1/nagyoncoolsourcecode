local FillProp = require("lua.client.Fill")
local eWarehouseUnit = require("lua.shared.enums.eWarehouseUnit")

local Props = {
    [eWarehouseUnit.CHICKEN_FEED] = "avp_animal_farm_prop_chicken_feed",
    [eWarehouseUnit.COW_FEED] = "avp_animal_farm_prop_cow_feed",
    [eWarehouseUnit.GRAIN_MIX_FEED] = "avp_animal_farm_prop_grainmix_feed",
    [eWarehouseUnit.PIG_FEED] = "avp_animal_farm_prop_grainmix_feed",
    [eWarehouseUnit.PROTEIN_FEED] = "avp_animal_farm_prop_protein_feed",
    [eWarehouseUnit.UNIVERSAL_FEED] = "avp_animal_farm_prop_universal_feed"
}

---@class C_Warehouse : OxClass
---@field id eWarehouseUnit
---@field position vector3
---@field rotation vector3
---@field private _entity number
---@field private _count number
---@field private _fill C_Fill
---@field private _target number
local Warehouse = lib.class("C_Warehouse")

---@param id eWarehouseUnit
---@param modelHash string
---@param position vector3
---@param rotation vector3
function Warehouse:constructor(id, modelHash, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation

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

    FreezeEntityPosition(self._entity, true)
    SetEntityRotation(self._entity, rotation.x, rotation.y, rotation.z, 2, false)

    self._fill = FillProp:new(
        CreateObject(
            Props[id],
            0,
            0,
            0,
            false,
            false,
            false
        ),
        self._entity,
        0.0,
        0.62
    )

    self._target = exports["ox_target"]:addSphereZone(
        {
            coords = position + vector3(0, 0, 0.5),
            radius = 0.5,
            drawSprite = true,
            options = {
                {
                    label = locale(self.id),
                    icon = "fas fa-hand",
                    distance = 2.5,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::Warehouse::Interact", self.id)

                        PlaySoundFromCoord(
                            GetSoundId(),
                            "pickup_food",
                            position.x,
                            position.y,
                            position.z,
                            "aquiver_farmhouse_sounds",
                            true,
                            15.0,
                            false
                        )
                    end
                }
            }
        }
    )
end

function Warehouse:getCount()
    return self._count
end

function Warehouse:setCount(count)
    self._count = math.max(0, count)

    self._fill:update(self._count)
end

function Warehouse:getPercentage()
    return math.min(100, self._count)
end

function Warehouse:destroy()
    DeleteObject(self._entity)

    self._fill:destroy()

    exports["ox_target"]:removeZone(self._target)
end

return Warehouse
