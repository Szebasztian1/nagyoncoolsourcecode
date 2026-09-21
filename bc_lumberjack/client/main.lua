local openedMenu = nil
local duty = false
local npccoords

Citizen.CreateThread(function()
    Citizen.Wait(2000)

    while ESX == nil do
        Citizen.Wait(10)
    end

    while not NetworkIsSessionStarted() do
        Citizen.Wait(100)
    end

    AddTextEntry('bc_lumberjack_cloathroom', locales[Config.locales]['open_cloothroom'])
    AddTextEntry('bc_lumberjack_cutwood', locales[Config.locales]['input_cut_tree'])
    AddTextEntry('bc_lumberjack_process', locales[Config.locales]['input_process'])
    AddTextEntry('bc_lumberjack_npc', locales[Config.locales]['input_npc'])

    local blip = AddBlipForCoord(Config.ClothRoom.x, Config.ClothRoom.y, Config.ClothRoom.z)
    SetBlipSprite(blip, 280)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locales[Config.locales]['hobby_clothroom'])
    EndTextCommandSetBlipName(blip)
    MunkaBlip('favago_oltozo', blip)

    local hash = GetHashKey('gr_prop_gr_speeddrill_01a')
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(10)
    end
    for _, v in pairs(Config.Process.Pos) do
        local obj = CreateObject(hash, v.x, v.y + 0.6, v.z, false, false, false)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
    end
    SetModelAsNoLongerNeeded(hash)

    RequestModel(Config.NPC.model)
    while not HasModelLoaded(Config.NPC.model) do
        Citizen.Wait(1)
    end

    local ped = CreatePed(1, Config.NPC.model, Config.NPC.x, Config.NPC.y, Config.NPC.z, Config.NPC.h, false, false)
    PlaceObjectOnGroundProperly(ped)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    SetModelAsNoLongerNeeded(Config.NPC.model)
    npccoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.8, -0.6)


    while true do

        local coords = GetEntityCoords(PlayerPedId())
        local sleep = 1000
        local dis = GetDistanceBetweenCoords(coords, Config.ClothRoom.x, Config.ClothRoom.y, Config.ClothRoom.z, true)

        if dis < 20 then
            sleep = 1
            DrawMarker(6, Config.ClothRoom.x, Config.ClothRoom.y, Config.ClothRoom.z - 0.6, 0.0, 0.0, 0.0, -90.0, 0.0,
                0.0, 2.0, 2.0, 2.0, 0, 155, 20, 100, true, true, 2, false, false, false, false)
            DrawMarker(31, Config.ClothRoom.x, Config.ClothRoom.y, Config.ClothRoom.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0
                , 1.0, 1.0, 0, 155, 20, 100, true, true, 2, false, false, false, false)
            if dis < 2.0 then
                DisplayHelpTextThisFrame('bc_lumberjack_cloathroom')
                if IsControlJustReleased(0, 38) then
                    OpenClothRoom()
                end
            elseif openedMenu == 'cloathroom' then
                ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bc_lumberjack_clothroom')
            end
        elseif openedMenu == 'cloathroom' then
            ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bc_lumberjack_clothroom')
        end

        Citizen.Wait(sleep)
    end

end)

function OpenClothRoom()
    openedMenu = 'cloathroom'
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bc_lumberjack_clothroom', {
        title    = locales[Config.locales]['lumberjack_clothroom'],
        align    = 'top-left',
        elements = {
            { label = locales[Config.locales]['civil_cloth'], value = "citizen" },
            { label = locales[Config.locales]['lumberjack_cloth'], value = "lumberjack" },
        }
    }, function(data, menu)
        menu.close()
        openedMenu = nil
        if data.current.value == "citizen" then
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
            end)
            SetDuty(false)
        elseif data.current.value == "lumberjack" then
            TriggerEvent('skinchanger:getSkin', function(skin)
                if skin.sex == 0 then
                    TriggerEvent('skinchanger:loadClothes', skin, Config.JobCloth.male)
                else
                    TriggerEvent('skinchanger:loadClothes', skin, Config.JobCloth.female)
                end
            end)
            SetDuty(true)
        end
    end, function(data, menu)
        menu.close()
        openedMenu = nil
    end)
end

local blips = {}
function SetDuty(state)
    if duty ~= state then
        duty = state
        if duty then
            local blip = AddBlipForCoord(Config.TreeZone.x, Config.TreeZone.y, Config.TreeZone.z)
            SetBlipSprite(blip, 238)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locales[Config.locales]['cut_tree'])
            EndTextCommandSetBlipName(blip)

            table.insert(blips, blip)

            blip = AddBlipForCoord(Config.NPC.x, Config.NPC.y, Config.NPC.z)
            SetBlipSprite(blip, 238)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locales[Config.locales]['lumberjack_leader'])
            EndTextCommandSetBlipName(blip)

            table.insert(blips, blip)

            blip = AddBlipForCoord(Config.Process.Blip.x, Config.Process.Blip.y, Config.Process.Blip.z)
            SetBlipSprite(blip, 238)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(locales[Config.locales]['process_tree'])
            EndTextCommandSetBlipName(blip)

            table.insert(blips, blip)

            DutyThread()
        else
            for k, v in pairs(blips) do
                RemoveBlip(v)
            end
            blips = {}
        end
    end
end

local trees = {}

function DutyThread()
    Citizen.CreateThread(function()
        RequestModel(Config.TreeObject)
        while not HasModelLoaded(Config.TreeObject) do
            Citizen.Wait(10)
        end

        while duty do
            Citizen.Wait(10)
            local coords = GetEntityCoords(PlayerPedId())

            if GetDistanceBetweenCoords(coords, Config.TreeZone.x, Config.TreeZone.y, Config.TreeZone.z, true) <
                Config.TreeZone.radius + 20 then
                if #trees < 7 then
                    local x, y, z = GenerateTreeCoords()
                    local tree = CreateObject(Config.TreeObject, x, y, z, false, false, false)
                    PlaceObjectOnGroundProperly(tree)
                    FreezeEntityPosition(tree, true)
                    local treecoords = GetEntityCoords(tree)
                    SetEntityCoordsNoOffset(tree, treecoords.x, treecoords.y, treecoords.z - 0.5, true, false, false)
                    table.insert(trees, tree)
                end
                Citizen.Wait(500)
            else
                if #trees < 0 then
                    for k, v in pairs(trees) do
                        DeleteEntity(v)
                        table.remove(trees, k)
                    end
                end
                Citizen.Wait(1000)
            end
        end

        SetModelAsNoLongerNeeded(Config.TreeObject)
    end)

    Citizen.CreateThread(function()
        while duty do
            if #trees > 0 then
                local coords = GetEntityCoords(PlayerPedId())
                local wait = 500
                for k, v in pairs(trees) do
                    if GetDistanceBetweenCoords(coords, GetEntityCoords(v), false) < 2.0 then
                        wait = 2
                        DisplayHelpTextThisFrame('bc_lumberjack_cutwood')
                        if IsControlJustReleased(0, 38) then
                            CutTree(v, k)
                        end
                    end
                end
                Citizen.Wait(wait)
            else
                Citizen.Wait(1000)
            end
        end
    end)

    Citizen.CreateThread(function()
        while duty do

            local coords = GetEntityCoords(PlayerPedId())
            local sleep = 1000

            for _, v in pairs(Config.Process.Pos) do
                local dis = GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true)
                if dis < 20 then
                    sleep = 1
                    DrawMarker(6, v.x, v.y, v.z - 0.6, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 155, 20, 100,
                        true, true, 2, false, false, false, false)
                    DrawMarker(42, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 155, 20, 100, true,
                        true, 2, false, false, false, false)
                    if dis < 1.0 then
                        DisplayHelpTextThisFrame('bc_lumberjack_process')
                        if IsControlJustReleased(0, 38) then
                            ProcessWood()
                        end
                    end
                end
            end

            Citizen.Wait(sleep)
        end
    end)

    Citizen.CreateThread(function()
        while duty do
            local coords = GetEntityCoords(PlayerPedId())
            local sleep = 1000
            local dis = GetDistanceBetweenCoords(coords, npccoords.x, npccoords.y, npccoords.z, true)

            if dis < 20 then
                sleep = 1
                DrawMarker(6, npccoords.x, npccoords.y, npccoords.z - 0.6, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 2.0, 2.0, 2.0
                    , 0, 155, 20, 100, true, true, 2, false, false, false, false)
                DrawMarker(21, npccoords.x, npccoords.y, npccoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 155
                    , 20, 100, true, true, 2, false, false, false, false)
                DrawText3D(Config.NPC.x, Config.NPC.y, Config.NPC.z + 1.8, Config.NPC.name)
                if dis < 2.0 then
                    DisplayHelpTextThisFrame('bc_lumberjack_npc')
                    if IsControlJustReleased(0, 38) then
                        OpenNpcMenu()
                    end
                elseif openedMenu == 'npc' then
                    ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bc_lumberjack_npc')
                end
            elseif openedMenu == 'npc' then
                ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'bc_lumberjack_npc')
            end

            Citizen.Wait(sleep)
        end
    end)
end

function OpenNpcMenu()
    openedMenu = 'npc'
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bc_lumberjack_npc', {
        title    = locales[Config.locales]['lumberjack_leader'],
        align    = 'top-left',
        elements = {
            { label = locales[Config.locales]['buy_axe'] .. Config.AxePrice, value = "axe" },
            { label = locales[Config.locales]['sell_tree'] .. Config.Rewards.sell.price, value = "sell" },
        }
    }, function(data, menu)
        menu.close()
        openedMenu = nil
        if data.current.value == "axe" then
            TriggerServerEvent('bc_lumberjack:buyAxe')
        elseif data.current.value == "sell" then
            TriggerServerEvent('bc_lumberjack:sellAll')
        end
    end, function(data, menu)
        menu.close()
        openedMenu = nil
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(trees) do
            DeleteEntity(v)
            table.remove(trees, k)
        end
    end
end)

function ProcessWood()
    local ended = false
    ESX.TriggerServerCallback("bc_lumberjack:getItemCount", function(count)
        if count > Config.Rewards.process.required then
            local ped = PlayerPedId()
            RequestAnimDict("mp_am_hold_up")
            while not HasAnimDictLoaded("mp_am_hold_up") do
                Citizen.Wait(10)
            end

            local obj = GetClosestObjectOfType(GetEntityCoords(ped), 3.0, GetHashKey('gr_prop_gr_speeddrill_01a'), false
                , false, false)
            TaskTurnPedToFaceEntity(ped, obj, 1000)
            Citizen.Wait(1000)

            local hash = GetHashKey('prop_fncwood_16f')

            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Citizen.Wait(10)
            end

            local wood = CreateObject(hash, 0.0, 0.0, 0.0, true, true, false)
            -- bc_kocsitorles: legalis spawn jelolese
            if wood and wood ~= 0 and NetworkGetEntityIsNetworked(wood) then Entity(wood).state:set('bc_spawned', true, true) end
            AttachEntityToEntity(wood, ped, GetPedBoneIndex(ped, 18905), 0.15, -0.13, -0.26, 308.0, 0.0, 0.0, true, true
                , false, true, 1, true)

            SetModelAsNoLongerNeeded(hash)

            FreezeEntityPosition(ped, true)
            TaskPlayAnim(ped, "mp_am_hold_up", "purchase_beerbox_shopkeeper", 8.0, 8.0, -1, 1, 0, false, false, false)
            TriggerServerEvent('bc_lumberjack:removeItem', Config.Rewards.treezone.item, Config.Rewards.process.required)

            if StartMinigame() then
                TriggerServerEvent('bc_lumberjack:rewardProcess')
            else
                TriggerEvent('esx:showNotification', locales[Config.locales]['bad_cut'])
            end

            ClearPedTasksImmediately(ped)
            RemoveAnimDict("mp_am_hold_up")
            DeleteEntity(wood)
            FreezeEntityPosition(ped, false)
        else
            TriggerEvent('esx:showNotification', locales[Config.locales]['dont_have_tree'])
        end
        ended = true
    end, Config.Rewards.treezone.item)

    while not ended do
        Citizen.Wait(10)
    end
end

function CutTree(tree, k)
    local ended = false
    ESX.TriggerServerCallback("bc_lumberjack:getItemCount", function(count)
        if count > 0 then
            local ped = PlayerPedId()
            RequestAnimDict("melee@hatchet@streamed_core")
            while not HasAnimDictLoaded("melee@hatchet@streamed_core") do
                Citizen.Wait(10)
            end
            TaskTurnPedToFaceEntity(ped, tree, 1000)
            Citizen.Wait(1000)

            RequestModel(Config.AxeObject)
            while not HasModelLoaded(Config.AxeObject) do
                Citizen.Wait(10)
            end

            local axe = CreateObject(Config.AxeObject, 0.0, 0.0, 0.0, true, true, false)
            -- bc_kocsitorles: legalis spawn jelolese
            if axe and axe ~= 0 and NetworkGetEntityIsNetworked(axe) then Entity(axe).state:set('bc_spawned', true, true) end
            AttachEntityToEntity(axe, ped, GetPedBoneIndex(ped, 57005), 0.15, -0.02, -0.02, 350.0, 100.00, 280.0, true,
                true, false, true, 1, true)

            SetModelAsNoLongerNeeded(Config.AxeObject)

            FreezeEntityPosition(ped, true)
            TaskPlayAnim(ped, "melee@hatchet@streamed_core", "plyr_front_takedown", 8.0, 8.0, -1, 1, 0, false, false,
                false)

            if StartMinigame() then
                Citizen.Wait(6000)
                ClearPedTasksImmediately(ped)
                table.remove(trees, k)
                Citizen.CreateThread(function()
                    while true do
                        local retval = GetEntityRotation(tree, 1)
                        local y = retval.y - 1
                        SetEntityRotation(tree, 0.0, y, 0.0, 1, true)
                        Citizen.Wait(10)

                        if y < -100 then
                            Citizen.Wait(3000)
                            exports["gs_eventprotect"]:GS_TriggerServerEvent('bc_lumberjack:rewardTree')
                            DeleteEntity(tree)
                            return nil
                        end
                    end
                end)
            else
                TriggerEvent('esx:showNotification', locales[Config.locales]['bad_cut'])
                ClearPedTasksImmediately(ped)
            end
            if math.random(1, 100) < Config.ChanceToBreakAxe then
                TriggerServerEvent('bc_lumberjack:removeItem', Config.AxeItem, 1)
                TriggerEvent('esx:showNotification', locales[Config.locales]['broken_axe'])
            end
            RemoveAnimDict("melee@hatchet@streamed_core")
            DeleteEntity(axe)
            FreezeEntityPosition(ped, false)
        else
            TriggerEvent('esx:showNotification', locales[Config.locales]['dont_have_axe'])
        end
        ended = true
    end, Config.AxeItem)

    while not ended do
        Citizen.Wait(10)
    end
end

local isInGame = false
function StartMinigame()
    if not isInGame then
        local ended = false
        local success = false
        isInGame = true
        local startTime = GetGameTimer()
        local timeall = 0
        local target = (math.random(70, 110) / 1000)
        local width = (math.random(35, 55) / 1000)
        local pressed = false
        Citizen.CreateThread(function()
            while timeall < 4700 do
                Citizen.Wait(1)

                local time = 250 * (timeall / 4500)
                if time > 250 then
                    time = 250
                end

                DrawRect(0.5, 0.6, 0.27 + 0.006, 0.03 + 0.006, 0, 0, 0, 150)
                DrawRect(0.5 + target, 0.6, width, 0.03 + 0.006, 156, 0, 0, 150)

                if ((0.5 + target) - (width / 2)) + 0.01 < 0.5 - 0.125 + (time / 1000) + 0.01 and
                    ((0.5 + target) + (width / 2)) - 0.01 > 0.5 - 0.125 + (time / 1000) - 0.01 then
                    DrawRect(0.5 - 0.125 + (time / 1000), 0.6, 0.02, 0.03, 0, 180, 0, 190)
                else
                    DrawRect(0.5 - 0.125 + (time / 1000), 0.6, 0.02, 0.03, 0, 100, 0, 190)
                end

                SetTextFont(4)
                SetTextScale(0.4, 0.4)
                SetTextColour(255, 255, 255, 255)
                SetTextCentre(1)
                SetTextEntry("STRING")
                AddTextComponentString(locales[Config.locales]['minigame_tutorial'])
                DrawText(0.5, 0.63)

                if not pressed and IsControlJustReleased(0, 38) then
                    pressed = true
                    if ((0.5 + target) - (width / 2)) < 0.5 - 0.125 + (time / 1000) + 0.01 and
                        ((0.5 + target) + (width / 2)) > 0.5 - 0.125 + (time / 1000) - 0.01 then
                        success = true
                    end
                end
                timeall = GetGameTimer() - startTime
            end
            isInGame = false
            ended = true
        end)

        while not ended do
            Citizen.Wait(10)
        end

        return success
    end
end

function GenerateTreeCoords()
    while true do
        Citizen.Wait(0)
        local x = Config.TreeZone.x + math.random(-Config.TreeZone.radius, Config.TreeZone.radius) + 0.0
        local y = Config.TreeZone.y + math.random(-Config.TreeZone.radius, Config.TreeZone.radius) + 0.0
        if GetDistanceBetweenCoords(Config.TreeZone.x, Config.TreeZone.y, Config.TreeZone.z, x, y, 0.0, false) <
            Config.TreeZone.radius then
            local _, z = GetGroundZFor_3dCoord(x, y, 999.0, false)
            if x and y and z then
                local vaild = true
                for k, v in pairs(trees) do
                    if GetDistanceBetweenCoords(x, y, z, GetEntityCoords(v), true) < 6 then
                        vaild = false
                    end
                end
                if vaild then
                    return x, y, z
                end
            end
        end
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0, 0.4 * scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end
