local ePitchforkContent = require("lua.shared.enums.ePitchforkContent")

---@class C_Pitchfork : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _entity number
---@field private _isPickedUp boolean
---@field private _attachedProp number
---@field private _contentState IPitchforkContentState
---@field private _target number
local Pitchfork = lib.class("C_Pitchfork")

---@type table<ePitchforkContent, string>
local Contents = {
    [ePitchforkContent.Empty] = "",
    [ePitchforkContent.DirtyStraw] = "avp_animal_farm_prop_garden_fork_straw_dirty",
    [ePitchforkContent.Straw] = "avp_animal_farm_prop_garden_fork_straw"
}

---@param id number
---@param position vector3
---@param rotation vector3
function Pitchfork:constructor(id, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation

    self._isPickedUp = false
    self._contentState = {
        id = ePitchforkContent.Empty,
        count = 0
    }

    self._entity = CreateObject(
        "avp_animal_farm_prop_garden_fork",
        position.x,
        position.y,
        position.z,
        false,
        false,
        false
    )

    FreezeEntityPosition(self._entity, true)
    SetEntityRotation(self._entity, rotation.x, rotation.y, rotation.z, 2, false)

    self:refreshChildProp()

    self._target = exports["ox_target"]:addSphereZone(
        {
            coords = position,
            radius = 0.35,
            drawSprite = true,
            options = {
                {
                    label = locale("OX_PITCHFORK_PUT", self.id),
                    icon = "fas fa-hand",
                    distance = 2.5,
                    canInteract = function()
                        return self:getIsPickedUp()
                    end,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::Pitchfork::Interact", self.id)
                    end
                },
                {
                    label = locale("OX_PITCHFORK_TAKE", self.id),
                    icon = "fas fa-hand",
                    distance = 2.5,
                    canInteract = function()
                        return not self:getIsPickedUp()
                    end,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::Pitchfork::Interact", self.id)
                    end
                }
            }
        }
    )
end

function Pitchfork:setIsPickedUp(state)
    self._isPickedUp = state

    SetEntityAlpha(self._entity, state and 50 or 255, false)
    SetEntityAlpha(self._attachedProp, state and 50 or 255, false)
end

function Pitchfork:getIsPickedUp()
    return self._isPickedUp
end

---@param contentState IPitchforkContentState
function Pitchfork:setContentState(contentState)
    self._contentState = contentState

    SetEntityVisible(self._attachedProp, contentState.count > 0, contentState.count > 0)

    self:refreshChildProp()
end

function Pitchfork:getContentState()
    return self._contentState
end

---@private
function Pitchfork:refreshChildProp()
    local modelName = Contents[self._contentState.id]
    local modelHash = GetHashKey(modelName)

    if IsModelValid(modelHash) and GetEntityModel(self._attachedProp) ~= modelHash then
        if DoesEntityExist(self._attachedProp) then
            DeleteObject(self._attachedProp)
        end

        self._attachedProp = CreateObject(
            modelHash,
            0,
            0,
            0,
            false,
            false,
            false
        )

        AttachEntityToEntity(
            self._attachedProp,
            self._entity,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            false,
            false,
            false,
            false,
            2,
            true
        )
    end
end

function Pitchfork:destroy()
    DeleteObject(self._entity)
    DeleteObject(self._attachedProp)

    exports["ox_target"]:removeZone(self._target)
end

return Pitchfork
