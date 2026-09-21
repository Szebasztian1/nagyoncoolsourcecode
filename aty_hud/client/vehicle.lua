SpeedMultiplier = 3.6
Cruise = false
SeatBelt = false
cs, fs = 0.0, 0.0
Ejected = false
MapAlwaysOn = true
MapOn = true

CreateThread(function()
    local lightsOn, highlightsOn, carSpeed, realSpeed, rpm, rpmMat, gear, lastGear, isDoorOpen, vehReversing, vehicleFuel, indicator, vehicleType = nil
    local sleep = 1000

    while true do
        local ped = PlayerPedId()
        isInVehicle = IsPedInAnyVehicle(ped, false)

        sleep = 1000

        if isInVehicle then
            sleep = 600

            if not MapOn then
                MapOn = true
                DisplayRadar(true)
            end

            local vehicle = GetVehiclePedIsIn(ped, false)
            _, lightsOn, highlightsOn = GetVehicleLightsState(vehicle)
            carSpeed = GetEntitySpeed(vehicle)

            -- Physics can return NaN/inf speed (e.g. after an explosion), which makes
            -- math.ceil return a float and breaks the %d format, killing this thread.
            if carSpeed ~= carSpeed or carSpeed > 1000.0 or carSpeed < 0.0 then
                carSpeed = 0.0
            end

            realSpeed = ("%d"):format(math.ceil(carSpeed * SpeedMultiplier))
            rpm = GetVehicleCurrentRpm(vehicle)
            gear = GetVehicleCurrentGear(vehicle)
            lastGear = GetVehicleHighGear(vehicle)
            isDoorOpen = false
            vehReversing = false
            vehicleFuel = 0
            indicator = GetVehicleIndicatorLights(vehicle)
            local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

            if Config.UseCustomFuel then
                vehicleFuel = Config.CustomFuel(vehicle)
            else
                vehicleFuel = GetVehicleFuelLevel(vehicle)
            end
    
            for i = 0, 3 do
                local doorsangle = GetVehicleDoorAngleRatio(vehicle, i)
    
                if doorsangle ~= 0.0 then
                    isDoorOpen = true
                end
            end
    
            if GetEntitySpeedVector(vehicle, true).y < -0.1 then
                vehReversing = true
            else
                vehReversing = false
            end

            if Config.UseSeatBelt then
                if not SeatBelt then
                    fs = cs
                    cs =  carSpeed
                    mfwd = GetEntitySpeedVector(vehicle, true).y > 1.0
                    vhfr = (fs - cs) / GetFrameTime() > 1000
                    
					if mfwd and fs * 3.6 > Config.MinSpeedToThrowFromVehicle and vhfr then
						Ejected = true
						ragdollP()
					else
						Ejected = false
						prevVelocity = GetEntityVelocity(vehicle)
					end
                else
                    Ejected = false
                    fs = 0.0
                    cs = 0.0
                end
			end

            if vehicleType == nil then
                local cb = GetVehicleType(GetVehiclePedIsIn(PlayerPedId(), false))
                --triggerServerCallback("aty_hud:server:getVehicleType", function(cb)
                    vehicleType = cb
    
                    SendNUIMessage({
                        action = "updateVehicleType",
                        vehicleType = vehicleType,
                    })
                --end)
            end

            SendNUIMessage({
                action = 'updateVehicle',
                speed = realSpeed,
                rpm = rpm,
                fuel = vehicleFuel,
                gear = gear,
                lastGear = lastGear,
                isDoorOpen = isDoorOpen,
                lightsOn = lightsOn,
                vehReversing = vehReversing,
                highlightsOn = highlightsOn,
                indicator = indicator,
                vehicleHash = vehicleName,
                braking = GetVehicleHandbrake(vehicle),
                engineHealth = GetVehicleEngineHealth(vehicle),
                bodyHealth = GetVehicleBodyHealth(vehicle),
                vehicleType = vehicleType,
                pitch = GetEntityPitch(vehicle)
            })
        else
            cs, fs = 0.0, 0.0
			Ejected = false
            vehicleType = nil
            SetVehicleMaxSpeed(vehicle, 0.0)

            --if not MapAlwaysOn and MapOn then
            if not IsPSMenu() then 
                DisplayRadar(true)
                MapOn = true
            end 
            --end
            
            if Cruise then
				Cruise = false
				SendNUIMessage({
					action = "toggleCruise",
					cruise = Cruise
				})
			end

			if SeatBelt then
				SeatBelt = false
			end
        end

        Wait(sleep)
    end
end)
local lastused = 0
if Config.UseCruiseControl then
    RegisterKeyMapping('cruisecontrol', 'Toggle Cruise Control', 'keyboard', Config.CruiseKey)
    RegisterCommand("cruisecontrol", function(src, args, raw)
        if vehicleType == "boat" or vehicleType == "plane" or vehicleType == "heli" then return end
        if GetGameTimer() < lastused + 2000 then 
            return TriggerEvent("esx:showNotification", "Ne spammeld a tempomatot!")
        end 
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local isDriver = GetPedInVehicleSeat(vehicle, -1) == ped
        local carSpeed = GetEntitySpeed(vehicle)

        lastused = GetGameTimer()

        if isDriver and vehicle ~= 0 then

            if carSpeed < 5 then 
                Config.Notify(Translations[Config.Locale]["CRUISE"], string.format(Translations[Config.Locale]["CRUISE_CANT_SET"], math.floor(5*SpeedMultiplier)), "error", 5000, "fas fa-car-crash", "red")
                return 
            end
            
            if not Cruise then
                Cruise = true
                SetVehicleMaxSpeed(vehicle, carSpeed)
                Config.Notify(Translations[Config.Locale]["CRUISE"], string.format(Translations[Config.Locale]["CRUISE_SET"], math.floor(carSpeed*SpeedMultiplier)), "success", 5000, "fas fa-car-crash", "green")
            else
                Cruise = false
                Config.Notify(Translations[Config.Locale]["CRUISE"], Translations[Config.Locale]["CRUISE_DISABLED"], "error", 5000, "fas fa-car-crash", "red")
                SetVehicleMaxSpeed(vehicle, 0.0)
            end

            SendNUIMessage({
                action = "toggleCruise",
                cruise = Cruise,
            })
        end
    end)
end

if Config.UseSeatBelt then
    RegisterKeyMapping('toggleseatbelt', 'Toggle Seat Belt', 'keyboard', Config.SeatBeltKey)
    RegisterCommand("toggleseatbelt", function(src, args, raw)
        if vehicleType == "bike" or vehicleType == "boat" then return end
		local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

		if vehicle ~= 0 then
			SeatBelt = not SeatBelt

            if SeatBelt then
                Config.Notify(Translations[Config.Locale]["SEATBELT"], Translations[Config.Locale]["SEATBELT_PUT_ON"], "success", 5000, "fas fa-car-crash", "green")
            else
                Config.Notify(Translations[Config.Locale]["SEATBELT"], Translations[Config.Locale]["SEATBELT_REMOVED"], "error", 5000, "fas fa-car-crash", "red")
            end
		end
    end)
end

RegisterNetEvent("aty_hud:client:toggleSeatBelt", function(val)
    SeatBelt = val
end)