local Bucket = require("lua.client.Bucket.Bucket")

local BucketService = {}
---@type table<number, C_Bucket>
BucketService._entities = {}

---@param data IBucket
function BucketService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Bucket:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end

    entity:setContentState(data.contentState)
    entity:setIsPickedUp(data.isPickedUp)

    return entity
end

function BucketService:get(id)
    return self._entities[id]
end

function BucketService:getAll()
    return self._entities
end

function BucketService:onEnteringInstance()
end

function BucketService:onLeavingInstance()
    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

return BucketService
