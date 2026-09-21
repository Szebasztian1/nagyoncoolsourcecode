local Config = require("lua.shared.Config")
local Straw = require("lua.client.Straw.Straw")
local PitchforkStateService = require("lua.client.Pitchfork.PitchforkStateService")

local StrawService = {}
---@type table<number, C_Straw>
StrawService._entities = {}
StrawService._tickState = false

---@param data IStraw
function StrawService:create(data)
    local entity = self:get(data.id)

    if not entity then
        entity = Straw:new(
            data.id,
            vector3(data.positionX, data.positionY, data.positionZ),
            vector3(data.rotationX, data.rotationY, data.rotationZ)
        )

        self._entities[entity.id] = entity
    end

    return entity
end

function StrawService:get(id)
    return self._entities[id]
end

function StrawService:getAll()
    return self._entities
end

function StrawService:onEnteringInstance()
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

function StrawService:onLeavingInstance()
    self._tickState = false

    for k, v in pairs(self._entities) do
        v:destroy()
    end

    self._entities = {}
end

---@param entity C_Straw
function StrawService:interact(entity)
    PlaySoundFromCoord(
        GetSoundId(),
        "pickup_straw",
        entity.position.x,
        entity.position.y,
        entity.position.z,
        "aquiver_farmhouse_sounds",
        true,
        15.0,
        false
    )

    TriggerServerEvent("Farmhouse::Straw::Interact", entity.id)

    lib.requestNamedPtfxAsset("cut_michael1")

    UseParticleFxAssetNextCall("cut_michael1")

    StartNetworkedParticleFxNonLoopedAtCoord(
        "cs_mich1_tool_dirt_impact",
        entity.position.x,
        entity.position.y,
        entity.position.z,
        0.0,
        0.0,
        1.5,
        2.75,
        false,
        false,
        false
    )
end

function StrawService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    for _, entity in pairs(self._entities) do
        local distanceTo = #(localPos - entity.position)

        if distanceTo < 3.0 then
            Graphics:drawTextThisFrame3D(
                entity.position + vector3(0, 0, 1.0),
                locale("GAME_STRAW"),
                0.2,
                true
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

            Graphics:drawTextThisFrame3D(
                entity:getInteractionPosition() + vector3(0, 0, 0.5),
                locale("GAME_STRAW_HINT"),
                0.2,
                true
            )

            if IsRawKeyPressed(Config.INTERACTION_KEY) and PitchforkStateService:hasLocally() then
                Citizen.CreateThread(function()
                    self:interact(entity)
                end)
            end
        end
    end
end

return StrawService
