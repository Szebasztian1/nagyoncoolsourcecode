local TileService = require("lua.client.Tile.TileService")

local lastTime = GetGameTimer()

local function GetDeltaTime()
    local now = GetGameTimer()
    local dt = (now - lastTime) / 1000.0
    lastTime = now
    return dt
end

local PitchforkHitService = {}
PitchforkHitService._isAiming = false
PitchforkHitService._isCharging = false
PitchforkHitService._strength = 0
PitchforkHitService._tickState = false
---@type C_Tile | nil
PitchforkHitService._lockedEntity = nil
PitchforkHitService.HIT_SPEED_INCREASE_SPEED = 50

function PitchforkHitService:start()
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

function PitchforkHitService:stop()
    self._tickState = false
end

---@param entity C_Tile
---@param strength number
function PitchforkHitService:hit(entity, strength)
    local position = entity.position

    TriggerServerEvent("Farmhouse::Tile::Interact", entity.id)

    PlaySoundFromCoord(
        GetSoundId(),
        "put_straw_to_ground",
        entity.position.x,
        entity.position.y,
        entity.position.z,
        "aquiver_farmhouse_sounds",
        true,
        15.0,
        false
    )

    lib.requestNamedPtfxAsset("cut_michael1")

    UseParticleFxAssetNextCall("cut_michael1")

    StartNetworkedParticleFxNonLoopedAtCoord(
        "cs_mich1_tool_dirt_impact",
        position.x,
        position.y,
        position.z,
        0.0,
        0.0,
        0.0,
        1.75,
        false,
        false,
        false
    )
end

function PitchforkHitService:onTick()
    DisableControlAction(0, 24, true)
    DisableControlAction(1, 24, true)

    if self._lockedEntity then
        Graphics:drawBar3D(
            self._lockedEntity.position + vector3(0, 0, 0.25),
            self._strength,
            0.075,
            0.01
        )
    end

    if self._isAiming then
        DisableAllControlActions(0)

        if not self._lockedEntity then
            -- Camera movement
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)

            -- WASD movement
            EnableControlAction(0, 30, true)
            EnableControlAction(0, 31, true)
        end

        local lookedAt = TileService:getLookedAt(5.0)

        if lookedAt then
            Graphics:drawMarker(
                20,
                lookedAt.position + vector3(0, 0, 0.5),
                vector3(0.125, 0.125, 0.125),
                nil,
                vector3(0, 180, 0),
                nil,
                true,
                false,
                true
            )

            Graphics:drawMarker(
                27,
                lookedAt.position + vector3(0, 0, 0.15),
                vector3(0.65, 0.65, 1.0),
                nil,
                nil,
                nil,
                false,
                false,
                true
            )

            if IsDisabledControlJustPressed(0, 24) and not self._isCharging then
                self._isCharging = true
                self._lockedEntity = lookedAt

                GetDeltaTime()
            end

            if IsDisabledControlJustReleased(0, 24) and self._isCharging then
                self._lockedEntity = nil
                self._isCharging = false
                self._strength = 0
            end
        end
    end

    if self._isCharging then
        if self._strength < 100 then
            self._strength += GetDeltaTime() * self.HIT_SPEED_INCREASE_SPEED
        end

        if self._strength >= 100 then
            self:hit(self._lockedEntity, self._strength)

            self._isCharging = false
            self._lockedEntity = nil
            self._strength = 0
        end
    end

    -- Handling the aiming
    if IsDisabledControlJustPressed(0, 25) and not self._isAiming then
        self._isAiming = true
    end

    if IsDisabledControlJustReleased(0, 25) and self._isAiming then
        self._isAiming = false

        if self._isCharging then
            self._isCharging = false
            self._strength = 0
        end
    end
end

return PitchforkHitService
