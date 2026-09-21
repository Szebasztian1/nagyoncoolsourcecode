
local eventType = false
local waitingForRespawn = false

RegisterNetEvent('mate-admin:event:syncStatus')
AddEventHandler('mate-admin:event:syncStatus', function(data)
    eventType = data.inEvent and data.type or false
    if not eventType then
        waitingForRespawn = false
    end
end)

CreateThread(function()
    while true do
        if eventType == 'ffa' or eventType == 'teampvp' then
            local ped = PlayerPedId()
            local dead = IsEntityDead(ped)

            if dead and not waitingForRespawn then
                waitingForRespawn = true
                if eventType == 'ffa' then
                    TriggerServerEvent('mate-admin:event:ffaDied')
                else
                    TriggerServerEvent('mate-admin:event:teamPvpDied')
                end
            elseif not dead then
                waitingForRespawn = false
            end

            Wait(500)
        else
            Wait(2000)
        end
    end
end)
