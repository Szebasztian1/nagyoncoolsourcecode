function openShop(markerId)
    ESX.TriggerServerCallback('esx_job_creator:getShopData', function(shopData)
       -- if not shopData then return end 
       -- exports.ox_inventory:openInventory("shop", 'job-shop-'..markerId)
        ESX.UI.Menu.CloseAll()

        table.sort(shopData, function (a, b)
            return string.upper(a.label) < string.upper(b.label)
          end)

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_shop', {
            title = getLocalizedText('job_shop'),
            align = 'bottom-right',
            elements = shopData
        },
        function(data, menu)
            local itemName = data.current.value
            local itemType = data.current.itemType

            if(itemName) then
                if(itemType == "item_standard") then
                    askQuantity(getLocalizedText('quantity'), "shop_quantity", 1, nil, function(quantity)
                        if(quantity) then
                            TriggerServerEvent('esx_job_creator:buyShopItem', markerId, itemName, quantity)
                        end
                    end)
                elseif(itemType == "item_weapon") then
                    TriggerServerEvent('esx_job_creator:buyShopItem', markerId, itemName, 1)
                end
            end
        end,
        function(data, menu)
            openedMenu = nil
            menu.close()
        end)
    end, markerId)
end