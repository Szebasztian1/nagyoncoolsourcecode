local PETS = {
    [GetHashKey('a_c_chop')]            = true,
    [GetHashKey('a_c_westy_2')]         = true,
    [GetHashKey('a_c_pug')]             = true,
    [GetHashKey('a_c_shepherd_2')]      = true,
    [GetHashKey('a_c_retriever_2')]     = true,
    [GetHashKey('a_c_poodle_2')]        = true,
    [GetHashKey('a_c_husky_2')]         = true,
    [GetHashKey('a_c_cat_01')]          = true,
    [GetHashKey('dusa_englishbulldog')] = true,
    [GetHashKey('dusa_cane')]           = true,
    [GetHashKey('dusa_sphynx')]         = true,
    [GetHashKey('dusa_doberman')]       = true,
}

---@param pedPool table
---@return table
local function CollectAggressivePedNetIds(pedPool)
    local aggressivePeds = {}

    for index = 1, #pedPool do
        local ped = pedPool[index]

        if DoesEntityExist(ped) and not PETS[GetEntityModel(ped)] then
            local combatTarget = GetPedTaskCombatTarget(ped, 0)

            if IsPedAPlayer(combatTarget) then
                aggressivePeds[#aggressivePeds + 1] = NetworkGetNetworkIdFromEntity(ped)
            end

            Wait(10)
        end
    end

    return aggressivePeds
end

CreateThread(function()
    while true do
        local pedPool = GetGamePool("CPed")
        local aggressivePedNetIds = CollectAggressivePedNetIds(pedPool)

        TriggerServerEvent("bc_ved:apedlist", aggressivePedNetIds)

        Wait(10000)
    end
end)

lib.onCache('ped', function(pedValue)
    if not DoesEntityExist(pedValue) then return end
    SetPedSuffersCriticalHits(pedValue, true)
end)
