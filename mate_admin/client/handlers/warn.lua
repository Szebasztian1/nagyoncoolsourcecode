RegisterNetEvent('mate-admin:warn')
AddEventHandler('mate-admin:warn', function(message)
    Rpc:Send('warn:show', { message = message })
end)
