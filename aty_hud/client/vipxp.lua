-- VIP EXP sav.
-- A regi, GTA-s rangsavot a bc_vip escrow-olt kliense rajzolta ki a
-- "bc_vip:xpadded" esemenyre, felul kozepen: ott van a bc_notyp felhivas es a
-- bc_tasksystem achievement toastja is, ezert egymasra csusztak. A bc_vip
-- szervere ezert mostantol "bc_vip:xpadded_hud" neven kuldi a mar kiszamolt
-- szintadatokat (GetPlayerVIPInfo), es azt ez a HUD rajzolja ki a miniterkep
-- mellett (ui/js/vipxp.js + ui/css/vipxp.css).

-- A sav 6 masodpercig latszik (ui/js/vipxp.js hideTimer), + a 0.25s
-- elhalvanyodas. Ennyi idore kerjuk a felso sav elso helyet.
local VIPXP_BAND_MS = 6300

-- Szolunk a tobbi, ugyanoda rajzolo scriptnek, hogy erre az idore csusszanak
-- lejjebb: bc_notyp (felhivas) es bc_tasksystem (achievement toastok). Mindketto
-- csak egy CSS osztalyt kapcsol, es a sajat idozitojevel oldja fel.
local function claimTopBand()
    TriggerEvent('bc_vipxp:visible', VIPXP_BAND_MS)
end

RegisterNetEvent('bc_vip:xpadded_hud', function(info)
    if type(info) ~= 'table' then return end

    SendNUIMessage({
        action = 'vipxp',
        data = info
    })

    claimTopBand()
end)

-- Teszteleshez: csak a sajat kepernyon mutat egy mintat, semmit nem ir at.
RegisterCommand('vipxpteszt', function(_, args)
    local level = tonumber(args[1]) or 6

    SendNUIMessage({
        action = 'vipxp',
        data = {
            label = 'Platina VIP',
            bundle = 'platina',
            level = level,
            maxLevel = 7,
            xp = 44250,
            prevXp = 21800,
            nextXp = 45800,
            percent = 93.5,
            gained = 250,
            maxed = false,
            leveledUp = level == 7
        }
    })

    claimTopBand()
end, false)
