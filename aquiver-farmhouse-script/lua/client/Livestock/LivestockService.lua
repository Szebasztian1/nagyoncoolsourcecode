local Livestock = require("lua.client.Livestock.Livestock")

-- How often the closest-animal scan runs. The scan is O(livestock) with a vector distance per
-- animal; nobody crosses a 5m radius inside 200ms, so running it every frame buys nothing. Only
-- the sprite has to be redrawn at frame rate.
local NEAREST_SCAN_INTERVAL = 200

local LivestockService = {}
---@type table<number, C_Livestock>
LivestockService._entities = {}
LivestockService._tickState = false
-- Built on entering a farmhouse, torn down on leaving. It used to be created at file scope, which
-- meant every player on the server carried a live 1080p CEF browser from connect to disconnect --
-- including the overwhelming majority who never set foot on a farm.
---@type table | nil
LivestockService._dui = nil
---@type C_Livestock | nil
LivestockService._lastEntity = nil
---@type C_Livestock | nil
LivestockService._nearest = nil
LivestockService._nextScan = 0

function LivestockService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Livestock:new(
            data.id,
            data.netId
        )

        self._entities[entity.id] = entity

        Citizen.CreateThread(function()
            while not entity:exists() do
                Citizen.Wait(100)
            end

            entity:initialize()
        end)
    end

    entity.type = data.type
    entity.age = data.age
    entity.health = data.health
    entity.quality = data.quality
    entity.requirements = data.requirements
    entity.gather = data.gather

    if entity:isDead() then
        Citizen.CreateThread(function()
            while not entity:exists() do
                Citizen.Wait(100)
            end

            SetEntityHealth(entity:getEntity(), 0.0)
        end)
    end

    return entity
end

function LivestockService:get(id)
    return self._entities[id]
end

function LivestockService:getAll()
    return self._entities
end

---@param atPosition vector3
---@param distanceToCheck number
function LivestockService:getNearest(atPosition, distanceToCheck)
    local closest = nil
    local closestDistance = distanceToCheck

    for _, entity in pairs(self._entities) do
        if entity:exists() then
            local distance = #(atPosition - entity:getPosition())

            if distance < closestDistance then
                closest = entity
                closestDistance = distance
            end
        end
    end

    return closest
end

function LivestockService:onEnteringInstance()
    if self._tickState then return end
    self._tickState = true

    if not self._dui then
        -- 960x540 keeps the 16:9 the page is laid out for (all component sizing is in vw), at a
        -- quarter of the pixels to paint and a quarter of the texture memory. The sprite is drawn
        -- at 0.1-0.5 of screen width, so this is still oversampled.
        self._dui = lib.dui:new({
            url = ("nui://%s/resource/dui/index.html"):format(GetCurrentResourceName()),
            width = 960,
            height = 540
        })
    end

    Citizen.CreateThread(function()
        local dui = self._dui

        -- The page is local, but a freshly built browser still needs a moment to come up. Now that
        -- the DUI is built on entry rather than at resource start, the first refresh could land
        -- before the page exists and get dropped -- leaving the panel blank until the player walked
        -- to another animal and back.
        while self._tickState and dui and not IsDuiAvailable(dui.duiObject) do
            Citizen.Wait(50)
        end

        while self._tickState do
            self:onTick()

            Citizen.Wait(0)
        end
    end)
end

function LivestockService:onLeavingInstance()
    self._tickState = false

    self._entities = {}
    self._lastEntity = nil
    self._nearest = nil
    self._nextScan = 0

    if self._dui then
        self._dui:remove()
        self._dui = nil
    end
end

function LivestockService:onTick()
    local dui = self._dui
    if not dui then return end

    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)
    local now = GetGameTimer()

    if now >= self._nextScan then
        self._nextScan = now + NEAREST_SCAN_INTERVAL
        self._nearest = self:getNearest(localPos, 5.0)
    end

    local entity = self._nearest
    if not entity or not entity:exists() then return end

    if self._lastEntity?.id ~= entity.id then
        self._lastEntity = entity

        entity:refresh(dui)
    end

    local entityPos = entity:getPosition()
    local distanceTo = #(localPos - entityPos)

    local maxDistance = 7.0
    local alpha = math.floor(
        255 * (1 - distanceTo / maxDistance)
    )

    -- The cached nearest can be up to NEAREST_SCAN_INTERVAL stale, so it may already be past
    -- maxDistance and have faded out entirely.
    if alpha <= 0 then return end

    local minScale = 0.1
    local maxScale = 0.5
    local scale = maxScale - (distanceTo / maxDistance) * (maxScale - minScale)

    local result, screenX, screenY = GetScreenCoordFromWorldCoord(
        entityPos.x,
        entityPos.y,
        entityPos.z + 0.5
    )

    if result then
        DrawSprite(
            dui.dictName,
            dui.txtName,
            screenX,
            screenY,
            scale,
            scale,
            0,
            255,
            255,
            255,
            alpha
        )
    end
end

return LivestockService
