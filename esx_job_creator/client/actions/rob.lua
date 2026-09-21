local function robPlayer(playerId)
    ESX.TriggerServerCallback('esx_job_creator:getTargetPlayerInventory', function(inventory) 
        if(not inventory) then return end

        if(#inventory == 0) then
            table.insert(inventory, {label = getLocalizedText('search_inventory_empty')})
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'actions_menu_search', {
            title = getLocalizedText('actions_menu_search'),
            align = 'bottom-right',
            elements = inventory
        }, 
        function(data, menu)
            local item = data.current

            if(item.value == nil) then return end

            if(item.max ~= nil) then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'actions_menu_quantity', {
                    title = getLocalizedText('quantity'),
                }, function (data2, menu2)
                    local quantity = tonumber(data2.value)
            
                    if quantity and quantity <= item.max then
                        menu2.close()

                        ESX.TriggerServerCallback('esx_job_creator:stealFromPlayer', function(isSuccessful) 
                            if(isSuccessful) then
                                robPlayer(playerId)
                            end
                        end, playerId, item, quantity)
                    else
                        notifyClient(getLocalizedText('invalid_quantity'))
                    end
                end, function (data2, menu2)
                    menu2.close()
                end)
            else
                ESX.TriggerServerCallback('esx_job_creator:stealFromPlayer', function(isSuccessful) 
                    if(isSuccessful) then
                        robPlayer(playerId)
                    end
                end, playerId, item)
            end
        end,
        function(data, menu)
            menu.close()
        end)
    end, playerId)
end

local allowedInPublic = {
    ['police'] = true,
    ['fbi'] = true,
    ['fbiuj'] = true,
    ['uss'] = true,
    ['irs'] = true,
    ['navi'] = true,
    ['atf'] = true,
    ['detective'] = true,
    ['guardarmy'] = true,
    ['usms'] = true,
    ['servicess'] = true
}

local function search()
    
    local targetId = GetPlayerServerId(getClosestPlayerId())

    if(targetId > 0) then
        if exports['bc_kocsitorles']:isPlayerSafe() then 
            --[[ESX.TriggerServerCallback('esx_job_creator:getJobInfo', function(jobName, jobLabel)
                if allowedInPublic[jobName] then 
                    robPlayer(targetId) 
                else 
                    notifyClient("Publikus területen nem pakolhatsz ki embereket!")
                end 
            end)]]
            local jobName = ESX.GetPlayerData().job.name
            if allowedInPublic[jobName] then 
                exports.ox_inventory:openInventory('player', targetId)
            else 
                notifyClient("Publikus területen nem pakolhatsz ki embereket!")
            end
        else 
            exports.ox_inventory:openInventory('player', targetId)
        end 
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:search', search)

local function searchplayer(targetId)
    if(targetId > 0) then
        if exports['bc_kocsitorles']:isPlayerSafe() then 
            --[[ESX.TriggerServerCallback('esx_job_creator:getJobInfo', function(jobName, jobLabel)
                if allowedInPublic[jobName] then 
                    robPlayer(targetId) 
                else 
                    notifyClient("Publikus területen nem pakolhatsz ki embereket!")
                end 
            end)]]
            local jobName = ESX.GetPlayerData().job.name
            if allowedInPublic[jobName] then 
                exports.ox_inventory:openInventory('player', targetId)
            else 
                notifyClient("Publikus területen nem pakolhatsz ki embereket!")
            end
        else 
            exports.ox_inventory:openInventory('player', targetId)
        end 
    else
        notifyClient(getLocalizedText('no_players_nearby'))
    end
end
RegisterNetEvent('esx_job_creator:actions:searchplayer', searchplayer)