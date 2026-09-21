local inffa = false
local spawntime = false
local gveh = 0

-- FIX: minden belépés saját "session" számot kap. A régi belépéshez tartozó
-- szálak így felismerik, hogy már nem ők az aktuálisak, és leállnak.
-- Enélkül minden újbóli belépés egy újabb monitor-szálat indított, ami
-- párhuzamosan teleportálgatta / lefegyverezte a játékost.
local session = 0
local respawning = false
-- FIX: türelmi idő. Amíg tart (teleport + collision streaming + spawnvédelem),
-- a távolság-ellenőrző nem dobja ki a játékost.
local graceUntil = 0

local COLLISION_TIMEOUT = 15000

-- ══════════════════════════════════════════════════════════════
--  Fegyvernevek a panelhez
--  A config vegyesen használ `WEAPON_X` hasht és 'WEAPON_X' stringet,
--  ezért hash szerint tároljuk és hívásnál normalizálunk.
-- ══════════════════════════════════════════════════════════════
local WeaponLabels = {
    [`WEAPON_KNIFE`]              = "Kés",
    [`WEAPON_SWITCHBLADE`]        = "Rugós kés",
    [`WEAPON_MUSKET`]             = "Muskéta",
    [`WEAPON_PISTOL`]             = "Pisztoly",
    [`WEAPON_PISTOL_MK2`]         = "Pisztoly Mk II",
    [`WEAPON_PISTOL50`]           = "Pistol .50",
    [`WEAPON_HEAVYPISTOL`]        = "Nehézpisztoly",
    [`WEAPON_APPISTOL`]           = "AP Pisztoly",
    [`WEAPON_VINTAGEPISTOL`]      = "Antik pisztoly",
    [`WEAPON_MACHINEPISTOL`]      = "Géppisztoly",
    [`WEAPON_TECPISTOL`]          = "Tec-9",
    [`WEAPON_GADGETPISTOL`]       = "Perico pisztoly",
    [`WEAPON_NAVYREVOLVER`]       = "Navy revolver",
    [`WEAPON_DOUBLEACTION`]       = "Double Action",
    [`WEAPON_MICROSMG`]           = "Micro SMG",
    [`WEAPON_MINISMG`]            = "Mini SMG",
    [`WEAPON_ASSAULTSMG`]         = "Assault SMG",
    [`WEAPON_COMBATPDW`]          = "Combat PDW",
    [`WEAPON_ASSAULTRIFLE`]       = "Gépkarabély",
    [`WEAPON_SPECIALCARBINE`]     = "Special Carbine",
    [`WEAPON_SPECIALCARBINE_MK2`] = "Special Carbine Mk II",
    [`WEAPON_TACTICALRIFLE`]      = "Service Carbine",
    [`WEAPON_PRECISIONRIFLE`]     = "Precíziós puska",
    [`WEAPON_SNIPERRIFLE`]        = "Mesterlövész puska",
    [`WEAPON_PUMPSHOTGUN`]        = "Sörétes",
}

local function WeaponLabel(w)
    local hash = (type(w) == 'string') and joaat(w) or w
    return WeaponLabels[hash] or "Fegyver"
end

-- FIX (fő ok): a régi kód fix 3000 ms freeze után engedte el a játékost.
-- Gyengébb gépen / HDD-n a magasban lévő egyedi map collisionje ennyi idő
-- alatt nem töltődik be, a ped átesik a világon és zuhanni kezd -> "kidob a
-- világba". Itt addig várunk, amíg a collision tényleg betölt (max 15 mp).
local function SafeTeleport(coords)
    local x, y, z = coords.x, coords.y, coords.z
    local ped = PlayerPedId()

    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    RequestCollisionAtCoord(x, y, z)

    local started = GetGameTimer()
    while GetGameTimer() - started < COLLISION_TIMEOUT do
        ped = PlayerPedId()
        RequestCollisionAtCoord(x, y, z)
        -- freeze mellett redundáns, de ha a freeze valamiért nem fogott meg,
        -- ez tartja a helyén a pedet, amíg a terep megérkezik
        SetEntityCoords(ped, x, y, z, false, false, false, false)
        if HasCollisionLoadedAroundEntity(ped) then
            break
        end
        Wait(0)
    end

    Wait(150)
    FreezeEntityPosition(PlayerPedId(), false)
end

-- ══════════════════════════════════════════════════════════════
--  HUD  (jobb oldalt fut, amíg a játékos FFA-ban van)
--  Fontos: SetNuiFocus NÉLKÜL megy ki, tehát nem blokkolja a játékot.
-- ══════════════════════════════════════════════════════════════
local ffaCounts = {}

-- a menet statisztikája: belépéskor nullázódik
local ffaKills  = 0
local ffaDeaths = 0
local ffaStreak = 0

local function HudCount(id)
    -- a szervertől JSON-on jön, ezért a string kulcsot is nézzük
    return ffaCounts[id] or ffaCounts[tostring(id)] or 1
end

local function HudStats()
    SendNUIMessage({
        action = 'hudStats',
        kills  = ffaKills,
        deaths = ffaDeaths,
        streak = ffaStreak,
    })
end

local function HudShow()
    if not inffa then return end
    local ffa = Config.FFAs[inffa]
    if not ffa then return end

    SendNUIMessage({
        action  = 'hudShow',
        name    = ffa.Name,
        players = HudCount(inffa),
        bet     = ffa.BetPerLife or 0,
        kills   = ffaKills,
        deaths  = ffaDeaths,
    })
end

-- a killt a szerver hitelesíti (a kliens nem növelheti magának)
RegisterNetEvent("bc_ffa:kills", function(kills, streak)
    ffaKills  = tonumber(kills) or 0
    ffaStreak = tonumber(streak) or 0
    if not inffa then return end
    HudStats()
end)

local function HudHide()
    SendNUIMessage({ action = 'hudHide' })
end

local function HudProtect(ms)
    SendNUIMessage({ action = 'hudProtect', ms = ms or 0 })
end

-- a szerver csak akkor szól, ha tényleg változott a létszám (nincs pollozás)
RegisterNetEvent("bc_ffa:counts", function(counts)
    ffaCounts = counts or {}
    if not inffa then return end
    SendNUIMessage({ action = 'hudPlayers', players = HudCount(inffa) })
end)

RegisterNetEvent('esx:onPlayerDeath', function(data)
    if not inffa then return end

    -- FIX: az eredetiben előbb volt gveh = 0, utána DoesEntityExist(gveh),
    -- így a jármű SOHA nem törlődött -> árva Bolide-ok maradtak a mapon.
    if gveh ~= 0 and DoesEntityExist(gveh) then
        DeleteEntity(gveh)
    end
    gveh = 0

    local ffa = Config.FFAs[inffa]

    -- FIX: a revive + respawn alatt a ped rövid ideig nem az arénában van.
    -- Türelmi idő nélkül a monitor-szál pont ilyenkor dobta ki a játékost.
    graceUntil = GetGameTimer() + 20000

    -- a saját halál lokálisan számolódik: a leesés/FallOut is halál
    ffaDeaths = ffaDeaths + 1
    ffaStreak = 0
    HudStats()

    -- Az újraélesztést a szerver végzi (esx_ambulancejob/server/revive_auth),
    -- a válasz a bc_ffa:revived esemény -- az indítja a Respawn()-t. Korábban a
    -- kliens élesztette fel magát lokálisan, és maga jelentette a szervernek,
    -- hogy már él; ezt bármelyik executor utánozni tudta.
    TriggerServerEvent('bc_ffa:requestRevive', true)

    if not inffa then return end
    -- a tét nélküli pályákon is szólunk, hogy a gyilkos kill-je számoljon;
    -- pénz továbbra is csak ott mozog, ahol van BetPerLife
    if ffa and data.killedByPlayer and data.killerServerId then
        TriggerServerEvent("bc_ffa:killed", data.killerServerId, inffa)
    end
end)

function Respawn()
    -- FIX: gyors egymás utáni halálnál (pl. FallOut) több Respawn futott
    -- párhuzamosan, egymás ghost- és spawntime-állapotát felülírva.
    if respawning then return end
    if not inffa then return end
    if not Config.FFAs[inffa] then return end

    respawning = true
    local mySession = session
    local ffa = Config.FFAs[inffa]
    local spawncoords = ffa.SpawnPoints[math.random(1, #ffa.SpawnPoints)]

    spawntime = true
    graceUntil = GetGameTimer() + 30000

    SetLocalPlayerAsGhost(true)
    SafeTeleport(spawncoords)

    if not inffa or mySession ~= session or not Config.FFAs[inffa] then
        spawntime = false
        respawning = false
        SetLocalPlayerAsGhost(false)
        return
    end

    if ffa.Vehicle then
        local started = GetGameTimer()
        RequestModel(ffa.Vehicle)
        -- FIX: az eredeti while végtelen ciklus volt, ha a modell nem létezik
        while not HasModelLoaded(ffa.Vehicle) and GetGameTimer() - started < 10000 do
            RequestModel(ffa.Vehicle)
            Wait(10)
        end
        if HasModelLoaded(ffa.Vehicle) then
            local vehicle = CreateVehicle(ffa.Vehicle, spawncoords.x, spawncoords.y, spawncoords.z, GetEntityHeading(PlayerPedId()), true, true)
            -- bc_kocsitorles: legalis spawn jelolese
            if vehicle and vehicle ~= 0 then Entity(vehicle).state:set('bc_spawned', true, true) end
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            gveh = vehicle
            SetModelAsNoLongerNeeded(ffa.Vehicle)
        end
    end

    -- FIX: friss ped handle. A régi kód a teleport/revive ELŐTT lekért `ped`
    -- változóval adta a fegyvereket; revive után a handle elavulhat, ilyenkor
    -- a játékos fegyver nélkül spawnolt.
    local ped = PlayerPedId()
    for _, weapon in pairs(ffa.Weapons) do
        GiveWeaponToPed(ped, weapon, 9999, false, false)
    end

    CreateThread(function()
        while spawntime do
            DisablePlayerFiring(PlayerId())
            DisableControlAction(0, 24, true)
            Wait(0)
        end
    end)

    local spawnTime = ffa.SpawnTime or 2000
    graceUntil = GetGameTimer() + spawnTime + 5000

    -- a HUD-on visszaszámol a spawn védelem
    HudProtect(spawnTime)

    Wait(spawnTime)
    SetLocalPlayerAsGhost(false)
    spawntime = false
    respawning = false
end

local function LeaveFFA()
    if not inffa then return end
    inffa = false
    -- FIX: a régi kód a "kiestél a pályáról" ágon csak lokálisan állította
    -- inffa = false-ra, a szervernek nem szólt. Emiatt a játékosszámláló
    -- elcsúszott, és az ElectronAC whitelist (antiKill/antiTeleport/
    -- antiVehicle) bent maradt a játékoson.
    Wait(2000)
    TriggerServerEvent("bc_ffa:leave")
end

function EnterFFA(id)
    if not Config.FFAs[id] then return end

    -- FIX: ha már bent van, előbb tiszta kilépés, hogy ne fussanak
    -- párhuzamosan a régi szálak
    if inffa then
        LeaveFFA()
        Wait(1000)
    end

    session = session + 1
    local mySession = session

    inffa = id
    graceUntil = GetGameTimer() + 40000

    -- új menet, tiszta lappal
    ffaKills  = 0
    ffaDeaths = 0
    ffaStreak = 0

    exports.ox_inventory:weaponWheel(true)
    LocalPlayer.state.invBusy = true
    TriggerServerEvent("bc_ffa:join", inffa)
    Wait(1000)

    -- FIX: a régi 5 másodperces néma várakozás alatt a játékos azt hitte, nem
    -- működik, és újra rákattintott -> dupla EnterFFA, dupla szálak
    TriggerEvent("esx:showNotification", "FFA betöltése, egy pillanat...")
    HudShow()
    Wait(5000)

    if mySession ~= session or not inffa then return end
    Respawn()

    CreateThread(function()
        while inffa and mySession == session do
            RestorePlayerStamina(PlayerId(), 1.0)
            EnableControlAction(0, 12, true)
            EnableControlAction(0, 13, true)
            EnableControlAction(0, 14, true)
            EnableControlAction(0, 15, true)
            EnableControlAction(0, 16, true)
            EnableControlAction(0, 17, true)
            Wait(1)
        end
    end)

    CreateThread(function()
        while inffa and mySession == session do
            local ffa = Config.FFAs[inffa]
            if not ffa then
                inffa = false
                break
            end

            LocalPlayer.state.invBusy = true
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local dist = #(coords - ffa.Coords)
            local inGrace = spawntime or respawning or GetGameTimer() < graceUntil

            if not inGrace then
                -- FIX: a FallOut határ fixen 100.0 volt, miközben 8 arénánál a
                -- Range 150-220. Ezekben a pályákban a normál játék közben is
                -- 100 m fölé lehetett kerülni, és a script megölte + az aréna
                -- közepére rakta a játékost.
                local falloutRange = ffa.FallOutRange or ffa.Range

                if ffa.FallOut and dist > falloutRange then
                    -- a halál után az onPlayerDeath viszi vissza a spawnpontra,
                    -- collision-várakozással együtt
                    SetEntityHealth(ped, 0)
                elseif dist > ffa.Range then
                    LeaveFFA()
                    break
                end
            end

            if gveh ~= 0 and not spawntime and GetEntityHealth(ped) > 2 and DoesEntityExist(gveh) then
                if ffa.Vehicle and not DoesEntityExist(GetVehiclePedIsIn(ped, false)) then
                    TaskWarpPedIntoVehicle(ped, gveh, -1)
                end
            end

            exports.ox_inventory:weaponWheel(true)

            Wait(500)
        end

        -- FIX: ha közben új belépés indult, ez a szál NEM takaríthat utána
        if mySession ~= session then return end

        HudHide()
        exports.ox_inventory:weaponWheel(false)
        LocalPlayer.state.invBusy = false
        RemoveAllPedWeapons(PlayerPedId())

        if gveh ~= 0 and DoesEntityExist(gveh) then
            DeleteEntity(gveh)
        end
        gveh = 0

        spawntime = false
        respawning = false
        SetLocalPlayerAsGhost(false)

        -- FIX: a visszateleportálás is collision-várakozással megy
        SafeTeleport(vector3(Config.EnterCoords.x + 1.0, Config.EnterCoords.y, Config.EnterCoords.z))
        SetEntityHeading(PlayerPedId(), Config.EnterCoords.w)
        -- Ha holtan lép ki az arénából, a szerver élessze fel; ha él, ez nem
        -- csinál semmit (a RevivePlayer csak halottra ad engedélyt).
        TriggerServerEvent('bc_ffa:requestRevive', false)
    end)
end

-- A szerver akkor szól vissza, ha az újraélesztés tényleg átment.
RegisterNetEvent('bc_ffa:revived', function()
    if not inffa then return end

    Wait(500)
    Respawn()
end)

exports("inffa", function()
    return inffa
end)

-- ══════════════════════════════════════════════════════════════
--  NUI PANEL  (a régi ox_lib context menü helyett)
-- ══════════════════════════════════════════════════════════════
local panelOpen = false

local function BuildList(counts)
    counts = counts or {}
    local list = {}

    for k, v in pairs(Config.FFAs) do
        local weapons = {}
        for _, w in pairs(v.Weapons) do
            weapons[#weapons + 1] = WeaponLabel(w)
        end

        list[#list + 1] = {
            id        = k,
            name      = v.Name,
            -- a callback JSON-on jön át, ezért a string kulcsot is nézzük
            players   = counts[k] or counts[tostring(k)] or 0,
            bet       = v.BetPerLife or 0,
            spawnTime = v.SpawnTime or 2000,
            range     = v.Range or 100.0,
            fallout   = v.FallOut and true or false,
            vehicle   = v.Vehicle and true or false,
            weapons   = weapons,
        }
    end

    return list
end

local function ClosePanel()
    if not panelOpen then return end
    panelOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function OpenPanel()
    if panelOpen then return end

    local counts = lib.callback.await('bc_ffa:getc', false)

    panelOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action  = 'open',
        current = inffa or nil,
        ffas    = BuildList(counts),
    })
end

RegisterNUICallback('close', function(_, cb)
    panelOpen = false
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('join', function(data, cb)
    panelOpen = false
    SetNuiFocus(false, false)
    cb({})

    local id = tonumber(data and data.id)
    if not id or not Config.FFAs[id] then return end

    CreateThread(function()
        EnterFFA(id)
    end)
    TriggerEvent("esx:showNotification", "A kilépéshez használd a /leaveffa parancsot")
end)

RegisterNUICallback('leave', function(_, cb)
    panelOpen = false
    SetNuiFocus(false, false)
    cb({})
    LeaveFFA()
end)

RegisterNUICallback('refresh', function(_, cb)
    cb({})
    CreateThread(function()
        local counts = lib.callback.await('bc_ffa:getc', false)
        SendNUIMessage({
            action  = 'update',
            current = inffa or nil,
            ffas    = BuildList(counts),
        })
    end)
end)

-- az aréna azonosítót a kliens fordítja névre, mert itt van a Config
local function ArenaName(id)
    id = tonumber(id)
    local ffa = id and Config.FFAs[id]
    return ffa and ffa.Name or nil
end

RegisterNUICallback('leaderboard', function(_, cb)
    cb({})
    CreateThread(function()
        local data = lib.callback.await('bc_ffa:leaderboard', false)
        if data and data.rows then
            for _, row in ipairs(data.rows) do
                row.favArenaName = ArenaName(row.favArena)
            end
        end
        SendNUIMessage({ action = 'leaderboard', data = data })
    end)
end)

RegisterNUICallback('mystats', function(_, cb)
    cb({})
    CreateThread(function()
        local data = lib.callback.await('bc_ffa:mystats', false)
        if data and data.arenas then
            for _, row in ipairs(data.arenas) do
                row.name = ArenaName(row.arena) or ('#' .. tostring(row.arena))
            end
        end
        SendNUIMessage({ action = 'mystats', data = data })
    end)
end)

-- ══════════════════════════════════════════════════════════════
--  Belépő ped
-- ══════════════════════════════════════════════════════════════
local ffaPed = nil

local function SpawnFfaPed()
    if ffaPed and DoesEntityExist(ffaPed) then return end

    local model = GetHashKey("mp_m_bogdangoon")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    ffaPed = CreatePed(4, model, Config.EnterCoords, false, true)
    FreezeEntityPosition(ffaPed, true)
    SetEntityInvincible(ffaPed, true)
    SetBlockingOfNonTemporaryEvents(ffaPed, true)
    SetModelAsNoLongerNeeded(model)

    exports.ox_target:addLocalEntity(ffaPed, {{
        name = 'bc_ffa',
        icon = 'fa-solid fa-crosshairs',
        label = "FFA arénák",
        distance = 2.0,
        onSelect = function()
            OpenPanel()
        end
    }})
end

local function DeleteFfaPed()
    if ffaPed and DoesEntityExist(ffaPed) then
        exports.ox_target:removeLocalEntity(ffaPed)
        DeleteEntity(ffaPed)
        ffaPed = nil
    end
end

CreateThread(function()
    Wait(10000)
    lib.zones.sphere({
        coords = vec3(Config.EnterCoords.x, Config.EnterCoords.y, Config.EnterCoords.z),
        radius = 50.0,
        debug = false,
        onEnter = function()
            SpawnFfaPed()
        end,
        onExit = function()
            DeleteFfaPed()
            ClosePanel()
        end,
    })
end)

RegisterCommand("leaveffa", function()
    LeaveFFA()
end)

-- FIX: a server.lua a "nincs elég pénz" ágon TriggerClientEvent("leaveffa", ...)
-- hívást küld, de kliens oldalon ilyen NET event nem létezett (csak egy
-- RegisterCommand). Emiatt a lecsúszott játékos bent ragadt az FFA-ban,
-- és se ő, se a gyilkosa nem kapott/vesztett pénzt.
RegisterNetEvent("leaveffa", function()
    if inffa then
        TriggerEvent("esx:showNotification", "Nincs elég pénzed a téthez, kiléptettünk az FFA-ból!")
    end
    LeaveFFA()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    SetNuiFocus(false, false)
    HudHide()

    if gveh ~= 0 and DoesEntityExist(gveh) then
        DeleteEntity(gveh)
    end
    if inffa then
        SetLocalPlayerAsGhost(false)
        FreezeEntityPosition(PlayerPedId(), false)
        LocalPlayer.state.invBusy = false
    end
    DeleteFfaPed()
end)
