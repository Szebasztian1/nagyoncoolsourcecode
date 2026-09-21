local InstanceRegistry = require("lua.client.Instance.InstanceRegistry")

local InstancePresenceService = {}
---@private
InstancePresenceService._currentState = -1

---@param id number
function InstancePresenceService:set(id)
    self._currentState = id
end

function InstancePresenceService:isInAny()
    return self._currentState ~= -1
end

function InstancePresenceService:get()
    return self._currentState
end

function InstancePresenceService:getHouseIsIn()
    if self:isInAny() then
        return InstanceRegistry:get(self._currentState)
    end
end

return InstancePresenceService
