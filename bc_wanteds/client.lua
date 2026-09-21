CreateThread(function()
    exports.ox_target:addGlobalPlayer({

		{
			name = 'bc_wanted',
			event = 'bc_wanted:add',
			icon = 'fa-regular fa-circle',
			label = 'Játékos köröztetése',
			distance = 3.0,
            canInteract = function(entity)
				if not ESX or not ESX.PlayerData or not ESX.PlayerData.job then return false end
				if not Config.AllowedJobs[ESX.PlayerData.job.name] then return false end
                local playerr
                for _, player in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(player)
                    if ped == entity then
                        playerr = player
                        break
                    end
                end
                if not playerr then return false end
                local targetSrc = GetPlayerServerId(playerr)

                local stateBag = Player(targetSrc).state
                if stateBag.ghostShape then return false end
                if GetResourceState("mate-ghost") == "started" and exports["mate-ghost"]:IsGhostServerId(targetSrc) then return false end
                return true
            end 
		}
    })
end)

AddEventHandler('bc_wanted:add', function(data)
	if data.distance > 3 then return TriggerEvent('esx:showNotification', "Túl messze van!") end

	local playerr
	for _, player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)
		if ped == data.entity then
			playerr = player
			break
		end
	end
	if not playerr then return end
	local targetSrc = GetPlayerServerId(playerr)

    print("wantedadd", targetSrc)

	TriggerServerEvent("bc_wanted:add", targetSrc)
end)

local mysh = ""

function TakePic()
    local ped = PlayerPedId()

    local headshot = RegisterPedheadshotTransparent(ped)
    local timeout = 20
    while timeout > 0 and not IsPedheadshotReady(headshot) or not IsPedheadshotValid(headshot) do 
        timeout = timeout - 1
        Wait(100)
    end 

    if not IsPedheadshotReady(headshot) or not IsPedheadshotValid(headshot) then 
        print("no headshot")
        headshot = RegisterPedheadshot(ped)
        timeout = 20
        while timeout > 0 and not IsPedheadshotReady(headshot) or not IsPedheadshotValid(headshot) do 
            timeout = timeout - 1
            Wait(100)
        end 
        if not IsPedheadshotReady(headshot) or not IsPedheadshotValid(headshot) then 
            print("no headshot2")
            return false
        end 
    end 

    local txdstr = GetPedheadshotTxdString(headshot)

    print("upload", txdstr)

    SendNUIMessage({
        type = "headshot",
        webhook = mysh,
        txdstr = txdstr
    })

    Wait(5000)

    UnregisterPedheadshot(headshot)

end 
RegisterNUICallback('uploadedimage', function(data, cb)
    local resp = json.decode(data.data) -- resp.attachments[1].proxy_url
    print(data.data)
    print(resp)
    if not resp or not resp.attachments or not resp.attachments[1] then 
		urlret = false 
        return 
    end 
    local img = resp.attachments[1].proxy_url
    print(img)
    if not img then 
		urlret = false 
        return 
    end 
print("urlret set")
    urlret = img
end)

function GetMg(w)
    mysh = w
    print("mymugsh")
	TakePic()
	urlret = nil
	while urlret == nil do 
		Wait(100)
	end 
    print("url found")
	if urlret then 
		return urlret
	end
	return false

end 

local urlret = nil 
lib.callback.register('bc_wanted:getmugshot', function(w)
    return GetMg(w)
end)

RegisterNetEvent('bc_wanted:addpic', function(b64)
	if not b64 then return end
	local img = b64
    print("addpic", img)
	SendNUIMessage({
		type = "addpic",
		img = img
	})
end)

RegisterNetEvent("bc_wanted:gps", function(c)
    local b = AddBlipForCoord(c)
        SetBlipSprite(b , 161)
        SetBlipScale(b , 1.0)
        SetBlipColour(b, 3)
        SetBlipAsShortRange(b, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Körözött személy")
  EndTextCommandSetBlipName(b)
        PulseBlip(b)
        Wait(1000*60*20)
        RemoveBlip(b)
end)