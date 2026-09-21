RegisterCommand("hazberbeadas", function(source, args, rawCommand)
    ESX.TriggerServerCallback("bc_houserent:getData", function(data) 
        if not data or #data < 1 then 
            return ESX.ShowNotification("Nincs házad!")
        end  

        local elements = {}
        for k, v in pairs(data) do 
            elements[#elements+1] = {
                title = "Ház ID: " .. v.hid,
                description = "Bérlő: " .. v.renter .. " | Fizetve eddig: " .. v.paiduntil,
                onSelect = function()
                    OpenRentMenu(v.hid)
                end,
            }
        end

        lib.registerContext({
            id = 'rentout_menu',
            title = 'Bérbeadás menu',
            options = elements
        })
         
        lib.showContext('rentout_menu')
    end)
end)

function OpenRentMenu(houseid)
    ESX.TriggerServerCallback("bc_houserent:getHouseData", function(data) 
        if not data then 
            return ESX.ShowNotification("Nem a te házad!")
        end  

        if not data.rented then 
            lib.registerContext({
                id = 'rentoutto_menu',
                title = 'Bérbeadás menu',
                options = {
                    {
                        title = "Ez a ház nincs bérbeadva"
                    },
                    {
                        title = "A ház bérbeadása ->",
                        onSelect = function()
                            local input = lib.inputDialog('Ház bérbeadása '..houseid, {
                                {type = 'number', label = 'Bérlő ID', description = 'Kinek szeretnéd kaidni?', icon = 'hashtag'},
                                {type = 'number', label = 'Héti bérleti díj', description = 'Mennyi legyen a heti bérleti díj?', icon = 'hashtag'},
                            })
                               
                            if not input or not input[1] or not input[2] then 
                                return 
                            end

                            TriggerServerEvent("bc_houserent:rentoutHouse", houseid, input[1], input[2])
                        end
                    },
                }
            })
             
            lib.showContext('rentoutto_menu')
        else 
            lib.registerContext({
                id = 'rentinfo_menu',
                title = 'Bérbeadás menu',
                options = {
                    {
                        title = "Ez a ház bérbe van adva",
                        description = "Bérlő: " .. data.renter .. " | Fizetve eddig: " .. data.paiduntil.." | Szerződés felbontva: "..(data.brokecontract and "Igen" or "Nem"),
                    },
                    {
                        title = "Szerződés felbontása",
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = 'Felbontás megerősítése',
                                content = 'Biztosan fel akarod bontani a szerződést? Ezután a bérlő nem fog tudni tovább fizetni a házért és a befizetett idő végével el kell hagynia a házat!',
                                centered = true,
                                cancel = true
                            })

                            if alert == true or alert == "confirm" then 
                                TriggerServerEvent("bc_houserent:breakContract", houseid)
                            end
                        end
                    },
                }
            })
             
            lib.showContext('rentinfo_menu')
        end 
    end, houseid)
end 


lib.callback.register('bc_houserent:rentmodal', function(houseid, price)
    local alert = lib.alertDialog({
        header = 'Ház bérlése',
        content = 'Ki bérled a ' .. houseid .. ' házat heti ' .. price .. '$-ért?',
        centered = true,
        cancel = true
    })
    if alert == true or alert == "confirm" then 
        return true 
    end
    return false 
end)

RegisterCommand("hazberles", function(source, args, rawCommand)
    ESX.TriggerServerCallback("bc_houserent:getMyRents", function(data) 
        if not data or #data < 1 then 
            return ESX.ShowNotification("Nincs bérelt házad!")
        end  

        local elements = {}
        for k, v in pairs(data) do 
            elements[#elements+1] = {
                title = "Ház ID: " .. v.hid,
                description = "Fizetve eddig: " .. v.paiduntil .. " | Szerződés felbontva: " .. (v.brokecontract and "Igen" or "Nem"),
                onSelect = function()
                    OpenRentedMenu(v.hid)
                end,
            }
        end

        lib.registerContext({
            id = 'rented_menu',
            title = 'Bérleti szerződések',
            options = elements
        })
         
        lib.showContext('rented_menu')
    end)
end)

function OpenRentedMenu(houseid)
    ESX.TriggerServerCallback("bc_houserent:getHouseData", function(data) 
        if not data then 
            return ESX.ShowNotification("Nem a te házad!")
        end  

        lib.registerContext({
            id = 'rentedinfo_menu',
            title = 'Bérleti szerződés',
            options = {
                {
                    title = "Ház: " .. houseid,
                    description = "Fizetve eddig: " .. data.paiduntil .. " | Szerződés felbontva: " .. (data.brokecontract and "Igen" or "Nem"),
                },
                {
                    title = "Bérlés +1 hétre ("..data.price.."$)",
                    onSelect = function()
                        local alert = lib.alertDialog({
                            header = 'Ház bérlése',
                            content = 'Ki bérled a ' .. houseid .. ' házat +1 hétre ' .. price .. '$-ért?',
                            centered = true,
                            cancel = true
                        })
                        if alert == true or alert == "confirm" then 
                            TriggerServerEvent("bc_houserent:payRent", houseid)
                        end
                    end
                },
            }
        })
         
        lib.showContext('rentedinfo_menu')
    end, houseid)
end