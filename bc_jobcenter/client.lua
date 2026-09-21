local opened = false

function OpenJobcenter()
    SetNuiFocus(true, true)
	opened = true

	SendNUIMessage({
		type = "show",
		enable = true
	})
end 

function Close()
    SetNuiFocus(false, false)
	opened = false

	SendNUIMessage({
		type = "show",
		enable = false
	})
end 

RegisterNUICallback('exit', function(data, cb)
    Close()
    cb(1)
end)

RegisterNUICallback('data', function(data, cb)
    while not ESX.PlayerLoaded do 
        Wait(10)
    end 
    local nuilocales = {}
    if not Config.Locale or not Locales[Config.Locale] then return print("^1SCRIPT ERROR: Invilaid locales configuartion") end
    for k, v in pairs(Locales[Config.Locale]) do 
        if string.find(k, "nui") then 
            nuilocales[k] = v
        end 
    end 
    local jobs = {}
    for id, v in pairs(Config.Jobs) do 
        jobs[#jobs+1] = {name = id, label = v.label, text = v.desc}
    end 
    cb({
        jobs = jobs,
        locales = nuilocales
    })
end)

RegisterNUICallback('setjob', function(data, cb)
    --TriggerServerEvent('villamos_jobcenter:setJob', data.job)
    --print(data.job)
    --Config.Jobs[data.job].coords

    if not Config.Jobs[data.job] then 
        return 
    end 
    if Config.Jobs[data.job].setjob then 
        TriggerServerEvent('villamos_jobcenter:setJob', data.job)
        return 
    end 
    SetNewWaypoint(Config.Jobs[data.job].coords.x, Config.Jobs[data.job].coords.y)
    Close()
    Config.Notify("Kijelölve a térképen!")
    cb(1)
end)


CreateThread(function()
    while not ESX or not ESX.PlayerLoaded do 
        Wait(200)
    end
    Wait(20000)
    local peds = {}
    local model = GetHashKey("mp_m_bogdangoon")

    for i=1, #Config.Positions, 1 do
        local blip = AddBlipForCoord(Config.Positions[i].x, Config.Positions[i].y, Config.Positions[i].z)
        SetBlipSprite (blip, Config.Blip.sprite)
        SetBlipScale  (blip, 1.0)
        SetBlipColour (blip, Config.Blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(_U("blip"))
        EndTextCommandSetBlipName(blip)

        lib.zones.sphere({
            coords = vec3(Config.Positions[i].x, Config.Positions[i].y, Config.Positions[i].z),
            radius = 50.0,
            debug = false,
            onEnter = function()
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(10)
                end
                
                local ped = CreatePed(4, model, Config.Positions[i], false, true)
                FreezeEntityPosition(ped, true)
                SetEntityInvincible(ped, true)
                SetBlockingOfNonTemporaryEvents(ped, true)

                peds[i] = ped

                exports.ox_target:addLocalEntity(ped, {
                    {
                        name = 'bc_jobcenter',
                        icon = 'fa-solid fa-circle',
                        label = 'Munkaügyi Hivatal',
                        onSelect = function()
                            OpenJobcenter()
                        end
                    }
                })
            end,
            onExit = function()
                if peds[i] then
                    exports.ox_target:removeLocalEntity(peds[i], 'bc_jobcenter')
                    DeleteEntity(peds[i])
                    peds[i] = nil
                end
            end
        })
    end 

    AddTextEntry('jobcenter_open_msg', _U("open_msg"))
end)