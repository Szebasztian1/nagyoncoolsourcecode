---@param _source number
---@param _args table
---@param _raw string
RegisterCommand("voice", function(_source, _args, _raw)
    MumbleSetActive(false)
    NetworkSetVoiceActive(false)
    Wait(2000)
    MumbleSetActive(true)
    NetworkSetVoiceActive(true)
end, false)

AddEventHandler('esx:removeInventoryItem', function(_item, _count)
    Wait(10)
    local phoneCount = exports.ox_inventory:Search('count', 'ujphone')
    if phoneCount < 1 then
        exports['pma-voice']:setRadioChannel(0)
    end
end)

local function safeReset()
if GetResourceState('pma-voice') == 'started' then
exports['pma-voice']:setRadioChannel(0)
exports['pma-voice']:setCallChannel(0)
end
end

CreateThread(function()
safeReset()
Wait(500)
safeReset()
Wait(500)
safeReset()
end)