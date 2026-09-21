local isUIOpen = false

local function debugLog(msg)
    if Config.Debug then
        print(("[mate-slot:client] %s"):format(msg))
    end
end

local function openSlotUI()
    if isUIOpen then return end

    isUIOpen = true
    SetNuiFocus(true, true)
    Rpc:Send("open", {
        betOptions = Config.BetOptions,
        defaultBet = Config.DefaultBet,
    })

    debugLog("UI opened")
end

local function closeSlotUI()
    if not isUIOpen then return end

    isUIOpen = false
    SetNuiFocus(false, false)
    Rpc:Send("close", {})

    debugLog("UI closed")
end

AddEventHandler("mate-slot:internal:openUI", function()
    openSlotUI()
end)

AddEventHandler("mate-slot:internal:closeUI", function()
    closeSlotUI()
end)

Rpc:Register("uiReady", function(_)
    debugLog("UI ready signal received")

    Rpc:Send("setConfig", {
        betOptions = Config.BetOptions,
        defaultBet = Config.DefaultBet,
    })

    debugLog(("Config sent to UI — %d bet option(s), defaultBet=$%d"):format(
        #Config.BetOptions, Config.DefaultBet
    ))
end)



Rpc:Register("getBalance", function(_)
    Rpc:SendServer("getBalance")
end)

Rpc:Register("spinResultProcessed", function(data)
    SlotSession:OnSpinResult(data)
end)

AddEventHandler("mate-slot:client:sessionReady", function(balance)
    Rpc:Send("setBalance", { balance = balance })
    debugLog(("Session ready — balance=$%d"):format(balance))
end)

AddEventHandler("mate-slot:client:sessionError", function(message)
    closeSlotUI()
    SlotSession:ForceLeave()
    Rpc:Send("spinError", { error = message })
    debugLog(("^1Session error: %s^0"):format(message))
end)

AddEventHandler("mate-slot:client:balanceSync", function(balance)
    Rpc:Send("setBalance", { balance = balance })
    debugLog(("Balance synced — $%d"):format(balance))
end)

AddEventHandler("mate-slot:client:spinError", function(message)
    Rpc:Send("spinError", { error = message })
    debugLog(("^1Spin error: %s^0"):format(message))
end)

AddEventHandler('ox_inventory:updateInventory', function()
    if not isUIOpen then return end
    Rpc:SendServer("getBalance")
end)

AddEventHandler('ox_inventory:itemCount', function(itemName, totalCount)
    if not isUIOpen then return end
    if itemName ~= "money" then return end
    Rpc:SendServer("getBalance")
end)

SlotWorld:SetUseCallback(function(chairData)
    if SlotSession:IsSeated() then
        debugLog("UseCallback fired while already seated — ignoring")
        return
    end

    CreateThread(function()
        SlotSession:Enter(chairData)
    end)
end)

RegisterCommand("slot", function()
    if isUIOpen then
        SlotSession:Leave()
    else
        openSlotUI()
        Rpc:SendServer("openSession")
    end
end, false)


CreateThread(function()
    Wait(500)

    SlotWorld:Init()

    debugLog("Client module initialised")
end)

AddEventHandler("onResourceStop", function(stoppedResource)
    if GetCurrentResourceName() ~= stoppedResource then return end

    if isUIOpen then
        closeSlotUI()
    end

    SlotSession:ForceLeave()

    SlotWorld:Cleanup()

    debugLog("Resource stopping — cleanup complete")
end)
