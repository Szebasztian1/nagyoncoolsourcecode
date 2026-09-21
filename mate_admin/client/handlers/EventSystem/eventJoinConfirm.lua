RegisterNetEvent('mate-admin:event:confirmJoin')
AddEventHandler('mate-admin:event:confirmJoin', function()
    local result = lib.alertDialog({
        header = locale('eventjoin.header'),
        content = locale('eventjoin.content'),
        centered = true,
        cancel = true,
        labels = { confirm = locale('eventjoin.confirm'), cancel = locale('eventjoin.cancel') },
    })

    if result == 'confirm' then
        TriggerServerEvent('mate-admin:event:confirmedJoin')
    end
end)
