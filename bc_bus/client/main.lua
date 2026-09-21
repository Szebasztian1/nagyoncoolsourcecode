local peds, blips, busStops = {}, {}, {}
local inJob = false
StopsDone = 0
ServiceCar = 0


local function initNewPoint(v)
    local currentStop = nil
    local doneWithCurrent = false

    local stops = v.busStops
    for k, v in pairs(stops) do
        if not v.done then
            currentStop = v
            break
        end
    end

    if not currentStop then
        ESX.ShowNotification(Config.translations["nomorestops"], 5000, "error")
        SetNewWaypoint(v.deleteCars.coords.x, v.deleteCars.coords.y)
        return
    end

    local stationBlip = AddBlipForCoord(currentStop.coords.xyz)
    SetBlipSprite(stationBlip, Config.blipSettings.busstop.sprite)
    SetBlipDisplay(stationBlip, 2)
    SetBlipColour(stationBlip, Config.blipSettings.busstop.color)
    SetBlipScale(stationBlip, Config.blipSettings.busstop.size)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.blipSettings.busstop.label)
    EndTextCommandSetBlipName(stationBlip)
    SetBlipRoute(stationBlip, true)
    SetBlipRouteColour(stationBlip, 46)
    busStops[#busStops + 1] = { type = "blip", value = stationBlip }
    local busStop = lib.zones.sphere({

        coords = currentStop.coords,
        distance = 5,
        radius = 5,
        debug = false
    })
    busStops[#busStops + 1] = { type = "zone", value = busStop }

    function busStop:onEnter()
        if not cache.vehicle or cache.vehicle ~= ServiceCar then
            ESX.ShowNotification(Config.translations["notinservicecar"], 5000, "error")
            return
        end
        ESX.ShowNotification(Config.translations["waitforpassengers"], 5000, "info")
        FreezeEntityPosition(ServiceCar, true)
        if lib.progressBar({
                duration = 4000,
                label = Config.translations["passengersboarding"],
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true
                },

            }) then
            currentStop.done = true
            currentStop = nil
            ESX.ShowNotification(Config.translations["passengersboarded"], 5000, "success")
            RemoveBlip(stationBlip)
            busStop:remove()

            StopsDone += 1

            Wait(50)
            initNewPoint(v)
            FreezeEntityPosition(ServiceCar, false)
        end
    end
end

local function startJob(v)
    local isClear = ESX.Game.IsSpawnPointClear(v.spawnPoint, 10)
    if not isClear then return ESX.ShowNotification("Valaki áll a garázs előtt, ahova kiálnál a busszal!", 5000, "error") end
    ESX.Game.SpawnVehicle(Config.busModel, vec3(v.spawnPoint.x, v.spawnPoint.y, v.spawnPoint.z), v.spawnPoint.w,
        function(veh)
            if DoesEntityExist(veh) then
                ServiceCar = veh
                SetPedIntoVehicle(cache.ped, veh, -1)
                inJob = true
                initNewPoint(v)
            end
        end)
end



local function drawEndJobPoint(v)
    local deleteZone = lib.zones.box({
        coords = v.deleteCars.coords,
        size = v.deleteCars.size,
        rotation = v.deleteCars.rotation,
        debug = false
    })

    local delBlip = AddBlipForCoord(v.deleteCars.coords.xyz)
    SetBlipSprite(delBlip, Config.blipSettings.sprite)
    SetBlipDisplay(delBlip, 2)
    SetBlipColour(delBlip, 59)

    SetBlipScale(delBlip, Config.blipSettings.size)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Buszos munka leadó")
    EndTextCommandSetBlipName(delBlip)


    function deleteZone:onEnter()
        -- kibasszuk a textUI-t
        lib.showTextUI(Config.translations["endjob"], {
            icon = "fa-solid fa-x"
        })
    end

    function deleteZone:inside()
        if IsControlJustPressed(0, 38) then -- toroljuk a verdat ha benne ul meg a zonet is
            local de = GetVehiclePedIsIn(PlayerPedId(), false)
            -- if de and (not cache.vehicle or cache.vehicle ~= ServiceCar) then
            --     ESX.ShowNotification(Config.translations["notinservicecar"])
            --     return
            -- end

            --if de == ServiceCar then
            if GetEntityModel(de) == GetHashKey(Config.busModel) then
                exports["gs_eventprotect"]:GS_TriggerServerEvent('givethingy', StopsDone)
            else
                ESX.ShowNotification("Busz nélkül nincs fizettség!")
            end

            inJob = false
            ESX.Game.DeleteVehicle(ServiceCar)

            RemoveBlip(delBlip)
            deleteZone:remove()
            lib.hideTextUI() --kibasszuk a textuit ha megy

            for k, v in pairs(busStops) do
                if v.type == "blip" then
                    RemoveBlip(v.value)
                else
                    v.value:remove()
                end
            end
        end
    end

    function deleteZone:onExit()
        local isOpen, _ = lib.isTextUIOpen()
        if isOpen then
            lib.hideTextUI() --kibasszuk a textuit ha megy
        end
    end
end

local function openMenu(v, levelData)
    lib.registerContext({
        id = 'busmenu',
        title = Config.translations["lib_title"],
        options = {
            {
                title = string.format(Config.translations["currenlevel"], levelData.level),
                description = string.format(Config.translations["tonextlevel"], levelData.xpToLevel),
                progress = levelData.xpPercentage,
                colorScheme = 'green.4',
                readOnly = true
            },
            {
                title = Config.translations["startjoblib"],
                description = 'Kezdj el melózni, hogy keress pénzt!',
                icon = 'hand',
                onSelect = function()
                    StopsDone = 0
                    local stops = v.busStops
                    for i, j in pairs(stops) do
                        v.busStops[i].done = false
                    end
                    startJob(v)
                    drawEndJobPoint(v)
                end
            }
        }
    })

    lib.showContext('busmenu')
end


local function createStations()
    for k, v in pairs(Config.busStations) do
        local blip = AddBlipForCoord(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z)
        blips[#blips + 1] = blip
        SetBlipSprite(blip, Config.blipSettings.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, Config.blipSettings.color)
        SetBlipScale(blip, Config.blipSettings.size)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.label)
        EndTextCommandSetBlipName(blip)
        MunkaBlip('buszallomas', blip)

        lib.zones.sphere({
            coords = vec3(v.pedCoords.x, v.pedCoords.y, v.pedCoords.z),
            distance = 50.0,
            radius = 50.0,
            debug = false,
            onEnter = function()
                RequestModel(Config.pedModel)
                while not HasModelLoaded(Config.pedModel) do
                    Wait(200)
                end
                local ped = CreatePed(2, Config.pedModel, v.pedCoords.x, v.pedCoords.y, v.pedCoords.z, v.pedCoords.w,
                    false, false)
                peds[k] = ped
                FreezeEntityPosition(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetEntityInvincible(ped, true)
                exports.ox_target:addLocalEntity(ped, {
                    name = k,
                    icon = "fa-solid fa-briefcase",
                    label = Config.translations["startjob"],
                    distance = 3,
                    canInteract = function()
                        return inJob ~= true
                    end,
                    onSelect = function()
                        local data = lib.callback.await('getPlayerData', 100)
                        openMenu(v, data)
                    end
                })
            end,
            onExit = function()
                if peds[k] then
                    exports.ox_target:removeLocalEntity(peds[k], k)
                    DeleteEntity(peds[k])
                    peds[k] = nil
                end
            end
        })
    end
end

local loaded = true
AddEventHandler("playerSpawned", function()
    loaded = true
end)

CreateThread(function()
    while not loaded do
        Wait(100)
    end
    Wait(10000)
    createStations()
end)


AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    inJob = false
    for k, v in pairs(peds) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
        end
        peds[k] = nil
    end
    for k, v in pairs(blips) do
        RemoveBlip(v)
        blips[k] = nil
    end

    if DoesEntityExist(ServiceCar) then
        DeleteEntity(ServiceCar)
    end
end)
