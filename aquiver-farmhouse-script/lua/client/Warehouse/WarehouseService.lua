local Warehouse = require("lua.client.Warehouse.Warehouse")

local WarehouseService = {}
---@type table<eWarehouseUnit, C_Warehouse>
WarehouseService._entities = {}
WarehouseService._tickState = false

---@param data IWarehouse
function WarehouseService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Warehouse:new(
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

function WarehouseService:get(id)
    return self._entities[id]
end

function WarehouseService:onEnteringInstance()
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

function WarehouseService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

function WarehouseService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    for _, entity in pairs(self._entities) do
        local distance = #(localPos - entity.position)

        if distance < 3.0 then
            local found, screenX, screenY = GetScreenCoordFromWorldCoord(
                entity.position.x,
                entity.position.y,
                entity.position.z + 1.25
            )

            if found then
                local screenPosition = vector2(screenX, screenY)

                Graphics:drawTextThisFrame2D(
                    vector2(screenX, screenY - 0.035),
                    locale('GAME_WAREHOUSE', entity:getCount(), locale(entity.id)),
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

return WarehouseService
