local Config = require("lua.shared.Config")
local Compost = require("lua.client.Compost.Compost")

local CompostService = {}
---@type table<number, C_Compost>
CompostService._entities = {}
CompostService._tickState = false

---@param data ICompost
function CompostService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Compost:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end

    entity:setPercentage(data.count)

    return entity
end

function CompostService:get(id)
    return self._entities[id]
end

function CompostService:getAll()
    return self._entities
end

---@param atPosition vector3
---@param distanceToCheck number
function CompostService:getNearest(atPosition, distanceToCheck)
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

function CompostService:onEnteringInstance()
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

function CompostService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

function CompostService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    local nearestEntity = self:getNearest(localPos, 2.0)
    if nearestEntity then
        Graphics:drawTextThisFrame3D(
            nearestEntity:getInteractionPosition() + vector3(0, 0, 0.5),
            locale("GAME_COMPOSTER_HINT"),
            0.2,
            true
        )

        if IsRawKeyPressed(Config.INTERACTION_KEY) then
            TriggerServerEvent("Farmhouse::Compost::Empty", nearestEntity.id)
        end
    end

    for _, entity in pairs(self._entities) do
        local distanceTo = #(localPos - entity.position)

        if distanceTo < 3.0 then
            local result, screenX, screenY = GetScreenCoordFromWorldCoord(
                entity.position.x,
                entity.position.y,
                entity.position.z + 1.25
            )

            if result then
                local screenPosition = vector2(screenX, screenY)

                -- DrawSpriteMeter(
                --     "aquiver_farmhouse",
                --     "composter",
                --     screenPosition.x,
                --     screenPosition.y,
                --     0.025,
                --     0.025,
                --     entity:getPercentage() / 100,
                --     { 153, 192, 227, 200 }
                -- )

                Graphics:drawTextThisFrame2D(
                    screenPosition + vector2(0, -0.025),
                    locale("GAME_COMPOSTER"),
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
                    entity:getInteractionPosition(),
                    vector3(0.65, 0.65, 1.0),
                    { 255, 255, 255, 175 },
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

return CompostService
