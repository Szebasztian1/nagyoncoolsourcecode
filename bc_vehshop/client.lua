local openedShop = false
local selling = false
local testing = false

--- The car under test and the two extras that can be switched on while sitting in it.
--- Both are local previews: nothing is bought, nothing is saved, nobody else sees them,
--- and both are dropped when the test ends.
local testVehicle = nil
local testChip = false
local testSmoke = false
local shops = {}
local blips = {}

local vehprices = {}

--- model hash -> the name a shop shows for it. Filled as shops are opened, so an owned car
--- that is sold somewhere is listed under the name the player bought it under.
local vehlabels = {}

--- The player's own cars as last listed, so picking one does not ask the server again.
local ownCars = {}

local shopsPed = {}

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do
        Wait(10)
    end

    TriggerEvent('chat:addSuggestion', '/vsadd', _U("command_vsadd"), {
        { name = "shop",     help = _U("command_shop") },
        { name = "model",    help = _U("command_model") },
        { name = "price",    help = _U("command_price") },
        { name = "category", help = _U("command_category") },
        { name = "name",     help = _U("command_name") },
    })
    TriggerEvent('chat:addSuggestion', '/vsdel', _U("command_vsdel"), {
        { name = "shop",  help = _U("command_shop") },
        { name = "model", help = _U("command_model") }
    })
    TriggerEvent('chat:addSuggestion', '/vsphoto', _U("command_vsphoto"), {
        { name = "shop", help = _U("command_shop") }
    })
    TriggerEvent('chat:addSuggestion', '/vsrefresh', _U("command_vsrefresh"), {})
    TriggerEvent('chat:addSuggestion', '/vsget', _U("command_vsget"), {})
    TriggerEvent('chat:addSuggestion', '/chip', _U("command_chip"), {})

    AddTextEntry('vehshop_sell_msg', _U("sell_msg"))

    ESX.TriggerServerCallback("villamos_vehshop:getprices", function(data)
        vehprices = data
    end)

    RefreshShops()

    for shop, data in pairs(shops) do
        lib.zones.sphere({
            coords = data.coords.xyz,
            radius = 15.0,
            debug = false,
            onEnter = function()
                lib.requestModel(`a_m_m_salton_02`)
                local ped = CreatePed(4, `a_m_m_salton_02`, data.coords, false)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)

                exports.ox_target:addLocalEntity(ped, {
                    {
                        label = 'Autókereskedés',
                        icon = 'fas fa-car',
                        distance = 2.0,
                        onSelect = function()
                            OpenShop(shop)
                        end
                    },
                    {
                        label = 'Autóker kezelése',
                        icon = 'fas fa-cogs',
                        distance = 2.0,
                        onSelect = function()
                            local sdata = Config.Shops[shop]
                            if not sdata then return end
                            local jobj = sdata.management
                            if not jobj then return end

                            ESX.TriggerServerCallback("villamos_vehshop:openShop", function(cars, money)
                                if not cars then
                                    Config.Notify("Hiba lekérdezés során!")
                                    return
                                end
                                local opt = {}
                                for k, v in pairs(cars) do
                                    opt[#opt + 1] = {
                                        title = v.label .. " (" .. v.model .. ")",
                                        description = (v.category or "?") ..
                                            " | " .. v.price .. "$ | Limit: " .. (v.limit == -1 and "Nincs" or v.limit),
                                        image = v.img,
                                        onSelect = function()
                                            OpenCarManagement(v.label, v.model, shop)
                                        end,
                                    }
                                end
                                lib.registerContext({
                                    id = 'vehshopmngmt',
                                    title = 'Autóker kezelése',
                                    options = opt
                                })
                                lib.showContext('vehshopmngmt')
                            end, shop)
                        end,
                        canInteract = function()
                            local mgmt = Config.Shops[shop] and Config.Shops[shop].management
                            if not mgmt then return false end
                            return HaveJob(mgmt)
                        end
                    }
                })

                shopsPed[shop] = ped

                SetModelAsNoLongerNeeded(`a_m_m_salton_02`)
            end,
            onExit = function()
                if shopsPed[shop] then
                    DeleteEntity(shopsPed[shop])
                    shopsPed[shop] = nil
                end
            end
        })

        if data.sellcoords and IsPedInAnyVehicle(PlayerPedId()) then
            local point = lib.points.new({
                coords = GetEntityCoords(cache.ped),
                distance = 5,
            })

            function point:nearby()
                DisplayHelpTextThisFrame('vehshop_sell_msg')
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent("villamos_vehshop:sellVehicle", shop)
                    Wait(2000)
                end
            end
        end
    end


    -- while true do
    --     local sleep = 1000
    --     local ped = PlayerPedId()
    --     local coords = GetEntityCoords(ped)
    --     if not openedShop and not selling then
    --         for shop, data in pairs(shops) do
    --             local dis = #(coords - data.coords)
    --             if dis < 20 then
    --                 sleep = 1
    --                 DrawMarker(6, data.coords, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 2.0, 2.0, 2.0, 0, 155, 20, 100, false,
    --                     true, 2, false, false, false, false)
    --                 DrawMarker(36, data.coords + vector3(0.0, 0.0, 0.6), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0,
    --                     155, 20, 100, false, true, 2, false, false, false, false)
    --                 if dis < 2.0 then
    --                     AddTextEntry('vehshop_open_msg', _U("open_msg", data.label))
    --                     DisplayHelpTextThisFrame('vehshop_open_msg')
    --                     if IsControlJustReleased(0, 38) then
    --                         OpenShop(shop)
    --                     end
    --                 end
    --             end
    --             if data.sellcoords and IsPedInAnyVehicle(ped) then
    --                 local sdis = #(coords - data.sellcoords)
    --                 if sdis < 20 then
    --                     sleep = 1
    --                     DrawMarker(6, data.sellcoords, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 3.0, 3.0, 3.0, 204, 35, 40, 100,
    --                         false, true, 2, false, false, false, false)
    --                     DrawMarker(36, data.sellcoords + vector3(0.0, 0.0, 0.6), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
    --                         1.0, 204, 35, 40, 100, false, true, 2, false, false, false, false)
    --                     if sdis < 2.0 then
    --                         DisplayHelpTextThisFrame('vehshop_sell_msg')
    --                         if IsControlJustReleased(0, 38) then
    --                             TriggerServerEvent("villamos_vehshop:sellVehicle", shop)
    --                             Wait(2000)
    --                         end
    --                     end
    --                 end
    --             end
    --         end
    --     end
    --     Wait(sleep)
    -- end
end)

RegisterNetEvent("esx:setJob", function()
    Wait(100)
    RefreshShops()
end)

function RefreshShops()
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
    Wait(1000)
    shops = {}
    for shop, data in pairs(Config.Shops) do
        if HaveJob(data.job) then
            shops[shop] = { coords = data.coords, label = data.label, sellcoords = (data.sell and data.sell.coords or false) }
            if data.blip then
                local blip = AddBlipForCoord(data.coords)
                SetBlipSprite(blip, data.blip.sprite)
                SetBlipScale(blip, 1.0)
                SetBlipColour(blip, data.blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(data.label)
                EndTextCommandSetBlipName(blip)
                blips[#blips + 1] = blip
            end
        end
    end
end

function HaveJob(jobobj)
    if not jobobj then return true end
    if not jobobj[ESX.PlayerData.job.name] then return false end
    for i = 1, #jobobj[ESX.PlayerData.job.name], 1 do
        if jobobj[ESX.PlayerData.job.name][i] == ESX.PlayerData.job.grade_name then
            return true
        end
    end
    return false
end

function OpenCarManagement(label, car, shop)
    lib.registerContext({
        id = 'vehshopcarmngmt',
        title = label .. ' kezelése',
        options = {
            {
                title = "Plusz autó vásárlása",
                description = "1.500PP/db áron új autók behozatala a limitáltakból",
                onSelect = function()
                    local input = lib.inputDialog('AZ ELFOGADÁSSAL MEGVÁSÁROLOD 1.500PP/db ÁRON AZ AUTÓKAT!!', {
                        { type = 'number', label = label .. ' autókból vásárol darabszám', description = '1.500PP/DB !!!!', icon = 'hashtag' },
                    })
                    if not input or not input[1] then
                        return
                    end
                    TriggerServerEvent("bc_vehshop:buyNewLimited", shop, car, input[1])
                end,
            },
            {
                title = "Ár beállítása",
                description = "Ár beállítása",
                onSelect = function()
                    local input = lib.inputDialog('Az autó árának beállítása', {
                        { type = 'number', label = label .. ' ára', icon = 'hashtag' },
                    })
                    if not input or not input[1] then
                        return
                    end
                    TriggerServerEvent("bc_vehshop:setNewPrice", shop, car, input[1])
                end,
            },
        }
    })

    lib.showContext('vehshopcarmngmt')
end

function OpenShop(shop)
    if not Config.Shops[shop] then return end
    openedShop = shop
    ESX.TriggerServerCallback("villamos_vehshop:openShop", function(cars, money, shopinfo)
        if not cars then
            openedShop = false
            return
        end
        for _, car in ipairs(cars) do
            if car.model and car.label then vehlabels[GetHashKey(car.model)] = car.label end
        end

        money.test        = Config.Shops[shop].testcoords and true or false
        -- offered in every dealership: the preview stands on vms_tuning's own showroom
        -- point, so it does not need the shop to have a test drive spot
        money.tuning      = GetResourceState('vms_tuning') == 'started'
        money.logo        = (shopinfo and shopinfo.logoImage) or Config.Shops[shop].logo or ""
        money.description = (shopinfo and shopinfo.description) or Config.Shops[shop].description or ""
        money.bannerImage = (shopinfo and shopinfo.bannerImage) or ""
        local mgmt        = Config.Shops[shop].management
        money.canManage   = mgmt ~= nil and HaveJob(mgmt) or false
        local label       = (shopinfo and shopinfo.label) or Config.Shops[shop].label
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "show",
            enable = true,
            shopdata = money,
            cars = cars,
            name = label,
            shop = shop
        })
    end, shop)
end

function CloseShop()
    SetNuiFocus(false, false)
    openedShop = false
    SendNUIMessage({
        type = "show",
        enable = false
    })
end

RegisterNUICallback('locales', function(data, cb)
    local nuilocales = {}
    if not Config.Locale or not Locales[Config.Locale] then
        return print(
            "^1SCRIPT ERROR: Invilaid locales configuartion")
    end
    for k, v in pairs(Locales[Config.Locale]) do
        if string.find(k, "nui") then
            nuilocales[k] = v
        end
    end
    cb(nuilocales)
end)

RegisterNUICallback('exit', function(data, cb)
    CloseShop()
    cb(1)
end)

RegisterNUICallback('saveShopInfo', function(data, cb)
    TriggerServerEvent('bc_vehshop:updateShopInfo', data)
    cb(1)
end)

RegisterNUICallback('buy', function(data, cb)
    if not openedShop then
        CloseShop()
        return cb(1)
    end
    local alert = lib.alertDialog({
        header = 'Megerősítés',
        content = 'Biztosan megveszed az autót',
        centered = true,
        cancel = true
    })
    if alert ~= "confirm" then return end
    TriggerServerEvent('villamos_vehshop:buyVehicle', openedShop, data.model, 'money')
    CloseShop()
    cb(1)
end)

RegisterNUICallback('buybank', function(data, cb)
    if not openedShop then
        CloseShop()
        return cb(1)
    end
    local alert = lib.alertDialog({
        header = 'Megerősítés',
        content = 'Biztosan megveszed az autót',
        centered = true,
        cancel = true
    })
    if alert ~= "confirm" then return end
    TriggerServerEvent('villamos_vehshop:buyVehicle', openedShop, data.model, 'bank')
    CloseShop()
    cb(1)
end)

RegisterNUICallback('buyfaction', function(data, cb)
    if not openedShop then
        CloseShop()
        return cb(1)
    end
    local alert = lib.alertDialog({
        header = 'Megerősítés',
        content = 'Biztosan megveszed az autót',
        centered = true,
        cancel = true
    })
    if alert ~= "confirm" then return end
    TriggerServerEvent('villamos_vehshop:buyVehicleFaction', openedShop, data.model)
    CloseShop()
    cb(1)
end)

--- Both extras live in other resources, and neither is a hard dependency: with the
--- resource missing the toggle simply is not offered.
local function ExtraReady(resource)
    return GetResourceState(resource) == 'started'
end

--- The test car, and only while the player is genuinely sitting in it. Both extras are
--- gated on this, so outside a test drive the commands do nothing at all: `testing` alone
--- is not enough — it is already true while the ped is still being warped into the car,
--- and it stays true until the loop notices the player got out.
local function TestCar()
    if not testing or not testVehicle or not DoesEntityExist(testVehicle) then return nil end
    if GetVehiclePedIsIn(PlayerPedId(), false) ~= testVehicle then return nil end

    return testVehicle
end

--- Chiptuning preview: everything the chip can do, applied to the test car only. Nothing
--- is flashed and nothing is charged.
local function ToggleTestChip()
    local vehicle = TestCar()
    if not vehicle or not ExtraReady('vilmos_chiptuning') then return false end

    testChip = not testChip
    exports['vilmos_chiptuning']:SetPreviewTune(vehicle, testChip)

    return true
end

--- Kormolás preview: the exhaust smoke at the configured level, drawn for this player only.
local function ToggleTestSmoke()
    local vehicle = TestCar()
    if not vehicle or not ExtraReady('vms_tuning') then return false end

    testSmoke = not testSmoke
    exports['vms_tuning']:SetLocalKormolasLevel(vehicle, testSmoke and Config.TestKormolasLevel or 0)

    return true
end

RegisterCommand('chip', function()
    if ToggleTestChip() then return end

    ESX.ShowNotification(_U("test_extra_only"))
end, false)

--- vms_tuning owns /kormolas — there it is the player's own smoke kill switch. It calls
--- this first and keeps the command when we do not take it, so both uses work.
exports('ToggleTestKormolas', ToggleTestSmoke)

--- What to call a model on screen: the shop's name for it, the game's label, or failing
--- both the model name itself - never an empty row.
local function VehicleLabel(hash)
    if vehlabels[hash] then return vehlabels[hash] end

    local name = GetDisplayNameFromVehicleModel(hash)
    local label = GetLabelText(name)
    if label and label ~= "" and label ~= "NULL" then return label end

    return name
end

--- Puts a car on vms_tuning's showroom point with the player in it, hands it to the given
--- starter, and clears everything away afterwards. Both previews share this.
---@param model number|string: model hash or spawn name
---@param shopcoords vector3: where the player came from
---@param start function: (vehicle) -> boolean, starts the preview in vms_tuning
local function RunTuningPreview(model, shopcoords, start)
    local hash = type(model) == "string" and GetHashKey(model) or model
    if not IsModelInCdimage(hash) then
        print("^1SCRIPT ERROR: Invalid model: " .. tostring(model))
        return ESX.ShowNotification(_U("tuning_unavailable"))
    end

    local spawn = exports["vms_tuning"]:GetShowroomSpawn()
    if not spawn then
        return ESX.ShowNotification(_U("tuning_unavailable"))
    end

    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(10)
    end

    -- The player travels first, the car second. Unlike the test drive this car has to be
    -- networked - vms_tuning works through a net id and a state bag, neither of which a
    -- local entity has - and a networked car created two kilometres away is out of the
    -- player's scope before anyone can be seated in it.
    local ped = PlayerPedId()
    SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, false)

    -- asked for every frame until it is there, or the car is created over a hole
    local ground = GetGameTimer() + 5000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < ground do
        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
        Wait(0)
    end

    local vehicle = CreateVehicle(hash, spawn, true, false)
    -- bc_kocsitorles: legalis spawn jelolese
    if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
    SetModelAsNoLongerNeeded(hash)
    SetVehicleNumberPlateText(vehicle, "SHOWROOM")
    TaskWarpPedIntoVehicle(ped, vehicle, -1)

    -- The warp takes a few frames, and vms_tuning opens its menu on the car the player is
    -- sitting in: called any earlier it finds nobody in a car and refuses, which looks
    -- exactly like the preview being broken.
    local deadline = GetGameTimer() + 5000
    while GetVehiclePedIsIn(ped, false) ~= vehicle and GetGameTimer() < deadline do
        Wait(0)
    end

    if GetVehiclePedIsIn(ped, false) ~= vehicle then
        DeleteVehicle(vehicle)
        SetEntityCoords(ped, shopcoords, false, false, false, false)
        print("^1SCRIPT ERROR: showroom: a jatekost nem sikerult beultetni a jarmube")
        return ESX.ShowNotification(_U("tuning_unavailable"))
    end

    FreezeEntityPosition(vehicle, true)

    if not start(vehicle) then
        DeleteVehicle(vehicle)
        SetEntityCoords(PlayerPedId(), shopcoords, false, false, false, false)
        return ESX.ShowNotification(_U("tuning_unavailable"))
    end

    while exports["vms_tuning"]:IsShowroomPreviewActive() do
        Wait(500)
    end

    if DoesEntityExist(vehicle) then
        FreezeEntityPosition(vehicle, false)
        DeleteVehicle(vehicle)
    end

    SetEntityCoords(PlayerPedId(), shopcoords, false, false, false, false)
end

--- Guards both previews: a shop has to be open, vms_tuning has to be running, and only
--- one car can be on the showroom point at a time.
---@return string|nil: the shop, or nil when the preview must not start
local function TuningPreviewReady()
    if not openedShop then
        CloseShop()
        return nil
    end

    if GetResourceState("vms_tuning") ~= "started" then
        ESX.ShowNotification(_U("tuning_unavailable"))
        return nil
    end

    if testing or exports["vms_tuning"]:IsShowroomPreviewActive() then
        ESX.ShowNotification(_U("tuning_busy"))
        return nil
    end

    return openedShop
end

--- Tuning preview on a car in the shop: stock, thrown away afterwards, nothing for sale.
RegisterNUICallback("tuningpreview", function(data, cb)
    local shop = TuningPreviewReady()
    if not shop or type(data.model) ~= "string" then return cb(1) end

    local model = data.model
    local shopcoords = Config.Shops[shop].coords
    CloseShop()
    cb(1)

    CreateThread(function()
        RunTuningPreview(model, shopcoords, function(vehicle)
            return exports["vms_tuning"]:StartShowroomPreview(vehicle, model)
        end)
    end)
end)

--- The player's own cars, so the shop can offer them as preview subjects.
RegisterNUICallback("ownvehicles", function(_, cb)
    if GetResourceState("vms_tuning") ~= "started" then return cb({}) end

    ownCars = exports["vms_tuning"]:GetOwnVehicles() or {}

    local list = {}
    for _, car in ipairs(ownCars) do
        if IsModelInCdimage(car.model) then
            list[#list + 1] = {plate = car.plate, label = VehicleLabel(car.model)}
        end
    end

    table.sort(list, function(a, b) return a.plate < b.plate end)

    cb(list)
end)

--- Tuning preview on a car the player owns: same trip, but the copy is dressed the way
--- the garage has it, so they are trying tuning on their own car.
RegisterNUICallback("owntuningpreview", function(data, cb)
    local shop = TuningPreviewReady()
    if not shop or type(data.plate) ~= "string" then return cb(1) end

    local plate = data.plate
    local shopcoords = Config.Shops[shop].coords
    CloseShop()
    cb(1)

    -- from the list the player just picked from: the server checks ownership again when
    -- the preview starts, so this only has to be good enough to spawn the right model
    local model
    for _, car in ipairs(ownCars) do
        if car.plate == plate then
            model = car.model
            break
        end
    end

    if not model then
        return ESX.ShowNotification(_U("tuning_unavailable"))
    end

    CreateThread(function()
        RunTuningPreview(model, shopcoords, function(vehicle)
            return exports["vms_tuning"]:StartOwnCarPreview(vehicle, plate)
        end)
    end)
end)

RegisterNUICallback('test', function(data, cb)
    if not openedShop then
        CloseShop()
        return cb(1)
    end
    local testcoords = Config.Shops[openedShop].testcoords
    if not testcoords then
        return cb(1)
    end
    local testtime = Config.Shops[openedShop].testtime
    local shopcoords = Config.Shops[openedShop].coords
    local maxtuning = false
    CloseShop()
    cb(1)
    local hash = GetHashKey(data.model)
    if not IsModelInCdimage(hash) then
        return print("^1SCRIPT ERROR: Invalid model: " .. data.model)
    end
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(10)
    end
    local vehicle = CreateVehicle(hash, testcoords, false, true)
    -- bc_kocsitorles: legalis spawn jelolese
    if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
    if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(hash)
    local start = GetGameTimer()
    testing = true
    testVehicle = vehicle
    testChip, testSmoke = false, false

    -- Resolved once per test drive: a resource does not start or stop mid-lap.
    local hasChip = ExtraReady('vilmos_chiptuning')
    local hasSmoke = ExtraReady('vms_tuning')

    CreateThread(function()
        while testing do
            Wait(0)
            if IsControlJustReleased(0, 38) then
                maxtuning = not maxtuning
                ESX.Game.SetVehicleProperties(vehicle, (maxtuning and {
                    modTurbo = true,
                    modArmor = 5,
                    modEngine = 5,
                    modBrakes = 5,
                    modTransmission = 5
                } or {
                    modTurbo = false,
                    modArmor = 0,
                    modEngine = 0,
                    modBrakes = 0,
                    modTransmission = 0
                }
                ))
            end

            local rem = testtime - (GetGameTimer() - start)
            if rem <= 0 or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle or #(vector3(testcoords.x, testcoords.y, testcoords.z) - GetEntityCoords(PlayerPedId())) > 900.0 then
                testing = false
            end
            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextCentre(1)
            -- CELL_EMAIL_BCON, not STRING: a component is cut off at 99 characters and the
            -- four lines together are longer than that, but STRING only takes one of them.
            BeginTextCommandDisplayText("CELL_EMAIL_BCON")
            AddTextComponentString(_U("test_msg", math.floor(rem / 1000)))
            AddTextComponentString("~n~" .. _U("test_maxtuning", _U(maxtuning and "test_on" or "test_off")))
            if hasChip then
                AddTextComponentString("~n~" .. _U("test_chip", _U(testChip and "test_on" or "test_off")))
            end
            if hasSmoke then
                AddTextComponentString("~n~" .. _U("test_kormolas", _U(testSmoke and "test_on" or "test_off")))
            end
            EndTextCommandDisplayText(0.5, 0.8)
        end

        -- Both previews have to be undone before the car goes: the chip holds a vehicle
        -- handle in its power loop, the smoke holds a state bag and a running effect.
        if testChip then exports['vilmos_chiptuning']:SetPreviewTune(vehicle, false) end
        if testSmoke then exports['vms_tuning']:SetLocalKormolasLevel(vehicle, 0) end

        testVehicle, testChip, testSmoke = nil, false, false

        DeleteVehicle(vehicle)
        SetEntityCoords(PlayerPedId(), shopcoords, false, false, false, false)
    end)
end)

RegisterNetEvent('villamos_vehshop:spawnCar', function(coords, model, plate)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then
        return print("^1SCRIPT ERROR: Invalid model: " .. model)
    end
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(10)
    end
    local vehicle = CreateVehicle(hash, coords, true, true)
    -- bc_kocsitorles: legalis spawn jelolese
    if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
    exports["gs_eventprotect"]:GS_TriggerServerEvent("villamos_vehshop:carspawned",
        NetworkGetNetworkIdFromEntity(vehicle))
    SetVehicleNumberPlateText(vehicle, plate)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    TriggerEvent("ox_fuel:setfuel", vehicle, 100.0)
    SetModelAsNoLongerNeeded(hash)
end)

RegisterCommand("vsget", function(s, a, r)
    local coords = GetEntityCoords(PlayerPedId())
    local closestshop, closestdis = false, 20
    for shop, data in pairs(Config.Shops) do
        local dis = #(coords - data.coords)
        if dis < closestdis then
            closestshop = shop
            closestdis = dis
        end
    end
    if not closestshop then
        return Config.Notify(_U("no_shop_near"))
    end
    Config.Notify(_U("closest_shop", closestshop))
end)

RegisterNetEvent("villamos_vehshop:takePhotos", function(shop, apikey, cars)
    Config.Notify(_U("taking_photos"))
    DisplayHud(false)
    DisplayRadar(false)
    FreezeEntityPosition(PlayerPedId(), true)

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, Config.Shops[shop].showroomcam)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)

    for i = 1, #cars, 1 do
        local model = cars[i].model
        local hash = GetHashKey(model)
        if IsModelInCdimage(hash) and IsModelValid(hash) then
            if not HasModelLoaded(hash) then
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Wait(0)
                end
            end

            local vehicle = CreateVehicle(hash, Config.Shops[shop].showroom, false, true)
            -- bc_kocsitorles: legalis spawn jelolese
            if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
            if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
            SetModelAsNoLongerNeeded(hash)
            FreezeEntityPosition(vehicle, true)
            PointCamAtEntity(cam, vehicle, 0.0, 0.0, 0.0, true)
            SetFocusEntity(vehicle)

            local p = promise.new()
            Wait(500)

            exports['screenshot-basic']:requestScreenshotUpload("https://api.imgbb.com/1/upload?key=" .. apikey, "image",
                {
                    encoding = "jpg"
                }, function(data)
                    if not data then
                        print("^1SCRIPT ERROR: Error while uploading image")
                        return p:resolve(false)
                    end
                    local resp = json.decode(data)
                    if not resp or not resp.data then
                        print("^1SCRIPT ERROR: Error while uploading image")
                        return p:resolve(false)
                    end
                    local img = resp.data.url
                    if not img then
                        print("^1SCRIPT ERROR: Error while uploading image")
                        return p:resolve(false)
                    end
                    p:resolve(img)
                end)


            --[[exports['screenshot-basic']:requestScreenshotUpload(webhook, "files[]", function(data)
                if not data then
                    print("^1SCRIPT ERROR: Error while uploadin image to discord")
                    return p:resolve(false)
                end
                local resp = json.decode(data)
                if not resp or not resp.attachments then
                    print("^1SCRIPT ERROR: Error while uploadin image to discord")
                    return p:resolve(false)
                end
                local img = resp.attachments[1].proxy_url
                if not img then
                    print("^1SCRIPT ERROR: Error while uploadin image to discord")
                    return p:resolve(false)
                end
                p:resolve(img)
            end)]]

            local image = Citizen.Await(p)
            if image then
                TriggerServerEvent("villamos_vehshop:savePhoto", shop, model, image)
            end
            DeleteEntity(vehicle)
            SetModelAsNoLongerNeeded(hash)
        else
            print("^1SCRIPT ERROR: Invalid model: " .. model)
        end
    end

    Wait(2000)

    ClearFocus()
    DisplayHud(true)
    DisplayRadar(true)
    FreezeEntityPosition(PlayerPedId(), false)
    RenderScriptCams(false)
    DestroyCam(cam, true)
    SetCamActive(cam, false)
    Config.Notify(_U("photos_done"))
    TriggerServerEvent("villamos_vehshop:refresh")
end)

ESX.RegisterClientCallback("villamos_vehshop:confirmSell", function(cb, plate, price)
    selling = true
    local eles = {
        {
            unselectable = true,
            icon = "fas fa-info-circle",
            title = _U("confirm_sell", plate, price),
        },
        {
            icon = "fas fa-check",
            title = _U("yes"),
            name = "yes"
        },
        {
            icon = "fas fa-times",
            title = _U("no"),
            name = "no"
        },
    }

    ESX.OpenContext("right", eles, function(menu, ele)
        if ele and ele.name and ele.name == "yes" then
            cb(true)
        else
            cb(false)
        end
        ESX.CloseContext()
        selling = false
    end, function(menu)
        cb(false)
        selling = false
    end)
end)


exports("GeneratePlate", function()
    local p = promise.new()
    ESX.TriggerServerCallback('villamos_vehshop:GeneratePlate', function(plate)
        p:resolve(plate)
    end)
    local plate = Citizen.Await(p)
    return plate
end)

exports("GetVehPrice", function(model)
    local checkshops = { "carshop", "boatshop", "helishop" }
    --print(model)
    --print(json.encode(vehprices))
    for _, ss in ipairs(checkshops) do
        if vehprices[ss] and vehprices[ss][model] then
            return vehprices[ss][model]
        end
    end
    return false
end)
