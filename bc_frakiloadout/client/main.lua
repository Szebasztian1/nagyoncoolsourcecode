-- ===================================================
-- CLIENT – NUI alapú, ox_lib context menu NÉLKÜL
-- ===================================================

local isOpen = false

-- ─── NUI → Lua üzenetek kezelése ───────────────────

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    isOpen = false
    cb('ok')
end)

RegisterNUICallback('getDetail', function(data, cb)
    ESX.TriggerServerCallback('loadout:get', function(res)
        if res.err then
            SendNUIMessage({ action='notify', msg=res.err, type='error' })
            cb({})
            return
        end
        -- Label-ek hozzáadása az itemekhez config alapján
        for _, it in ipairs(res.items or {}) do
            local cfg = U.findItem(it.name or it.item_name)
            it.label      = cfg and cfg.label or (it.name or it.item_name)
            it.name       = it.name or it.item_name
            it.unit_price = it.unit_price or (cfg and cfg.price or 0)
        end
        cb(res)
        res.action = "detail"
        SendNUIMessage(res)
    end, data.id)
end)

RegisterNUICallback('create', function(data, cb)
    ESX.TriggerServerCallback('loadout:create', function(res)
        if res.err then
            SendNUIMessage({ action='notify', msg=res.err, type='error' })
        else
            SendNUIMessage({ action='notify', msg='Loadout létrehozva!', type='success' })
            refreshAndSend()
        end
        cb({})
    end, { name=data.name, shared=data.shared, items=data.items })
end)

RegisterNUICallback('edit', function(data, cb)
    ESX.TriggerServerCallback('loadout:edit', function(res)
        if res.err then
            SendNUIMessage({ action='notify', msg=res.err, type='error' })
        else
            SendNUIMessage({ action='notify', msg='Loadout frissítve!', type='success' })
        end
        cb({})
    end, { id=data.id, items=data.items })
end)

RegisterNUICallback('rename', function(data, cb)
    ESX.TriggerServerCallback('loadout:rename', function(res)
        if res.err then
            SendNUIMessage({ action='notify', msg=res.err, type='error' })
        else
            SendNUIMessage({ action='notify', msg='Átnevezve.', type='success' })
        end
        cb({})
    end, { id=data.id, name=data.name })
end)

RegisterNUICallback('delete', function(data, cb)
    ESX.TriggerServerCallback('loadout:delete', function(res)
        if res.err then
            SendNUIMessage({ action='notify', msg=res.err, type='error' })
        else
            SendNUIMessage({ action='notify', msg='Loadout törölve.', type='success' })
            refreshAndSend()
        end
        cb({})
    end, data.id)
end)

RegisterNUICallback('redeem', function(data, cb)
    ESX.TriggerServerCallback('loadout:redeem', function(res)
        if res.err then
            SendNUIMessage({ action='notify', msg=res.err, type='error' })
        else
            SendNUIMessage({ action='notify',
                msg='Felvéve! Levonva: $'..math.floor(res.total),
                type='success' })
        end
        cb({})
    end, data.id)
end)

-- ─── UI megnyitása ──────────────────────────────────
local itemsasd = false 
function openLoadoutUI()
    if not itemsasd then 
        local itemNames = {}
        local oxitems = exports.ox_inventory:Items()
        for item, data in pairs(oxitems) do
            itemNames[item] = data.label
        end

        for k, v in pairs(Config.Items) do 
            for d, a in pairs(v.items) do 
                if itemNames[a.name] then 
                    Config.Items[k].items[d].label = itemNames[a.name]  
                end 
            end 
        end 
        itemsasd = true
    end 
    if isOpen then return end

    ESX.TriggerServerCallback('loadout:list', function(res)
        if res.err then
            lib.notify({ title='Loadout', description=res.err, type='error' })
            return
        end

        local xPlayer = ESX.GetPlayerData()
        local job     = xPlayer.job

        isOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action   = 'open',
            jobLabel = job and (job.label or job.name) or '',
            own      = res.own,
            faction  = res.shared,
            config   = Config.Items,
        })
    end)
end

-- Lista frissítés és újraküldés (create/delete után)
function refreshAndSend()
    ESX.TriggerServerCallback('loadout:list', function(res)
        if res.err then return end
        local xPlayer = ESX.GetPlayerData()
        local job     = xPlayer.job
        SendNUIMessage({
            action   = 'open',
            jobLabel = job and (job.label or job.name) or '',
            own      = res.own,
            faction  = res.shared,
            config   = Config.Items,
        })
    end)
end

-- ─── Parancs / event ───────────────────────────────

--RegisterCommand('loadouts', function() openLoadoutUI() end, false)
RegisterNetEvent('loadout:open', function() openLoadoutUI() end)

CreateThread(function ()
  while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do 
    Wait(10)
  end 
    while true do
        Wait(0)

        local coords = GetEntityCoords(PlayerPedId())
        local sleep = true

        for k,v in pairs(Config.Jobs) do
          local dis = #(coords - v.coords)
          if dis < 10 then
            local jobName = ESX.PlayerData.job.name
            local grade = ESX.PlayerData.job.grade
            if k == jobName  then
              if not v.minGrade or (v.minGrade and v.minGrade <= grade) then
                sleep = false
                DrawMarker(27, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 200, 45, 111, 100, true, true, 2, false, false, false, false)
                if dis < 1.0 then 
                  ESX.ShowHelpNotification("loadout menü megnyitás", true)
                  if IsControlJustReleased(0, 38) then
                    openLoadoutUI()
                    Wait(10000)
                  end
                end 
              end 
            end
          end
        end

        if sleep then
          Wait(1000)
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)

U.log('Client betöltve (NUI mod).')
