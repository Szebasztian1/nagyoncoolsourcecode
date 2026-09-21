local Watertip = require("lua.client.Watertip.Watertip")

local WatertipService = {}
---@type table<number, C_Watertip>
WatertipService._entities = {}
WatertipService._tickState = false

---@param data IWatertip
function WatertipService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Watertip:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end


    entity:setIsActive(data.isActive)
    entity:setOccupied(data.isOccupied)
    entity:setWaterPercentage(data.waterPercentage)

    -- 		entity.bucketFillEntity.update(entity.waterPercentage);

    return entity
end

function WatertipService:get(id)
    return self._entities[id]
end

function WatertipService:getAll()
    return self._entities
end

function WatertipService:onEnteringInstance()
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

function WatertipService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

function WatertipService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    for _, entity in pairs(self._entities) do
        local distance = #(localPos - entity.position)

        if distance < 2.5 then
            local found, screenX, screenY = GetScreenCoordFromWorldCoord(
                entity.position.x,
                entity.position.y,
                entity.position.z + 1.0
            )

            if found then
                local screenPosition = vector2(screenX, screenY)

                DrawSpriteMeter(
                    "aquiver_farmhouse",
                    "water_drop_icon",
                    screenPosition.x,
                    screenPosition.y,
                    0.025,
                    0.025,
                    entity:getWaterPercentage() / 100,
                    { 153, 192, 227, 200 }
                )
            end
        end
    end
end

return WatertipService
