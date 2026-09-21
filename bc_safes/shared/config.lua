Config = {}

Config.Safes = {
    ['small'] = {
        item = "small_safe",
        prop = GetHashKey('prop_ld_int_safe_01'),
        slots = 100,
        weight = 40000,
        locks = 10
    },
    ['big'] = {
        item = "big_safe",
        prop = GetHashKey('prop_ld_int_safe_01'),
        slots = 300,
        weight = 70000,
        locks = 10
    },
}

Config.LockPickItem = "lockpick"
Config.RemoveLockPick = true
Config.OnlyRobWhenOwnerOnline = true

Config.TimeBetweenRobs = 5*60 --in secs

Config.PoliceJobs = {'police','detective','guardarmy','fbiuj','uss','irs','atf','navi','usms','servicess','fbi'}
Config.MinPolice = 4 --false to dont need police
Config.AlertOwner = true 
Config.AlertPolice = true 
Config.AlertEveryone = false

Config.BlipTime = 30*1000 --in ms

--groups that can delete any safe (besides its owner), they dont get the safe item back
Config.AdminGroups = {'owner'}

Config.MaxDeleteDistance = 5.0 --max distance from the safe when deleting it

Config.Debug = function(msg)
   -- print(msg)
end 