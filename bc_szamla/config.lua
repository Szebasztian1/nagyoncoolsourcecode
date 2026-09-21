Config = {}

-- Framework: 'esx' vagy 'qb'
Config.Framework = 'esx'

-- Egyetlen parancs
Config.OpenMainCommand = 'eszamla'

-- Távolság számlázáshoz
Config.NearbyDistance = 4.0

-- Automatikus levonás (óra)
Config.AutoCollectHours = 72

-- Automatikus ellenőrzés (perc)
Config.AutoCollectCheckMinutes = 60

-- Lista limitek
Config.MaxOpenInvoicesShown = 50
Config.MaxTrackedInvoicesShown = 100

-- Számla limitek
Config.MaxAmount = 50000000
Config.MinReasonLength = 3
Config.MaxReasonLength = 120

-- Cooldown rendszer (mp)
Config.Cooldowns = {
    OpenMain = 2,
    OpenTrack = 3,
    CreateInvoice = 5,
    SameTarget = 10,
    RespondInvoice = 2,
    PayInvoice = 2,
    DeleteInvoice = 2
}

-- Engedélyezett jobok
Config.AllowedJobs = {
    asian = true,
    corleone = true
}

-- UI Theme (Black City)
Config.Theme = {
    bg = '#1f1f22',
    panel = '#2a2a2e',
    panel2 = '#303035',
    accent = '#3f7fb8',
    accent2 = '#4d8ec8',
    border = 'rgba(255,255,255,0.08)',
    text = '#f1f1f1',
    muted = '#b7b7b7',
    success = '#33cc4d',
    danger = '#ff2b2b',
    warning = '#d7a64a'
}

-- Notify rendszer
Config.NotifyType = 'okokNotify'
Config.UseOxLibNotify = false

-- Frakció pénz
function Config.AddMoneyToSociety(jobName, amount)
    if Config.Framework == 'esx' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. jobName, function(account)
            if account then
                account.addMoney(amount)
            end
        end)
    else
        if GetResourceState('qb-management') == 'started' then
            exports['qb-management']:AddMoney(jobName, amount)
        end
    end
end