CreateThread(function()
    AddTextEntry('bc_safes_place_msg', '~INPUT_SKIP_CUTSCENE~ széf lehelyezése ~n~ ~INPUT_CELLPHONE_CANCEL~ mégse') --18 177
end)

RegisterNetEvent('bc_safes:placeSafe', function(size)

    if exports['loaf_housing']:isInHouse() then 
        ESX.ShowNotification("Itt nem rakhatod le a széfet!")
        return
    end 
    local input = lib.inputDialog('Széf adatai', {
        { type = "input", label = "A széf neve" },
        { type = "input", label = "A széf biztonsági kódja", password = false, icon = 'lock' },
    })
    if not input then
        ESX.ShowNotification("Helytelen adatok!")
        return
    end
    local newname = input[1]
    if not newname or newname == "" then
        ESX.ShowNotification("Helytelen név!")
        return
    end
    local newpasscode = input[2]
    if not newpasscode or newpasscode == "" then
        ESX.ShowNotification("Helytelen biztonsági kulcs!")
        return
    end

    CreateThread(function()
        local hash = Config.Safes[size].prop
        if not IsModelInCdimage(hash) then
            print('érvénytelen model: ' .. hash)
            return
        end
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
        local obj = CreateObject(hash, GetEntityCoords(PlayerPedId()), false)
        while not DoesEntityExist(obj) do
            Wait(10)
        end
        SetEntityAlpha(obj, 70, false)
        SetEntityCollision(obj, false, true)
        while true do
            Wait(1)
            DisplayHelpTextThisFrame('bc_safes_place_msg')
            local ped = PlayerPedId()
            SetEntityCoords(obj, GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.2, -0.58))
            SetEntityHeading(obj, GetEntityHeading(ped))
            if IsControlJustReleased(0, 18) then
                PlaceObjectOnGroundProperly(obj)
                TriggerServerEvent('bc_safes:safePlaced', size, GetEntityCoords(obj), GetEntityHeading(obj), newpasscode,
                    newname)
                break
            elseif IsControlJustReleased(0, 177) then
                break
            end
        end
        DeleteEntity(obj)
        SetModelAsNoLongerNeeded(hash)
    end)
end)
