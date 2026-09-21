local resourceName = GetCurrentResourceName()

--
-- Standalone snippet for npm package @matehun/rpc
--


RPC_EVENTS      = {
    C2S_REQ = ("mate-slot:rpc:c2s_req:%s"):format(resourceName),
    C2S_RES = ("mate-slot:rpc:c2s_res:%s"):format(resourceName),
    S2C_REQ = ("mate-slot:rpc:s2c_req:%s"):format(resourceName),
    S2C_RES = ("mate-slot:rpc:s2c_res:%s"):format(resourceName),
    PUSH    = ("mate-slot:rpc:push:%s"):format(resourceName),
}

PROXY_ROUTE     = "__rpc:proxy"
RESPONSE_ROUTE  = "__rpc:response"
DEFAULT_TIMEOUT = 10000

local idCounter = 0

function generateId()
    idCounter = idCounter + 1
    return ("%s:%x:%d"):format(resourceName, math.random(0, 0xFFFFFF), idCounter)
end

function wrapResult(ok, result)
    if not ok then
        return false, tostring(result)
    end
    return true, result
end
