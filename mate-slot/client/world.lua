SlotWorld               = {}

local _useCallback      = nil
local _occupiedMachines = {}
local _machineOwners    = {}
local _nextMachineIndex = 1
local _zoneMachines     = {}
local _runtimeMachines  = {}
local _spawnedByUs      = {}
local _machineData      = {}
local _zoneHandles      = {}

local HAS_OX_TARGET     = GetResourceState("ox_target") == "started"

local function dbg(msg)
    if Config.Debug then
        print(("[mate-slot:world] %s"):format(msg))
    end
end

local function resolveSeatTransform(obj)
    for _, boneName in ipairs(Config.SeatBoneNames) do
        local boneIdx = GetEntityBoneIndexByName(obj, boneName)
        if boneIdx ~= -1 then
            local pos = GetWorldPositionOfEntityBone(obj, boneIdx)
            local rot = GetWorldRotationOfEntityBone(obj, boneIdx)
            return pos, rot
        end
    end

    local fallbackPos = GetOffsetFromEntityInWorldCoords(obj, 0.0, 0.5, 0.0)
    local fallbackRot = vector3(0.0, 0.0, GetEntityHeading(obj))

    dbg(("resolveSeatTransform — no bone on obj %d, using offset fallback"):format(obj))
    return fallbackPos, fallbackRot
end

local function buildMachineData(obj, label)
    local model            = GetEntityModel(obj)
    local coords           = GetEntityCoords(obj)
    local rot              = GetEntityRotation(obj)
    local seatPos, seatRot = resolveSeatTransform(obj)

    return {
        obj     = obj,
        model   = model,
        coords  = coords,
        rot     = rot,
        seatPos = seatPos,
        seatRot = seatRot,
        label   = label or "Slot Gép",
    }
end

local function buildChairData(machineIndex)
    local data = _machineData[machineIndex]
    if not data then return nil end

    return {
        machineIndex  = machineIndex,
        machineObj    = data.obj,
        machineModel  = data.model,
        machineCoords = data.coords,
        machineRot    = data.rot,
        seatPos       = data.seatPos,
        seatRot       = data.seatRot,
    }
end

local function registerTarget(machineIndex, obj, label)
    if not HAS_OX_TARGET then return nil end

    local optionName = ("mate_slot_prop_%d"):format(obj)

    exports.ox_target:addLocalEntity(obj, {
        {
            name     = optionName,
            label    = label or "Slot Gép",
            icon     = "fas fa-dice",
            distance = Config.InteractDistance,
            onSelect = function()
                if _occupiedMachines[machineIndex] then
                    lib.notify({
                        title       = "Slot Gép",
                        description = "Ez a gép már foglalt!",
                        type        = "error",
                    })
                    return
                end

                if _useCallback then
                    local chairData = buildChairData(machineIndex)
                    if chairData then
                        _useCallback(chairData)
                    end
                end
            end,
        },
    })

    dbg(("registerTarget — obj=%d, idx=%d, label=%s"):format(obj, machineIndex, label or "?"))
    return optionName
end

local function removeTarget(obj, targetName)
    if not HAS_OX_TARGET then return end
    if not targetName then return end
    if DoesEntityExist(obj) then
        exports.ox_target:removeLocalEntity(obj, targetName)
    end
end

local function spawnMachineObj(machineCfg)
    local hash = machineCfg.model
    RequestModel(hash)

    local deadline = GetGameTimer() + 10000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > deadline then
            dbg(("spawnMachineObj — model load timeout for hash %d at %s"):format(
                hash, tostring(machineCfg.coords)))
            return nil
        end
        Wait(50)
    end

    local c   = machineCfg.coords
    local obj = CreateObjectNoOffset(hash, c.x, c.y, c.z, false, false, false)

    SetEntityHeading(obj, machineCfg.heading or 0.0)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    SetModelAsNoLongerNeeded(hash)

    SetEntityLodDist(obj, 75)

    dbg(("spawnMachineObj — spawned obj=%d model=%d"):format(obj, hash))
    return obj
end

local _machineModelSet = nil

local function getMachineModelSet()
    if _machineModelSet then return _machineModelSet end
    _machineModelSet = {}
    for _, hash in ipairs(Config.MachineObjects) do
        _machineModelSet[hash] = true
    end
    return _machineModelSet
end

local function onZoneEnter(zoneId, zoneCfg)
    if _zoneMachines[zoneId] then
        dbg(("onZoneEnter — zone %d already active, skipping"):format(zoneId))
        return
    end

    dbg(("onZoneEnter — zone %d '%s', scanning r=%.1f"):format(
        zoneId, zoneCfg.label, zoneCfg.spawnRadius))

    local modelSet   = getMachineModelSet()
    local centre     = zoneCfg.coords
    local radius     = zoneCfg.spawnRadius
    local registered = {}
    local pool       = GetGamePool("CObject")

    for _, obj in ipairs(pool) do
        if DoesEntityExist(obj) then
            local model = GetEntityModel(obj)
            if modelSet[model] then
                local dist = #(centre - GetEntityCoords(obj))
                if dist <= radius and not _spawnedByUs[obj] then
                    local idx         = _nextMachineIndex
                    _nextMachineIndex = _nextMachineIndex + 1

                    _machineData[idx] = buildMachineData(obj, zoneCfg.label)
                    registered[idx]   = { obj = obj, targetName = registerTarget(idx, obj, zoneCfg.label) }

                    dbg(("  pool: obj=%d model=%d dist=%.1fm → idx=%d"):format(obj, model, dist, idx))
                end
            end
        end
    end

    if Config.Machines then
        for _, machineCfg in ipairs(Config.Machines) do
            local dist = #(centre - machineCfg.coords)
            if dist <= radius then
                local obj = spawnMachineObj(machineCfg)
                if obj then
                    _spawnedByUs[obj] = true

                    local idx         = _nextMachineIndex
                    _nextMachineIndex = _nextMachineIndex + 1

                    _machineData[idx] = buildMachineData(obj, machineCfg.label)
                    registered[idx]   = { obj = obj, targetName = registerTarget(idx, obj, machineCfg.label) }

                    dbg(("  spawned: obj=%d dist=%.1fm → idx=%d label='%s'"):format(
                        obj, dist, idx, machineCfg.label or "?"))
                else
                    dbg(("  spawn FAILED for machine at %s"):format(tostring(machineCfg.coords)))
                end
            end
        end
    end

    _zoneMachines[zoneId] = registered

    local n = 0
    for _ in pairs(registered) do n = n + 1 end
    dbg(("onZoneEnter — zone %d registered %d machine(s) total"):format(zoneId, n))
end

local function onZoneExit(zoneId)
    local machines = _zoneMachines[zoneId]
    if not machines then return end

    dbg(("onZoneExit — zone %d, cleaning up"):format(zoneId))

    for machineIndex, entry in pairs(machines) do
        removeTarget(entry.obj, entry.targetName)

        if _spawnedByUs[entry.obj] then
            if DoesEntityExist(entry.obj) then
                SetEntityAsMissionEntity(entry.obj, false, true)
                DeleteObject(entry.obj)
            end
            _spawnedByUs[entry.obj] = nil
        end

        _machineData[machineIndex]      = nil
        _occupiedMachines[machineIndex] = nil
    end

    _zoneMachines[zoneId] = nil
end

local function initZones()
    for zoneId, zoneCfg in ipairs(Config.Zones) do
        local handle = lib.zones.sphere({
            coords  = zoneCfg.coords,
            radius  = zoneCfg.radius,
            debug   = Config.Debug,
            onEnter = function()
                CreateThread(function()
                    Wait(500)
                    onZoneEnter(zoneId, zoneCfg)
                end)
            end,
            onExit  = function()
                onZoneExit(zoneId)
            end,
        })

        _zoneHandles[zoneId] = handle

        dbg(("initZones — zone %d '%s' created, r=%.1f"):format(zoneId, zoneCfg.label, zoneCfg.radius))
    end
end

local function destroyZones()
    for zoneId, handle in pairs(_zoneHandles) do
        if handle and handle.remove then
            handle:remove()
        end
        onZoneExit(zoneId)
    end
    _zoneHandles = {}
end

local function startKeyboardFallback()
    if HAS_OX_TARGET then return end

    CreateThread(function()
        while true do
            local playerCoords = GetEntityCoords(cache.ped)
            local bestIdx      = nil
            local bestDist     = math.huge

            for _, machines in pairs(_zoneMachines) do
                for machineIndex, entry in pairs(machines) do
                    if DoesEntityExist(entry.obj) then
                        local d = #(playerCoords - GetEntityCoords(entry.obj))
                        if d < bestDist then
                            bestDist = d
                            bestIdx  = machineIndex
                        end
                    end
                end
            end

            for _, machineIndex in pairs(_runtimeMachines) do
                local data = _machineData[machineIndex]
                if data and DoesEntityExist(data.obj) then
                    local d = #(playerCoords - GetEntityCoords(data.obj))
                    if d < bestDist then
                        bestDist = d
                        bestIdx  = machineIndex
                    end
                end
            end

            if bestIdx and bestDist <= Config.InteractDistance then
                local lbl = (_machineData[bestIdx] and _machineData[bestIdx].label) or "Slot Gép"

                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName(("Press ~INPUT_CONTEXT~ to use %s"):format(lbl))
                EndTextCommandDisplayHelp(0, false, true, -1)

                if IsControlJustPressed(0, 38) and _useCallback then
                    if _occupiedMachines[bestIdx] then
                        lib.notify({
                            title       = "Slot Gép",
                            description = "Ez a gép már foglalt!",
                            type        = "error",
                        })
                    else
                        local chairData = buildChairData(bestIdx)
                        if chairData then
                            _useCallback(chairData)
                        end
                    end
                end

                Wait(0)
            else
                Wait(500)
            end
        end
    end)
end

function SlotWorld:RegisterRuntimeMachine(obj, label, heading)
    assert(DoesEntityExist(obj), "RegisterRuntimeMachine: entity does not exist")

    local idx                    = _nextMachineIndex
    _nextMachineIndex            = _nextMachineIndex + 1

    _machineData[idx]            = buildMachineData(obj, label)
    _spawnedByUs[obj]            = true

    local targetName             = registerTarget(idx, obj, label)
    local runtimeZoneId          = "runtime_" .. idx
    _zoneMachines[runtimeZoneId] = {
        [idx] = { obj = obj, targetName = targetName }
    }

    dbg(("RegisterRuntimeMachine — obj=%d, idx=%d, label=%s"):format(obj, idx, label or "?"))
    return idx
end

function SlotWorld:RegisterRuntimeMachineByNetId(netId, label, heading)
    local deadline = GetGameTimer() + 10000

    while not NetworkDoesEntityExistWithNetworkId(netId) do
        if GetGameTimer() > deadline then
            dbg(("RegisterRuntimeMachineByNetId — timed out waiting for netId=%d"):format(netId))
            return nil
        end
        Wait(50)
    end

    local obj   = NetworkGetEntityFromNetworkId(netId)
    local extra = GetGameTimer() + 2000

    while not DoesEntityExist(obj) do
        if GetGameTimer() > extra then
            dbg(("RegisterRuntimeMachineByNetId — entity invalid for netId=%d"):format(netId))
            return nil
        end
        Wait(50)
    end

    local idx               = SlotWorld:RegisterRuntimeMachine(obj, label, heading)
    _runtimeMachines[netId] = idx

    dbg(("RegisterRuntimeMachineByNetId — netId=%d, obj=%d, idx=%d"):format(netId, obj, idx))
    return idx
end

function SlotWorld:UnregisterRuntimeMachineByNetId(netId)
    local idx = _runtimeMachines[netId]
    if not idx then
        dbg(("UnregisterRuntimeMachineByNetId — netId=%d not tracked"):format(netId))
        return
    end

    local runtimeZoneId = "runtime_" .. idx
    local machines      = _zoneMachines[runtimeZoneId]

    if machines then
        for machineIndex, entry in pairs(machines) do
            removeTarget(entry.obj, entry.targetName)

            if _spawnedByUs[entry.obj] then
                if DoesEntityExist(entry.obj) then
                    SetEntityAsMissionEntity(entry.obj, false, true)
                    DeleteObject(entry.obj)
                end
                _spawnedByUs[entry.obj] = nil
            end

            _machineData[machineIndex]      = nil
            _occupiedMachines[machineIndex] = nil
        end
        _zoneMachines[runtimeZoneId] = nil
    end

    _runtimeMachines[netId] = nil

    dbg(("UnregisterRuntimeMachineByNetId — netId=%d, idx=%d removed"):format(netId, idx))
end

RegisterNetEvent("mate-slot:world:machineSpawned")
AddEventHandler("mate-slot:world:machineSpawned", function(netId, label, heading)
    CreateThread(function()
        SlotWorld:RegisterRuntimeMachineByNetId(netId, label, heading)
    end)
end)

RegisterNetEvent("mate-slot:world:machineDeleted")
AddEventHandler("mate-slot:world:machineDeleted", function(netId)
    SlotWorld:UnregisterRuntimeMachineByNetId(netId)
end)

function SlotWorld:SetUseCallback(fn)
    _useCallback = fn
end

function SlotWorld:GetMachineIndexByNetId(netId)
    return _runtimeMachines[netId]
end

function SlotWorld:FindClosestMachine()
    local playerCoords = GetEntityCoords(cache.ped)
    local bestObj      = nil
    local bestModel    = nil
    local bestIdx      = 0
    local bestDist     = math.huge

    for _, machines in pairs(_zoneMachines) do
        for machineIndex, entry in pairs(machines) do
            if DoesEntityExist(entry.obj) then
                local d = #(playerCoords - GetEntityCoords(entry.obj))
                if d < bestDist then
                    bestDist  = d
                    bestObj   = entry.obj
                    bestModel = GetEntityModel(entry.obj)
                    bestIdx   = machineIndex
                end
            end
        end
    end

    return bestObj, bestModel, bestIdx, bestDist
end

function SlotWorld:BuildChairData(machineIndex)
    return buildChairData(machineIndex)
end

---@param machineIndex number
---@param occupied boolean
---@param occupantServerId? number
function SlotWorld:SetMachineOccupied(machineIndex, occupied, occupantServerId)
    _occupiedMachines[machineIndex] = occupied == true

    if occupied and occupantServerId then
        _machineOwners[machineIndex] = occupantServerId
    else
        _machineOwners[machineIndex] = nil
    end

    dbg(("SetMachineOccupied — idx=%d, occupied=%s, owner=%s"):format(
        machineIndex,
        tostring(occupied),
        tostring(occupantServerId or "nil")
    ))
end

---@param machineIndex number
---@return boolean
function SlotWorld:IsMachineOccupied(machineIndex)
    return _occupiedMachines[machineIndex] == true
end

---@param machineIndex number
---@return number|nil
function SlotWorld:GetMachineOwner(machineIndex)
    return _machineOwners[machineIndex]
end

function SlotWorld:Cleanup()
    destroyZones()

    for obj in pairs(_spawnedByUs) do
        if DoesEntityExist(obj) then
            SetEntityAsMissionEntity(obj, false, true)
            DeleteObject(obj)
        end
    end

    _spawnedByUs      = {}
    _occupiedMachines = {}
    _machineOwners    = {}
    _machineData      = {}
    _zoneMachines     = {}
    _runtimeMachines  = {}

    dbg("Cleanup complete")
end

RegisterNetEvent("mate-slot:world:machineOccupied")
AddEventHandler("mate-slot:world:machineOccupied", function(machineIndex, occupied, occupantServerId)
    SlotWorld:SetMachineOccupied(machineIndex, occupied, occupantServerId)

    dbg(("machineOccupied broadcast — idx=%d, occupied=%s, owner=%s"):format(
        machineIndex,
        tostring(occupied),
        tostring(occupantServerId or "nil")
    ))
end)

function SlotWorld:Init()
    initZones()
    startKeyboardFallback()

    dbg(("Init complete — %d zone(s), ox_target=%s"):format(#Config.Zones, tostring(HAS_OX_TARGET)))
end
