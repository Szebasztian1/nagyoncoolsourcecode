local Config = require("lua.shared.Config")

---@class C_Instance : OxClass
---@field id number
---@field price number
---@field private _position vector3
---@field lockState boolean
---@field private _isOwnedBySomeone boolean
---@field private _name string
---@field private _blip number
local Instance = lib.class("C_Instance")

function Instance:constructor(id)
    self.id = id
    self.price = -1
    self.lockState = true

    self._isOwnedBySomeone = false
    self._blip = -1
end

function Instance:createBlip()
    if self._blip ~= -1 then return end

    self._blip = AddBlipForCoord(self._position.x, self._position.y, self._position.z)
    SetBlipAsShortRange(self._blip, true)
    SetBlipSprite(self._blip, Config.BLIP_SPRITE_ID)
    SetBlipScale(self._blip, 0.65)
    SetBlipCategory(self._blip, 20)
    AddTextEntry('MYBLIP', "Farm")
    BeginTextCommandSetBlipName('MYBLIP')
    EndTextCommandSetBlipName(self._blip)
end

---@param position vector3
function Instance:setPosition(position)
    self._position = position

    if self._blip ~= -1 then
        SetBlipCoords(self._blip, position.x, position.y, position.z)
    end
end

function Instance:getPosition()
    return self._position
end

function Instance:setIsOwnedBySomeone(newState)
    self._isOwnedBySomeone = newState

    if self._blip ~= -1 then
        SetBlipColour(self._blip, self._isOwnedBySomeone and 76 or 2)
    end
end

function Instance:getIsOwnedBySomeone()
    return self._isOwnedBySomeone
end

---@param name string
function Instance:setName(name)
    self._name = name

    if self._blip ~= -1 then
        AddTextEntry('MYBLIP', name);
        BeginTextCommandSetBlipName('MYBLIP');
        EndTextCommandSetBlipName(self._blip);
    end
end

function Instance:getName()
    return self._name
end

function Instance:getInteriorPosition()
    return Config.INTERIOR_POSITION
end

function Instance:destroy()
    if self._blip ~= -1 then
        RemoveBlip(self._blip)
    end
end

return Instance
