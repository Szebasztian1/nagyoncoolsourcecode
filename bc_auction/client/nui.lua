lastAuction = -1



RegisterNetEvent('bc_auction:openNUI', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "show",
        enable = true
    })
end)
RegisterCommand('auctions', function()
    TriggerEvent('bc_auction:openNUI')
end, false)

function closeNUI()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastAuction = 0
end

RegisterNUICallback('exit', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "show",
        enable = false
    })
    lastAuction = 0
    cb(1)
end)

RegisterNUICallback('getItemtypes', function(data, cb)
    local data = {}
    for k,v in pairs(Config.AuctionItems) do
        data[#data+1] = {
            name = k, 
            label = v.label,
            editableLabel = (v.GetItemLabel == false),
            editableDescription = (v.GetItemDescription == false),
            editableImage = (v.GetItemImage == false),
            fields = v.properties,
            minBidPercent = (v.minBidPercent or 0),
        }
    end

    print("getitemtypes", json.encode(data))
    cb(data)
end)

RegisterNUICallback('getLocales', function(data, cb)
    local data = {}

    --cb(data)
end)

RegisterNUICallback('setNotification', function(data, cb)
    TriggerServerEvent('bc_auction:notifySettings', data.notification)
    cb(1)
end)

RegisterNUICallback('getAuctions', function(data, cb)
    local data = lib.callback.await('bc_auction:getAllAuctions', false)
    cb(data)
end)

RegisterNUICallback('getInterestedAuctions', function(data, cb)
    local data = lib.callback.await('bc_auction:getInterestedAuctions', false)
    cb(data)
end)

RegisterNUICallback('getMyAuctions', function(data, cb)
    local data = lib.callback.await('bc_auction:getMyAuctions', false)
    cb(data)
end)

RegisterNUICallback('getPlaceableItems', function(data, cb)
    print("pitems called")
    local data = lib.callback.await('bc_auction:getPlaceableItems', false)
    print("pitems", json.encode(data))
    cb(data)
end)

local to = false  
RegisterNUICallback('startAuction', function(data, cb)
    closeNUI()
    if to then 
        cb(false)
        return 
    end
    to = true
    data.duration = tonumber(data.duration)
    data.acceptprice = tonumber(data.acceptprice)
    if data.slectedCount then 
        data.slectedCount = tonumber(data.slectedCount)
    end
    local suc = lib.callback.await('bc_auction:startAuction', false, data)
    to = false
    cb(suc)
end)

RegisterNUICallback('getAuction', function(data, cb)
    data.id = tonumber(data.id)
    lastAuction = data.id
    local data = lib.callback.await('bc_auction:getAuction', false, data.id)
    if not data then 
        cb(false)
        return 
    end
    cb(data)
end)

RegisterNUICallback('placeBid', function(data, cb)
    data.amount = tonumber(data.amount)
    data.id = tonumber(data.id)
    TriggerServerEvent('bc_auction:placeBid', data.id, data.amount)
    cb(1)
end)

RegisterNUICallback('test', function(data, cb)
    data.id = tonumber(data.id)
    TriggerServerEvent('bc_auction:testProduct', data.id)
    cb(1)
end)

RegisterNUICallback('acceptOffer', function(data, cb)
    data.id = tonumber(data.id)
    local data = lib.callback.await('bc_auction:acceptOffer', false, data.id)
    cb(data)
end)

RegisterNUICallback('declineOffer', function(data, cb)
    data.id = tonumber(data.id)
    local data = lib.callback.await('bc_auction:declineOffer', false, data.id)
    cb(data)
end)

RegisterNUICallback('delAuction', function(data, cb)
    data.id = tonumber(data.id)
    local data = lib.callback.await('bc_auction:delAuction', false, data.id)
    cb(data)
end)

RegisterNetEvent('bc_auction:notify', function(title, message)
    TriggerEvent("esx:showNotification", title.." - "..message)
end)

RegisterNetEvent('bc_auction:refreshAuction', function(data)
    if data and data.id == lastAuction then 
        SendNUIMessage({
            type = "updateauction",
            auction = data
        })
    end
end)


local takingpic = false  
lib.callback.register('bc_auction:getVehPic', function(plate)
    print("takepic", plate)
    local data, uplink = lib.callback.await('bc_auction:getVehData', false, plate)
    if not data then 
        print("nodata")
        return false
    end
    if GetResourceState("screenshot-basic") ~= "started" then 
        print("noshb")
        return false 
    end 
    DisplayHud(false)
    DisplayRadar(false)

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam, vector3(-45.54, -1100.37, 27.42))
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)



    local hash = data.model
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then 
        ClearFocus()
        DisplayHud(true)
        DisplayRadar(true)
        RenderScriptCams(false)
        DestroyCam(cam, true)
        SetCamActive(cam, false)
        print("^1SCRIPT ERROR: Invalid model: "..model)
        return false 
    end 
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
    end

    local vehicle = CreateVehicle(hash, vector4(-46.1, -1096.43, 25.71, 230.0), false, true)
    -- bc_kocsitorles: legalis spawn jelolese
    if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
    if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(vehicle, true)
    PointCamAtEntity(cam, vehicle, 0.0, 0.0, 0.0, true)
    SetFocusEntity(vehicle)
    --print("vehicle", vehicle, hash)

    ESX.Game.SetVehicleProperties(vehicle, data)
    takingpic = true 

    CreateThread(function()
        while takingpic do 
            Wait(1)
            DisableFrontendThisFrame()
        end 
    end)

    local p = promise.new()
    Wait(4000)

    exports['screenshot-basic']:requestScreenshotUpload(uplink, "image", {
        encoding = "jpg"
    }, function(imgdata)
        --print('scbasic')
        if not data then 
            print("^1SCRIPT ERROR: Error while uploading image")
            return p:resolve(false)
        end 
        local resp = json.decode(imgdata)
        if not resp or not resp.url then 
            print("^1SCRIPT ERROR: Error while uploading image")
            return p:resolve(false)
        end 
        p:resolve(resp.url)
    end)

    Wait(3000)

    takingpic = false 

    DeleteEntity(vehicle)
    SetModelAsNoLongerNeeded(hash)

    ClearFocus()
    DisplayHud(true)
    DisplayRadar(true)
    RenderScriptCams(false)
    DestroyCam(cam, true)
    SetCamActive(cam, false)

    local image = Citizen.Await(p)

    return image
end)


local testing = false
RegisterNetEvent('bc_auction:spawnVehicle', function(data)
    print("s", data)
    local coords = GetEntityCoords(PlayerPedId())
	local dist = #(coords - vector3(-363.2847, -124.9899, 38.697391))
	if dist < 70 then 
        print("disok")
		local hash = data.model
        if not IsModelInCdimage(hash) or testing then 
			TriggerEvent('esx:showNotification', "Ez az autó nem tesztelhető!")
            return
        end 
         print("modelok")
        while not HasModelLoaded(hash) do 
            RequestModel(hash)
            Citizen.Wait(10)
        end 
        local svcoords = GetEntityCoords(PlayerPedId())
        local vehicle = CreateVehicle(hash, -1735.94, -2926.65, 13.5, 314.81, false, false)
        -- bc_kocsitorles: legalis spawn jelolese
        if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
        if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
        Citizen.Wait(1000)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetModelAsNoLongerNeeded(hash)
        ESX.Game.SetVehicleProperties(vehicle, data)
        local start = GetGameTimer()
        testing = true 
        Citizen.CreateThread(function()
            while testing do 
                Citizen.Wait(0)
                local rem = 60000 - (GetGameTimer() - start)
                if rem <= 0 then 
                    testing = false 
                end 
                if GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then 
                    testing = false
                end 
                if #(vector3(-1735.94, -2926.65, 13.5) - GetEntityCoords(PlayerPedId())) > 900.0 then 
                    testing = false
                end 
                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextCentre(1)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentString("Hátra van ~g~"..math.floor(rem/1000).." mp")
                EndTextCommandDisplayText(0.5, 0.9)
            end 
            DeleteEntity(vehicle)
            SetEntityCoords(PlayerPedId(), svcoords)
        end)
	else 
		TriggerEvent('esx:showNotification', "Csak az autókerből indíthatod a tesztelést!")
	end 
end)

--[[]]