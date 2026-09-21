
local FriendlyGroup <const> = 'mh_TeamFriendly'
local TeamAGroup <const> = 'mh_TeamA'
local TeamBGroup <const> = 'mh_TeamB'

local currentHash = nil

---@param groupName string
local function enable(groupName)
    local ped = PlayerPedId()
    if ped == 0 or not DoesEntityExist(ped) then return end

    local _, hash = AddRelationshipGroup(groupName)
    if currentHash == hash then return end

    SetPedRelationshipGroupHash(ped, hash)
    SetEntityCanBeDamagedByRelationshipGroup(ped, false, hash)
    currentHash = hash
end

local function disable()
    if not currentHash then return end

    local ped = PlayerPedId()
    if ped == 0 or not DoesEntityExist(ped) then return end

    SetPedRelationshipGroupHash(ped, 'PLAYER')
    SetEntityCanBeDamagedByRelationshipGroup(ped, true, 'PLAYER')
    currentHash = nil
end

local eventType = false
---@type false|{ teamDamage: boolean, sideA: number[], sideB: number[] }
local matchRoster = false

---@return string? relationship group name to be immune within, if any
local function resolveTargetGroup()
    if eventType == 'friendly' then
        return FriendlyGroup
    end

    if matchRoster and not matchRoster.teamDamage then
        local myServerId = GetPlayerServerId(PlayerId())

        for _, id in ipairs(matchRoster.sideA) do
            if id == myServerId then return TeamAGroup end
        end
        for _, id in ipairs(matchRoster.sideB) do
            if id == myServerId then return TeamBGroup end
        end
    end

    return nil
end

local function refresh()
    local targetGroup = resolveTargetGroup()
    if targetGroup then
        enable(targetGroup)
    else
        disable()
    end
end

RegisterNetEvent('mate-admin:event:syncStatus')
AddEventHandler('mate-admin:event:syncStatus', function(data)
    eventType = data.inEvent and data.type or false
    refresh()
end)

RegisterNetEvent('mate-admin:event:matchRoster')
AddEventHandler('mate-admin:event:matchRoster', function(data)
    matchRoster = data or false
    refresh()
end)

CreateThread(function()
    while true do
        Wait(3000)
        if eventType == 'friendly' or (matchRoster and not matchRoster.teamDamage) then
            refresh()
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    disable()
end)
