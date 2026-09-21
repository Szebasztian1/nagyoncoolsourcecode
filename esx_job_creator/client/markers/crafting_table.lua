local craftMarkerId = nil

---Releases NUI focus and clears the marker lock so the menu can be reopened.
local function closeCraftingNui()
    SetNuiFocus(false, false)
    craftMarkerId = nil
    openedMenu = nil
end

---Opens the crafting NUI for the given marker.
function openCraftingTable(markerId)
    ESX.TriggerServerCallback('esx_job_creator:getCraftingTableData', function(craftingTableData)
        if not craftingTableData then
            closeCraftingNui()
            return
        end

        ESX.UI.Menu.CloseAll()

        craftMarkerId = markerId

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'craft:open',
            data = craftingTableData
        })
    end, markerId)
end

RegisterNUICallback('craft:close', function(_, cb)
    closeCraftingNui()
    cb({})
end)

RegisterNUICallback('craft:craft', function(data, cb)
    local markerId = craftMarkerId
    local itemName = data and data.itemName
    local amount = math.floor(tonumber(data and data.amount) or 0)

    closeCraftingNui()

    -- the server re-validates ingredients, amount and free space
    if markerId and itemName and amount > 0 then
        TriggerServerEvent('esx_job_creator:craftItem', markerId, itemName, amount)
    end

    cb({})
end)

---@param durationMs number craft duration in milliseconds
---@return boolean completed
local function runCraftProgress(durationMs)
    local startTime     = GetGameTimer()
    local totalMs       = durationMs
    local reductionMs   = 0
    local cancelled     = false
    local boostCooldown = 0

    while true do
        local elapsed = GetGameTimer() - startTime + reductionMs
        if elapsed >= totalMs or cancelled then break end

        local progress = math.min(elapsed / totalMs, 1.0)

        DrawRect(0.5, 0.957, 0.404, 0.033, 0, 0, 0, 180)
        DrawRect(0.5 - 0.2 + (progress * 0.4 / 2), 0.957, progress * 0.4, 0.027, 220, 150, 30, 230)

        SetTextScale(0.30, 0.30)
        SetTextFont(4)
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentSubstringPlayerName("Crafting  |  ~g~[G]~s~ -10mp (50.000$)  |  ~r~[BACKSPACE]~s~ Mégse")
        EndTextCommandDisplayText(0.5, 0.937)

        if IsControlJustPressed(0, 47) and GetGameTimer() > boostCooldown then
            local plyMoney = ESX.GetPlayerData().money
            if plyMoney >= 50000 then
                boostCooldown = GetGameTimer() + 500
                reductionMs   = reductionMs + 10000
                TriggerServerEvent('crafting:PayBoost')
                ESX.ShowNotification("~g~-10 másodperc! ~s~(-50.000$)")
            else
                ESX.ShowNotification("~r~Nincs elég pénzed!~s~ (50.000$ szükséges)")
                boostCooldown = GetGameTimer() + 1500
            end
        end

        if IsControlJustPressed(0, 177) then
            cancelled = true
            break
        end

        Wait(0)
    end

    return not cancelled
end

---@param time number duration in seconds
---@param text string progress label
---@param itemName string item name for icon
local function startCrafting(time, text, itemName, craftAmount)
    if isProgressbarRunning then return end
    isProgressbarRunning = true
    FreezeEntityPosition(PlayerPedId(), true)
    ESX.UI.Menu.CloseAll()

    CreateThread(function()
        local completed = exports['crafting']:StartProgressBar(time / 1000, itemName, text, craftAmount or 1)
        isProgressbarRunning = false
        FreezeEntityPosition(PlayerPedId(), false)
        if completed then
            exports["gs_eventprotect"]:GS_TriggerServerEvent('esx_job_creator:craftingDone')
        else
            TriggerServerEvent('esx_job_creator:craftingCancelled')
        end
    end)
end
RegisterNetEvent('esx_job_creator:crafting_table:startCrafting', startCrafting)
