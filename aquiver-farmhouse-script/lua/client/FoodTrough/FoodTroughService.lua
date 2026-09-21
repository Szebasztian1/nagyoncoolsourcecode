local FoodTrough             = require("lua.client.FoodTrough.FoodTrough")

local FoodTroughService      = {}
---@type table<number, C_FoodTrough>
FoodTroughService._entities  = {}
FoodTroughService._tickState = false

---@param data IFoodTrough
function FoodTroughService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = FoodTrough:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end

    entity:setContent(data.content)
    entity:setPercentage(data.count)

    return entity
end

function FoodTroughService:get(id)
    return self._entities[id]
end

function FoodTroughService:getAll()
    return self._entities
end

---@param atPosition vector3
---@param distanceToCheck number
function FoodTroughService:getNearest(atPosition, distanceToCheck)
    local closest = nil
    local closestDistance = distanceToCheck

    for _, entity in pairs(self._entities) do
        local distance = #(atPosition - entity.position)

        if distance < closestDistance then
            closest = entity
            closestDistance = distance
        end
    end

    return closest
end

function FoodTroughService:onEnteringInstance()
    if not self._tickState then
        self._tickState = true

        Citizen.CreateThread(function()
            while self._tickState do
                self:onTick()

                Citizen.Wait(0)
            end
        end)
    end
end

function FoodTroughService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

function FoodTroughService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    for _, entity in pairs(self._entities) do
        local distance = #(localPos - entity.position)

        if distance < 3.0 then
            local result, screenX, screenY = GetScreenCoordFromWorldCoord(
                entity.position.x,
                entity.position.y,
                entity.position.z + 1.25
            )

            if result then
                local screenPosition = vector2(screenX, screenY)

                Graphics:drawTextThisFrame2D(
                    screenPosition + vector2(0, -0.025),
                    locale('GAME_FOOD_TROUGH', locale(entity:getContent())),
                    0.2,
                    true
                )

                Graphics:drawBar2D(
                    screenPosition,
                    entity:getPercentage(),
                    0.075,
                    nil,
                    nil,
                    { 0, 255, 125, 200 }
                )

                Graphics:drawMarker(
                    27,
                    entity:getInteractPosition(),
                    vector3(0.65, 0.65, 1.0),
                    { 150, 75, 0, 175 },
                    nil,
                    nil,
                    nil,
                    nil,
                    true
                )
            end
        end
    end
end

return FoodTroughService
