local Tile = require("lua.client.Tile.Tile")

local TileService = {}
---@type table<number, C_Tile>
TileService._entities = {}

---@param data ITile
function TileService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Tile:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end

    entity:setStrawState(data.strawState)
    entity:setDirtiness(data.dirtiness)

    return entity
end

function TileService:get(id)
    return self._entities[id]
end

function TileService:getAll()
    return self._entities
end

---@param distanceTo number
function TileService:getLookedAt(distanceTo)
    ---@type vector3
    local camPos = GameplayCamera:getPosition()
    ---@type vector3
    local camDir = GameplayCamera:getDirection()

    local targetPos = vector3(
        camPos.x + camDir.x * distanceTo,
        camPos.y + camDir.y * distanceTo,
        camPos.z + camDir.z * distanceTo
    )

    local ray = StartExpensiveSynchronousShapeTestLosProbe(
        camPos.x,
        camPos.y,
        camPos.z,
        targetPos.x,
        targetPos.y,
        targetPos.z,
        1,
        PlayerPedId(),
        -1
    )

    local _, didHit, hitPos, _, hitEntity = GetRaycastResult(ray)

    if didHit then
        for _, entity in pairs(self._entities) do
            if entity:getEntity() == hitEntity then
                return entity
            end
        end
    end
end

function TileService:onEnteringInstance()

end

function TileService:onLeavingInstance()
    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

return TileService
