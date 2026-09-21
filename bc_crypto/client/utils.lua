local cbevent = ("bc_crypto:cb:%s")
local events = {}

RegisterNetEvent(cbevent:format("ret"), function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

function TriggerServerCallback(event, ...)
    local key 
    repeat
		key = ('%s:%s'):format(event, math.random(0, 100000))
	until not events[key]

    TriggerServerEvent(cbevent:format(event), key, ...)

    local promise = promise.new()

    events[key] = function(response, ...)
        response = { response, ... }
        events[key] = nil
        return promise:resolve(response)
    end 

    SetTimeout(30000, function() promise:reject(("callback event '%s' timed out"):format(key)) end)

    return table.unpack(Citizen.Await(promise))
end 

RegisterNetEvent("bc_crypto:notification", function(msg)
    Notify(msg)
end)

function Notify(msg)
    TriggerEvent("esx:showNotification", msg)
end 

function IsPlayerLoaded()
    if not ESX then
        return false
    end
    if not ESX.PlayerLoaded then
        return false
    end
    return true
end

local groundProbes = {0.5, 3.0, 10.0}

-- Surface Z at (x, y), probed downwards from a few heights so props (piers, crates) are hit too.
-- Returns nil while the collision around the point is not loaded.
function GetSurfaceZ(x, y, fromZ)
    for _, up in ipairs(groundProbes) do
        local found, z = GetGroundZFor_3dCoord(x, y, fromZ + up, false)
        if found then
            return z
        end
    end
    return nil
end

-- [E] range: horizontal distance with a loose Z window, so a container that sits a bit above or
-- below the player's feet stays reachable.
function IsAtContainer(coords, target)
    return #(vector2(coords.x, coords.y) - vector2(target.x, target.y)) < 1.3
        and math.abs(coords.z - target.z) < 2.0
end 