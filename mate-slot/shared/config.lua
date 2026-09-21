Config                     = {}

---@class SymbolDef
---@field id       string
---@field label    string
---@field weight   integer
---@field payouts  table<integer, number>

Config.Symbols             = {
    { id = "seven",   label = "Lucky Seven", weight = 2,  payouts = { [3] = 32, [4] = 85, [5] = 200 } },
    { id = "diamond", label = "Diamond",     weight = 3,  payouts = { [3] = 24, [4] = 55, [5] = 125 } },
    { id = "crown",   label = "Crown",       weight = 4,  payouts = { [3] = 16, [4] = 38, [5] = 90 } },
    { id = "goldbar", label = "Gold Bar",    weight = 5,  payouts = { [3] = 13, [4] = 27, [5] = 60 } },
    { id = "watch",   label = "Watch",       weight = 8,  payouts = { [3] = 9, [4] = 19, [5] = 37 } },
    { id = "gun",     label = "Gun",         weight = 10, payouts = { [3] = 6.5, [4] = 13.5, [5] = 25 } },
    { id = "cash",    label = "Cash",        weight = 10, payouts = { [3] = 6.5, [4] = 13.5, [5] = 25 } },
    { id = "skull",   label = "Skull",       weight = 14, payouts = { [3] = 4.5, [4] = 8.5, [5] = 15 } },
    { id = "keys",    label = "Keys",        weight = 14, payouts = { [3] = 4.5, [4] = 8.5, [5] = 15 } },
    { id = "wild",    label = "Wild",        weight = 14, payouts = { [3] = 4, [4] = 7, [5] = 12 } },
    { id = "book",    label = "Book",        weight = 3,  payouts = { [3] = 4, [4] = 7, [5] = 12 } },
}

Config.BookBonus           = {
    symbolId = "book",
    minCount = 3,
    tiers    = {
        [3] = 1,
        [8] = 5,
        [9] = 10,
    },
}

Config.ReelCount           = 5
Config.VisibleRows         = 3
Config.MinMatchCount       = 3

---@alias ReelStrip string[]
---@type ReelStrip[]
Config.ReelStrips          = {
    {
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "wild", "gun", "cash", "goldbar",
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "wild", "goldbar", "crown", "diamond", "seven", "book",
    },
    {
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "wild", "gun", "cash", "goldbar",
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "crown", "goldbar", "crown", "diamond", "seven", "book",
    },
    {
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "wild", "gun", "cash", "watch",
        "skull", "keys", "wild", "gun", "cash", "goldbar",
        "skull", "keys", "crown", "gun", "cash", "watch",
        "skull", "keys", "diamond", "goldbar", "crown", "diamond", "seven", "book",
    },
    {
        "skull", "keys", "gun", "cash", "watch",
        "skull", "keys", "gun", "cash", "watch",
        "skull", "keys", "gun", "cash", "goldbar",
        "skull", "keys", "gun", "cash", "watch",
        "skull", "keys", "goldbar", "crown", "diamond",
        "watch", "goldbar", "crown", "diamond", "wild", "seven", "book",
    },
    {
        "keys", "skull", "cash", "gun", "watch",
        "keys", "skull", "cash", "gun", "watch",
        "keys", "skull", "cash", "gun", "goldbar",
        "keys", "skull", "cash", "gun", "watch",
        "keys", "skull", "goldbar", "diamond", "crown",
        "watch", "goldbar", "diamond", "crown", "wild", "seven", "book",
    },
}

Config.Paylines            = {
    { id = 0, pattern = { 2, 2, 2, 2, 2 }, label = "Middle" },
    { id = 1, pattern = { 1, 1, 1, 1, 1 }, label = "Top" },
    { id = 2, pattern = { 3, 3, 3, 3, 3 }, label = "Bottom" },
    { id = 3, pattern = { 1, 2, 3, 2, 1 }, label = "V-Shape" },
    { id = 4, pattern = { 3, 2, 1, 2, 3 }, label = "Inverted V" },
    { id = 5, pattern = { 1, 1, 2, 3, 3 }, label = "Diagonal Down" },
    { id = 6, pattern = { 3, 3, 2, 1, 1 }, label = "Diagonal Up" },
    { id = 7, pattern = { 2, 1, 1, 1, 2 }, label = "Top Arch" },
    { id = 8, pattern = { 2, 3, 3, 3, 2 }, label = "Bottom Arch" },
}

Config.BetOptions          = { 10000, 30000, 50000, 100000, 300000, 3000000 }
Config.DefaultBet          = 10000
Config.MaxWinCap           = 0

Config.WinTiers            = {
    normal  = 0,
    bigWin  = 20,
    megaWin = 50,
    jackpot = 100,
}

Config.Economy             = {
    payoutNormFactor       = 9.54,
    globalPayoutMultiplier = 1.0,
    nearMissRate           = 0.10,
    spinCooldownMs         = 800,
    maxSpinsPerMinute      = 40,
}

Config.Zones               = {
    {
        label       = "Vinewood Casino – Slots",
        coords      = vector3(250.734070, -787.978027, 30.442505),
        radius      = 80.0,
        spawnRadius = 80.0,
    },
}

Config.Machines            = {
    {
        coords  = vector3(250.734070, -787.978027, 29.442505),
        heading = 252.283463,
        model   = `vw_prop_casino_slot_01a`,
        label   = "Slot Gép",
    },
    {
        coords  = vector3(249.916489, -790.206604, 29.425659),
        heading = 252.283463,
        model   = `vw_prop_casino_slot_01a`,
        label   = "Slot Gép",
    },
    {
        coords  = vector3(249.085724, -792.553833, 29.391968),
        heading = 252.283463,
        model   = `vw_prop_casino_slot_01a`,
        label   = "Slot Gép",
    },
}

Config.MachineObjects      = {
    `vw_prop_casino_slot_01a`,
    `vw_prop_casino_slot_02a`,
    `vw_prop_casino_slot_03a`,
    `vw_prop_casino_slot_04a`,
    `vw_prop_casino_slot_05a`,
    `vw_prop_casino_slot_06a`,
    `vw_prop_casino_slot_07a`,
    `vw_prop_casino_slot_08a`,
}

Config.MachineSounds       = {
    [`vw_prop_casino_slot_01a`] = "dlc_vw_casino_slot_machine_ak_npc_sounds",
    [`vw_prop_casino_slot_02a`] = "dlc_vw_casino_slot_machine_ir_npc_sounds",
    [`vw_prop_casino_slot_03a`] = "dlc_vw_casino_slot_machine_rsr_npc_sounds",
    [`vw_prop_casino_slot_04a`] = "dlc_vw_casino_slot_machine_fs_npc_sounds",
    [`vw_prop_casino_slot_05a`] = "dlc_vw_casino_slot_machine_ds_npc_sounds",
    [`vw_prop_casino_slot_06a`] = "dlc_vw_casino_slot_machine_kd_npc_sounds",
    [`vw_prop_casino_slot_07a`] = "dlc_vw_casino_slot_machine_td_npc_sounds",
    [`vw_prop_casino_slot_08a`] = "dlc_vw_casino_slot_machine_hz_npc_sounds",
}

Config.MachineSearchRadius = 2.0
Config.SeatSearchRadius    = 0.8

Config.SeatBoneNames       = {
    "Chair_Base_01",
    "seat_f",
    "seat",
}

Config.InteractDistance    = 1.8

Config.Debug               = false

Config.RtpVariance         = {
    enabled           = true,
    payoutScalarSigma = 0.015,
    safeMin           = 0.94,
    safeMax           = 1.06,
    nearMissRateMin   = 0.06,
    nearMissRateMax   = 0.18,
}

Config.SymbolMap           = {}
Config.TotalWeight         = 0

for _, sym in ipairs(Config.Symbols) do
    Config.SymbolMap[sym.id] = sym
    Config.TotalWeight       = Config.TotalWeight + sym.weight
end

Config.ValidBets = {}

for _, v in ipairs(Config.BetOptions) do
    Config.ValidBets[v] = true
end
