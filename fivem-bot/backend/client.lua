-- weather and time
if(config.enableweather == true) then
    local weather = "EXTRASUNNY"
    RegisterNetEvent('NAT2k15:updateWeatherandTime')
    AddEventHandler('NAT2k15:updateWeatherandTime', function(fixedweather)
        weather = fixedweather
    end)
    

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(400)
            SetWeatherTypeOverTime(weather, 15.0)
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypePersist(weather)
            SetWeatherTypeNow(weather)
            SetWeatherTypeNowPersist(weather)
            if weather == 'XMAS' then
                SetForceVehicleTrails(true)
                SetForcePedFootstepsTracks(true)
            else
                SetForceVehicleTrails(false)
                SetForcePedFootstepsTracks(false)
            end
        end
    end)

        -- player spawned - 
    AddEventHandler('playerSpawned', function()
        Citizen.Wait(1000)
        TriggerServerEvent('NAT2K15:requestSync')
    end)
    
end

ESX = exports['es_extended']:getSharedObject()

ESX.RegisterClientCallback("bc_fivembot:getCarNames", function(cb, data)
    local carnames = {}
    for _, v in pairs(data) do 
        carnames[v] = GetDisplayNameFromVehicleModel(v)
    end 
    cb(carnames)
end)



RegisterNetEvent("realtime:event")
AddEventHandler("realtime:event", function(h, m, s)
	NetworkOverrideClockTime(h, m, s)
end)

CreateThread(function()
    Wait(5000)
    while true do 
        --SetMillisecondsPerGameMinute(5000)
        SetMillisecondsPerGameMinute(60000)
        TriggerServerEvent("realtime:event")
        TriggerServerEvent('NAT2K15:requestSync')
        Wait(2*60000)
    end 
end)