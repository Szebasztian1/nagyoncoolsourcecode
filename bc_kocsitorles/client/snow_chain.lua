local holancTimeout = 0
local holancVehicle = false

---@param vehicle integer
---@return boolean
local function IsSnowWeatherActive()
    local currentWeather, nextWeather = GetWeatherTypeTransition()
    return currentWeather == `XMAS` or nextWeather == `XMAS`
end

---@param vehicle integer
---@param tractionMin number
---@param tractionMax number
---@param brakeForce number
local function RestoreHandling(vehicle, tractionMin, tractionMax, brakeForce)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', tractionMin)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', tractionMax)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce', brakeForce)
end

---@param vehicle integer
---@param tractionMin number
---@param tractionMax number
---@param brakeForce number
local function ApplyBoostHandling(vehicle, tractionMin, tractionMax, brakeForce)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin', tractionMin * 1.5)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax', tractionMax * 1.5)
    SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce', brakeForce * 1.4)
end

---@param vehicle integer
local function RunSnowChainLoop(vehicle)
    local originalTractionMin = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMin')
    local originalTractionMax = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fTractionCurveMax')
    local originalBrakeForce = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce')

    TriggerEvent("esx:showNotification", "A hólánc feltéve")

    CreateThread(function()
        while holancVehicle == vehicle do
            local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            if currentVehicle ~= vehicle then break end

            local chainCount = exports.ox_inventory:Search('count', 'holanc')
            if chainCount < 1 then break end

            if not IsSnowWeatherActive() then break end

            ApplyBoostHandling(vehicle, originalTractionMin, originalTractionMax, originalBrakeForce)

            Wait(500)
        end

        TriggerEvent("esx:showNotification", "A hólánc levéve")
        RestoreHandling(vehicle, originalTractionMin, originalTractionMax, originalBrakeForce)
        holancVehicle = false
    end)
end

AddEventHandler("holanc:onoff", function()
    if holancTimeout + 5000 > GetGameTimer() then
        TriggerEvent("esx:showNotification", "Ne spammelj!")
        return
    end

    holancTimeout = GetGameTimer()

    if holancVehicle then
        holancVehicle = false
        return
    end

    if not IsSnowWeatherActive() then
        TriggerEvent("esx:showNotification", "Hóláncot csak havazáskor lehet használni!")
        return
    end

    local chainCount = exports.ox_inventory:Search('count', 'holanc')
    if chainCount < 1 then
        TriggerEvent("esx:showNotification", "Nincs náald hólánc")
        return
    end

    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not DoesEntityExist(vehicle) then
        TriggerEvent("esx:showNotification", "Nem ülsz autóban")
        return
    end

    holancVehicle = vehicle
    RunSnowChainLoop(vehicle)
end)
