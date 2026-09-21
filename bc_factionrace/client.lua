RegisterNUICallback('exit', function(data, cb)
    SetNuiFocus(false, false) 
    SendNUIMessage({
        type = "show",
        enable = false
    })
    cb('ok')
end)

RegisterNUICallback('getdata', function(data, cb)
    cb({
        config = {
            infos = Config.Description
        }
    })
end)

function OpenBoard()
    ESX.TriggerServerCallback("bc_factionrace:getData", function(factionlist, mydata) 
        --print("openboard", mydata, factionlist)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "show",
            enable = true,
            mydata = mydata,
            factionlist = factionlist,
        })
    end)
end

RegisterCommand("factionrace", function()
    OpenBoard()
end)


local spawnedPed = nil

local function SpawnPed()
    if spawnedPed then return end
    local model = GetHashKey("mp_m_bogdangoon")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    spawnedPed = CreatePed(4, model, vector4(128.6392, 6628.5883, 30.733091, 226.21385), false, true)
    FreezeEntityPosition(spawnedPed, true)
    SetEntityInvincible(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)

    exports.ox_target:addLocalEntity(spawnedPed, {
        {
            name = 'bc_factionrace',
            icon = 'fa-solid fa-circle',
            label = 'Frakcióverseny',
            distance = 2.0,
            onSelect = function()
                OpenBoard()
            end
        }
    })
end

local function DeletePed()
    if spawnedPed then
        exports.ox_target:removeLocalEntity(spawnedPed)
        DeleteEntity(spawnedPed)
        spawnedPed = nil
    end
end

lib.zones.sphere({
    coords = vec3(128.6392, 6628.5883, 30.733091),
    radius = 50.0,
    debug = false,
    onEnter = function()
        SpawnPed()
    end,
    onExit = function()
        DeletePed()
    end,
})