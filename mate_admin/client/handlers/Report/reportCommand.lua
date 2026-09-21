RegisterCommand('report', function()
    CreateThread(function()
        -- The "AI question" type only makes sense while the assistant is actually reachable.
        local ok, aiEnabled = pcall(function()
            return Rpc:CallServer('report:aiAvailable')
        end)

        SetNuiFocus(true, true)
        Rpc:Send('report:openCreate', { aiEnabled = ok and aiEnabled == true })
    end)
end, false)

RegisterNUICallback('report:cancelCreate', function(_, cb)
    SetNuiFocus(false, false)
    Rpc:Send('report:closeCreate', {})
    cb({ success = true })
end)

RegisterNUICallback('report:submitCreate', function(data, cb)
    CreateThread(function()
        if not data or not data.type or not data.subject or data.subject == '' or not data.description or data.description == '' then
            cb({ success = false, message = 'Ervenytelen adatok.' })
            return
        end

        local ok, result = pcall(function()
            return Rpc:CallServer('report:create', {
                type        = data.type,
                subject     = data.subject,
                description = data.description,
            })
        end)

        SetNuiFocus(false, false)
        Rpc:Send('report:closeCreate', {})

        if ok and result and result.success then
            lib.notify({
                title       = 'Jelentes',
                description = ('Jelentesed sikeresen elkuldve! [%s]'):format(result.id),
                type        = 'success',
                duration    = 5000,
            })
            cb({ success = true, id = result.id })
        else
            lib.notify({
                title       = 'Hiba',
                description = 'A jelentes kuldese sikertelen. Probald ujra.',
                type        = 'error',
                duration    = 4000,
            })
            cb({ success = false })
        end
    end)
end)

RegisterNUICallback('chatwidget:exit', function(_, cb)
    SetNuiFocus(false, false)
    cb({ success = true })
end)
