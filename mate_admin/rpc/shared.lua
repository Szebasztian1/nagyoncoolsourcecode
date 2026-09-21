local resourceName = GetCurrentResourceName()

RPC_EVENTS         = {
    C2S_REQ     = ("%s:rpc:c2s_req"):format(resourceName),
    C2S_RES     = ("%s:rpc:c2s_res"):format(resourceName),
    C2S_RES_LAT = ("%s:rpc:c2s_res_lat"):format(resourceName),
    S2C_REQ     = ("%s:rpc:s2c_req"):format(resourceName),
    S2C_RES     = ("%s:rpc:s2c_res"):format(resourceName),
    PUSH        = ("%s:rpc:push"):format(resourceName),
}

PROXY_ROUTE        = "__rpc:proxy"
RESPONSE_ROUTE     = "__rpc:response"
DEFAULT_TIMEOUT    = 60000

local idCounter    = 0

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
