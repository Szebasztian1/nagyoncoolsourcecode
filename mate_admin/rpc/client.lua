Rpc = {}

local nuiHandlers = {}
local clientHandlers = {}
local pendingServerCalls = {}
local pendingNuiCalls = {}
local pendingProxyCbs = {}

function Rpc:Register(route, handler)
    nuiHandlers[route] = handler

    RegisterNUICallback(route, function(data, cb)
        CreateThread(function()
            local ok, result = wrapResult(pcall(handler, data))
            cb({ success = ok, data = result })
        end)
    end)
end

function Rpc:RegisterServerProxy(route)
    RegisterNUICallback(route, function(data, cb)
        local id               = generateId()
        local p                = promise.new()

        pendingServerCalls[id] = p

        TriggerServerEvent(RPC_EVENTS.C2S_REQ, id, route, data or {})

        SetTimeout(DEFAULT_TIMEOUT, function()
            if pendingServerCalls[id] then
                pendingServerCalls[id] = nil
                p:reject(("RPC proxy '%s' timed out"):format(route))
            end
        end)

        CreateThread(function()
            local ok, result = pcall(Citizen.Await, p)
            cb({ success = ok, data = ok and result or tostring(result) })
        end)
    end)
end

function Rpc:Send(action, data)
    SendNUIMessage({ action = action, data = data or {} })
end

function Rpc:Call(action, data, timeout)
    local id            = generateId()
    local p             = promise.new()

    pendingNuiCalls[id] = p

    SendNUIMessage({
        action  = action,
        data    = data or {},
        __rpcId = id,
    })

    SetTimeout(timeout or DEFAULT_TIMEOUT, function()
        if pendingNuiCalls[id] then
            pendingNuiCalls[id] = nil
            p:reject(("RPC NUI call '%s' timed out"):format(action))
        end
    end)

    return Citizen.Await(p)
end

function Rpc:CallServer(route, data, timeout)
    local id               = generateId()
    local p                = promise.new()

    pendingServerCalls[id] = p

    TriggerServerEvent(RPC_EVENTS.C2S_REQ, id, route, data or {})

    SetTimeout(timeout or DEFAULT_TIMEOUT, function()
        if pendingServerCalls[id] then
            pendingServerCalls[id] = nil
            p:reject(("RPC server call '%s' timed out"):format(route))
        end
    end)

    return Citizen.Await(p)
end

function Rpc:SendServer(route, data)
    TriggerServerEvent(RPC_EVENTS.C2S_REQ, nil, route, data or {})
end

RegisterNUICallback(RESPONSE_ROUTE, function(payload, cb)
    local id = payload.__rpcId

    if not id then
        cb({ success = false, data = "Missing __rpcId" })
        return
    end

    local p = pendingNuiCalls[id]

    if not p then
        cb({ success = false, data = "No pending call for this id" })
        return
    end

    pendingNuiCalls[id] = nil
    p:resolve(payload.data)
    cb({ success = true, data = {} })
end)

RegisterNUICallback(PROXY_ROUTE, function(payload, cb)
    local route = payload.route

    if not route then
        cb({ success = false, data = "Missing route in proxy call" })
        return
    end

    local id            = generateId()
    pendingProxyCbs[id] = cb

    TriggerServerEvent(RPC_EVENTS.C2S_REQ, id, route, payload.data or {})

    SetTimeout(DEFAULT_TIMEOUT, function()
        local storedCb = pendingProxyCbs[id]
        if not storedCb then return end
        pendingProxyCbs[id] = nil
        storedCb({ success = false, data = ("RPC proxy '%s' timed out"):format(route) })
    end)
end)

RegisterNetEvent(RPC_EVENTS.C2S_RES)
AddEventHandler(RPC_EVENTS.C2S_RES, function(id, success, data)
    local proxyCb = pendingProxyCbs[id]
    if proxyCb then
        pendingProxyCbs[id] = nil
        proxyCb({ success = success, data = data })
        return
    end

    local p = pendingServerCalls[id]
    if not p then return end

    pendingServerCalls[id] = nil

    if success then
        p:resolve(data)
    else
        p:reject(data)
    end
end)

RegisterNetEvent(RPC_EVENTS.C2S_RES_LAT)
AddEventHandler(RPC_EVENTS.C2S_RES_LAT, function(id, success, data)
    local proxyCb = pendingProxyCbs[id]
    if proxyCb then
        pendingProxyCbs[id] = nil
        proxyCb({ success = success, data = data })
        return
    end

    local p = pendingServerCalls[id]
    if not p then return end

    pendingServerCalls[id] = nil

    if success then
        p:resolve(data)
    else
        p:reject(data)
    end
end)

RegisterNetEvent(RPC_EVENTS.PUSH)
AddEventHandler(RPC_EVENTS.PUSH, function(action, data)
    SendNUIMessage({ action = action, data = data or {} })
end)

RegisterNetEvent(RPC_EVENTS.S2C_REQ)
AddEventHandler(RPC_EVENTS.S2C_REQ, function(id, route, data)
    local handler = clientHandlers[route] or nuiHandlers[route]

    if not handler then
        TriggerServerEvent(RPC_EVENTS.S2C_RES, id, false, ("RPC handler '%s' not found on client"):format(route))
        return
    end

    local ok, result = wrapResult(pcall(handler, data))
    TriggerServerEvent(RPC_EVENTS.S2C_RES, id, ok, result)
end)
