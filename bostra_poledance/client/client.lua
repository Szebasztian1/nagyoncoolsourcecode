local polePoints = {}
local poleProps = {}
local modelTargs = {}
local isDancing = false
local Config = require 'config.config'

lib.registerContext({
    id = 'dance_menu',
    title = 'Tánc kiválasztása',
    options = {
        { title = 'Tánc opciók' }, {
        title = 'Tánc megszakítása',
        icon = 'times',
        onSelect = function()
            isDancing = false
            ClearPedTasks(cache.ped)
        end,
    }, {
        title = 'Rúdtánc #1',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 1 }
    }, {
        title = 'Rúdtánc #2',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 2 }
    }, {
        title = 'Rúdtánc #3',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = { dance = 3 }
    }, {
        title = 'Öltánc #1',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 1,
            anim = 'lap_dance_girl',
            dict = 'mp_safehouse'
        }
    }, {
        title = 'Öltánc #2',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 2,
            anim = 'priv_dance_idle',
            dict = 'mini@strip_club@private_dance@idle'
        }
    }, {
        title = 'Öltánc #3',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 3,
            anim = 'priv_dance_p1',
            dict = 'mini@strip_club@private_dance@part1'
        }
    }, {
        title = 'Öltánc #4',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 4,
            anim = 'priv_dance_p2',
            dict = 'mini@strip_club@private_dance@part2'
        }
    }, {
        title = 'Öltánc #5',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 5,
            anim = 'priv_dance_p3',
            dict = 'mini@strip_club@private_dance@part3'
        }
    }, {
        title = 'Öltánc #6',
        icon = 'shoe-prints',
        event = 'bm_dance:start',
        args = {
            lapdance = 6,
            anim = 'yacht_ld_f',
            dict = 'oddjobs@assassinate@multi@yachttarget@lapdance'
        }
    }
    }
})

lib.addKeybind({
    name = 'cancelpoledance',
    description = 'Rúdtánc megszakítása',
    defaultKey = 'x',
    onReleased = function(self)
        if not isDancing then return end -- Ellenőrzi, hogy a játékos táncol-e vagy sem.
        isDancing = false
        ClearPedTasks(cache.ped)
    end
})

local function StartRay()
    lib.showTextUI('[E] másolás  \n[DEL] megszakítás')
    while true do
        local _, _, endCoords, _, _ = lib.raycast.cam(1, 4, 10)
        DrawMarker(21, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 255,
            255, 255, true, true, 0, false, false, false, false)
        if IsControlJustPressed(0, 38) or IsControlJustReleased(0, 38) then
            lib.hideTextUI()
            return endCoords
        elseif IsControlJustPressed(0, 178) or IsControlJustReleased(0, 178) then
            lib.hideTextUI()
            return nil
        end
        Wait(0)
    end
end

local function DestroyTargets()
    for _, pole in ipairs(polePoints) do
        if Config.Target == 'ox' then
            exports.ox_target:removeZone(pole)
            if Config.UseModels then
                for _, v in pairs(modelTargs) do
                    exports.ox_target:removeModel('prop_strip_pole_01', v)
                end
            end
        elseif Config.Target == 'qb' then
            exports['qb-target']:RemoveZone(pole)
        elseif Config.Target == 'lib' then
            pole:remove()
        end
    end
    for _, pole in ipairs(poleProps) do
        if DoesEntityExist(pole) then
            DeleteObject(pole)
            DeleteEntity(pole)
        end
    end
end

local function CreateTargets()
    DestroyTargets()
    if Config.Target == 'ox' then
        if Config.UseModels then
            local modelTarg = exports.ox_target:addModel(`prop_strip_pole_01`, {
                {
                    label = "Rúdtánc",
                    icon = "fas fa-shoe-prints",
                    distance = 3.0,
                    --offsetSize = 2.0,
                   -- offset = vec3(1, 1, 1),
                    onSelect = function() lib.showContext('dance_menu') end
                }
            })
            modelTargs[#modelTargs + 1] = modelTarg
        end

        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false,
                    false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
            local params = {
                coords = v.position,
                size = vec3(1, 1, 3) or v.size,
                rotation = v.position.w,
                debug = Config.Debug,
                options = {
                    {
                        label = 'Rúdtánc',
                        name = 'Pole' .. k,
                        icon = 'fas fa-shoe-prints',
                        distance = 3.0,
                        groups = nil or v.job,
                        onSelect = function()
                            lib.showContext('dance_menu')
                        end
                    }
                }
            }
            local poleZone = exports.ox_target:addBoxZone(params)
            polePoints[#polePoints + 1] = poleZone
        end
    elseif Config.Target == 'qb' then
        if Config.UseModels then
            exports['qb-target']:AddTargetModel('prop_strip_pole_01', {
                options = {
                    {
                        icon = 'fas fa-shoe-prints',
                        label = 'Rúdtánc',
                        action = function()
                            lib.showContext('dance_menu')
                        end
                    }
                },
                distance = 1.5
            })
        end
        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false,
                    false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
            local poleZone = exports['qb-target']:AddBoxZone('pole' .. k, v.position.xyz, 1.5, 1.5, {
                name = "pole" .. k,
                heading = v.position.w,
                debugPoly = Config.Debug,
                minZ = v.position.z - 2.0,
                maxZ = v.position.z + 2.0
            }, {
                options = {
                    {
                        icon = 'fas fa-shoe-prints',
                        label = 'Rúdtánc',
                        action = function()
                            lib.showContext('dance_menu')
                        end
                    }
                },
                distance = 2.0
            }
            )
            polePoints[#polePoints + 1] = poleZone
        end
    elseif Config.Target == 'lib' then
        for k, v in pairs(Config.Poles) do
            if v.spawn then
                lib.requestModel('prop_strip_pole_01')
                local pole = CreateObject(joaat('prop_strip_pole_01'), v.position.x, v.position.y, v.position.z, false,
                    false,
                    false)
                poleProps[#poleProps + 1] = pole
            end
            local params = {
                coords = vec3(v.position.x, v.position.y, v.position.z + 1.0),
                size = vec3(1, 1, 1),
                rotation = v.position.w,
                onEnter = function()
                    lib.showTextUI('Nyomd meg az [E] gombot a tánchoz')
                end,
                inside = function()
                    if isDancing then
                        lib.showTextUI('Nyomd meg az [X] gombot a tánc leállításához')
                        if IsControlJustPressed(0, 73) then
                            isDancing = false
                            ClearPedTasks(cache.ped)
                            lib.hideTextUI()
                            lib.showTextUI('Nyomd meg az [E] gombot a tánchoz')
                        end
                    end
                    if IsControlJustReleased(0, 38) then
                        lib.showContext('dance_menu')
                    end
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                debug = Config.Debug,
            }
            local poleZone = lib.zones.box(params)
            polePoints[#polePoints + 1] = poleZone
        end
    end
    for _, v in ipairs(Config.Poles) do
        local polePoints = lib.points.new({
            coords = v.position,
            distance = 3.0,
        })
        polePoints[#polePoints + 1] = v
    end
end

local function ToConfigFormat(poleConfig)
    local formattedConfig = "{ position = vec4(" ..
        poleConfig.position.x .. "," .. poleConfig.position.y .. "," .. poleConfig.position.z .. ",0.0),"
    if poleConfig.spawn then
        formattedConfig = formattedConfig .. " spawn = true },"
    else
        formattedConfig = formattedConfig .. " },"
    end
    return formattedConfig
end

RegisterNetEvent('bm_dance:start', function(args)
    local position = GetEntityCoords(cache.ped)
    local usePolePosition = false
    if not args.coords then args.coords = position end
    if args.dance then
        local nearbyObjects = lib.points.getClosestPoint()
        if nearbyObjects then
            isDancing = true
            local scene = NetworkCreateSynchronisedScene(nearbyObjects.coords.x + 0.07, nearbyObjects.coords.y + 0.3,
                nearbyObjects.coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(cache.ped, scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
                'pd_dance_0' .. args.dance, 1.5, -4.0, 1, 1, 1148846080, 0)
            NetworkStartSynchronisedScene(scene)
        else
            isDancing = true
            usePolePosition = true
        end
    elseif args.lapdance then
        lib.requestAnimDict(args.dict)
        TaskPlayAnim(cache.ped, args.dict, args.anim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
        isDancing = true
    else
        for _, point in ipairs(polePoints) do
            local distance = #(point.coords - GetEntityCoords(cache.ped))
            if distance <= point.distance then
                usePolePosition = true
                break
            end
        end
    end
    if usePolePosition then
        local closestPoint = lib.points.getClosestPoint()
        if closestPoint then
            if Config.Debug then print('Közel') end
            args.coords = closestPoint.coords
            isDancing = true
            local scene = NetworkCreateSynchronisedScene(args.coords.x + 0.07, args.coords.y + 0.3,
                args.coords.z + 1.15, 0.0, 0.0, 0.0, 2, false, true, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(cache.ped, scene, 'mini@strip_club@pole_dance@pole_dance' .. args.dance,
                'pd_dance_0' .. args.dance, 1.5, -4.0, 1, 1, 1148846080, 0)
            NetworkStartSynchronisedScene(scene)
        else
            if Config.Debug then print('Nincs közel') end
        end
    end
end)

RegisterNetEvent('bm_dance:pole', function()
    local polePosition = StartRay()
    if polePosition then
        local poleConfig = {
            position = vec4(polePosition.x, polePosition.y, polePosition.z, 0.0),
            spawn = true,
        }
        Config.Poles[#Config.Poles + 1] = poleConfig
        if Config.Debug then
            print("Új rúd hozzáadva a Config.Poles listához:")
            print(ToConfigFormat(poleConfig))
        end
        lib.setClipboard(ToConfigFormat(poleConfig))
        lib.notify({ title = 'Tánc', description = 'Az új rúd a vágólapra másolva', type = 'success' })
        CreateTargets()
    else
        print("Művelet megszakítva.")
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    CreateTargets()
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    DestroyTargets()
end)

if GetResourceState('qb-core') == 'started' then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        Wait(3000)
        CreateTargets()
    end)
end