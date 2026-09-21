--- @module driveby

--- @type number
local maxDriveBySpeedMs = Config.DriveBy.MaxSpeedMs

--- @type integer[]
local excludedClasses = { 8, 13, 14, 15 }

--- @param class integer
--- @return boolean
local function isExcludedClass(class)
    for _, v in ipairs(excludedClasses) do
        if v == class then
            return true
        end
    end
    return false
end

canShoot = false

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local car = GetVehiclePedIsIn(playerPed, false)

        if car and car ~= 0 and DoesEntityExist(car) and GetPedInVehicleSeat(car, -1) == playerPed then
            local class = GetVehicleClass(car)

            if not isExcludedClass(class) then
                canShoot = GetEntitySpeed(car) <= maxDriveBySpeedMs
                SetPlayerCanDoDriveBy(PlayerId(), canShoot)
            end
        end

        Wait(1000)
    end
end)
