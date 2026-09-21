local WaterTrough = require("lua.client.WaterTrough.WaterTrough")

local WaterTroughService = {}
---@type table<number, C_WaterTrough>
WaterTroughService._entities = {}
WaterTroughService._tickState = false

---@param data IWaterTrough
function WaterTroughService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = WaterTrough:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end

    entity:setPercentage(data.count)
end

function WaterTroughService:get(id)
    return self._entities[id]
end

function WaterTroughService:getAll()
    return self._entities
end

---@param atPosition vector3
---@param distanceToCheck number
function WaterTroughService:getNearest(atPosition, distanceToCheck)
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

function WaterTroughService:onEnteringInstance()
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

function WaterTroughService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

function WaterTroughService:onTick()
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

                DrawSpriteMeter(
                    "aquiver_farmhouse",
                    "water_drop_icon",
                    screenPosition.x,
                    screenPosition.y,
                    0.03,
                    0.03,
                    entity:getPercentage() / 100,
                    { 153, 192, 227, 200 }
                )

                Graphics:drawMarker(
                    27,
                    entity:getInteractPosition(),
                    vector3(0.65, 0.65, 1.0),
                    { 15, 94, 156, 175 },
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

return WaterTroughService
