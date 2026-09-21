---@class C_Tile : OxClass
---@field id number
---@field position vector3
---@field rotation vector3
---@field private _dirtiness number
---@field private _strawState boolean
---@field private _entity number
---@field private _strawEntityFx number
---@field private _dirtyEntityFx number
---@field private _ptfx number
local Tile = lib.class("C_Tile")

---@param id number
---@param position vector3
---@param rotation vector3
function Tile:constructor(id, position, rotation)
    self.id = id
    self.position = position
    self.rotation = rotation

    self._dirtiness = 0
    self._strawState = false

    self._entity = CreateObject(
        "avp_animal_farm_ground_01",
        position.x,
        position.y,
        position.z,
        false,
        false,
        false
    )
    FreezeEntityPosition(self._entity, true)

    self._strawEntityFx = CreateObject(
        "avp_animal_farm_ground_02",
        0,
        0,
        0,
        false,
        false,
        false
    )
    SetEntityVisible(self._strawEntityFx, false, false)
    AttachEntityToEntity(
        self._strawEntityFx,
        self._entity,
        -1,
        0.0,
        0.0,
        0.001,
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

    self._dirtyEntityFx = CreateObject(
        "avp_animal_farm_ground_03",
        0,
        0,
        0,
        false,
        false,
        false
    )
    SetEntityAlpha(self._dirtyEntityFx, 0, false)
    AttachEntityToEntity(
        self._dirtyEntityFx,
        self._entity,
        -1,
        0.0,
        0.0,
        0.002,
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

    lib.requestNamedPtfxAsset("core")

    UseParticleFxAssetNextCall("core")

    self._ptfx = StartParticleFxLoopedOnEntity(
        "ent_amb_fly_swarm",
        self._entity,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.0,
        1.0,
        false,
        false,
        false
    )
end

function Tile:getEntity()
    return self._entity
end

function Tile:getDirtiness()
    return self._dirtiness
end

function Tile:setDirtiness(percentage)
    self._dirtiness = percentage

    local alpha = math.floor(
        (self._dirtiness / 100) * 255
    )

    SetEntityAlpha(self._dirtyEntityFx, alpha, false)

    SetParticleFxLoopedAlpha(self._ptfx, alpha > 100 and 1.0 or 0.0)
end

function Tile:getStrawState()
    return self._strawState
end

function Tile:setStrawState(newState)
    self._strawState = newState

    SetEntityVisible(self._strawEntityFx, newState, false)
end

function Tile:destroy()
    DeleteObject(self._entity)
    DeleteObject(self._dirtyEntityFx)
    DeleteObject(self._strawEntityFx)
    StopParticleFxLooped(self._ptfx, false)
end

return Tile
