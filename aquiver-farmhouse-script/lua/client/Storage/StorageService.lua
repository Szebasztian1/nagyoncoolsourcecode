local Storage = require("lua.client.Storage.Storage")

local StorageService = {}
---@type table<number, C_Storage>
StorageService._entities = {}
StorageService._tickState = false

---@param data IStorage
function StorageService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Storage:new(
            data.id,
            data.modelHash,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end

    entity:setCount(data.count)

    return entity
end

function StorageService:get(id)
    return self._entities[id]
end

function StorageService:onEnteringInstance()
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

function StorageService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

function StorageService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    for _, entity in pairs(self._entities) do
        local distance = #(localPos - entity.position)

        if distance < 3.0 then
            local found, screenX, screenY = GetScreenCoordFromWorldCoord(
                entity.position.x,
                entity.position.y,
                entity.position.z + 1.0
            )

            if found then
                local screenPosition = vector2(screenX, screenY)

                Graphics:drawTextThisFrame2D(
                    screenPosition + vector2(0, -0.035),
                    locale("GAME_STORAGE", entity:getCount(), locale(entity.id)),
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
            end
        end
    end
end

return StorageService
