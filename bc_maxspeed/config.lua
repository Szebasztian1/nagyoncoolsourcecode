--- @class VehicleSpeedEntry
--- @field [integer] number

--- @class DMZoneEntry
--- @field c vector3
--- @field r number

--- @class CruiseConfig
--- @field MaxAllowedSpeed number

--- @class Config
--- @field VehicleSpeeds table<integer, number>
--- @field GlobalMaxSpeedKmh number
--- @field WeaponDamageMult number
--- @field DMZones DMZoneEntry[]
--- @field DriveBy DriveByConfig
--- @field Cruise CruiseConfig

--- @class DriveByConfig
--- @field MaxSpeedMs number

Config = {}

Config.VehicleSpeeds = {
    [`t20`] = 300,
}

Config.GlobalMaxSpeedKmh = 300

Config.WeaponDamageMult = 0.3

Config.DMZones = {
    { c = vector3(3615.9567, 3737.998, 28.689374),  r = 150 },
    { c = vector3(1376.9473, -2624.946, 49.670768), r = 150 },
    { c = vector3(-610.1783, -1600.354, 26.74682),  r = 100 },
}

Config.DriveBy = {
    MaxSpeedMs = 33,
}

Config.Blackout = {
    BlackoutTime              = 8000,
    BlackoutFromDamage        = false,
    BlackoutDamageRequired    = 25,
    BlackoutFromSpeed         = true,
    BlackoutSpeedRequired     = 185.0 / 3.6,
    DisableControlsOnBlackout = true,
}

Config.Cruise = {
    MaxAllowedSpeed = 250,
}
