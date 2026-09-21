local function withdrawStash(markerId)
    ESX.TriggerServerCallback('esx_job_creator:retrieveStash', function(elements)
        if(#elements == 0) then
            table.insert(elements, {label = getLocalizedText("empty_stash")})
        end
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash_take', {
            title = getLocalizedText('stash_take'),
            align = 'bottom-right',
            elements = elements
        }, 
        function(data, menu) 
            local item = data.current
            
            if(item.value) then
                askQuantity(getLocalizedText('quantity'), "stash_take_dialog", 1, item.quantity, function(quantity)
                    ESX.TriggerServerCallback('esx_job_creator:stash:takeItem', function(isSuccessful)
                        if(isSuccessful) then
                            withdrawStash(markerId)
                        end
                    end, item.value, quantity, markerId)
                end)
            end
        end,
        function(data, menu)
            menu.close()
        end
        )
    end, markerId)
end

local function depositStash(markerId)
    ESX.TriggerServerCallback('esx_job_creator:getPlayerInventory', function(elements)
        if(#elements == 0) then
            table.insert(elements, {label = getLocalizedText("empty_inventory"), value = "emptyinventory"})
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash_deposit', {
            title = getLocalizedText('stash_deposit'),
            align = 'bottom-right',
            elements = elements
        }, 
        function(data, menu)
            local item = data.current

            if(item.value ~= "emptyinventory") then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stash_deposit_dialog', {
                    title = getLocalizedText('quantity'),
                }, function (data2, menu2)
                    local quantity = tonumber(data2.value)
            
                    if quantity and quantity <= item.quantity then
                        menu2.close()

                        ESX.TriggerServerCallback('esx_job_creator:stash:depositItem', function(isSuccessful)
                            if(isSuccessful) then
                                depositStash(markerId)
                            end
                        end, item.value, quantity, markerId)
                    else
                        notifyClient(getLocalizedText('invalid_quantity'))
                    end
                end, function (data2, menu2)
                    menu2.close()
                end)
            end
        end,
        function(data, menu)
            menu.close()
        end
        )
    end, markerId)
end

local function openStashInventory(markerId)
    exports.ox_inventory:openInventory('stash', "job-stash-"..markerId)
end

local function stashStateLabel(isAllowed)
    return isAllowed and getLocalizedText('stash:on') or getLocalizedText('stash:off')
end

local function openStashAccessMenu(markerId, info)
    local elements = {}

    for _, rank in ipairs(info.ranks) do
        elements[#elements + 1] = {
            label = getLocalizedText('stash:row', rank.label, getLocalizedText('stash:withdraw'), stashStateLabel(rank.withdraw)),
            grade = rank.grade,
            kind = 'withdraw',
            cur = rank.withdraw
        }
        elements[#elements + 1] = {
            label = getLocalizedText('stash:row', rank.label, getLocalizedText('stash:deposit'), stashStateLabel(rank.deposit)),
            grade = rank.grade,
            kind = 'deposit',
            cur = rank.deposit
        }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash_access', {
        title = getLocalizedText('stash:access_title'),
        align = 'bottom-right',
        elements = elements
    },
    function(data, menu)
        local element = data.current

        if(element.kind and element.grade ~= nil) then
            ESX.TriggerServerCallback('esx_job_creator:stash:setAccess', function(newInfo)
                if(newInfo and newInfo.isBoss and newInfo.ranks) then
                    menu.close()
                    openStashAccessMenu(markerId, newInfo)
                end
            end, markerId, element.kind, element.grade, not element.cur)
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function openStashBossMenu(markerId, info)
    local elements = {
        { label = getLocalizedText('stash:open'), value = 'open' },
        { label = getLocalizedText('stash:manage_access'), value = 'manage' },
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash_boss', {
        title = getLocalizedText('stash:menu_title'),
        align = 'bottom-right',
        elements = elements
    },
    function(data, menu)
        local value = data.current.value

        if(value == 'open') then
            menu.close()
            openStashInventory(markerId)
        elseif(value == 'manage') then
            menu.close()
            openStashAccessMenu(markerId, info)
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function openStash(markerId)
    ESX.TriggerServerCallback('esx_job_creator:stash:getAccessInfo', function(info)
        if(info and info.isBoss and info.ranks) then
            openStashBossMenu(markerId, info)
        else
            openStashInventory(markerId)
        end
    end, markerId)

    --[[ESX.UI.Menu.CloseAll()

    local elements = {
        {label = getLocalizedText('deposit'), value = "deposit"},
        {label = getLocalizedText('take'), value = "take"},
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stash', {
        title = getLocalizedText('stash'),
        align = 'bottom-right',
        elements = elements
    }, function(data, menu) 
        local value = data.current.value

        if(value == "deposit") then
            depositStash(markerId)
        elseif(value == "take") then
            withdrawStash(markerId)
        end
    end, function(data, menu)
        openedMenu = nil
        menu.close()
    end)]]
end