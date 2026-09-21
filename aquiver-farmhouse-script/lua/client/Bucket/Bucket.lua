local FillProp = require("lua.client.Fill")
local BucketProps = require("lua.shared.data.BucketProps")

---@class C_Bucket : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _isPickedUp boolean
---@field private _contentState IBucketContentState
---@field private _entity number
---@field private _fill C_Fill
---@field private _target number
local Bucket = lib.class("C_Bucket")

---@param id number
---@param position vector3
---@param rotation vector3
function Bucket:constructor(id, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation
    self._isPickedUp = false

    self._entity = CreateObject(
        "avp_animal_farm_prop_bucket_outhand",
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
            "avp_animal_farm_prop_bucket_fill_chicken",
            0.0,
            0.0,
            0.0,
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
            coords = position,
            radius = 0.35,
            drawSprite = true,
            options = {
                {
                    label = locale("OX_BUCKET_PUT", self.id),
                    icon = "fas fa-hand",
                    distance = 2.5,
                    canInteract = function()
                        return self:getIsPickedUp()
                    end,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::Bucket::Interact", self.id)
                    end
                },
                {
                    label = locale("OX_BUCKET_TAKE", self.id),
                    icon = "fas fa-hand",
                    distance = 2.5,
                    canInteract = function()
                        return not self:getIsPickedUp()
                    end,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::Bucket::Interact", self.id)
                    end
                }
            }
        }
    )
end

function Bucket:setIsPickedUp(newState)
    self._isPickedUp = newState

    SetEntityAlpha(self._entity, newState and 55 or 255, false)
    SetEntityAlpha(self._fill:getEntity(), newState and 55 or 255, false)
end

function Bucket:getIsPickedUp()
    return self._isPickedUp
end

---@param contentState IBucketContentState
function Bucket:setContentState(contentState)
    self._contentState = contentState

    local modelHash = BucketProps[contentState.id]
    if modelHash and #modelHash > 0 and GetEntityModel(self._fill:getEntity()) ~= modelHash then
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

    self._fill:setVisible(modelHash and #modelHash > 0)

    self._fill:update(contentState.count * 10)
end

function Bucket:getContentState()
    return self._contentState
end

function Bucket:destroy()
    DeleteObject(self._entity)

    exports["ox_target"]:removeZone(self._target)
end

return Bucket
