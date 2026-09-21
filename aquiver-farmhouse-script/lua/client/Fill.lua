local Tick = require("lua.shared.Tick")

---@class C_Fill : OxClass
---@field private _minZ number
---@field private _maxZ number
---@field private _entity number
---@field private _parent number
---@field private _targetPercentage number
---@field private _currentPercentage number
---@field private _tick Tick
local FillProp = lib.class("C_Fill")

---@param entity number
---@param parent number
---@param minZ number
---@param maxZ number
function FillProp:constructor(entity, parent, minZ, maxZ)
    self._minZ = minZ
    self._maxZ = maxZ
    self._entity = entity
    self._parent = parent
    self._targetPercentage = 0
    self._currentPercentage = 0
    self._tick = Tick:new(35, function()
        self:onTick()
    end)

    self:refreshAttach(0.0)
end

---@param entity number
function FillProp:changeEntity(entity)
    DeleteObject(self._entity)

    self._entity = entity

    self:refreshAttach(self:getZCalc())
end

function FillProp:setVisible(visible)
    SetEntityVisible(self._entity, visible, visible)
end

function FillProp:getEntity()
    return self._entity
end

---@param z number
function FillProp:refreshAttach(z)
    AttachEntityToEntity(
        self._entity,
        self._parent,
        -1,
        0.0,
        0.0,
        z,
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

function FillProp:update(percentage)
    self._targetPercentage = math.min(100, math.round(percentage))

    self._tick:start()
end

function FillProp:getZCalc()
    return self._minZ + (self._maxZ - self._minZ) * (self._currentPercentage / 100)
end

function FillProp:onTick()
    local step = 1

    if self._currentPercentage < self._targetPercentage then
        self._currentPercentage = math.min(
            self._currentPercentage + step, self._targetPercentage
        )
    else
        self._currentPercentage = math.max(
            self._currentPercentage - step,
            self._targetPercentage
        )
    end

    self:refreshAttach(self:getZCalc())

    if self._targetPercentage == self._currentPercentage then
        self._tick:stop()
    end
end

function FillProp:destroy()
    DeleteObject(self._entity)
end

return FillProp
