local hiredNPC = nil

-- NPC létrehozása
CreateThread(function()
    while not ESX or not ESX.PlayerLoaded do 
        Wait(100)
    end 

    Wait(1000)

    lib.zones.sphere({
        coords = vec(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z + 1.0),
        radius = Config.ZoneRadius or 3.0,
        debug = Config.Debug,
        inside = function()
            Draw3DText(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z + 2.0,
                Config.Labels.text_label)
        end,
    })

    local function SpawnNPC()
        if hiredNPC and DoesEntityExist(hiredNPC) then return end

        local model = GetHashKey(Config.NPC.model)
        RequestModel(model)
        local timeout = 0
        while not HasModelLoaded(model) and timeout < 100 do
            Wait(50)
            timeout = timeout + 1
        end

        if HasModelLoaded(model) then
            hiredNPC = CreatePed(4, model, Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z, Config.NPC.coords.w, false, true)
            SetEntityHeading(hiredNPC, Config.NPC.coords.w)
            FreezeEntityPosition(hiredNPC, true)
            SetEntityInvincible(hiredNPC, true)
            SetBlockingOfNonTemporaryEvents(hiredNPC, true)
            SetModelAsNoLongerNeeded(model)

            exports.ox_target:addLocalEntity(hiredNPC, {
                {
                    name = 'bc_publiktarolo:openMenu',
                    icon = 'fa-solid fa-box-open',
                    label = Config.Labels.target_label,
                    onSelect = function()
                        OpenStorageMenu()
                    end
                }
            })
        end
    end

    local function DespawnNPC()
        if hiredNPC and DoesEntityExist(hiredNPC) then
            exports.ox_target:removeLocalEntity(hiredNPC, 'bc_publiktarolo:openMenu')
            DeleteEntity(hiredNPC)
            hiredNPC = nil 
        end
    end

    lib.points.new({
        coords = vec3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z),
        distance = 50.0,
        onEnter = SpawnNPC,
        onExit = DespawnNPC
    })
end)

function OpenStorageMenu()
    lib.callback('bc_publiktarolo:getStorageStatus', false, function(data)
        local options = {}

        if data.isRented then
            local expiryDate = data.expireDateStr

            -- Megnyitás opció (csak ha nincs lejárva)
            if not data.isExpired then
                table.insert(options, {
                    title = Config.Labels.open_storage,
                    description = string.format(Config.Labels.expiry_date, expiryDate),
                    icon = 'box',
                    onSelect = function()
                        TriggerServerEvent('bc_publiktarolo:openStorage')
                    end
                })
            else
                table.insert(options, {
                    title = 'A raktár le van járva!',
                    description = Config.Labels.storage_expired,
                    icon = 'triangle-exclamation',
                    disabled = true
                })
            end

            -- Hosszabbítás opció
            table.insert(options, {
                title = Config.Labels.renew_storage,
                description = string.format(Config.Labels.rent_info, Config.Storage.price),
                icon = 'money-bill',
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = Config.Labels.renew_storage,
                        content = string.format(Config.Labels.confirm_renew, Config.Storage.price),
                        centered = true,
                        cancel = true
                    })

                    if alert == 'confirm' then
                        TriggerServerEvent('bc_publiktarolo:rentStorage', true)
                    end
                end
            })
        else
            -- Bérlés opció
            table.insert(options, {
                title = Config.Labels.rent_storage,
                description = string.format(Config.Labels.rent_info, Config.Storage.price),
                icon = 'hand-holding-dollar',
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = Config.Labels.rent_storage,
                        content = string.format(Config.Labels.confirm_rent, Config.Storage.price),
                        centered = true,
                        cancel = true
                    })

                    if alert == 'confirm' then
                        TriggerServerEvent('bc_publiktarolo:rentStorage', false)
                    end
                end
            })
        end

        lib.registerContext({
            id = 'storage_rental_menu',
            title = Config.Labels.target_label,
            options = options
        })

        lib.showContext('storage_rental_menu')
    end)
end

function Draw3DText(x, y, z, text, r, g, b)
    if not x or not y or not z or not text then return end
    SetDrawOrigin(x, y, z)

    SetTextScale(0.35 * 1.0, 0.35 * 1.0)
    SetTextFont(0)
    SetTextProportional(true)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()

    SetTextWrap(0.0, 1.0)
    SetTextColour(r or 255, g or 255, b or 255, 255)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(0.0, 0.0)

    ClearDrawOrigin()
end

-- Törlés ha leáll a resource
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if hiredNPC then
        DeleteEntity(hiredNPC)
    end
end)
