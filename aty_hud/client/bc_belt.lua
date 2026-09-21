local beltOn = false
local speedBuffer, velBuffer = {}, {}
local wasInCar = false

local hashSf71h = GetHashKey("sf71h")
local hashAmg = GetHashKey("amg")
local hashW11 = GetHashKey("W11")
local hashForma1 = GetHashKey("forma1")

function IsCar(veh)
    local model = GetEntityModel(veh)
    if  model == hashSf71h then
        return true
    end
    if model == hashAmg or model == hashW11 or model == hashForma1 then
        return false
    end
    local vc = GetVehicleClass(veh)
    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20) or (vc == 15)
end

function Fwv(entity)  
    local hr = GetEntityHeading(entity) + 90.0
    if hr < 0.0 then hr = 360.0 + hr end
    hr = hr * 0.0174533
    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

CreateThread(function()
	while true do
        local player = PlayerPedId()
		local car = GetVehiclePedIsIn(player, false)
		if car ~= 0 and (wasInCar or IsCar(car)) then
            if not wasInCar then 
                SendNUIMessage({
                    action = "bc_toggleBelt",
                    seatBelt = beltOn,
                    sbsoundoff = false
                })
            end 
			wasInCar = true
			
	    	if beltOn then 
                DisableControlAction(0, 75)
            end
			
			local curVel = GetEntityVelocity(car)

			speedBuffer[2] = speedBuffer[1]
			speedBuffer[1] = #curVel

			if speedBuffer[2] and not beltOn and GetEntitySpeedVector(car, true).y > 1.0  and speedBuffer[1] > 15 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.455) then
				local co = GetEntityCoords(player)
				local fw = Fwv(player)
				SetEntityCoords(player, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
				SetEntityVelocity(player, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
				Wait(500)
				SetPedToRagdoll(player, 1000, 1000, 0, 0, 0, 0)
			end

			velBuffer[2] = velBuffer[1]
			velBuffer[1] = curVel
		elseif wasInCar then
            wasInCar = false
            beltOn = false
           	speedBuffer[1], speedBuffer[2] = 0.0, 0.0
            SendNUIMessage({
                action = "bc_toggleBelt",
                seatBelt = beltOn,
                sbsoundoff = (DoesEntityExist(car) == true)
            })
        else 
            Wait(600)
        end
        Wait(10) 
	end
end)

--[[RegisterNUICallback('loadSetting', function(data, cb)
    local settingsid = data.setid 
    TriggerServerEvent("aty_hud:loadSetting", settingsid)
    cb('ok')
end)

CreateThread(function()
    Wait(5000)
    local setid2 = GetResourceKvpInt('hud-set-bc')
    TriggerServerEvent("aty_hud:loadSetting:kvp", setid2)
end)

RegisterNetEvent("bc-hud-set:update", function(settingsid)
    SetResourceKvp('hud-set-bc', settingsid)
    SendNUIMessage({
        action = "setsettingid",
        setid = settingsid 
    })
end)]]


RegisterNetEvent("bc:kickcarsb", function()
    if not beltOn then 
        ClearPedTasksImmediately(PlayerPedId()) 
    end 
end)

RegisterCommand('biztiov', function()
    local car = GetVehiclePedIsIn(PlayerPedId(), false)
    if not car or car == 0 then return end 
    local vehicleClass = GetVehicleClass(car)

    if not IsCar(car) then
	    print("You can't enable your seatbelt in this type of vehicle")
    else
        beltOn = not beltOn				  
        SendNUIMessage({
            action = "bc_toggleBelt",
            seatBelt = beltOn,
            sbsoundoff = false 
        })
        if beltOn then 
            TriggerEvent("esx:showNotification", "Biztonsági öv becsatolva!")
        else 
            TriggerEvent("esx:showNotification", "Biztonsági öv kicsatolva!")
        end 
    end
end, false)

RegisterKeyMapping('biztiov', 'Biztonsági öv', 'keyboard', 'J')

local showmap = false 


RegisterNetEvent("bc:beltoff", function()
    beltOn = false  
end)
--[[AddEventHandler("map:onoff", function()
    showmap = not showmap 
    if not showmap then return end 
    CreateThread(function()
        while showmap do 
            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped) then 
                showmap = false 
            end 
            local count = exports.ox_inventory:Search('count', 'handmap')
            if count and count < 1 then 
                showmap = false 
            end 

            Wait(1000)
        end 
        DisplayRadar(false)
        if IsPedInAnyVehicle(ped) then 
            DisplayRadar(true)
        end 
        showmap = false 
    end)
end)]]