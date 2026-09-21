local lastveh = 0
local showui = false 

RegisterCommand("kmora", function()
    showui = not showui
end)


CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if not DoesEntityExist(veh) or GetPedInVehicleSeat(veh, -1) ~= ped or not Config.InspectionMilages[GetVehicleClass(veh)] then
            lastveh = 0
            SendNUIMessage({
                type = "data",
                show = false
            })
        elseif NetworkGetEntityIsNetworked(veh) then
            local plate = GetVehicleNumberPlateText(veh)
            local netveh = NetworkGetNetworkIdFromEntity(veh)
            local lastpos = GetEntityCoords(veh)
            local class = GetVehicleClass(veh)
            local milage = Entity(veh).state.mileage
            local motorhealth = Entity(veh).state.motorhealth
            local lastinspection = Entity(veh).state.lastinspection
            if not milage or not motorhealth then
                --FROM SERVER
                local data = lib.callback.await('bc_carsys:getcardata', false, plate, netveh)
                if not data then
                    data = {}
                end
                milage = (data.milage or 0)
                motorhealth = (data.motorhealth or 100)
                lastinspection = (data.lastinspection or 0)
            end
            local lastmilage = milage
            lastveh = veh 
            while lastveh == veh do 
                ped = PlayerPedId()
                veh = GetVehiclePedIsIn(ped, false)
                if DoesEntityExist(veh) then 
                    local newmotorhealth = Entity(veh).state.motorhealth
                    if newmotorhealth and newmotorhealth ~= motorhealth then
                        motorhealth = newmotorhealth
                    end
                    if motorhealth < 0.2 then
                        SetVehicleEngineHealth(veh, 0.0)
                        SetVehicleEngineOn(veh, false, true, true)
                        SetVehicleUndriveable(veh, true)
                    end 
                    local pos = GetEntityCoords(veh)
                    local dist = #(pos - lastpos)
                    if dist > 0.1 then
                        milage = milage + (dist * Config.DistMult)
                        lastpos = pos
                    end
                    if lastmilage + 10 < milage then
                        lastmilage = milage
                        TriggerServerEvent('bc_carsys:savemilage', plate, netveh, milage, class, false)
                    end
                    local nextinspection = (Config.InspectionMilages[GetVehicleClass(veh)] or 0)
                    if showui or (motorhealth < 10.2) or ((milage-lastinspection) > nextinspection*0.75) then 
                        SendNUIMessage({
                            type = "data",
                            show = true,
                            milage = milage,
                            checkengine = motorhealth < 10.2,
                            nextinspection = nextinspection,
                            lastinspection = lastinspection
                        })
                    else 
                        SendNUIMessage({
                            type = "data",
                            show = false
                        })
                    end 
                end 
                Wait(1000)
            end 
            TriggerServerEvent('bc_carsys:savemilage', plate, netveh, milage, class, true)
        end
        Wait(1000)
    end
end)

--Math.round((data.milage - data.lastinspection)) + ' km/'+data.nextinspection

AddEventHandler('bc_carsys:check', function(data)
    local veh = data.entity
    if DoesEntityExist(veh) and not DoesEntityExist(GetPedInVehicleSeat(veh, -1)) and Config.InspectionMilages[GetVehicleClass(veh)] then
        if not lib.progressBar({
            duration = 2000,
            label = 'Autó vizsgálata',
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
            },
            anim = {
                scenario = 'PROP_HUMAN_BUM_BIN'
            },
        }) then return end 
        
        local plate = GetVehicleNumberPlateText(veh)
        local netveh = NetworkGetNetworkIdFromEntity(veh)
        local milage = Entity(veh).state.mileage
        local motorhealth = Entity(veh).state.motorhealth
        local lastinspection = Entity(veh).state.lastinspection
        if not milage or not motorhealth then
            --FROM SERVER
            local data = lib.callback.await('bc_carsys:getcardata', false, plate, netveh)
            if not data then
                data = {}
            end
            milage = (data.milage or 0)
            motorhealth = (data.motorhealth or 100)
            lastinspection = (data.lastinspection or 0)
        end

        local rebuildprice = Config.GetRebuildPrice(veh)
        local inspectionprice = Config.GetInspectionPrice(veh)
        
        lib.registerContext({
            id = 'car_inspection',
            title = 'Autó szervízelés',
            options = {
              {
                title = 'Motor állapota',
                description = math.ceil(motorhealth/20)..'/5',
                icon = 'circle',
                disabled = true
              },
              {
                title = 'Olaj + Szűrőcsere',
                description = 'Ára: $'..inspectionprice,
                icon = 'circle',
                onSelect = function()
                    if not lib.progressBar({
                        duration = 60000,
                        label = 'Olaj + Szűrőcsere',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                        },
                        anim = {
                            scenario = 'PROP_HUMAN_BUM_BIN'
                        },
                    }) then return end 
                    TriggerServerEvent('bc_carsys:oilchange', plate, netveh, inspectionprice, milage)
                end
              },
              {
                title = 'Motorfelújítás',
                description = 'Ára: $'..rebuildprice,
                icon = 'circle',
                onSelect = function()
                    if not lib.progressBar({
                        duration = 120000,
                        label = 'Motorfelújítás',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            move = true,
                            car = true,
                        },
                        anim = {
                            scenario = 'PROP_HUMAN_BUM_BIN'
                        },
                    }) then return end 
                    TriggerServerEvent('bc_carsys:rebuild', plate, netveh, rebuildprice, milage)
                end
              },
            }
        })
        lib.showContext('car_inspection')
    else 
        TriggerEvent("esx:showNotification", "Ezt az autót nem tudod megvizsgálni vagy ülnek a vezető ülésben!")
    end
end)

CreateThread(function() 
    exports.ox_target:addGlobalVehicle({
		{
			name = 'bc_carsys',
			event = 'bc_carsys:check',
			icon = 'fa-solid fa-eye-slash',
			label = 'Autó vizsgálata',
			groups = Config.AllowedJobs
		},
	})
end)




---INNEN VEDD KI HA SZAR
local alldoors = { "door_dside_f", "door_pside_f", "door_dside_r",  "door_pside_r" }
local doorseats = { ["door_dside_f"] = -1, ["door_pside_f"] = 0, ["door_dside_r"] = 1,  ["door_pside_r"] = 2 }
local allvehs = {}
--[[CreateThread(function()
    while true do 
        Wait(2000)
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        allvehs = {}
        local gamevehs = GetGamePool("CVehicle")
        for _, veh in pairs(gamevehs) do 
            if DoesEntityExist(veh) and #(GetEntityCoords(veh) - pos) < 200.0 then 
                allvehs[#allvehs+1] = veh
            end 
        end 
    end 
end)]]

local allowshuffle = false 

RegisterNetEvent("SeatShuffle")
AddEventHandler("SeatShuffle", function()
    local ped = PlayerPedId()
    local currentvehicle = GetVehiclePedIsIn(ped, false)
	if IsPedInAnyVehicle(ped, false) then
		
		seat=-1
		if GetPedInVehicleSeat(currentvehicle, -1) == ped then
			seat=0
		end

        SetPedConfigFlag(ped, 184, false)
        Wait(500)
		
		--if GetPedInVehicleSeat(currentvehicle,-1) == ped then
			TaskShuffleToNextVehicleSeat(ped,currentvehicle)
		--end
        SetPedIntoVehicle(ped,currentvehicle, seat)

        SetPedConfigFlag(ped, 184, true)


		allowshuffle=true
		while GetPedInVehicleSeat(currentvehicle,seat) == ped do
			Citizen.Wait(0)
		end
		allowshuffle=false
	else
		allowshuffle=false
		CancelEvent('SeatShuffle')
	end
end)

RegisterCommand("shuff",function()
    TriggerEvent("SeatShuffle")
end,false)
RegisterCommand("ules",function()
    TriggerEvent("SeatShuffle")
end,false)


--[[local disabled = false

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local restrictSwitching = false
        
        if IsPedInAnyVehicle(ped, false) and not disabled then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), 0) == ped then
                restrictSwitching = true
            end
        end
        
        SetPedConfigFlag(ped, 184, restrictSwitching)
        Wait(300)
    end
end)

local function shuffleSeat()
    if not DoesEntityExist(GetVehiclePedIsIn(PlayerPedId(), false)) then return end 
    CreateThread(function()
        disabled = true
        Wait(1000)
        
        TaskShuffleToNextVehicleSeat(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId(), false))
        Wait(3000)
        disabled = false
    end)
end

RegisterCommand("shuff", shuffleSeat)
RegisterCommand("ules", shuffleSeat)]]



local showicon = true 

--[[RegisterCommand("autoajto", function()
    showicon = not showicon
end)

CreateThread(function()
    while true do 
        local wa = 500
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)


        if IsPedInAnyVehicle(ped, false) and allowshuffle == false then
            wa = 1
			SetPedConfigFlag(ped, 184, true)
			if GetIsTaskActive(ped, 165) then
				seat=0
				if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) == ped then
					seat=-1
				end
				
				SetPedIntoVehicle(ped, GetVehiclePedIsIn(ped, false), seat)
		    end
        end 

        if not IsPedInAnyVehicle(ped) then 
            local mindis = 1000
            local minveh = 0 
            local mindoor = -1
            local mincoords = false

            for _, veh in pairs(allvehs) do 
                if veh and DoesEntityExist(veh) then 
                    for i = 0, GetNumberOfVehicleDoors(veh) - 1, 1 do]]
                        --if alldoors[i+1] and GetEntityBoneIndexByName(veh, alldoors[i+1]) ~= -1 and doorseats[alldoors[i+1]] and IsVehicleSeatFree(veh, doorseats[alldoors[i+1]]) then
                            --print(alldoors[i+1])
                            --[[local scoords = GetEntryPositionOfDoor(veh, i)
                            local dis = #(scoords - pos)
                            if dis < mindis then 
                                mindis = dis
                                minveh = veh 
                                mindoor = alldoors[i+1] 
                                mincoords = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, alldoors[i+1]))
                            end 
                            --DrawMarker(2, scoords.x, scoords.y, scoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.3, 0.3, 0.3, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                        end
                        
                    end
                end 
            end 
            if mindis < 1.4 and mincoords then 
                wa = 1
                --DrawMarker(2, mincoords.x, mincoords.y, mincoords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.3, 0.3, 0.3, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                if showicon then
                    DrawText3D(mincoords.x, mincoords.y, mincoords.z, "🚪") 
                end 
                if IsControlJustPressed(0, 23) then 
                    Wait(1)
                    --print("pressed")
                    if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and doorseats[mindoor]  then 
                        --print("clear tasks")
                        ClearPedTasks(ped)
                        ClearPedSecondaryTask(ped)
                        TaskEnterVehicle(ped, minveh, 10000, doorseats[mindoor], 1.0, 1, 0)
                    end 
                    --Wait(2000)
                end 
            end 
        end 

        Wait(wa)
    end 
end)]]

function DrawText3D(x, y, z, text) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.0, 0.25*scale)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(1)
        BeginTextCommandDisplayText("STRING")
	    AddTextComponentString(text)
	    EndTextCommandDisplayText(_x, _y)
    end
end