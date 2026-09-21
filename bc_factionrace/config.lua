Config = {}
--print("configsrt")

Config.ResetOnDay = "01"
Config.ResetRewards = function(place, job)
    if place == 1 then
        local ret = exports["bc_vehshop"]:giveVeh("factionrace", "BMWI4GC", "car", job)
    elseif place == 2 then
        TriggerEvent("esx_addonaccount:getSharedAccount", "society_"..job, function(account)
            if account ~= nil then
                account.addMoney(20000000)
            end
        end)
    elseif place == 3 then
        TriggerEvent("esx_addonaccount:getSharedAccount", "society_"..job, function(account)
            if account ~= nil then
                account.addMoney(10000000)
            end
        end)
    end
end

Config.Description = [[
Pontot szerezve a rablásokból, a szinted nőni fog. 
Minél magasabb a szinted, annál több előnyt kapsz a rablások során. 
Az előnyök között lehet például a gyorsabb rablás, vagy több pénz rablás közben. 
Mindez csak a következő rablásoknál érvényes: <br>
-Bolt rablás (+5 pont) <br>
-Bank rablás (+10 pont) <br>

A lista minden hónap elsején 0-zódik, és a legjobbak jutalomban részesülnek.
Az első helyezett frakció egy 2022 BMW i4 Gran Coupe (Elektromos) autót kap, a második helyezett 20 millió dollárt, 
a harmadik helyezett 10 millió dollárt.

]]

local disabledfactions = {
  "unemployed", "police", "fbiuj", "uss", "irs", "atf", "navi", "fbi", "detective", "guardarmy", "usms", "servicess"
}
Config.IsFactionEnabled = function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    for k,v in pairs(disabledfactions) do
        if v == xPlayer.job.name then
            return false
        end
    end
    return true 
end

Config.Levels = {--min 2 levels
    {
        xp = 0,--first lvl xp always 0
        level = 1,
        unlock = 'Semmi, lépj szintet!',
        roblootmultiplier = 1,
        robtimemultiplier = 1
    },
    {
        xp = 200,
        level = 2,
        unlock = '+4% lootmennyiség',
        roblootmultiplier = 1.04,
        robtimemultiplier = 1
    },
    {
        xp = 500,
        level = 3,
        unlock = '+8% lootmennyiség',
        roblootmultiplier = 1.08,
        robtimemultiplier = 1
    },
    {
        xp = 1000,
        level = 4,
        unlock = '+15% lootmennyiség',
        roblootmultiplier = 1.15,
        robtimemultiplier = 1
    },
}

Config.Robberies = {
    ["train"] = 3,
    ["shop"] = 5,
    ["bank"] = 10,
}