CreateThread(function()
    local concealed = {}

    while true do
        Wait(3000)
        local me = PlayerPedId()
        local myCoords = GetEntityCoords(me)

        -- GetActivePlayers returns only the players actually in scope (a few dozen)
        -- instead of all 512 slots, and the yield spreads the sweep across frames so a
        -- whole pass can never land inside a single one.
        local players = GetActivePlayers()

        for i = 1, #players do
            local id = players[i]

            if i % 8 == 0 then Wait(0) end

            if id ~= PlayerId() and NetworkIsPlayerActive(id) then
                local ped = GetPlayerPed(id)
                local serverId = GetPlayerServerId(id)



                if DoesEntityExist(ped) and serverId ~= GetPlayerServerId(PlayerId()) then
                    local coords = GetEntityCoords(ped)

                    local dist = #(vector2(myCoords.x, myCoords.y) - vector2(coords.x, coords.y))

                    
                    if  dist > Config.HideDistance then
                        if not concealed[serverId] then
                            NetworkConcealPlayer(id, true)
                            concealed[serverId] = true
                        end
                    else
                        if concealed[serverId] then
                            NetworkConcealPlayer(id, false)
                            concealed[serverId] = false
                        end
                    end
                end
            end
        end
    end
end)