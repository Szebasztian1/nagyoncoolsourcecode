--- @module cruise

--- @type number
local cruise = 0

--- @param message string
local function Notify(message)
    TriggerEvent("esx:showNotification", message)
end

--- @param targetSpeed number | nil
local function SetCruiseSpeed(targetSpeed)
    local playerPed = GetPlayerPed(-1)

    if cruise ~= 0 then
        Notify("Tempomat: STOP")
        cruise = 0
        return
    end

    if not IsPedInAnyVehicle(playerPed, false) then return end

    local veh = GetVehiclePedIsIn(playerPed, false)

    if GetVehicleType(veh) == "boat" then return end

    if GetEntitySpeedVector(veh, true).y <= 0 then
        cruise = 0
        Notify("Tempomat: STOP")
        return
    end

    cruise = targetSpeed or GetEntitySpeed(veh)

    local cruiseKmh = math.floor(cruise * 3.6 + 0.5)
    Notify("Tempomat: Sebesség beállítva: " .. cruiseKmh .. " km/h, gyorsítani gáz adással tudsz")

    CreateThread(function()
        while cruise > 0 do
            local ped    = GetPlayerPed(-1)
            local curVeh = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(curVeh, -1) ~= ped then
                cruise = 0
                Notify("Tempomat: STOP")
                break
            end

            if not IsVehicleOnAllWheels(curVeh) or GetEntitySpeed(curVeh) <= (cruise - 2.0) then
                cruise = 0
                Notify("Tempomat: STOP")
                break
            end

            SetVehicleForwardSpeed(curVeh, cruise)

            if IsControlPressed(1, 8) then
                cruise = 0
                Notify("Tempomat: STOP")
                break
            end

            if IsControlPressed(1, 32) then
                cruise = 0
                TriggerEvent("pv:setNewSpeed")
                break
            end

            Wait(200)
        end

        cruise = 0
    end)
end

AddEventHandler("pv:setCruiseSpeed", function(targetSpeed)
    SetCruiseSpeed(targetSpeed)
end)

AddEventHandler("pv:setNewSpeed", function()
    CreateThread(function()
        while IsControlPressed(1, 32) do
            Wait(1)
        end
        TriggerEvent("pv:setCruiseSpeed")
    end)
end)

RegisterCommand("tempomat", function()
    TriggerEvent("pv:setCruiseSpeed")
end)

RegisterKeyMapping(
    "tempomat",
    "Tempomat",
    "keyboard",
    "9"
)

RegisterCommand("fixtempomat", function(_, args)
    if not args[1] then
        return Notify("Érvénytelen használat!")
    end

    local speed = tonumber(args[1])

    if not speed then
        return Notify("Érvénytelen használat!")
    end

    if speed > Config.Cruise.MaxAllowedSpeed then
        return Notify(Config.Cruise.MaxAllowedSpeed .. " felett nem használható fix tempomat!")
    end

    TriggerEvent("pv:setCruiseSpeed", (speed - 0.5) / 3.6)
end)
