-----------------------------------------------------------------------------------------------------------------------------------------
-- aquiver_farm_phone - client
-- Bridge between the phone iframe (NUI) and the server via ox_lib callbacks. GPS uses cached coords.
-----------------------------------------------------------------------------------------------------------------------------------------

local coordsCache = {}  -- [houseId] = { x, y, z }

local function cacheCoords(arr)
    for _, f in ipairs(arr or {}) do
        if f.coords then coordsCache[tostring(f.id)] = f.coords end
        f.coords = nil
    end
end

RegisterNUICallback('getFarms', function(_, cb)
    local data = lib.callback.await('aquiver_farm_phone:getFarms', false)
    if data then
        cacheCoords(data.farms)
        cacheCoords(data.purchasable)
    end
    cb(data or { ok = false, reason = 'error' })
end)

RegisterNUICallback('getFarmStats', function(body, cb)
    local id = body and body.id
    if id == nil then cb({ ok = false, reason = 'bad_input' }) return end
    local data = lib.callback.await('aquiver_farm_phone:getFarmStats', false, id)
    cb(data or { ok = false, reason = 'error' })
end)

RegisterNUICallback('buyAccess', function(body, cb)
    local id = body and body.id
    if id == nil then cb({ ok = false, reason = 'bad_input' }) return end
    local data = lib.callback.await('aquiver_farm_phone:buyAccess', false, id)
    cb(data or { ok = false, reason = 'error' })
end)

RegisterNUICallback('setGps', function(body, cb)
    local c = body and body.id and coordsCache[tostring(body.id)]
    if c then
        SetNewWaypoint(c[1] + 0.0, c[2] + 0.0)
        cb({ ok = true })
    else
        cb({ ok = false })
    end
end)
