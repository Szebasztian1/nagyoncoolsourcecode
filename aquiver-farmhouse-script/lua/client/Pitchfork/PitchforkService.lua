local Pitchfork = require("lua.client.Pitchfork.Pitchfork")

local PitchforkService = {}
---@type table<number, C_Pitchfork>
PitchforkService.entities = {}

---@param data IPitchfork
function PitchforkService:create(data)
    local entity = self:get(data.id)
    if not entity then
        entity = Pitchfork:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self.entities[entity.id] = entity
    end

    entity:setIsPickedUp(data.isPickedUp)
    entity:setContentState(data.contentState)

    return entity
end

function PitchforkService:get(id)
    return self.entities[id]
end

function PitchforkService:getAll()
    return self.entities
end

function PitchforkService:onEnteringInstance()
end

function PitchforkService:onLeavingInstance()
    for k, v in pairs(self.entities) do
        v:destroy()
    end

    self.entities = {}
end

return PitchforkService
