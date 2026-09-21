-- BC Express – RoadPhone custom app NUI-híd (html/app.js ehhez a resource-hoz tartozik).

local PhoneApp = {}

RegisterNUICallback('bcx:getState', function(_, cb)
    local data = lib.callback.await('bc_express:getState', false)
    cb(data or { ok = false })
end)

-- a telefon "Cég" füle: CSAK NÉZET – a menedzsment + üzemeltetés adatait olvassa (kezelni a depo-panelben lehet)
RegisterNUICallback('bcx:getCompany', function(_, cb)
    local manager = lib.callback.await('bc_express:getManager', false)
    local ops     = lib.callback.await('bc_express:getOperations', false)
    cb({ ok = true, manager = manager or { ok = false }, ops = ops or { ok = false } })
end)

-- a telefon "Munkahely" füle: CSAK NÉZET – hol vagy alkalmazott + a tulaj eszközeinek állapota
RegisterNUICallback('bcx:getEmployment', function(_, cb)
    local data = lib.callback.await('bc_express:getEmployment', false)
    cb(data or { ok = false })
end)

RegisterNUICallback('bcx:waypoint', function(data, cb)
    if data and data.x and data.y then SetNewWaypoint(data.x + 0.0, data.y + 0.0) end
    cb('ok')
end)

return PhoneApp
