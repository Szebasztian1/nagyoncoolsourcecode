---@type integer
local lastVehicle = 0

---@type string
local lastPlate = ""

---@type boolean
local isChangingPlate = false

--Citizen.CreateThread(function()
--    while true do
--        Citizen.Wait(2000)
--
--        local playerPed = PlayerPedId()
--
--        if IsPedInAnyVehicle(playerPed, false) then
--            local currentVehicle = GetVehiclePedIsIn(playerPed, false)
--            local currentPlate   = GetVehicleNumberPlateText(currentVehicle)
--
--            if currentVehicle ~= lastVehicle then
--                lastVehicle = currentVehicle
--                lastPlate   = currentPlate
--                Wait(3000)
--            else
--                if currentPlate ~= lastPlate and not isChangingPlate then
--                    SetVehicleNumberPlateText(currentVehicle, lastPlate)
--                    TriggerServerEvent("bc_carsys:newplate", lastPlate, currentPlate)
--                end
--            end
--        else
--            lastVehicle = 0
--            lastPlate   = ""
--        end
--    end
--end)


--exports["ox_inventory"]:haveparachute()
lib.callback.register('bc:getParachute', function()
    local ok, inventoryFlag = pcall(function()
        return exports["ox_inventory"]:haveparachute()
    end)
    return GetPedParachuteState(PlayerPedId()) ~= -1 or (ok and inventoryFlag)
end)

-- Az item-alapú "bc:parachute" trigger csak akkor tüzel, ha a jatekos
-- ekkor hasznalja az ox_inventory ejtoernyo itemjet. Ha mar korabbrol
-- nala van a GADGET_PARACHUTE fegyver (pl. ujra kiugrik egy repulobol),
-- az item-flow ki sem tud tuzelni, es az AC whitelist sosem indul el.
-- Ezert itt kozvetlenul a nativ ejtoernyo-allapotot figyeljuk, es arra
-- tuzeljuk a szerver esemenyt, fuggetlenul attol, honnan van a fegyver.
CreateThread(function()
    local wasParachuting = false

    while true do
        local isParachuting = GetPedParachuteState(PlayerPedId()) ~= -1

        if isParachuting and not wasParachuting then
            TriggerServerEvent("bc:parachute")
        end

        wasParachuting = isParachuting
        Wait(500)
    end
end)