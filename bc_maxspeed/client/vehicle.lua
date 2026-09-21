--- @module vehicle

local maxSpeedMs = 300 / 3.6

local espeeds = {}
local currentEs = 0

function GetESpeed(veh)
    if espeeds[veh] and (GetGameTimer()-espeeds[veh].time) < 1000*3 then
        return espeeds[veh].es
    end

    local es = 0
    if Entity(veh) and Entity(veh).state and Entity(veh).state.extraspeed then
        es = Entity(veh).state.extraspeed
    end
    espeeds[veh] = {
        es = es,
        time = GetGameTimer()
    }
    return es
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        if veh and veh ~= 0 then
            local es = GetESpeed(veh)
            --print("ajsn", es)
            currentEs = es
            if GetEntitySpeed(veh) > (math.floor((300.0) / 3.6) + (es / 3.6) + 0.0) then
                SetVehicleMaxSpeed(veh, math.floor((300.0) / 3.6) + (es / 3.6) + 0.0)
            end

            --SetVehicleHandlingFloat(veh, 'CHandlingData', 'fWeaponDamageMult', Config.WeaponDamageMult)
            SetPedCanBeDraggedOut(ped, false)
            SetPedStayInVehicleWhenJacked(ped, true)
        end

        Wait(300)
    end
end)

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat)
	-- Az esemeny 0-s handle-lel is megerkezhet (a jarmu eltunt, mire lefutunk) --
	-- a handling-nativ ilyenkor "no script guid for vehicle 0" warningot ir a konzolra.
	if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

	SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fWeaponDamageMult', Config.WeaponDamageMult)
end)

RegisterNetEvent('esx:enteringVehicle', function(plate, seat, netId)
    local myped = PlayerPedId()
    local playerId = PlayerId()

    CreateThread(function()
        while not IsPedInAnyVehicle(myped, false) and GetVehiclePedIsTryingToEnter(myped) ~= 0 do
            DisablePlayerVehicleRewards(PlayerId())
            Wait(1)
        end

        while IsPedInAnyVehicle(myped, false) do
            DisablePlayerVehicleRewards(playerId)
            Wait(1)
        end
    end)
    
end)

RegisterCommand("vehname", function()
    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(ped, false) then
        TriggerEvent("esx:showNotification", "Nem ülsz autóba!")
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local model = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local label = GetLabelText(displayName)

    -- Fallback if label is not found
    if label == "NULL" or label == "" then
        label = displayName
    end

    TriggerEvent("esx:showNotification", "Az autó neve "..label..", lehívója: "..displayName)
end, false)

-- New thread for drawing extraspeed on screen
CreateThread(function()
    local showUntil = 0
    while true do
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local es = 0
        if veh and veh ~= 0 then
            es = GetESpeed(veh)
            if es > 0 and showUntil == 0 then
                showUntil = GetGameTimer() + 5000
            end
        else 
            showUntil = 0
        end
        
        if GetGameTimer() < showUntil and es > 0 then
            SetTextCentre(true)
            SetTextFont(0)
            SetTextScale(0.0, 0.5)
            SetTextColour(255, 255, 255, 255)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(string.format("Extrasebesség: %.1f km/h", es))
            EndTextCommandDisplayText(0.5, 0.1)
            Wait(0)
        else 
            Wait(500)
        end
    end
end)