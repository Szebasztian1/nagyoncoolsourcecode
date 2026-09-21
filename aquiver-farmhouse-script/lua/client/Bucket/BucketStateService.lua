local WaterTroughService = require("lua.client.WaterTrough.WaterTroughService")
local FoodTroughService = require("lua.client.FoodTrough.FoodTroughService")
local eBucketContent = require("lua.shared.enums.eBucketContent")
local BucketProps = require("lua.shared.data.BucketProps")

local BucketStateService = {}
BucketStateService._currentState = false
BucketStateService._contentState = {
    id = eBucketContent.EMPTY,
    count = 0
}
BucketStateService._entity = -1
BucketStateService._attachedEntity = -1
BucketStateService._tickState = false
BucketStateService._isAiming = false
BucketStateService._isPouring = false

local lastPacketSent = GetGameTimer()

local ANIM_DICTIONARY = "weapons@misc@jerrycan@"
local ANIM_NAME = "fire"
local ANIM_FLAG = 49

function BucketStateService:hasLocally()
    return self._currentState
end

function BucketStateService:clear()
    self._tickState = false

    if self._currentState then
        self._currentState = false

        self:remove()
    end
end

---@param contentState IPitchforkContentState
function BucketStateService:set(contentState)
    self._contentState = contentState

    if not self._currentState then
        self._currentState = true

        self:give(contentState)
    end

    self:refreshAttach(contentState.id)

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

function BucketStateService:give(contentState)
    local localPed = PlayerPedId()

    if self._entity == -1 then
        self._entity = CreateObject(
            "avp_animal_farm_prop_bucket_inhand",
            0,
            0,
            0,
            true,
            true,
            false
        )
        -- bc_kocsitorles: legalis spawn jelolese
        if self._entity and self._entity ~= 0 and NetworkGetEntityIsNetworked(self._entity) then Entity(self._entity).state:set('bc_spawned', true, true) end

        AttachEntityToEntity(
            self._entity,
            localPed,
            GetPedBoneIndex(localPed, 57005),
            0.65,
            -0.1,
            0.0,
            208.0,
            -85.0,
            -7.0,
            false,
            false,
            false,
            false,
            2,
            true
        )
    end
end

function BucketStateService:remove()
    DeleteObject(self._entity)
    self._entity = -1

    DeleteObject(self._attachedEntity)
    self._attachedEntity = -1
end

---@param content ePitchforkContent
function BucketStateService:refreshAttach(content)
    if self._attachedEntity ~= -1 then
        DeleteObject(self._attachedEntity)
        self._attachedEntity = -1
    end

    local modelHash = BucketProps[content]
    if not modelHash then
        return false
    end

    local attachedProp = CreateObject(
        modelHash,
        0,
        0,
        0,
        true,
        true,
        false
    )
    -- bc_kocsitorles: legalis spawn jelolese
    if attachedProp and attachedProp ~= 0 and NetworkGetEntityIsNetworked(attachedProp) then Entity(attachedProp).state:set('bc_spawned', true, true) end

    AttachEntityToEntity(
        attachedProp,
        self._entity,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        false,
        false,
        false,
        false,
        2,
        true
    )

    self._attachedEntity = attachedProp
end

function BucketStateService:onTick()
    local localPed = PlayerPedId()
    local localPos = GetEntityCoords(localPed)

    if self._entity == -1 then return end

    if self._isAiming then
        DisableAllControlActions(0)
        EnableControlAction(0, 1, true)
        EnableControlAction(0, 2, true)
        EnableControlAction(0, 30, true)
        EnableControlAction(0, 31, true)
        EnableControlAction(0, 32, true)
        EnableControlAction(0, 33, true)
        EnableControlAction(0, 34, true)
        EnableControlAction(0, 35, true)

        if not self._isPouring then
            SetEntityAnimCurrentTime(
                localPed,
                ANIM_DICTIONARY,
                ANIM_NAME,
                0.0
            );
        end
    end

    if self._isPouring then
        local waterTrough = WaterTroughService:getNearest(localPos, 2.0)

        if waterTrough then
            if GetGameTimer() - lastPacketSent > 750 then
                lastPacketSent = GetGameTimer()

                TriggerServerEvent("Farmhouse::WaterTrough::Pour", waterTrough.id)
            end
        end

        local foodTrough = FoodTroughService:getNearest(localPos, 2.0)

        if foodTrough then
            if GetGameTimer() - lastPacketSent > 750 then
                lastPacketSent = GetGameTimer()

                TriggerServerEvent("Farmhouse::FoodTrough::Pour", foodTrough.id)
            end
        end
    end

    if IsDisabledControlJustPressed(0, 24) and self._isAiming and not self._isPouring then
        self._isPouring = true
    end

    if IsDisabledControlJustReleased(0, 24) and self._isPouring then
        self._isPouring = false
    end

    -- Aiming
    if IsDisabledControlJustPressed(0, 25) and not self._isAiming then
        self._isAiming = true

        if not IsEntityPlayingAnim(localPed, ANIM_DICTIONARY, ANIM_NAME, 3) then
            lib.requestAnimDict(ANIM_DICTIONARY)

            TaskPlayAnim(
                localPed,
                ANIM_DICTIONARY,
                ANIM_NAME,
                8.0,
                8.0,
                -1,
                ANIM_FLAG,
                1.0,
                false,
                false,
                false
            )

            AttachEntityToEntity(
                self._entity,
                PlayerPedId(),
                GetPedBoneIndex(PlayerPedId(), 57005),
                0.014,
                0.115,
                -0.022,
                179.264,
                22.534,
                24.024,
                false,
                false,
                false,
                false,
                2,
                true
            )
        end
    end

    if IsDisabledControlJustReleased(0, 25) and self._isAiming then
        self._isAiming = false

        if IsEntityPlayingAnim(localPed, ANIM_DICTIONARY, ANIM_NAME, 3) then
            StopAnimTask(localPed, ANIM_DICTIONARY, ANIM_NAME, 1.0)
        end

        AttachEntityToEntity(
            self._entity,
            PlayerPedId(),
            GetPedBoneIndex(PlayerPedId(), 57005),
            0.65,
            -0.1,
            0.0,
            208.0,
            -85.0,
            -7.0,
            false,
            false,
            false,
            false,
            2,
            true
        )
    end

    local position = GetOffsetFromEntityInWorldCoords(
        self._entity,
        0,
        0,
        0
    )

    Graphics:drawTextThisFrame3D(
        position,
        locale("GAME_BUCKET_GRAPHICS", self._contentState.count, locale(self._contentState.id)),
        0.2,
        true
    )
end

return BucketStateService
