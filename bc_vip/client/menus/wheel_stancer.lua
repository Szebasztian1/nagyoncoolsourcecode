--[[RegisterCommand('setfrontoffset', function(s, args, r)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh and veh ~= 0 and args[1] and tonumber(args[1]) then 
        AddFrontOffset(veh, tonumber(args[1]))
    end 
end)

RegisterCommand('setrearoffset', function(s, args, r)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh and veh ~= 0 and args[1] and tonumber(args[1]) then 
        AddRearOffset(veh, tonumber(args[1]))
    end 
end)

RegisterCommand('setfrontrot', function(s, args, r)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh and veh ~= 0 and args[1] and tonumber(args[1]) then 
        AddFrontRot(veh, tonumber(args[1]))
    end 
end)

RegisterCommand('setrearrot', function(s, args, r)
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh and veh ~= 0 and args[1] and tonumber(args[1]) then 
        AddRearRot(veh, tonumber(args[1]))
    end 
end)]]


function OpenWheelStancerMenu()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)

    if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == player then 
        local elements = {
            { label="Első kerék távolsága", value = "frontoffset" },
            { label='Hátsó kerék távolsága', value = "rearoffset" },
            { label='Első kerék döntése', value = "frontrot" },
            { label='Hátsó kerék döntése', value = "rearrot" },
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stance', {
            title    = 'Kerékdöntés',
            align    = "center",
            elements = elements
        }, function(data, menu)
            local player = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(player, false)
            if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == player then
                if data.current.value  then 
                    OpenValMenu(data.current.value)
                end 
            else 
                Notify("Nem vagy autóba!")
                menu.close()
            end 
        end, function(data, menu)
            menu.close()
        end)
    else 
        Notify("Nem vagy autóba!")
    end 
end

function OpenValMenu(t)
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)

    if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == player then 
        local elements = {
            { label="Alap", value = 0 },
            { label='5%', value = 0.051 },
            { label='10%', value = 0.11 },
            { label='15%', value = 0.151 },
            { label='20%', value = 0.21 },
            { label='25%', value = 0.251 },
            { label='30%', value = 0.31 },
            { label='35%', value = 0.351 },
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stance_val', {
            title    = 'Kerékdöntés',
            align    = "center",
            elements = elements
        }, function(data, menu)
            local player = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(player, false)
            if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == player then
                if data.current.value then 
                    if t == "frontoffset" then 
                        exports["villamos_stancer"]:AddFrontOffset(vehicle, (data.current.value == 0 and 0 or 0.8+(data.current.value) ))
                    elseif t == "rearoffset" then 
                        exports["villamos_stancer"]:AddRearOffset(vehicle, (data.current.value == 0 and 0 or 0.8+(data.current.value)))
                    elseif t == "frontrot" then 
                        exports["villamos_stancer"]:AddFrontRot(vehicle, data.current.value)
                    elseif t == "rearrot" then 
                        exports["villamos_stancer"]:AddRearRot(vehicle, data.current.value)
                    end 
                end 
            else 
                Notify("Nem vagy autóba!")
                menu.close()
            end 
        end, function(data, menu)
            menu.close()
        end)
    else 
        Notify("Nem vagy autóba!")
    end 
end 