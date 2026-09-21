local config = require 'shared.config'

local previewObject = false
local object = nil

local tryConnectData = {
    apptitle = "Rádió",
    title = "Rádió blokkolva",
    message = "Nem csatlakozhatsz rádióhoz ,mivel rádiózavar alatt állsz!",
    img = "/public/img/Apps/radio.png"
}

local enterData = {
    apptitle = "Rádió",
    title = "Rádió blokkolva",
    message = "Rádiózavar alattt állsz ,így lecsatlakozott a rádió!",
    img = "/public/img/Apps/radio.png"
}

local pendingZones = {}
local loadedZones = {}

-- Egy netId-t csak akkor szabad lekerdezni, ha a halozati objektum tenyleg letezik.
-- Enelkul a motor minden egyes hivasnal kiirja a konzolra:
-- "[entity] GetNetworkObject: no object by ID <netId>"
local function getBlockerEntity(netId)
    if type(netId) ~= 'number' or not NetworkDoesNetworkIdExist(netId) then return nil end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return nil end

    return entity
end

-- Ennyi ido utan a soha meg nem jeleno (torolt) zona eldobja magat, hogy ne pollozzuk orokke.
local PENDING_TIMEOUT = 5 * 60 * 1000

local function stopPlacing()
    previewObject = false
    if DoesEntityExist(object) then
        DeleteEntity(object)
        object = nil
    end
    lib.hideTextUI()
end

local function placeObject()
    if previewObject or cache.vehicle then return end

    previewObject = true
    local state = 'preview'
    local rotationZ = 0.0

    lib.showTextUI('E- Lehelyezés  \n RM - Mégse  \n Scroll up - Jobbra forgatás  \n Scroll down - Balra forgatás')

    lib.requestModel(config.model)

    local _, _, coords, normalSurface = lib.raycast.fromCamera(1, 4, 10)

    object = CreateObjectNoOffset(config.model, coords, false, false, false)
    SetEntityAlpha(object, 150, false)
    SetEntityCollision(object, false, false)
    SetEntityRotation(object, lib.math.normaltorotation(normalSurface), 1)

    while previewObject do
        if cache.vehicle or not object then
            stopPlacing()
            break
        end

        DisablePlayerFiring(cache.ped, true)
        DisableControlAction(0, 38, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 175, true)
        DisableControlAction(0, 174, true)

        if state == 'moving' then
            DisableControlAction(0, 21, true)
        end

        if state == 'preview' then
            local _, _, coords, normalSurface = lib.raycast.fromCamera(1, 4, 10)

            local min, max = GetModelDimensions(config.model)
            local objectHeight = math.abs(min.z - max.z) / 2

            local adjustedCoords = {
                x = coords.x + (normalSurface.x * objectHeight),
                y = coords.y + (normalSurface.y * objectHeight),
                z = coords.z + (normalSurface.z * objectHeight)
            }

            SetEntityCoords(object, adjustedCoords.x, adjustedCoords.y, adjustedCoords.z, 0, 0, 0, false)

            local baseRotation = lib.math.normaltorotation(normalSurface)
            if IsDisabledControlPressed(0, 180) then
                rotationZ = rotationZ + 2.0
            elseif IsDisabledControlPressed(0, 181) then
                rotationZ = rotationZ - 2.0
            end

            SetEntityRotation(object, baseRotation.x, baseRotation.y, baseRotation.z + rotationZ, 1, true)

            if IsDisabledControlJustPressed(0, 25) then
                stopPlacing()
                break
            elseif IsDisabledControlJustPressed(0, 38) then
                state = 'moving'
                local distance = #(GetEntityCoords(cache.ped) - vec3(adjustedCoords.x, adjustedCoords.y, adjustedCoords.z))
                if distance > 1.4 then
                    TaskGoToEntity(cache.ped, object, -1, 1.0, 1.0, 1073741824, 0)
                else
                    state = 'placing'
                end
            end
        elseif state == 'moving' then
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            DisableControlAction(0, 22, true)

            local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(object))
            if distance <= 1.4 then
                state = 'placing'
            end
        elseif state == 'placing' then
            if lib.progressBar({
                    duration = config.place_duration,
                    label = 'Lehelyezés...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        combat = true,
                        mouse = true,
                        car = true,
                    },
                    anim = {
                        dict = config.place_animation.dict,
                        clip = config.place_animation.clip,
                        flag = 2,
                    },
                }) then
                TriggerServerEvent('bc_radioblocker:server:placeProp', config.model, GetEntityCoords(object),
                    GetEntityRotation(object))
                stopPlacing()
            else
                stopPlacing()
            end
            break
        end

        Wait(0)
    end
end

RegisterNetEvent('bc_radioblocker:client:createZone', function(netId, coords, radius)
    if type(netId) ~= 'number' or not coords then return end

    local attempts = 0
    local entityObj = nil

    while attempts < 20 do
        entityObj = getBlockerEntity(netId)
        if entityObj then
            break
        end
        attempts = attempts + 1
        Wait(100)
    end

    if not entityObj then
        pendingZones[netId] = {
            coords = coords,
            radius = radius or config.default_radius,
            since = GetGameTimer()
        }
        return
    end

    local zoneRadius = radius or config.default_radius
    local zoneId = 'radioblocker_' .. netId

    loadedZones[netId] = {
        coords = coords,
        radius = zoneRadius,
        entityObj = entityObj,
        isActive = false
    }

    local playerCoords = GetEntityCoords(cache.ped)
    local distanceToZone = #(playerCoords - coords)

    if distanceToZone <= (zoneRadius * 1.5) then
        createSphereZone(netId, coords, zoneRadius, entityObj, zoneId)
    end
end)

function createSphereZone(netId, coords, zoneRadius, entityObj, zoneId)
    if loadedZones[netId] then
        loadedZones[netId].isActive = true
    end

    local zone = lib.zones.sphere({
        coords = coords,
        radius = zoneRadius,
        debug = false,
        onEnter = function()
            if LocalPlayer.state.radioChannel ~= 0 then
                exports["roadphone"]:sendNotification(enterData)
                exports['pma-voice']:setRadioChannel(0)
            end

            local centerBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(centerBlip, 161)
            SetBlipColour(centerBlip, 0)
            SetBlipScale(centerBlip, 0.8)
            SetBlipAsShortRange(centerBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Rádió blokkoló")
            EndTextCommandSetBlipName(centerBlip)

            local blip = AddBlipForRadius(coords.x, coords.y, coords.z, zoneRadius + 0.0)
            SetBlipHighDetail(blip, true)
            SetBlipColour(blip, 1)
            SetBlipAlpha(blip, 128)

            if not lib.zones.data[zoneId].blips then
                lib.zones.data[zoneId].blips = {}
            end
            lib.zones.data[zoneId].blips.area = blip
            lib.zones.data[zoneId].blips.center = centerBlip

            exports.ox_target:addLocalEntity(entityObj, {
                {
                    name = 'pickup_radioblocker',
                    icon = 'fas fa-hand-rock',
                    label = 'Felvétel',
                    onSelect = function()
                        local playerJob = ESX.GetPlayerData().job.name
                        local isJobAllowed = false

                        for _, job in ipairs(config.allowedJobs) do
                            if playerJob == job then
                                isJobAllowed = true
                                break
                            end
                        end

                        if not isJobAllowed then
                            lib.notify({
                                title = 'Blokker',
                                description = 'Nincs jogosultságod felvenni ezt az eszközt',
                                type = 'error'
                            })
                            return
                        end

                        if lib.progressBar({
                                duration = 2000,
                                label = 'Rádió felvétele...',
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    move = true,
                                    combat = true,
                                    mouse = false,
                                    car = true,
                                },
                                anim = {
                                    dict = 'pickup_object',
                                    clip = 'pickup_low',
                                    flag = 49,
                                },
                            }) then
                            TriggerServerEvent('bc_radioblocker:server:pickupRadio', netId)

                            lib.notify({
                                title = 'Blokker',
                                description = 'Eszköz felvéve',
                                type = 'success'
                            })
                        end
                    end,
                    distance = 2.0
                },
                {
                    name = 'destroy_radioblocker',
                    icon = 'fas fa-hammer',
                    label = 'Széttörés',
                    onSelect = function()
                        if lib.progressBar({
                                duration = config.break_duration,
                                label = 'Eszköz széttörése...',
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    move = true,
                                    combat = true,
                                    mouse = false,
                                    car = true,
                                },
                                anim = {
                                    dict = config.break_animation.dict,
                                    clip = config.break_animation.clip,
                                    flag = 1,
                                },
                            }) then
                            TriggerServerEvent('bc_radioblocker:server:breakRadio', netId)
                        end
                    end,
                    distance = 2.0
                },
                {
                    name = 'modify_radius_radioblocker',
                    icon = 'fas fa-expand-arrows-alt',
                    label = 'Rádiusz módosítás',
                    onSelect = function()
                        local playerJob = ESX.GetPlayerData().job.name
                        local isJobAllowed = false

                        for _, job in ipairs(config.allowedJobs) do
                            if playerJob == job then
                                isJobAllowed = true
                                break
                            end
                        end

                        if not isJobAllowed then
                            lib.notify({
                                title = 'Blokker',
                                description = 'Nincs jogosultságod módosítani a eszköz rádiuszát',
                                type = 'error'
                            })
                            return
                        end

                        local input = lib.inputDialog('Rádiusz módosítása', {
                            {
                                type = 'slider',
                                label = 'Rádiusz (méter)',
                                default = zoneRadius,
                                min = config.min_radius,
                                max = config.max_radius,
                                step = 5
                            }
                        })

                        if input and input[1] then
                            local newRadius = input[1]
                            TriggerServerEvent('bc_radioblocker:server:updateRadius', netId, newRadius)
                            lib.notify({
                                title = 'Blokker',
                                description = 'Rádiusz módosítva ' .. newRadius .. ' méterre',
                                type = 'success'
                            })
                        end
                    end,
                    distance = 2.0
                }
            })

            LocalPlayer.state:set('inRadioBlock', true, true)
        end,
        onExit = function()
            if lib.zones.data[zoneId] and lib.zones.data[zoneId].blips then
                if lib.zones.data[zoneId].blips.area then
                    RemoveBlip(lib.zones.data[zoneId].blips.area)
                end
                if lib.zones.data[zoneId].blips.center then
                    RemoveBlip(lib.zones.data[zoneId].blips.center)
                end
                lib.zones.data[zoneId].blips = nil
            end

            exports.ox_target:removeLocalEntity(entityObj)

            LocalPlayer.state:set('inRadioBlock', false, true)
        end
    })

    if not lib.zones.data then lib.zones.data = {} end
    lib.zones.data[zoneId] = {
        zone = zone,
        entity = entityObj,
    }
end

RegisterNetEvent('bc_radioblocker:client:removeZone', function(netId)
    local zoneId = 'radioblocker_' .. netId
    local zoneData = lib.zones.data and lib.zones.data[zoneId]

    if zoneData then
        if zoneData.blips then
            if zoneData.blips.area then
                RemoveBlip(zoneData.blips.area)
            end
            if zoneData.blips.center then
                RemoveBlip(zoneData.blips.center)
            end
        end

        if zoneData.zone then
            local playerCoords = GetEntityCoords(cache.ped)
            if #(playerCoords - zoneData.zone.coords) < zoneData.zone.radius then
                LocalPlayer.state:set('inRadioBlock', false, true)
            end

            zoneData.zone:remove()

            if DoesEntityExist(zoneData.entity) then
                exports.ox_target:removeLocalEntity(zoneData.entity)
            end

            lib.zones.data[zoneId] = nil
        end
    end

    pendingZones[netId] = nil
    loadedZones[netId] = nil
end)

RegisterNetEvent('bc_radioblocker:client:syncAllRadioblockers', function(blockers)
    for _, data in pairs(blockers) do
        TriggerEvent('bc_radioblocker:client:createZone', data.netId, data.coords, data.radius)
    end
end)

RegisterNetEvent('bc_radioblocker:client:updateRadius', function(netId, newRadius)
    local zoneId = 'radioblocker_' .. netId
    local zoneData = lib.zones.data and lib.zones.data[zoneId]

    if loadedZones[netId] then
        loadedZones[netId].radius = newRadius
    elseif pendingZones[netId] then
        pendingZones[netId].radius = newRadius
    else
        pendingZones[netId] = {
            coords = nil,
            radius = newRadius,
            since = GetGameTimer()
        }
        TriggerServerEvent('bc_radioblocker:server:requestBlockerInfo', netId)
        return
    end
    if zoneData and zoneData.zone then
        local entityObj = zoneData.entity
        local oldZone = zoneData.zone
        local coords = oldZone.coords

        oldZone:remove()

        if zoneData.blips then
            if zoneData.blips.area then
                RemoveBlip(zoneData.blips.area)
            end
            if zoneData.blips.center then
                RemoveBlip(zoneData.blips.center)
            end
        end
        createSphereZone(netId, coords, newRadius, entityObj, zoneId)
    end
end)

RegisterNetEvent('bc_radioblocker:client:receiveBlockerInfo', function(netId, data)
    if not data or not data.coords then return end

    if pendingZones[netId] and not pendingZones[netId].coords then
        pendingZones[netId].coords = data.coords
        pendingZones[netId].radius = data.radius or pendingZones[netId].radius
    end
end)

CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(cache.ped)
        local nearAnyPending = false

        for netId, data in pairs(pendingZones) do
            local expired = GetGameTimer() - (data.since or 0) > PENDING_TIMEOUT

            if not data.coords then
                -- meg nem tudjuk, hol van; ha nem jott valasz ra, dobjuk el
                if expired then
                    pendingZones[netId] = nil
                end
            elseif #(playerCoords - data.coords) <= (data.radius * 1.5) then
                local entityObj = getBlockerEntity(netId)

                if entityObj then
                    pendingZones[netId] = nil
                    local zoneId = 'radioblocker_' .. netId
                    createSphereZone(netId, data.coords, data.radius, entityObj, zoneId)

                    loadedZones[netId] = {
                        coords = data.coords,
                        radius = data.radius,
                        entityObj = entityObj,
                        isActive = true
                    }
                elseif expired then
                    -- az objektum mar nem letezik (felvettek / eltortek / takaritas)
                    pendingZones[netId] = nil
                else
                    nearAnyPending = true
                end
            end
        end

        for netId, data in pairs(loadedZones) do
            if not data.isActive then
                local distanceToZone = #(playerCoords - data.coords)

                if distanceToZone <= (data.radius * 1.5) then
                    -- a mentett entity handle ervenytelenne valhat, ha az objektum kikerult a korzetbol
                    local entityObj = getBlockerEntity(netId)

                    if not entityObj and data.entityObj and DoesEntityExist(data.entityObj) then
                        entityObj = data.entityObj
                    end

                    if entityObj then
                        data.entityObj = entityObj
                        createSphereZone(netId, data.coords, data.radius, entityObj, 'radioblocker_' .. netId)
                        nearAnyPending = true
                    end
                end
            end
        end

        Wait(nearAnyPending and 1000 or 5000)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    Wait(1000)
    TriggerServerEvent('bc_radioblocker:server:requestAllRadioblockers')
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    pendingZones = {}
    loadedZones = {}
    TriggerServerEvent('bc_radioblocker:server:requestAllRadioblockers')
end)

AddStateBagChangeHandler("radioChannel", ('player:%s'):format(cache.serverId), function(bagName, key, value)
    if LocalPlayer.state.inRadioBlock and value ~= 0 then
        exports["roadphone"]:sendNotification(tryConnectData)
        exports['pma-voice']:setRadioChannel(0)
    end
end)

exports('placeBlocker', placeObject)
