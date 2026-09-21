---@type string?
PlayerActiveReportId = nil

Rpc:RegisterServerProxy('report:playerClose')

AddEventHandler(RPC_EVENTS.PUSH, function(action, data)
    if action == 'report:opened' then
        PlayerActiveReportId = data.report and data.report.id
    elseif action == 'report:claimed' then
        PlayerActiveReportId = data.reportId
    elseif action == 'report:closed' then
        PlayerActiveReportId = nil
    end
end)

RegisterNUICallback('report:getAll', function(_, cb)
    CreateThread(function()
        local ok, result = pcall(function() return Rpc:CallServer('report:getAll', {}) end)
        cb({ success = ok, data = ok and result or {} })
    end)
end)

RegisterNUICallback('report:claim', function(data, cb)
    CreateThread(function()
        local ok, result = pcall(function() return Rpc:CallServer('report:claim', { reportId = data.reportId }) end)
        cb({ success = ok and result and result.success, data = ok and result or tostring(result) })
    end)
end)

RegisterNUICallback('report:close', function(data, cb)
    CreateThread(function()
        local ok, result = pcall(function()
            return Rpc:CallServer('report:close',
                { reportId = data.reportId, reason = data.reason })
        end)
        cb({ success = ok and result and result.success, data = ok and result or tostring(result) })
    end)
end)

RegisterNUICallback('report:sendMessage', function(data, cb)
    CreateThread(function()
        local reportId = (data and data.reportId ~= '' and data.reportId) or PlayerActiveReportId

        if not reportId then
            cb({ success = false, data = 'Nincs aktiv jelentes.' })
            return
        end

        local ok, result = pcall(function()
            return Rpc:CallServer('report:sendMessage',
                { reportId = reportId, content = data.content })
        end)
        cb({ success = ok and result and result.success, data = ok and result or tostring(result) })
    end)
end)

RegisterNUICallback('report:typing', function(data, cb)
    local reportId = (data and data.reportId ~= '' and data.reportId) or PlayerActiveReportId
    if reportId then
        Rpc:SendServer('report:typing', { reportId = reportId })
    end
    cb({ success = true, data = {} })
end)
