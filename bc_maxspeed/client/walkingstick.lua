--- @module walkingstick

--- @type integer
local propNetId = 0

--- @type integer
local propEntity = 0

--- @type boolean
local used = false

--- @type string
local PROP_MODEL = "prop_cs_walking_stick"

--- @type integer
local PROP_BONE = 57005

--- @type string
local WALK_ANIM_CANE = "move_lester_caneup"

--- @type string
local WALK_ANIM_DEFAULT = "move_m@multiplayer"

--- @return boolean
local function IsUsingWalkingStick()
    return used
end

exports("iswstick", IsUsingWalkingStick)

--- @param set string
local function RequestWalkingSet(set)
    RequestAnimSet(set)
    while not HasAnimSetLoaded(set) do
        Wait(1)
    end
end

--- @param modelHash integer
local function RequestPropModel(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end
end

--- @param ped integer
--- @param obj integer
local function AttachPropToPed(ped, obj)
    AttachEntityToEntity(
        obj, ped,
        GetPedBoneIndex(ped, PROP_BONE),
        0.15, 0.0, 0.0,
        0.0, 266.0, 0.0,
        false, false, false, true, 2, true
    )
end

--- @param ped integer
--- @return integer, integer
local function SpawnAndAttachProp(ped)
    local hash = GetHashKey(PROP_MODEL)
    RequestPropModel(hash)

    local obj = CreateObject(hash, GetEntityCoords(ped), true, false, false)

    local netId = 0
    local attempts = 0
    while netId == 0 and attempts < 50 do
        netId = ObjToNet(obj)
        if netId == 0 then
            Wait(50)
        end
        attempts = attempts + 1
    end

    -- bc_kocsitorles: legalis spawn jelolese
    if obj and obj ~= 0 and NetworkGetEntityIsNetworked(obj) then Entity(obj).state:set('bc_spawned', true, true) end

    AttachPropToPed(ped, obj)

    return obj, netId
end

--- @param ped integer
local function StartPropKeepAliveLoop(ped)
    CreateThread(function()
        while used do
            Wait(1000)

            if not used then break end

            if propEntity == 0 or not DoesEntityExist(propEntity) then
                local obj, netId = SpawnAndAttachProp(ped)
                propEntity       = obj
                propNetId        = netId
            elseif not IsEntityAttachedToAnyPed(propEntity) then
                AttachPropToPed(ped, propEntity)
            end
        end
    end)
end

--- @param ped integer
local function EnableWalkingStick(ped)
    if used then return end

    RequestWalkingSet(WALK_ANIM_CANE)
    SetPedMovementClipset(ped, WALK_ANIM_CANE, 1.0)

    local obj, netId = SpawnAndAttachProp(ped)
    propEntity       = obj
    propNetId        = netId
    used             = true

    StartPropKeepAliveLoop(ped)
end

--- @param ped integer
local function DisableWalkingStick(ped)
    if not used then return end

    used = false

    RequestWalkingSet(WALK_ANIM_DEFAULT)
    SetPedMovementClipset(ped, WALK_ANIM_DEFAULT, 1.0)
    ClearPedSecondaryTask(ped)

    if propEntity ~= 0 and DoesEntityExist(propEntity) then
        SetEntityAsMissionEntity(propEntity, true, false)
        DetachEntity(propEntity, true, true)
        DeleteEntity(propEntity)
    end

    propEntity = 0
    propNetId  = 0
end

RegisterNetEvent("stg_walkingstick")
AddEventHandler("stg_walkingstick", function(isEnabled)
    local ped = PlayerPedId()
    ClearPedTasks(ped)

    CreateThread(function()
        if isEnabled then
            EnableWalkingStick(ped)
        else
            DisableWalkingStick(ped)
        end
    end)
end)
