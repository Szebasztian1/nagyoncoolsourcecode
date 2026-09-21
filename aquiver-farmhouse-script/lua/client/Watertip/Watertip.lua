---@class C_Watertip : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _isActive boolean
---@field private _isOccupied boolean
---@field private _waterPercentage number
---@field private _entity number
---@field private _bucketEntity number
---@field private _ptfx number
---@field private _target number
local Watertip = lib.class("C_Watertip")

function Watertip:constructor(id, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation
    self._isActive = false
    self._isOccupied = false
    self._waterPercentage = 0
    self._ptfx = -1

    self._entity = CreateObject(
        "prop_ld_faucet",
        position.x,
        position.y,
        position.z,
        false,
        false,
        false
    )
    FreezeEntityPosition(self._entity, true)
    SetEntityRotation(self._entity, rotation.x, rotation.y, rotation.z, 2, false)

    self._bucketEntity = CreateObject(
        "avp_animal_farm_prop_bucket_outhand",
        0,
        0,
        0,
        false,
        false,
        false
    )
    AttachEntityToEntity(
        self._bucketEntity,
        self._entity,
        0,
        0,
        -0.2,
        0,
        0,
        0,
        0,
        false,
        false,
        false,
        false,
        2,
        true
    )
    SetEntityAlpha(self._bucketEntity, 50, false)

    self._target = exports["ox_target"]:addSphereZone(
        {
            coords = position,
            radius = 0.35,
            drawSprite = true,
            options = {
                {
                    label = locale("OX_WATERTIP_BUCKET_PUT"),
                    icon = "fas fa-hand",
                    distance = 2.5,
                    canInteract = function()
                        return not self:getOccupied()
                    end,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::Watertip::Interact", self.id)
                    end
                },
                {
                    label = locale("OX_WATERTIP_BUCKET_TAKE"),
                    icon = "fas fa-hand",
                    distance = 2.5,
                    canInteract = function()
                        return self:getOccupied()
                    end,
                    onSelect = function()
                        TriggerServerEvent("Farmhouse::Watertip::Interact", self.id)
                    end
                }
            }
        }
    )
end

function Watertip:setOccupied(newState)
    self._isOccupied = newState

    SetEntityAlpha(self._bucketEntity, newState and 255 or 55, false)

    if newState then
        self:createPtfx()
    else
        self:removePtfx()
    end
end

function Watertip:getOccupied()
    return self._isOccupied
end

function Watertip:getWaterPercentage()
    return self._waterPercentage
end

function Watertip:setWaterPercentage(percentage)
    self._waterPercentage = percentage
end

function Watertip:setIsActive(newState)
    self._isActive = newState
end

function Watertip:getIsActive()
    return self._isActive
end

function Watertip:createPtfx()
    if self._ptfx ~= -1 then return end

    lib.requestNamedPtfxAsset("scr_carwash")

    UseParticleFxAssetNextCall("scr_carwash")

    self._ptfx = StartParticleFxLoopedOnEntity(
        'ent_amb_car_wash_jet',
        self._entity,
        0.0,
        -0.135,
        0.7,
        180.0,
        0.0,
        0.0,
        0.5,
        false,
        false,
        false
    )
end

function Watertip:removePtfx()
    if self._ptfx == -1 then return end

    StopParticleFxLooped(self._ptfx, false)

    self._ptfx = -1
end

function Watertip:destroy()
    DeleteObject(self._entity)

    exports["ox_target"]:removeZone(self._target)
end

return Watertip
