local isStorageMonitorOpen = false

-- NUI Callback kezelése
RegisterNUICallback('closeStorageMonitor', function(data, cb)
    SetNuiFocus(false, false)
    isStorageMonitorOpen = false
    SendNUIMessage({
        type = 'close',
    })
    if cb then cb('ok') end
end)

RegisterNUICallback('unlockStorage', function(data, cb)
    local suc = lib.callback.await('bc_factionlogs:unlock', false, data.storageId)
    cb({
        success = suc
    })
end)

RegisterNUICallback('saveWebhook', function(data, cb)
    local suc = lib.callback.await('bc_factionlogs:saveWebhook', false, data.storageId, data.webhookUrl)
    cb({
        success = suc
    })
end)

-- Storage monitor megnyitása
RegisterNetEvent('storageMonitor:open')
AddEventHandler('storageMonitor:open', function(markerid)
    if isStorageMonitorOpen then return end
    --print("req storages")
    
    local storages = lib.callback.await('bc_factionlogs:getStorages', false, markerid)
    --print("storages", storages)
    if not storages then return end

    isStorageMonitorOpen = true
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'open',
        storages = storages
    })
end) 