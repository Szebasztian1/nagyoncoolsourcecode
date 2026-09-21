RegisterCommand('frakievent', function()

    ESX.TriggerServerCallback('fraki_event:getPlayerFaction', function(jobName, jobLabel)

        if not jobName then
            lib.notify({
                title       = 'Hiba',
                description = 'Te nem vagy jogosult event létrehozására!',
                type        = 'error',
            })
            return
        end

        -- Sensible defaults
        --local now     = os.date('*t')
        --local defDate = string.format('%04d-%02d-%02d', now.year, now.month, now.day)
        --local defTime = string.format('%02d:00', (now.hour + 1) % 24)

        -- ── ox_lib input dialog ──────────────────────────────
        local result = lib.inputDialog('⚔️  Frakció Esemény – ' .. jobLabel, {
            {
                type        = 'input',
                label       = '📅 Dátum (ÉÉÉÉ-HH-NN)',
                required    = true,
                min         = 10,
                max         = 10,
            },
            {
                type        = 'input',
                label       = '🕐 Kezdési idő (ÓÓ:PP)',
                required    = true,
                min         = 5,
                max         = 5,
            },
            {
                type        = 'input',
                label       = '📍 Helyszín',
                description = 'pl. Pillbox Hill kórház előtt',
                required    = true,
                min         = 2,
                max         = 80,
            },
            {
                type        = 'textarea',
                label       = '📝 Leírás',
                description = 'Rövid eseményleírás (max 200 karakter)',
                required    = true,
                min         = 5,
                max         = 200,
            },
        })
--print("logeci")
        if not result then return end

        local dateStr = result[1] and result[1]:match('^%s*(.-)%s*$') or ''
        local timeStr = result[2] and result[2]:match('^%s*(.-)%s*$') or ''
        local location= result[3] and result[3]:match('^%s*(.-)%s*$') or ''
        local desc    = result[4] and result[4]:match('^%s*(.-)%s*$') or ''
--print("logeci")
        if not dateStr:match('^%d%d%d%d%-%d%d%-%d%d$') then
            lib.notify({ title = 'Hiba', description = 'Érvénytelen dátum formátum! (ÉÉÉÉ-HH-NN)', type = 'error' })
            return
        end
--print("logeci")
        if not timeStr:match('^%d%d:%d%d$') then
            lib.notify({ title = 'Hiba', description = 'Érvénytelen idő formátum! (ÓÓ:PP)', type = 'error' })
            return
        end
--        print("logeci")

        --local ts = parseDateTime(dateStr, timeStr)
        --if not ts then
        --    lib.notify({ title = 'Hiba', description = 'Nem sikerült értelmezni a dátumot/időt!', type = 'error' })
        --    return
        --end
--
        --if ts <= os.time() then
        --    lib.notify({ title = 'Hiba', description = 'Az esemény kezdési ideje a jövőben kell legyen!', type = 'error' })
        --    return
        --end

        TriggerServerEvent('fraki_event:createEvent', {
            dateStr    = dateStr,
            timeStr    = timeStr,
            --startTime   = ts,
            location    = location,
            description = desc,
        })
    end)

end, false)

RegisterCommand('frakieventek', function()
    TriggerServerEvent('fraki_event:requestEventList')
end, false)

RegisterNetEvent('fraki_event:receiveEventList', function(list)
    if #list == 0 then
        lib.notify({
            title       = 'Nincs aktív esemény',
            description = 'Jelenleg nincs meghirdetett esemény.',
            type        = 'inform',
        })
        return
    end

    local items = {}
    for _, ev in ipairs(list) do
        table.insert(items, {
            title       = string.format('[%s]  %s', ev.faction, ev.location),
            description = string.format('⏰ %s\n%s', ev.timeStr, ev.description),
            readOnly    = true,
        })
    end

    lib.registerContext({
        id      = 'fraki_event_list',
        title   = '📅 Aktív frakció események',
        options = items,
    })
    lib.showContext('fraki_event_list')
end)


RegisterNetEvent('fraki_event:notify', function(title, description, ntype)
    lib.notify({
        title       = title,
        description = description,
        type        = ntype or 'inform',
        duration    = 8000,
        position    = 'top-right',
    })
end)
