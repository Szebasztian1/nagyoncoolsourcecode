local PlayerData = {}

AddEventHandler('playerSpawned', function()
    Citizen.Wait(10 * 1000)
    setplayerped()
end)

RegisterNetEvent('bc_duty:off', function()
    Citizen.Wait(3000)
    setplayerped()
end)


AddEventHandler("bc:reloadedskin", function()
    Citizen.Wait(3000)
    setplayerped()
end)

RegisterCommand('getmyped', function(source, args)
    setplayerped()
end, false)

function setplayerped()
    ESX.TriggerServerCallback('asdasd_getped', function(ped)
        if ped ~= "none" and ped ~= "" then
            local hash = GetHashKey(ped)
            requestmodel(hash)
            SetPlayerModel(PlayerId(), hash)
            TriggerEvent('esx:restoreLoadout')
        end
    end)
end

function requestmodel(hash)
    RequestModel(hash)
    local start = GetGameTimer()
    while not HasModelLoaded(hash) do
        if (GetGameTimer() - start) > 4000 then 
            return 
        end 
        RequestModel(hash)
        Citizen.Wait(0)
    end
end

RegisterNetEvent("asdasdpeds_setpedcommandremove")
AddEventHandler("asdasdpeds_setpedcommandremove", function()
    loadplayerskin()

    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
end)

function loadplayerskin()
    local hash = GetHashKey('mp_m_freemode_01')
    requestmodel(hash)
    SetPlayerModel(PlayerId(), hash)
    TriggerEvent('esx:restoreLoadout')
end

RegisterNetEvent("asdasdpeds_setpedcommand")
AddEventHandler("asdasdpeds_setpedcommand", function()
    setplayerped()
end)

local hajgumi = false
local savedhajgumi1 = 0
local savedhajgumi2 = 0

RegisterCommand('hajgumi', function(source, args, raw)
    if hajgumi then
        --[[ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)]]
        SetPedComponentVariation(PlayerPedId(), 2, savedhajgumi1, savedhajgumi2, 0)
        hajgumi = false
    else
        --TriggerEvent('skinchanger:change', 'hair_1', 74)

        savedhajgumi1 = GetPedDrawableVariation(PlayerPedId(), 2)
        savedhajgumi2 = GetPedTextureVariation(PlayerPedId(), 2)
        SetPedComponentVariation(PlayerPedId(), 2, 0, 0, 0)
        hajgumi = true
    end
end)

lib.callback.register('bc_ped:transferRequest', function(senderName, pedName)
    local conf = lib.alertDialog({
        header = 'Ped átadás',
        content = senderName .. ' át akarja adni a ped-jét (**' .. pedName .. '**), elfogadod?',
        centered = true,
        cancel = true
    })
    return conf == 'confirm'
end)

lib.callback.register('bc_ped:onoff', function(active, freeAvailable)
    local conf = lib.alertDialog({
        header = freeAvailable and 'Ped csere (ma ingyenes)' or 'Ped csere 500 PP',
        content = freeAvailable
            and (active and "Visszaváltasz az alap pedre, ma még ingyenes, később ha úgy döntesz visszacserélheted a peded?" or "Visszaváltasz a pededre az alap pededről, ma még ingyenes!")
            or (active and "Visszaváltasz az alap pedre 500PP-ért, később ha úgy döntesz visszacserélheted a peded?" or "Visszaváltasz a pededre az alap pededről 500PP-ért"),
        centered = true,
        cancel = true
    })
    if conf == "confirm" then
        return true
    end
    return false
end)
