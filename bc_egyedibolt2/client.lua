local openedShop = false
local selling = false
local testing = false
local shops = {}
local blips = {}

local vehprices = {}

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do 
        Wait(10)
    end 

    TriggerEvent('chat:addSuggestion', '/vsadd', _U("command_vsadd"), {
        { name="shop", help=_U("command_shop") },
        { name="model", help=_U("command_model") },
        { name="price", help=_U("command_price") },
        { name="category", help=_U("command_category") },
        { name="name", help=_U("command_name") },
    })
    TriggerEvent('chat:addSuggestion', '/vsdel', _U("command_vsdel"), {
        { name="shop", help=_U("command_shop") },
        { name="model", help=_U("command_model") }
    })
    TriggerEvent('chat:addSuggestion', '/vsphoto', _U("command_vsphoto"), {
        { name="shop", help=_U("command_shop") }
    })
    TriggerEvent('chat:addSuggestion', '/vsrefresh', _U("command_vsrefresh"), {})
    TriggerEvent('chat:addSuggestion', '/vsget', _U("command_vsget"), {})

    AddTextEntry('vehshop_sell_msg', _U("sell_msg"))
    
    ESX.TriggerServerCallback("bc_egyediautoker2:getprices", function(data)
        vehprices = data
    end)

    RefreshShops()

    while true do 
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        if not openedShop and not selling then 
            for shop, data in pairs(shops) do 
                local dis = #(coords - data.coords)
                if dis < 20 then 
                    sleep = 1
                    DrawMarker(6, data.coords, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 2.0, 2.0, 2.0, 0, 155, 20, 100, true, true, 2, false, false, false, false)
                    DrawMarker(36, data.coords+vector3(0.0, 0.0, 0.6), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 155, 20, 100, true, true, 2, false, false, false, false)
                    if dis < 2.0 then 
                        AddTextEntry('vehshop_open_msg', _U("open_msg", data.label))
                        DisplayHelpTextThisFrame('vehshop_open_msg')
                        if IsControlJustReleased(0, 38) then
                            OpenShop(shop)
                        end
                    end 
                end 
                if data.sellcoords and IsPedInAnyVehicle(ped) then
                    local sdis = #(coords - data.sellcoords)
                    if sdis < 20 then 
                        sleep = 1 
                        DrawMarker(6, data.sellcoords, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 3.0, 3.0, 3.0, 204, 35, 40, 100, true, true, 2, false, false, false, false)
                        DrawMarker(36, data.sellcoords+vector3(0.0, 0.0, 0.6), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 204, 35, 40, 100, true, true, 2, false, false, false, false)
                        if sdis < 2.0 then 
                            DisplayHelpTextThisFrame('vehshop_sell_msg')
                            if IsControlJustReleased(0, 38) then
                                TriggerServerEvent("bc_egyediautoker2:sellVehicle", shop)
                                Wait(2000)
                            end
                        end
                    end 
                end 
            end
        end  
        Wait(sleep)
    end 
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
                blips[#blips+1] = blip
            end 
        end 
    end 
end 

function HaveJob(jobobj)
    if not jobobj then return true end 
    if not jobobj[ESX.PlayerData.job.name] then return false end 
    for i=1, #jobobj[ESX.PlayerData.job.name], 1 do
        if jobobj[ESX.PlayerData.job.name][i] == ESX.PlayerData.job.grade_name then 
            return true 
        end 
    end 
    return false 
end 


function OpenShop(shop)
    if not Config.Shops[shop] then return end 
    openedShop = shop
    ESX.TriggerServerCallback("bc_egyediautoker2:openShop", function(cars, money) 
        if not cars then 
            openedShop = false 
            return 
        end 
        money.test = Config.Shops[shop].testcoords and true or false
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "show",
            enable = true,
            shopdata = money,
            cars = cars,
            name = Config.Shops[shop].label
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
    if not Config.Locale or not Locales[Config.Locale] then return print("^1SCRIPT ERROR: Invilaid locales configuartion") end
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

RegisterNUICallback('buy', function(data, cb)
    if not openedShop then 
        CloseShop()
        return cb(1)
    end 
    TriggerServerEvent('bc_egyediautoker2:buyVehicle', openedShop, data.model, 'money')
    CloseShop()
    cb(1)
end)

RegisterNUICallback('buybank', function(data, cb)
    if not openedShop then 
        CloseShop()
        return cb(1)
    end 
    TriggerServerEvent('bc_egyediautoker2:buyVehicle', openedShop, data.model, 'bank')
    CloseShop()
    cb(1)
end)

RegisterNUICallback('buyfaction', function(data, cb)
    if not openedShop then 
        CloseShop()
        return cb(1)
    end 
    TriggerServerEvent('bc_egyediautoker2:buyVehicleFaction', openedShop, data.model)
    CloseShop()
    cb(1)
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

    local plate = data.model
    ESX.TriggerServerCallback("bc_egyediautoker2:getVehDataFromPlate", function(can)
        if can then 
            local hash = can.model
            if not IsModelInCdimage(hash) then 
                return print("^1SCRIPT ERROR: Invalid model: "..hash)
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

            ESX.Game.SetVehicleProperties(vehicle, can)
            local start = GetGameTimer()
            testing = true 
            CreateThread(function()
                while testing do 
                    Wait(0)


                    local rem = testtime - (GetGameTimer() - start)
                    if rem <= 0 or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then 
                        testing = false 
                    end 
                    SetTextFont(4)
                    SetTextScale(0.5, 0.5)
                    SetTextColour(255, 255, 255, 255)
                    SetTextCentre(1)
                    BeginTextCommandDisplayText("STRING")
                    AddTextComponentString(_U("test_msg", math.floor(rem/1000)).. "~n~" )
                    EndTextCommandDisplayText(0.5, 0.8)
                end 
                DeleteVehicle(vehicle)
                SetEntityCoords(PlayerPedId(), shopcoords, false, false, false, false)
            end)
        end 
    end, plate)

    
end)

RegisterNetEvent('bc_egyediautoker2:spawnCar', function(coords, plate)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then 
        return print("^1SCRIPT ERROR: Invalid model: "..model)
    end 
    while not HasModelLoaded(hash) do 
        RequestModel(hash)
        Wait(10)
    end 
    ESX.TriggerServerCallback("bc_egyediautoker2:getVehDataFromPlate", function(can)
        local hash = can.model
        local vehicle = CreateVehicle(hash, coords, true, true)
        -- bc_kocsitorles: legalis spawn jelolese
        if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
        ESX.Game.SetVehicleProperties(vehicle, can)
        exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_egyediautoker2:carspawned", NetworkGetNetworkIdFromEntity(vehicle))
        SetVehicleNumberPlateText(vehicle, plate)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        TriggerEvent("ox_fuel:setfuel", vehicle, 100.0)
        SetModelAsNoLongerNeeded(hash)
    end, plate)
end)


ESX.RegisterClientCallback("bc_egyediautoker2:confirmSell", function(cb, plate, price)
    selling = true 

    local input = lib.inputDialog('Autó eladása', {
        {type = 'input', label = 'Az autó neve', description = 'Az autó neve', required = true, max = 16},
        {type = 'number', label = 'Az autó ára', description = 'Az autó ára', required = true},
    })
    if not input or not input[1] or not input[2] then 
        selling = false 
        return cb(false)
    end
    selling = false 
    cb(true, input[1], input[2])

    --[[local eles = {
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
    end)]]
end)