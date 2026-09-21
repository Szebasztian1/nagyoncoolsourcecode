---@param v number
---@return number
local function toUint32(v)
    return v & 0xFFFFFFFF
end

---@param data { models: (number|string)[] }
---@return table<string, string>
Rpc:Register('admin:resolveVehicleNames', function(data)
    local result = {}
    for _, raw in ipairs(data.models or {}) do
        local hash     = toUint32(tonumber(raw) or 0)
        local labelKey = GetDisplayNameFromVehicleModel(hash)
        local displayName
        if labelKey and labelKey ~= '' and labelKey ~= 'NULL' then
            local label = GetLabelText(labelKey)
            displayName = (label and label ~= '' and label ~= 'NULL') and label or labelKey
        else
            displayName = 'Ismeretlen'
        end
        result[tostring(raw)] = displayName
    end
    return result
end)

lib.callback.register('mate-admin:getClosestPlate', function()
    local pos = GetEntityCoords(PlayerPedId())
    local veh = lib.getClosestVehicle(pos, 10.0, false)
    if not veh or veh == 0 then return nil end
    return GetVehicleNumberPlateText(veh)
end)

lib.callback.register('mate-admin:getWaypointCoords', function()
    local handle = GetFirstBlipInfoId(8)
    if not DoesBlipExist(handle) then return nil end
    return GetBlipCoords(handle)
end)
