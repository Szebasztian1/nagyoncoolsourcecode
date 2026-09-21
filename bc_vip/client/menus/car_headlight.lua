function OpenCarHeadlightMenu()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)

    if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == player then 
        local elements = {
        { label = "Nincs", value = -2 },
        { label = "Alap", value = -1 },
        { label = "Fehér", value = 0 },
        { label = "Kék", value = 1 },
        { label = "Sötétkék", value = 2 },
        { label = "Zöld", value = 3 },
        { label = "Világoszöld", value = 4 },
        { label = "Sárga", value = 5 },
        { label = "Arany", value = 6 },
        { label = "Narancs", value = 7 },
        { label = "Piros", value = 8 },
        { label = "Rózsaszín", value = 9 },
        { label = "Rózsa", value = 10 },
        { label = "Lila", value = 11 },
        { label = "Fekete", value = 12 },
        }

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'headlight', {
            title    = 'Fényszóró színe',
            align    = "bottom-right",
            elements = elements
        }, function(data, menu)
            local player = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(player, false)
            if vehicle and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == player then
                if data.current.value == -2 then 
                    ToggleVehicleMod(vehicle, 22, false) 
                    SetVehicleHeadlightsColour(vehicle, -1)
                else
                    ToggleVehicleMod(vehicle, 22, true) 
                    SetVehicleHeadlightsColour(vehicle, data.current.value)
                end 
            else 
                Notify("Nem vagy az autóban!")
                menu.close()
            end 
        end, function(data, menu)
            menu.close()
        end)
    else 
        Notify("Nem vagy az autóban!")
    end 
end