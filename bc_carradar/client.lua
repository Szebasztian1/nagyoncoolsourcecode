local radar = nil
local freezed = false
local lastid = 0
local lastplate = ""
local lastspeed = 0

local disids = {}

local lastveh = 0
CreateThread(function()
    while true do
        local ve = GetVehiclePedIsIn(PlayerPedId(), false)
        if radar == false then return end
        if radar == nil then
            if lastveh == 0 and ve ~= 0 then
                local ispolice = false
                for k, v in pairs(JOBS) do
                    if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == v then
                        ispolice = true
                        break
                    end
                end
                if ispolice then
                    ExecuteCommand("carradar")
                    TriggerEvent("esx:showNotification",
                        "Radar megnyitva, bezárni a /carradar segítségével tudod! \n Radar mozgatás a /radarmozgatas paranccsal lehetséges, és ESC-el lehet abbahagyni!")
                end
            end
        end
        lastveh = ve
        Wait(3000)
    end
end)

RegisterCommand("carradar", function(s, a, r)
    if radar then
        radar = false
        return
    end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if not DoesEntityExist(veh) then
        return TriggerEvent("esx:showNotification", "Nem vagy járműben!")
    end
    local ispolice = false
    --[[for i = 1, #POLICECARS do
        if GetEntityModel(veh) == POLICECARS[i] then
            ispolice = true
            break
        end
    end]]
    for k, v in pairs(JOBS) do
        if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == v then
            ispolice = true
            break
        end
    end
    if not ispolice then
        return TriggerEvent("esx:showNotification", "Nem rendőrautóban ülsz vagy nem vagy rendőr!")
    end
    radar = veh
    freezed = false

    SendNUIMessage({ action = "show" })
    SendNUIMessage({ action = "setRadarFixed", data = false })
    SendNUIMessage({ action = "setVehicle", data = false })
    CreateThread(function()
        while radar and GetVehiclePedIsIn(PlayerPedId(), false) == radar do
            Wait(150)
            if not freezed then
                local coordA = GetOffsetFromEntityInWorldCoords(radar, 0.0, 1.0, 1.0)
                local coordB = GetOffsetFromEntityInWorldCoords(radar, 0.0, 105.0, 0.0)
                local frontcar = StartShapeTestCapsule(coordA, coordB, 3.0, 10, radar, 7)
                local a, b, c, d, e = GetShapeTestResult(frontcar)

                if IsEntityAVehicle(e) then
                    local fmodel = GetDisplayNameFromVehicleModel(GetEntityModel(e))
                    local fvspeed = GetEntitySpeed(e) * 3.59999953
                    local fplate = GetVehicleNumberPlateText(e)

                    if not freezed then
                        SendNUIMessage({ action = "setVehicle", data = { plate = fplate, model = fmodel, speed = math.ceil(fvspeed) } })
                    end

                    local dped = GetPedInVehicleSeat(e, -1)
                    if dped and dped ~= 0 and fvspeed > 100 then
                        local playerr
                        for _, player in pairs(GetActivePlayers()) do
                            local pede = GetPlayerPed(player)
                            if pede == dped then
                                playerr = player
                            end
                        end
                        if playerr then
                            lastid = GetPlayerServerId(playerr)
                            lastspeed = fvspeed
                            lastplate = GetVehicleNumberPlateText(e)
                        end
                    end
                elseif not freezed then
                    SendNUIMessage({ action = "setVehicle", data = false })
                end
            end
        end
        if radar then
            radar = nil
        end
        lastid = 0
        lastplate = ""
        lastspeed = 0
        SendNUIMessage({ action = "hide" })
    end)
end, false)

RegisterCommand("carradarfreeze", function(s, a, r)
    if not radar then
        return
    end
    freezed = not freezed
    SendNUIMessage({ action = "setRadarFixed", data = freezed })
end, false)
RegisterKeyMapping("carradarfreeze", "Radar fagyastása", "keyboard", "g")

RegisterCommand("carradarbill", function(s, a, r)
    if not radar then
        return
    end
    if lastid == 0 then
        TriggerEvent("esx:showNotification", "Hiba számlázás közben!")
        return
    end
    local timeout = (disids[lastid] or 0)
    if timeout + (1000 * 60 * 60) > GetGameTimer() then
        TriggerEvent("esx:showNotification", "Őt már megbüntetted nem régen!")
        return
    end
    disids[lastid] = GetGameTimer()
    TriggerServerEvent("radar:addbill", lastid, lastplate, lastspeed)
end, false)
RegisterKeyMapping("carradarbill", "Radar számlázás", "keyboard", "i")

RegisterCommand("radarmozgatas", function(s, a, r)
    if not radar then
        return
    end
    SendNUIMessage({ action = "radarmove" })
    SetNuiFocus(true, true)
end, false)

RegisterNUICallback("closeMoveMode", function(data, cb)
    SetNuiFocus(false, false)
    cb({})
end)




local BORDERS = {
    vector3(-2732.15, 2309.3, 17.87),
    vector3(1684.75, 1478.09, 85.03),
    vector3(1920.29, 1858.52, 60.68),
    vector3(1300.66, 1489.82, 98.16),
    vector3(-2039.45, 1930.41, 187),
    vector3(1037.04, 1526.56, 173.7),
    vector3(136.69, 1622.03, 229.03),
    vector3(-767.68, 1599.82, 211.41),
    vector3(-1444.43, 1823.57, 80.77),
    vector3(2527.5, 1870.91, 51.4),
    vector3(-2234.85, 2277.26, 32.61)
}
local lastcross = 0

CreateThread(function()
    Wait(5000)

    for k, v in pairs(BORDERS) do 
    local handle = lib.zones.sphere({
        coords  = v,
        radius  = 20,
        debug   = false,
        onEnter = function()
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            if not veh or not DoesEntityExist(veh) then 
                return 
            end 
            if GetPedInVehicleSeat(veh, -1) ~= ped then 
                return 
            end 
            if (GetGameTimer() - lastcross) < 10000 then 
                return 
            end 
            lastcross = GetGameTimer()

            local plate = GetVehicleNumberPlateText(veh)
            local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
		    local StreetHash = GetStreetNameAtCoord(x, y, z)
            local StreetName = GetStreetNameFromHashKey(StreetHash)
            TriggerServerEvent("bc:borderCrossed", plate, StreetName)
        end,
        onExit  = function()
        end,
    })
    end 
end)