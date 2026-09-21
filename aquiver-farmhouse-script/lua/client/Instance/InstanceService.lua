local Config = require("lua.shared.Config")
local Instance = require("lua.client.Instance.Instance")
local InstanceRegistry = require("lua.client.Instance.InstanceRegistry")
local InstanceEntranceService = require("lua.client.Instance.InstanceEntranceService")

local InstanceService = {}
---@type C_Instance[]
InstanceService._nearby = {}

---@param data IFarmhouse
function InstanceService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Instance:new(data.id)

        InstanceRegistry:add(entity)
    end

    entity.lockState = data.lockState
    entity.price = data.price
    entity:setIsOwnedBySomeone(data.isOwnedBySomeone)
    entity:setName(data.name)
    entity:setPosition(
        vector3(data.positionX, data.positionY, data.positionZ)
    )

    if not Config.USE_LOBBY_ENTRANCE then
        entity:createBlip()

        InstanceEntranceService:create(entity)
    end

    return entity
end

function InstanceService:get(id)
    return InstanceRegistry:get(id)
end

function InstanceService:fetch()
    ---@type IFarmhouse[]
    local response = lib.callback.await("Farmhouse::Client::Fetch", false)

    for _, instance in pairs(response) do
        self:create(instance)
    end
end

---@return C_Instance | nil
function InstanceService:getNearest(atPosition, distanceToCheck)
    local closest = nil
    local closestDistance = distanceToCheck

    for _, entity in pairs(InstanceRegistry._entities) do
        local distance = #(atPosition - entity:getPosition())

        if distance < closestDistance then
            closest = entity
            closestDistance = distance
        end
    end

    return closest
end

return InstanceService
