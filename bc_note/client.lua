ESX = nil
local isInUi = false
local openedId = nil
local notes = {}

RegisterNUICallback('exit', function(data, cb)
    if not openedId and data.text ~= "" then 
        TriggerServerEvent("bc_note:create", data.text, GetEntityCoords(PlayerPedId()))
    elseif openedId and notes[openedId].text ~= data.text then 
        TriggerServerEvent("bc_note:updatenote", openedId, data.text)
    end 

    openedId = nil

	SendNUIMessage({
		type = "show",
		enable = false 
	})
	SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('bc_note:open')
AddEventHandler('bc_note:open', function()
	SendNUIMessage({
        type = "show",
        enable = true,
        text = ""
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('bc_note:update')
AddEventHandler('bc_note:update', function(data)
	notes = data
end)

Citizen.CreateThread(function()
    while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

    Citizen.Wait(2000)

    TriggerServerEvent("bc_note:login")

    AddTextEntry('note_open_msg', '~INPUT_PICKUP~ a cetli elolvasáséhoz ~INPUT_LOOK_BEHIND~ a cetli törléséhez')

    while true do 
        local coords = GetEntityCoords(PlayerPedId())
        local sleep = 1000

        for i, v in pairs(notes) do 
            local distance = #(coords - v.coords)
            if distance < 20 then 
                sleep = 2
                DrawMarker(21, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 155, 20, 100, true, true, 2, false, false, false, false)
                if distance < 0.8 then   
                    DisplayHelpTextThisFrame('note_open_msg')
                    if IsControlJustReleased(0, 38) then
                        openedId = i
                        SendNUIMessage({
                            type = "show",
                            enable = true,
                            text = v.text
                        })
                        SetNuiFocus(true, true)
                    elseif IsControlJustReleased(0, 26) then
                        TriggerServerEvent("bc_note:delete", i)
                    end 
                end 
            end 
        end 

        Citizen.Wait(sleep)
    end 
end)