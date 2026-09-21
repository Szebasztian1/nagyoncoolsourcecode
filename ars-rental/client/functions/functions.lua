local rentedCar = false

local function spawnRentalCar(vehicle, spawnPos, time)
    local playerPed = cache.ped

    DoScreenFadeOut(500)
    Wait(500)

    local rentalCar = utils.createVehicle(vehicle, spawnPos, true, false)
    exports["gs_eventprotect"]:GS_TriggerServerEvent("ars-rental:rentalCar", NetworkGetNetworkIdFromEntity(rentalCar), time)

    lib.setVehicleProperties(rentalCar, { plate = Config.PlatePrefix..math.random(1, 99999) })

    if GetResourceState("rcore_fuel") == "started" then 
        exports["rcore_fuel"]:SetFuel(rentalCar, 100.0)
    end 

    Wait(500)
    DoScreenFadeIn(600)

    rentedCar = true
    utils.showNotification("Sikeressen béreltél egy járművet", "success")

    TaskEnterVehicle(playerPed, rentalCar, -1, -1, 1.0, 1, 0)

    SetTimeout(time, function()
        if rentalCar then
            if cache.vehicle then
                TaskLeaveVehicle(playerPed, rentalCar, 0)

                while cache.vehicle do
                    Wait(10)
                end

                Wait(500)
                NetworkFadeOutEntity(rentalCar, true, true)
                Wait(100)

                DeleteVehicle(rentalCar)
                utils.showNotification("A jármű bérleted lejárt", "success")
                rentedCar = false
            else
                if DoesEntityExist(rentalCar) then
                    DeleteVehicle(rentalCar)
                end

                utils.showNotification("A jármű bérleted lejárt", "success")
                rentedCar = false
            end
        end
    end)

    CreateThread(function()
        local start = GetGameTimer()
        local en = start + time 
        while true do 
            local rem = en - GetGameTimer()
            local remmin = math.floor(rem/60000)
            if remmin <= 0 then 
                return 
            end 
            TriggerEvent("esx:showNotification", "Kevesebb mint "..remmin.." perced maradt hátra a bérlésből!")
            Wait(60000)
        end 
    end)
end

local function calculateRentalCost(price, time, method)
    local cost = 0

    if method == "minutes" then
        cost = math.ceil(price * Config.mpMinutes * time / 200)
        time = time * 60000
    elseif method == "hours" then
        cost = math.ceil(price * Config.mpHours * time / 100)
        time = time * 3600000
    end

    return cost, time
end

local function rentCar(vehicle)
    if rentedCar then return end

    local input = lib.inputDialog('Bérlő', {
        { type = "number", label = "Idő (Perc)", default = 1 },
        --[[{
            type = "select",
            label = "Idő",
            default = "minutes",
            options = {
                { value = "minutes", "Perc" },
                --{ value = "Hours",   "Hours" },
            }
        },]]
    })

    if not input then return end

    local time = input[1]
    local method = "minutes"

    if time > 60 then 
        return  utils.showNotification("Max 1 órára bérelhetsz autót", "success")
    end 

    local rentalCost, rentalTime = calculateRentalCost(vehicle.price, time, method)
    --    --local money = exports.ox_inventory:Search("count", "money", nil)
    local money = lib.callback.await('ars-rental:getBank', false)

    if money >= rentalCost then
        local alert = lib.alertDialog({
            header = 'Black City Bérlő',
            content = 'Biztos ki akarod bérelni? \n ennyibe fog fájni: ' .. rentalCost .. "$",
            centered = true,
            cancel = true
        })
        if alert == "confirm" then
            TriggerServerEvent("ars-rental:removeMoney", { price = rentalCost, coords = vehicle.spawnPosition })
            spawnRentalCar(vehicle.car, vehicle.spawnPosition, rentalTime)
        end
    else
        utils.showNotification("Nincs Elég pénzed", "error")
    end
end

function openRentalMenu(data)
    local vehicles = {}

    for i = 1, #data.vehicles, 1 do
        local vehicle = data.vehicles[i]
        table.insert(vehicles, {
            title = vehicle.label,
            description = "Ár: $" .. vehicle.price,
            onSelect = function()
                rentCar(vehicle)
            end,
        })
    end

    lib.registerContext({
        id = 'ars_rental_menu',
        title = 'Bérlő',
        options = vehicles
    })

    lib.showContext('ars_rental_menu')
end
