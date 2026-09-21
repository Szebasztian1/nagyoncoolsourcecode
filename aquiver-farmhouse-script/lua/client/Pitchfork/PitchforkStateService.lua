local ePitchforkContent = require("lua.shared.enums.ePitchforkContent")
local PitchforkHitService = require("lua.client.Pitchfork.PitchforkHitService")

local PitchforkStateService = {}
PitchforkStateService._entity = -1
PitchforkStateService._attachedEntity = -1
PitchforkStateService._tickState = false
PitchforkStateService._currentState = false
PitchforkStateService._contentState = {
    id = ePitchforkContent.Empty,
    count = 0
}

local IDLE_ANIM_DICT = "pitchfork_straw_idle@pose"
local IDLE_ANIM_NAME = "pitchfork_straw_idle_clip"
local IDLE_ANIM_FLAG = 49

function PitchforkStateService:hasLocally()
    return self._currentState
end

function PitchforkStateService:clear()
    self._tickState = false

    if self._currentState then
        self._currentState = false

        self:remove()

        PitchforkHitService:stop()

        StopAnimTask(PlayerPedId(), IDLE_ANIM_DICT, IDLE_ANIM_NAME, 1.0)
    end
end

---@param contentState IPitchforkContentState
function PitchforkStateService:set(contentState)
    self._contentState = contentState

    if not self._currentState then
        self._currentState = true

        self:apply(contentState)

        PitchforkHitService:start()
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

function PitchforkStateService:apply(contentState)
    local localPed = PlayerPedId()

    if self._entity == -1 then
        self._entity = CreateObjectNoOffset(
            "avp_animal_farm_prop_garden_fork",
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
            0.0379,
            1.347,
            0.184,
            -95.918,
            -3.708,
            180.117,
            false,
            false,
            false,
            false,
            2,
            true
        )
    end
end

function PitchforkStateService:remove()
    DeleteObject(self._entity)
    self._entity = -1

    DeleteObject(self._attachedEntity)
    self._attachedEntity = -1
end

---@param content ePitchforkContent
function PitchforkStateService:getPropByContent(content)
    if content == ePitchforkContent.Straw then
        return "avp_animal_farm_prop_garden_fork_straw"
    elseif content == ePitchforkContent.DirtyStraw then
        return "avp_animal_farm_prop_garden_fork_straw_dirty"
    end
end

---@param content ePitchforkContent
function PitchforkStateService:refreshAttach(content)
    if self._attachedEntity ~= -1 then
        DeleteObject(self._attachedEntity)
        self._attachedEntity = -1
    end

    local modelHash = self:getPropByContent(content)
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

function PitchforkStateService:onTick()
    local localPed = PlayerPedId()

    if self._entity ~= -1 then
        local position = GetOffsetFromEntityInWorldCoords(
            self._entity,
            0,
            0,
            0
        )

        if self._contentState then
            Graphics:drawTextThisFrame3D(
                position,
                "~y~" .. locale(self._contentState.id) .. "\n" .. '~s~x' .. self._contentState.count,
                0.2,
                true
            )
        end

        if not IsEntityPlayingAnim(localPed, IDLE_ANIM_DICT, IDLE_ANIM_NAME, 3) then
            if not HasAnimDictLoaded(IDLE_ANIM_DICT) then
                RequestAnimDict(IDLE_ANIM_DICT)
            else
                TaskPlayAnim(
                    localPed,
                    IDLE_ANIM_DICT,
                    IDLE_ANIM_NAME,
                    8.0,
                    8.0,
                    -1,
                    IDLE_ANIM_FLAG,
                    1.0,
                    false,
                    false,
                    false
                )
            end
        end
    end
end

return PitchforkStateService
