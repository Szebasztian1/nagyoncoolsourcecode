local config = require 'shared.config'

local activeMission = nil
local missionBlip = nil
local missionRadius = nil
local missionNPCs = {}
local missionArea = nil
local isMonitoring = false
local relationGroup = nil
local isActionBlocked = false

local function openUI()
    SendNUIMessage({ action = "setVisible", data = true })
    SetNuiFocus(true, true)
end

local function closeUI()
    SendNUIMessage({ action = "setVisible", data = false })
    SetNuiFocus(false, false)
end

local function refreshUI()
    SendNUIMessage({ action = "refreshMissions", data = true })
end

local function setupRelations()
    if not relationGroup then
        AddRelationshipGroup("MISSION_NPCS")
        relationGroup = GetHashKey("MISSION_NPCS")
        SetRelationshipBetweenGroups(0, relationGroup, relationGroup)
        SetRelationshipBetweenGroups(5, relationGroup, GetHashKey("PLAYER"))
    end
end

local function createBlips(location, radius)
    missionBlip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(missionBlip, 84)
    SetBlipColour(missionBlip, 1)
    SetBlipScale(missionBlip, 1.0)
    SetBlipAsShortRange(missionBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Célpont helye")
    EndTextCommandSetBlipName(missionBlip)

    missionRadius = AddBlipForRadius(location.x, location.y, location.z, radius)
    SetBlipColour(missionRadius, 1)
    SetBlipAlpha(missionRadius, 128)

    missionArea = {
        x = location.x,
        y = location.y,
        z = location.z,
        radius = radius
    }
end

local function removeBlips()
    if missionBlip then
        RemoveBlip(missionBlip)
        missionBlip = nil
    end

    if missionRadius then
        RemoveBlip(missionRadius)
        missionRadius = nil
    end

    missionArea = nil
end

local function cleanupLocalNPCData()
    for _, npc in ipairs(missionNPCs) do
        if npc.blip and DoesBlipExist(npc.blip) then
            RemoveBlip(npc.blip)
        end
    end
    missionNPCs = {}
end

local function createNPCBlip(ped, label)
    local blip = AddBlipForEntity(ped)
    SetBlipSprite(blip, 433)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function cleanup()
    removeBlips()
    cleanupLocalNPCData()
    activeMission = nil
    isMonitoring = false
    if relationGroup then
        SetRelationshipBetweenGroups(1, relationGroup, relationGroup)
        relationGroup = nil
    end
end

local function startMonitoring()
    if isMonitoring then return end
    isMonitoring = true

    CreateThread(function()
        while isMonitoring and activeMission do
            for i, npc in ipairs(missionNPCs) do
                if DoesEntityExist(npc.ped) then
                    if not npc.dead and IsEntityDead(npc.ped) then
                        npc.dead = true
                        if npc.blip and DoesBlipExist(npc.blip) then
                            RemoveBlip(npc.blip)
                            npc.blip = nil
                        end
                        TriggerServerEvent('bc_hitman:server:reportEntityDeath', npc.netId)
                    end
                end
            end
            Wait(1000)
        end
        isMonitoring = false
    end)
end

local function startProximityCheck()
    if not activeMission or not missionArea then return end

    CreateThread(function()
        local entitiesRequested = false

        while activeMission and missionArea and not entitiesRequested do
            local playerCoords = GetEntityCoords(cache.ped)
            local distance = #(vector3(missionArea.x, missionArea.y, missionArea.z) - playerCoords)

            if distance <= 120.0 then
                TriggerServerEvent('bc_hitman:server:requestMissionEntities', activeMission.id, missionArea)
                entitiesRequested = true

                lib.notify({
                    title = 'Célpont közelében',
                    description = 'Célpontok a közelben! Légy óvatos!',
                    type = 'inform',
                    duration = 3000
                })
            end

            Wait(1000)
        end
    end)
end

local function initMission(data)
    cleanup()
    activeMission = data

    local location = data.location

    createBlips(location, 100.0)
    setupRelations()

    missionArea = {
        x = location.x,
        y = location.y,
        z = location.z,
        radius = 100.0
    }

    startProximityCheck()

    lib.notify({
        title = 'Küldetés elkezdve',
        description = 'Menj a jelzett helyre és iktasd ki a célpontokat. A célpontoknál piros pont jelzi őket.',
        type = 'inform',
        duration = 5000
    })
end

AddStateBagChangeHandler("configNPC", nil, function(bagName, key, value)
    if value.source ~= cache.serverId then return end
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then return end

    SetPedMaxHealth(entity, value.health)
    SetEntityHealth(entity, value.health)
    SetPedSuffersCriticalHits(entity, false)

    SetPedCombatAttributes(entity, 46, true)
    SetPedCombatAttributes(entity, 5, true)
    SetPedCombatAttributes(entity, 58, true)
    SetPedCombatAbility(entity, 100)
    SetPedCombatMovement(entity, 3)
    SetPedCombatRange(entity, 2)
    SetPedKeepTask(entity, true)

    local blip = createNPCBlip(entity, "Célpont")

    table.insert(missionNPCs, {
        ped = entity,
        netId = NetworkGetNetworkIdFromEntity(entity),
        blip = blip,
        dead = false
    })
end)

RegisterNetEvent('bc_hitman:client:configureNPC', function(netId, npcData, index)
    local ped = NetToPed(netId)

    if not DoesEntityExist(ped) then
        Wait(1000)
        ped = NetToPed(netId)
        if not DoesEntityExist(ped) then
            return
        end
    end

    NetworkRequestControlOfEntity(ped)
    while NetworkGetEntityOwner(ped) ~= cache.playerId do
        Wait(0)
    end

    SetPedMaxHealth(ped, npcData.health)
    SetEntityHealth(ped, npcData.health)
    SetPedSuffersCriticalHits(ped, false)

    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatAttributes(ped, 58, true)
    SetPedCombatAbility(ped, 100)
    SetPedCombatMovement(ped, 3)
    SetPedCombatRange(ped, 2)
    SetPedKeepTask(ped, true)

    GiveWeaponToPed(ped, GetHashKey(npcData.weapon), 999, false, true)
    TaskCombatPed(ped, cache.ped, 0, 16)

    local blip = createNPCBlip(ped, "Célpont " .. index)

    table.insert(missionNPCs, {
        ped = ped,
        netId = netId,
        blip = blip,
        dead = false
    })
end)

RegisterNetEvent('bc_hitman:client:entitiesSpawned', function(missionId)
    startMonitoring()
end)

RegisterNetEvent('bc_hitman:client:entitiesCleanedUp', function()
    cleanupLocalNPCData()
end)

RegisterNetEvent('bc_hitman:client:missionCompleted', function()
    removeBlips()
    cleanupLocalNPCData()
    activeMission = nil
end)

RegisterNUICallback('close', function(body, cb)
    closeUI()
    cb('ok')
end)

lib.callback.register('bc_hitman:callback:getGroundZ', function(x, y)
    local groundZ = 0.0
    local found = false

    for z = 1000.0, -500.0, -25.0 do
        local success, zPos = GetGroundZFor_3dCoord(x, y, z, true)
        if success then
            groundZ = zPos
            found = true
            break
        end
        Wait(0)
    end

    if not found then
        return false
    end

    return groundZ + 1.0
end)

RegisterNUICallback('getCurrentWorks', function(body, cb)
    local works = lib.callback.await('bc_hitman:callback:getWorks')
    cb(works)
end)

RegisterNUICallback('missionSelected', function(body, cb)
    if isActionBlocked then
        lib.notify({
            title = 'Hitman',
            description = 'Kérlek várj egy kicsit.',
            type = 'inform',
            duration = 5000
        })
        return
    end

    isActionBlocked = true

    SetTimeout(5000, function()
        isActionBlocked = false
    end)

    local result = lib.callback.await('bc_hitman:callback:activateMission', false, body.id)

    if result.success then
        lib.notify({
            title = 'Küldetés elfogadva',
            description = 'A küldetést sikeresen elfogadtad.',
            type = 'success'
        })

        refreshUI()
        closeUI()

        local missionData = lib.callback.await('bc_hitman:callback:getMissionData', false, body.id)
        if missionData then
            initMission(missionData)
        end
    else
        lib.notify({
            title = 'Küldetés hiba',
            description = result.message,
            type = 'error'
        })
    end

    cb(result)
end)

RegisterNUICallback('cancelMission', function(body, cb)
    if isActionBlocked then
        lib.notify({
            title = 'Hitman',
            description = 'Kérlek várj egy kicsit.',
            type = 'inform',
            duration = 5000
        })
        return
    end

    isActionBlocked = true

    SetTimeout(5000, function()
        isActionBlocked = false
    end)

    local result = lib.callback.await('bc_hitman:callback:cancelMission', false, body.id)

    if result.success then
        lib.notify({
            title = 'Küldetés lemondva',
            description = 'A küldetést sikeresen lemondtad.',
            type = 'success'
        })

        refreshUI()
        cleanup()
    else
        lib.notify({
            title = 'Lemondás hiba',
            description = result.message,
            type = 'error'
        })
    end

    cb(result)
end)

RegisterNetEvent('bc_hitman:client:refreshMissions', function()
    refreshUI()
end)

RegisterNetEvent('bc_hitman:client:missionExpired', function(missionName)
    lib.notify({
        title = 'Küldetés lejárt',
        description = 'A' .. missionName .. ' küldetés lejárt.',
        type = 'error',
        duration = 7000
    })

    refreshUI()
    if activeMission then
        cleanup()
    end
end)

RegisterNetEvent('bc_hitman:client:cleanupMission', function()
    cleanup()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    cleanup()
end)

exports('openUI', openUI)
exports('closeUI', closeUI)
