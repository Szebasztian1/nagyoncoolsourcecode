local itemNames = {}
CreateThread(function()
    for item, data in pairs(exports.ox_inventory:Items()) do
        itemNames[item] = data.label
    end
end)

function GetRewLabel(rew)
    if rew.label then
        return rew.label
    end

    local label = ""

    for k, v in pairs(rew.add) do
        if v.type == "item" then
            local itemLabel = (itemNames[v.item] or v.item)
            label = label .. string.format("%s: %d ", itemLabel, v.amount)
        elseif v.type == "money" then
            local accountLabel = "Pénz"
            label = label .. string.format("%s: $%d ", accountLabel, v.amount)
        end
    end

    return label
end

-- The walk / drive daily tasks no longer run their own 300 ms loops here: the achievement
-- tracker (achievements/client/tracker.lua) measures the movement once, filters teleports,
-- respawns and noclip, and the server feeds the tasks from its clamped report
-- (server/editable.lua, Config.MovementSteps).
