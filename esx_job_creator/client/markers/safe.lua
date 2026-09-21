local function depositIntoSafe(markerId)
    ESX.TriggerServerCallback('esx_job_creator:getPlayerAccounts', function(accounts)
        if(#accounts == 0) then
            table.insert(accounts, {
                label = getLocalizedText('nothing_to_deposit'),
                value = "empty"
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe_deposit', {
            title = getLocalizedText('safe'),
            align = 'bottom-right',
            elements = accounts
        },
        function(data, menu)
            if(data.current.value == "empty") then return end

            local accountName = data.current.accountName

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'safe_deposit_dialog', {
                title = getLocalizedText('quantity'),
            }, function (data2, menu2)
                local quantity = tonumber(data2.value)
        
                if quantity and quantity > 0 and quantity <= data.current.money then
                    menu2.close()

                    ESX.TriggerServerCallback('esx_job_creator:depositIntoSafe', function(isSuccessful)
                        if(isSuccessful) then
                            depositIntoSafe(markerId)
                        end
                    end, accountName, quantity, markerId)
                else
                    notifyClient(getLocalizedText('invalid_quantity'))
                end
            end, function (data2, menu2)
                menu2.close()
            end)
        end,
        function(data, menu)
            openedMenu = nil
            menu.close()
        end)
    end)
end

local function withdrawFromSafe(markerId)
    ESX.TriggerServerCallback('esx_job_creator:retrieveReadableSafeData', function(safeData)
        if(#safeData == 0) then
            table.insert(safeData, {
                label = getLocalizedText("empty_safe"),
                value = "empty"
            })
        end
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe_withdraw', {
            title = getLocalizedText('safe'),
            align = 'bottom-right',
            elements = safeData
        },
        function(data, menu)
            if(data.current.value == "empty") then return end

            local accountName = data.current.accountName

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'safe_withdraw_dialog', {
                title = getLocalizedText('quantity'),
            }, function (data2, menu2)
                local quantity = tonumber(data2.value)
        
                if quantity and quantity > 0 and quantity <= data.current.money then
                    menu2.close()

                    ESX.TriggerServerCallback('esx_job_creator:withdrawFromSafe', function(isSuccessful)
                        if(isSuccessful) then
                            withdrawFromSafe(markerId)
                        end
                    end, accountName, quantity, markerId)
                else
                    notifyClient(getLocalizedText('invalid_quantity'))
                end
            end, function (data2, menu2)
                menu2.close()
            end)
        end,
        function(data, menu)
            openedMenu = nil
            menu.close()
        end)
    end, markerId)
end

local function safeStateLabel(allowed)
    return allowed and "BE" or "KI"
end

-- Széf hozzáférés-kezelö menü (boss állítja, melyik rang vehet ki / tehet be)
function openSafeAccessMenu(markerId, info)
    local elements = {}

    for _, rank in ipairs(info.ranks) do
        elements[#elements + 1] = {
            label = ("%s - Kivét: %s"):format(rank.label, safeStateLabel(rank.withdraw)),
            grade = rank.grade,
            kind = 'withdraw',
            cur = rank.withdraw
        }
        elements[#elements + 1] = {
            label = ("%s - Betét: %s"):format(rank.label, safeStateLabel(rank.deposit)),
            grade = rank.grade,
            kind = 'deposit',
            cur = rank.deposit
        }
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe_access', {
        title = "Széf hozzáférés",
        align = 'bottom-right',
        elements = elements
    },
    function(data, menu)
        local element = data.current
        if(element.kind and element.grade ~= nil) then
            ESX.TriggerServerCallback('esx_job_creator:safe:setAccess', function(newInfo)
                if(newInfo and newInfo.isBoss and newInfo.ranks) then
                    menu.close()
                    openSafeAccessMenu(markerId, newInfo)
                end
            end, markerId, element.kind, element.grade, not element.cur)
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

-- Boss menü egy széfhez: megnyitás vagy hozzáférés kezelése
function openSafeBossMenu(markerId, info)
    local elements = {
        { label = "Széf megnyitása", value = "open" },
        { label = "Hozzáférés kezelése", value = "manage" },
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe_boss', {
        title = "Széf",
        align = 'bottom-right',
        elements = elements
    },
    function(data, menu)
        local value = data.current.value
        if(value == "open") then
            menu.close()
            openSafe(markerId)
        elseif(value == "manage") then
            menu.close()
            openSafeAccessMenu(markerId, info)
        end
    end,
    function(data, menu)
        menu.close()
    end)
end

function openSafe(markerId)
    local elements = {
        {label = getLocalizedText('deposit'), value = "deposit"},
        {label = getLocalizedText('withdraw'), value = "withdraw"},
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'safe', {
        title = getLocalizedText('safe'),
        align = 'bottom-right',
        elements = elements
    },
    function(data, menu)
        local action = data.current.value

        if(action == "deposit") then
            depositIntoSafe(markerId)
        elseif(action == "withdraw") then
            withdrawFromSafe(markerId)
        end
    end,
    function(data, menu)
        openedMenu = nil
        menu.close()
    end)
end