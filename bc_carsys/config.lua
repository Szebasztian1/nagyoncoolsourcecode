Config = {}

Config.DistMult = 0.003

-- Minimum time (ms) between two `owned_vehicles` UPDATEs for the same plate,
-- unless the player is leaving the vehicle (that save always goes through).
Config.CacheSaveInterval = 5 * 60 * 1000

Config.AllowedJobs = {"blackmamba","alkaida","bennysservice","exotic","lifthouse","mechanic","metamechanic","ms13","speedmechanic","ujfrakciodawe3","sonsofanarchy","topgear"}

Config.InspectionMilages = {
    [0] = 20000,  -- Compacts 
    [1] = 22000,  -- Sedans 
    [2] = 22000,  -- SUVs 
    [3] = 18000,  -- Coupes 
    [4] = 16000,  -- Muscle 
    [5] = 16000,  -- Sports Classics 
    [6] = 16000,  -- Sports 
    [7] = 17000,  -- Super 
    [8] = 20000,  -- Motorcycles 
    [9] = 20000,  -- Off-road 
    [10] = 22000, -- Industrial 
    [11] = 22000, -- Utility 
    [12] = 22000, -- Vans 
    [13] = false, -- Cycles 
    [14] = false, -- Boats 
    [15] = false, -- Helicopters 
    [16] = false, -- Planes 
    [17] = 22000, -- Service 
    [18] = 22000, -- Emergency 
    [19] = 22000, -- Military 
    [20] = 22000, -- Commercial 
    [21] = false, -- Trains ( disabled )
    [22] = 22000, -- Open Wheel 
}

Config.MilageDamage = function(overinspection)
    local damagemult = 1.0
    if overinspection then
        local over = (overinspection / 20000) * 2
        damagemult = damagemult + over
        if damagemult > 3.0 then
            damagemult = 3.0
        end
    end
    local rand = math.random(3, 5)
    return 0.0001 * rand * damagemult
end

Config.GetInspectionPrice = function(veh)
    if GetResourceState('bc_vehshop') ~= 'started' then
        return 2000000
    end
    local shopprice = exports['bc_vehshop']:GetVehPrice(GetEntityModel(veh))
    if shopprice then 
        return math.floor(shopprice/20)
    end 
    return 2000000
end

Config.GetRebuildPrice = function(veh)
    if GetResourceState('bc_vehshop') ~= 'started' then
        return 10000000
    end
    local shopprice = exports['bc_vehshop']:GetVehPrice(GetEntityModel(veh))
    if shopprice then 
        return math.floor(shopprice/4)
    end 
    return 10000000
end



Config.Debug = function(...)
      --  print(...)
    
end

