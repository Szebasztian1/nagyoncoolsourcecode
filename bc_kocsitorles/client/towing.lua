---@type table<number, table>
local towingData = {}

---@param towList table
RegisterNetEvent("bc_pub:tow", function(towList)
    local resolvedTowData = {}

    for _, towEntry in pairs(towList) do
        if towEntry and towEntry[1] and towEntry[2] then
            local towingEntity                    = NetworkGetEntityFromNetworkId(towEntry[1]) or 0
            local towedEntity                     = NetworkGetEntityFromNetworkId(towEntry[2]) or 0
            resolvedTowData[#resolvedTowData + 1] = { towingEntity, towedEntity }
        end
    end

    towingData = resolvedTowData
end)

---@param vehicle number
---@return number|false
function IsTowing(vehicle)
    for _, towEntry in ipairs(towingData) do
        if towEntry[1] == vehicle then
            return towEntry[2]
        elseif towEntry[2] == vehicle then
            return towEntry[1]
        end
    end
    return false
end
