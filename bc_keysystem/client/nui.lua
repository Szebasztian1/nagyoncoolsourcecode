function CloseNui()
    SetNuiFocus(false, false)
    SendNUIMessage({
		action = "show",
		enable = false
	})
end

RegisterNUICallback('exit', function(data, cb)
    CloseNui()
    cb(1)
end)

RegisterNUICallback('prices', function(data, cb)
    cb({
        newkey = Config.Price,
        alarmprice = Config.Alarms.alarm.price,
        alarmgpsprice = Config.Alarms.alarmgps.price,
    })
end)

RegisterNUICallback('getcars', function(data, cb)
    local cars = lib.callback.await('carkeys:getCars', false)
    local nuicars = {}
    if not cars then 
        return cb({})
    end
    if #cars < 1 then 
        return cb({})
    end
    for i = 1, #cars do
        local veh = json.decode(cars[i].vehicle)
        local label 
        local isjobveh = ""
        if not veh.model then 
            label = "Ismeretlen"
        else 
            label = GetDisplayNameFromVehicleModel(veh.model)
            if GetLabelText(label) ~= "NULL" then 
                label = GetLabelText(label)
            end 
        end 
        if cars[i].job and cars[i].job ~= "civ" then 
            isjobveh = " (Frakció)"
        end 
        nuicars[#nuicars + 1] = {
            plate = cars[i].plate,
            label = label..isjobveh
        }
    end
    cb(nuicars)
end)

RegisterNUICallback('getkeys', function(data, cb)
    if not data.plate then 
        return cb({})
    end 
    local keys = lib.callback.await('carkeys:getKeys', false, data.plate)
    local nuikeys = {}
    if not keys then 
        return cb({})
    end
    if #keys < 1 then 
        return cb({})
    end
    for i = 1, #keys do
        nuikeys[#nuikeys + 1] = {
            label = keys[i].label,
            id = keys[i].keyid
        }
    end
    cb(nuikeys)
end)

RegisterNUICallback('delkey', function(data, cb)
    if not data.kid then 
        return cb(1)
    end 
    CloseNui()
    TriggerServerEvent("carkeys:deleteKey", data.kid)
    cb(1)
end)

RegisterNUICallback('newkey', function(data, cb)
    if not data.plate or not data.label then 
        return cb(1)
    end 
    if data.label == "" then 
        return cb(1)
    end 
    CloseNui()
    TriggerServerEvent("carkeys:createKey", data.plate, data.label, (data.bank or false))
    cb(1)
end)

RegisterNUICallback('getalarm', function(data, cb)
    if not data.plate then 
        return cb(false)
    end 
    local alarm = lib.callback.await('carkeys:getAlarm', false, data.plate)
    if not Config.Alarms[alarm] then 
        return cb(false)
    end 
    cb(Config.Alarms[alarm].label)
end)

RegisterNUICallback('buyalarm', function(data, cb)
    if not data.plate or not data.alarmtyp then 
        return cb(1)
    end 
    CloseNui()
    TriggerServerEvent("carkeys:addAlarm", data.plate, data.alarmtyp, (data.bank or false))
    cb(1)
end)

RegisterNUICallback('removealarm', function(data, cb)
    if not data.plate  then 
        return cb(1)
    end 
    CloseNui()
    TriggerServerEvent("carkeys:removeAlarm", data.plate)
    cb(1)
end)

RegisterNUICallback('getpos', function(data, cb)
    if not data.plate  then 
        return cb(1)
    end 
    CloseNui()
    cb(1)
    local pos = lib.callback.await('carkeys:getPos', false, data.plate)
    if not pos then 
        return TriggerEvent("esx:showNotification", "Az autó egy garázsban van!")
    end 
    SetNewWaypoint(pos.x, pos.y)
    TriggerEvent("esx:showNotification", "Az autó pozíciója kijelölve a térképen!")
end)