SlotAnims                  = {}

local ANIM_DICT_SHARED     = "anim_casino_b@amb@casino@games@shared@player@"
local ANIM_DICT_MACHINE    = "anim_casino_a@amb@casino@games@slots@male"

local SIT_ENTER_ANIMS      = { "sit_enter_left", "sit_enter_right" }
local SIT_EXIT_ANIMS       = { "sit_exit_left", "sit_exit_right" }
local SPIN_ANIMS           = { "press_spin_a", "press_spin_b", "pull_spin_a", "pull_spin_b" }

local LEVER_ANIMS          = {
    pull_spin_a = "pull_spin_a_SLOTMACHINE",
    pull_spin_b = "pull_spin_b_SLOTMACHINE",
}

local SCENE_COMPLETE_PHASE = 0.99

local SIT_DONE_EVENT_A     = 2038294702
local SIT_DONE_EVENT_B     = -1424880317

---@param msg string
local function dbg(msg)
    if Config.Debug then
        print(("[mate-slot:anim] %s"):format(msg))
    end
end

local function requireDict(dict)
    if HasAnimDictLoaded(dict) then return end

    if not DoesAnimDictExist(dict) then
        dbg(("requireDict — dict does not exist: %s"):format(dict))
        return
    end

    lib.requestAnimDict(dict)
end

local function randomFrom(t)
    return t[math.random(#t)]
end

---@param pos vector3
---@param rot vector3
function SlotAnims:SitDown(pos, rot)
    requireDict(ANIM_DICT_SHARED)

    local animName = randomFrom(SIT_ENTER_ANIMS)

    SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, false, false, false, false)
    SetEntityHeading(cache.ped, rot.z)

    Wait(25)

    local scene = NetworkCreateSynchronisedScene(
        pos.x, pos.y, pos.z,
        rot.x, rot.y, rot.z,
        2, true, false, 1.0, 0, 1.0
    )

    NetworkAddPedToSynchronisedScene(
        cache.ped, scene,
        ANIM_DICT_SHARED, animName,
        2.0, -1.5, 13, 16, 2.0, 0
    )

    NetworkStartSynchronisedScene(scene)

    scene = NetworkConvertSynchronisedSceneToSynchronizedScene(scene)

    repeat
        Wait(0)
    until GetSynchronizedScenePhase(scene) >= SCENE_COMPLETE_PHASE
        or HasAnimEventFired(cache.ped, SIT_DONE_EVENT_A)
        or HasAnimEventFired(cache.ped, SIT_DONE_EVENT_B)

    Wait(300)

    NetworkStopSynchronisedScene(scene)
    RemoveAnimDict(ANIM_DICT_SHARED)

    dbg(("SitDown complete — anim=%s"):format(animName))
end

---@param pos vector3
---@param rot vector3
function SlotAnims:StandUp(pos, rot)
    requireDict(ANIM_DICT_SHARED)

    local animName = randomFrom(SIT_EXIT_ANIMS)
    local duration = GetAnimDuration(ANIM_DICT_SHARED, animName)

    SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, false, false, false, false)
    SetEntityHeading(cache.ped, rot.z)

    Wait(25)

    local scene = NetworkCreateSynchronisedScene(
        pos.x, pos.y, pos.z,
        rot.x, rot.y, rot.z,
        2, true, false, 1.0, 0, 1.0
    )

    NetworkAddPedToSynchronisedScene(
        cache.ped, scene,
        ANIM_DICT_SHARED, animName,
        2.0, -1.5, 13, 16, 2.0, 0
    )

    NetworkStartSynchronisedScene(scene)

    Wait(math.floor(duration * 700))

    NetworkStopSynchronisedScene(scene)
    RemoveAnimDict(ANIM_DICT_SHARED)

    dbg(("StandUp complete — anim=%s"):format(animName))
end

---@param machineObj    number   Entity handle of the slot machine prop.
---@param machineCoords vector3  World coords of the machine.
---@param machineRot    vector3  World rotation of the machine.
---@return { animName: string, leverScene: number|nil, duration: number }
function SlotAnims:PlaySpinAnim(machineObj, machineCoords, machineRot)
    requireDict(ANIM_DICT_MACHINE)

    local isLoaded = lib.waitFor(function()
        requireDict(ANIM_DICT_MACHINE)
        return HasAnimDictLoaded(ANIM_DICT_MACHINE) or nil
    end)

    if not isLoaded then
        dbg("PlaySpinAnim — failed to load anim dict: " .. ANIM_DICT_MACHINE)
        return { animName = "", leverScene = nil, duration = 1.0 }
    end

    local animName = randomFrom(SPIN_ANIMS)

    local pedScene = NetworkCreateSynchronisedScene(
        machineCoords.x, machineCoords.y, machineCoords.z,
        machineRot.x, machineRot.y, machineRot.z,
        2, true, false, 1.0, 0, 1.0
    )

    NetworkAddPedToSynchronisedScene(
        cache.ped, pedScene,
        ANIM_DICT_MACHINE, animName,
        2.0, -1.5, 13, 16, 2.0, 0
    )

    NetworkStartSynchronisedScene(pedScene)

    local duration   = GetAnimDuration(ANIM_DICT_MACHINE, animName)
    local leverScene = nil
    local leverAnim  = LEVER_ANIMS[animName]

    if leverAnim and DoesEntityExist(machineObj) then
        leverScene = NetworkCreateSynchronisedScene(
            machineCoords.x, machineCoords.y, machineCoords.z,
            machineRot.x, machineRot.y, machineRot.z,
            2, true, false, 1.0, 0, 1.0
        )

        NetworkAddMapEntityToSynchronisedScene(
            leverScene, machineObj,
            machineCoords.x, machineCoords.y, machineCoords.z,
            ANIM_DICT_MACHINE, leverAnim,
            2.0, -1.5, 13
        )

        NetworkStartSynchronisedScene(leverScene)
    end

    dbg(("PlaySpinAnim — anim=%s, lever=%s, duration=%.2f"):format(
        animName, tostring(leverScene ~= nil), duration
    ))

    return {
        animName   = animName,
        leverScene = leverScene,
        duration   = duration,
    }
end

---@param leverScene number|nil
function SlotAnims:StopLeverScene(leverScene)
    if leverScene then
        NetworkStopSynchronisedScene(leverScene)
    end
end
