-- Tasks side of the BC Küldetések panel: the progress rows for the NUI and the reward claim.
-- The panel itself (open, close, the achievement pages) is achievements/client/panel.lua.

---@type { key: string, type: string }[]
local TASK_TYPES = {
    { key = "daily",     type = "DailyTasks" },
    { key = "weekly",    type = "WeeklyTasks" },
    { key = "permanent", type = "PermanentTasks" },
}

---@param tasks table Config.DailyTasks / WeeklyTasks / PermanentTasks
---@param progress table|nil the player's rows of that type from bc_tasksystem:getData
---@return table[]
local function BuildTaskList(tasks, progress)
    local list = {}
    for id, task in pairs(tasks) do
        local row = progress and progress[id]
        list[#list + 1] = {
            id = id,
            name = task.name,
            description = task.description,
            completed = row and row.count or 0,
            required = task.required,
            claimed = row and row.collected or false,
            reward = GetRewLabel(task.reward),
        }
    end
    return list
end

---Waits for the server, so call it from a thread.
---@return { daily: table[], weekly: table[], permanent: table[] }
function FetchTaskLists()
    local p = promise.new()
    ESX.TriggerServerCallback("bc_tasksystem:getData", function(data)
        p:resolve(data or {})
    end)
    local data = Citizen.Await(p)

    local lists = {}
    for _, taskType in ipairs(TASK_TYPES) do
        lists[taskType.key] = BuildTaskList(Config[taskType.type], data[taskType.type])
    end
    return lists
end

-- rota-pausemenu and bc_tablet open the panel with ExecuteCommand('taskmenu').
function OpenTaskMenu()
    OpenMissionPanel("daily")
end

RegisterCommand("taskmenu", OpenTaskMenu)

-- rota-pausemenu's Extra page shows how many task rewards are waiting. An export must not wait for
-- the server, so the count comes back through cb from a thread.
exports("GetClaimableCount", function(cb)
    CreateThread(function()
        local count = 0
        for _, list in pairs(FetchTaskLists()) do
            for _, task in ipairs(list) do
                if not task.claimed and task.completed >= (tonumber(task.required) or math.huge) then
                    count = count + 1
                end
            end
        end
        pcall(cb, count)
    end)
end)

RegisterNUICallback("claim", function(data, cb)
    ESX.TriggerServerCallback("bc_tasksystem:reward", function(success)
        if success then
            ESX.ShowNotification(Translate("reward_claimed"))
            cb({success = true})
        else
            ESX.ShowNotification(Translate("claim_failed"))
            cb({success = false})
        end
    end, data.taskType, data.taskId)
end)

RegisterNUICallback("data", function(data, cb)
    local locales = {}
    for k, v in pairs(Locales[Config.Locale]) do
        if string.find(k, "ui_") then
            locales[k] = v
        end
    end
    cb({locales = locales})
end)
