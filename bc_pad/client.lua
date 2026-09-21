local dynos = {}

CreateThread(function()
    RequestModel(Config.Model)
    while not HasModelLoaded(Config.Model) do
        Wait(100)
    end
    for k, v in pairs(Config.Points) do
        local object = CreateObject(Config.Model, v.platform.x, v.platform.y, v.platform.z,false,false)
		while not DoesEntityExist(object) do Wait(1) end
		Wait(100)
		FreezeEntityPosition(object,true)
		SetEntityHeading(object,v.platform.w)
        dynos[k] = {
            object = object
        }
	end
    SetModelAsNoLongerNeeded(Config.Model)

    AddTextEntry('dyno_start',"Nyomj ~INPUT_CONTEXT~ a padozás elindításához")

    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local sleep = 1000

        for k, v in pairs(Config.Points) do
            local veh = GetVehiclePedIsIn(ped, false)
            if DoesEntityExist(veh) and GetPedInVehicleSeat(veh, -1) == ped then
                local dist = #(pos - vector3(v.platform.x, v.platform.y, v.platform.z))
                if dist < 3 then
                    sleep = 1
                    DisplayHelpTextThisFrame('dyno_start')
                    if IsControlJustReleased(0, 38) then
                        StartDyno(k)
                    end 
                end
            end
            
        end

        Wait(sleep)
    end
end)

GetDefaultHandling = function(vehicle) -- saves default handling of new vehicles
	local ent = Entity(vehicle).state
	local handlings = ent.defaulthandling
	if not ent.engine then
		ent:set('currentengine','default',false)
	end
	if not handlings  then
		handlings = {
			fInitialDriveForce = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fInitialDriveForce'),
			fDriveInertia = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fDriveInertia'),
			fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fInitialDriveMaxFlatVel'),
			fClutchChangeRateScaleUpShift = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fClutchChangeRateScaleUpShift'),
			fClutchChangeRateScaleDownShift = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fClutchChangeRateScaleDownShift'),
			fLowSpeedTractionLossMult = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fLowSpeedTractionLossMult'),
			fTractionLossMult = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fTractionLossMult'),
			fTractionCurveMin = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fTractionCurveMin'),
			fTractionCurveMax = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fTractionCurveMax'),
			fTractionCurveLateral = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fTractionCurveLateral'),
			fBrakeForce = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fBrakeForce'),
			fHandBrakeForce = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fHandBrakeForce'),
			fSuspensionForce = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fSuspensionForce'),
			fSuspensionCompDamp = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fSuspensionCompDamp'),
			fSuspensionReboundDamp = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fSuspensionReboundDamp'),
			fSuspensionUpperLimit = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fSuspensionUpperLimit'),
			fSuspensionLowerLimit = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fSuspensionLowerLimit'),
			fSuspensionRaise = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fSuspensionRaise'),
			fSuspensionBiasFront = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fSuspensionBiasFront'),
			fAntiRollBarForce = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fAntiRollBarForce'),
			fAntiRollBarBiasFront = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fAntiRollBarBiasFront'),
			fRollCentreHeightFront = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fRollCentreHeightFront'),
			fRollCentreHeightRear = GetVehicleHandlingFloat(vehicle,'CHandlingData', 'fRollCentreHeightRear'),
			nInitialDriveGears = GetVehicleHandlingInt(vehicle,'CHandlingData', 'nInitialDriveGears'),

		}
		ent:set('defaulthandling', handlings, true)
		return handlings
	end
	return handlings
end

local gear = 1

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
    local nearbyEntities = {}



    for k, entity in pairs(entities) do
        local distance = #(coords - GetEntityCoords(entity))

        if distance <= maxDistance then
            nearbyEntities[#nearbyEntities + 1] = isPlayerEntities and k or entity
        end
    end

    return nearbyEntities
end

function GetVehiclesInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(GetGamePool('CVehicle'), false, coords, maxDistance)
end


function StartDyno(index)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if not DoesEntityExist(veh) or GetPedInVehicleSeat(veh, -1) ~= ped then
        return 
    end 
    local v = Config.Points[index]

    local targetPos = vector3(v.platform.x + v.offsets.x, v.platform.y + v.offsets.y, v.platform.z + v.offsets.z)
   
    if #GetVehiclesInArea(targetPos, 5.0) > 1 then
        lib.notify({
            title = 'Hiba',
            description = 'Csak egy jármű lehet a dyno padon!',
            type = 'error'
        })
        return
    end

    local alert = lib.alertDialog({
        header = 'Padozás',
        content = 'Leméred az autód teljesítményét? Az ára '..Config.Price..' $ (csak készpénzben fizethető, számla nincs!!!)! FIGYELEM! A pad csak a motor teljesítményét méri, a gumi, kormányozhatóság és más egyéb tényezőket nem tudja figyelembe venni!',
        centered = true,
        cancel = true
    })
    if alert ~= "confirm" then
        return
    end

    local moneyok = lib.callback.await('bc_pad:server:payDyno', false)
    if not moneyok then
        lib.notify({
            title = 'Hiba',
            description = 'Nincs elég pénzed a padozáshoz!',
            type = 'error'
        })
        return
    end

    
    SetEntityCoords(veh, targetPos.x, targetPos.y, targetPos.z)
    SetEntityHeading(veh, v.platform.w)

    SetVehicleBurnout(veh, true)

    gear = 1


    

    local defaultHandling = GetDefaultHandling(veh)

    local turbo = (GetVehicleMod(veh, 18) == -1 and false or true)
    local engine = GetVehicleMod(veh, 11)
    local tuningmult = 1.0
    if engine > 0 then
        tuningmult = tuningmult + (engine * 0.05)
    end
    if turbo then
        tuningmult = tuningmult + 0.1
    end

    local highgear = defaultHandling.nInitialDriveGears

    local maxtqrpm = math.random(2800,3100)

    local calculate_horsepower = function(rpm)
        

        local pow = defaultHandling.fInitialDriveMaxFlatVel * defaultHandling.fInitialDriveForce * tuningmult

        local maxtq = ((2.915*pow)+24.6637)

        local randomizedheat = 1 + math.random(-2,2)/200

        local tq = maxtq * (1 - ((rpm - maxtqrpm)/3000)^2)*randomizedheat
        if rpm > maxtqrpm then
            tq = maxtq * (1 - ((rpm - maxtqrpm)/6200)^2)*randomizedheat
        end
        local hp = (tq * rpm) / 7127

		return hp, tq
    end

    SendNUIMessage({
        action = 'resetDyno'
    })
    local rpmlist = {}
    local hplist = {}
    local nmlist = {}

    for i=1000,6600,150 do
        local hp, nm = calculate_horsepower(i)
        rpmlist[#rpmlist+1] = i
        hplist[#hplist+1] = math.floor(hp)
        nmlist[#nmlist+1] = math.floor(nm)
    end

    Citizen.CreateThread(function()
        local running = true
        local lastws = 0
        local maxacc = 0
        while running do
            Wait(10)

            local rpm = GetVehicleCurrentRpm(veh)*8000
            SetVehicleCurrentGear(veh, gear)
            TaskVehicleTempAction(PlayerPedId(), veh, 23, 100) -- hold the throttle 

            --local hp, nm = calculate_horsepower(rpm)
            if rpm > 1000 then 
                --rpmlist[#rpmlist+1] = math.floor(rpm)
                --hplist[#hplist+1] = math.floor(hp)
                --nmlist[#nmlist+1] = math.floor(nm)
                --SendNUIMessage({
                --    action = 'updateDyno',
                --    rpm = rpmlist,
                --    hp = hplist,
                --    nm = nmlist
                --})

                local sendrpm = {}
                local sendhp = {}
                local sendnm = {}
                for i=1,#rpmlist do
                    if rpmlist[i] <= rpm then
                        sendrpm[#sendrpm+1] = rpmlist[i]
                        sendhp[#sendhp+1] = hplist[i]
                        sendnm[#sendnm+1] = nmlist[i]
                    end
                end
                SendNUIMessage({
                    action = 'updateDyno',
                    rpm = sendrpm,
                    hp = sendhp,
                    nm = sendnm
                })
            end 


            
            --lib.showTextUI("RPM: "..rpm.." | Gear: "..gear.." / "..highgear)


            -- Simulate dyno run duration
            if rpm >= 6600 or IsControlPressed(0, 20) or not DoesEntityExist(veh) then
                running = false
            end

            if rpm < 3200 then 
                gear = 1
            else 
                gear = 2
            end 
        end

        SetNuiFocus(true,true)
        --print(json.encode(rpmlist))
        --print(json.encode(hplist))
        --print(json.encode(nmlist))

        --lib.hideTextUI()
        Wait(2000)
        SetVehicleBurnout(veh, false)
        ClearVehicleTasks(veh)
        SendNUIMessage({
            action = 'closeDyno'
        })
    end)

end

RegisterNUICallback('closeDyno', function(data, cb)
    SetNuiFocus(false,false)
    cb('ok')
end)

