function OpenTablet()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openTablet"
    })
end

RegisterCommand("__tablet", function()
    OpenTablet()
end)

RegisterNetEvent("tablet:open")
AddEventHandler("tablet:open", function()
    OpenTablet()
end)

RegisterNUICallback("closeTablet", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeTablet"
    })
    cb(1)
end)

RegisterNUICallback("commands", function(data, cb)
    cb(Config.Commands)
end)

RegisterNUICallback("dmzones", function(data, cb)
    local zonestats = lib.callback.await('rota_zones:getZoneStats', false)

    local zones = {}
    for _, zone in pairs(Config.DMZones) do
        local playersInZone = 0
        for k, v in pairs(zonestats) do
            if v.name == zone.zonename then
                playersInZone = v.playersInZone
            end
        end

        table.insert(zones, {
            name = zone.name,
            location = zone.location,
            players = playersInZone,
        })
    end
    cb(zones)
end)

RegisterNUICallback("events", function(data, cb)
    local events = lib.callback.await('bc_tablet:getEvents', false)
    cb(events)
end)

RegisterNUICallback("jobs", function(data, cb)
    local joblist = {}
    local boosts = lib.callback.await('bc_tablet:getJobBoosts', false)
    for k, v in pairs(Config.Jobs) do
        table.insert(joblist, {
            id = k,
            name = v.name,
            icon = v.icon,
            color = v.color,
            location = v.location,
            description = v.description,
            payoutBoost = (boosts[k] or false),
            requirements = v.requirements,
        })
    end
    cb(joblist)
end)

RegisterNUICallback("startJob", function(data, cb)
    local jobId = data.jobId
    if Config.Jobs[jobId] then
        SetNewWaypoint(Config.Jobs[jobId].coords.x, Config.Jobs[jobId].coords.y)
    end
    cb(1)
end)

RegisterNUICallback("menus", function(data, cb)
    local menulist = {}
    for k, v in pairs(Config.Menus) do
        table.insert(menulist, {
            id = k,
            name = v.name,
            icon = v.icon,
            gradient = v.gradient,
            description = v.description,
        })
    end

    cb(menulist)
end)

RegisterNUICallback("openMenu", function(data, cb)
    local menuId = data.menuId
    if Config.Menus[menuId] then
        Config.Menus[menuId].Open()
    end
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeTablet"
    })
    cb(1)
end)

RegisterNUICallback("robberies", function(data, cb)
    local cds = lib.callback.await('bc_tablet:getRobberyCDs', false)
    local robs = {}
    for k, v in pairs(Config.Robberies) do
        local cd = "Tájékozódj a rablás kezdetén, hogy indítható-e"
        if v.res and cds[v.res] then
            cd = cds[v.res]
        end
        table.insert(robs, {
            name = v.name,
            location = v.location,
            players = v.players,
            tools = v.tools,
            start = v.start,
            difficulty = (v.difficulty or "easy"),
            cooldown = cd,
        })
    end
    cb(robs)
end)

RegisterNUICallback("getQuests", function(data, cb)
    local questData = lib.callback.await('bc_tablet:getQuests', false)
    cb(questData)
end)

RegisterNUICallback("claimQuestReward", function(data, cb)
    local result = lib.callback.await('bc_tablet:claimQuestReward', false, data.questId)
    cb({ success = result })
end)

RegisterNUICallback("claimLegalQuestReward", function(data, cb)
    local result = lib.callback.await('bc_tablet:claimLegalQuestReward', false, data.questId)
    cb({ success = result })
end)

AddEventHandler('bc_tablet:questUpdate', function()
    SendNUIMessage({
        action = "questUpdate"
    })
end)
