Config = {}

Config.Start = {
    coords = vec3(-86.60111, 6594.5761, 29.289077),
    heading = 101.65317,
    --model = `t20`,
    model = `cff991gt2rs`,
    plate = 'VILMOS'
}

Config.TargetDistance = 2.0
Config.Reward = 25000000
Config.MissionDuration = 10 * 60
Config.NoExitDuration = 3 * 60
Config.LeaveVehicleFailSeconds = 10
Config.StartCooldown = 60 * 60
Config.FailedHackCooldown = 20
Config.RequiredPolice = 0
Config.AlertRadius = 5.0
Config.TrackerRefreshSeconds = 8

Config.HackSkillcheck = {
    difficulties = { 'easy', 'medium', 'medium' },
    --difficulties = { 'easy' },
    keys = { 'w', 'a', 's', 'd' }
    --keys = { 'w' }
}

Config.AlertJobs = {
    police = true,
    sheriff = true,
    fib = true,
    fbi = true,
    fbiuj = true,
    uss = true,
    irs = true,
    atf = true,
    detective = true,
    guardarmy = true,
    usms = true,
    servicess = true,
    navi = true
}

Config.Notify = {
    title = 'Vilmos Autója',
    start = 'Elkezdted Vilmos autójának elrablását.',
    failed = 'Vilmos autója rablása félbeszakadt.',
    success = 'Sikeresen elloptad Vilmos autóját.',
    failedHackCooldown = 'Várj %s másodpercet az újabb feltöréshez.',
    notAvailable = 'Most nem elérhető. Újra rabolható: %s múlva.',
    alreadyActive = 'Már folyamatban van egy rablás.',
    policeAlert = 'Valaki megközelítette Vilmos autóját.',
    unlockSuccess = 'Sikeresen feltörted az autót, vidd el!',
    tooFar = 'Túl sokáig nem voltál az autóban.',
    countdown = 'Hátralévő idő: %s',
    needPolice = 'Nincs elég rendvédelmi szolgálatban.',
    noExit = 'Az első 3 percben nem szállhatsz ki a járműből.',
    killerReward = 'Megölted az autó sofőrjét, megkaptad a pénzt.',
    killedByPlayer = 'Megöltek az autóban, a jutalmat a gyilkos kapta.',
    availableAgain = 'Vilmos autója újra rabolható.'
}

Config.StaticBlip = {
    enabled = true,
    sprite = 225,
    color = 5,
    scale = 0.85,
    name = 'Rabolható autó'
}

Config.Blip = {
    sprite = 161,
    color = 1,
    scale = 0.95,
    name = 'Vilmos autója'
}

function Config.NotifyPlayer(src, msg, typ)
    TriggerClientEvent('bc_vilmos_heist:client:notify', src, msg, typ or 'inform')
end

function Config.NotifyAll(msg, typ)
    TriggerClientEvent('bc_vilmos_heist:client:notify', -1, msg, typ or 'inform')
end

function Config.GiveReward(src, amount)
    local ESX = exports['es_extended']:getSharedObject()
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        xPlayer.addAccountMoney('black_money', amount)
    end
end