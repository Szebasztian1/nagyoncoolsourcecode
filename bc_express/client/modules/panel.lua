-- BC Express – statisztika/menedzsment panel: depo NPC + blip + saját NUI panel.
-- A menedzsment akciók mind szerveroldalon validáltak.

local Core = require 'client.modules.core'   -- telefon-értesítéshez (cégátvétel visszajelzés)

local Panel = {}

-- ezres-tagolt pénz a felugró ablakhoz (a NUI hu-HU szóközös tagolásához illeszkedik)
local function money(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local sign = ''
    if s:sub(1, 1) == '-' then sign = '-'; s = s:sub(2) end
    local grouped = s:reverse():gsub('(%d%d%d)', '%1 '):reverse():gsub('^%s+', '')
    return '$' .. sign .. grouped
end

local panelOpen = false
local statsNpc  = nil

local function fetchPanelData()
    local state      = lib.callback.await('bc_express:getState', false)
    local manager    = lib.callback.await('bc_express:getManager', false)
    local ops        = lib.callback.await('bc_express:getOperations', false)
    local employment = lib.callback.await('bc_express:getEmployment', false)   -- ha máshol alkalmazott vagy
    return { state = state, manager = manager, ops = ops, employment = employment }
end

-- a hozzánk legközelebbi (rajtunk kívüli) online játékos szerver-ID-je – alkalmazott felvételéhez
local function nearestPlayerId()
    local me       = PlayerPedId()
    local myCoords = GetEntityCoords(me)
    local closest, closestDist
    for _, pid in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(pid)
        if ped ~= me and DoesEntityExist(ped) then
            local d = #(GetEntityCoords(ped) - myCoords)
            if not closestDist or d < closestDist then closestDist, closest = d, pid end
        end
    end
    if closest then return GetPlayerServerId(closest) end
    return nil
end

local function OpenStatsPanel()
    if panelOpen then return end
    local data = fetchPanelData()
    if not data.state or not data.state.ok then return end
    panelOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openPanel', data = data })
end

RegisterNUICallback('bcx:closePanel', function(_, cb)
    panelOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- menedzsment akciók (feloldás / sofőr felvétele / beszedés / elbocsátás) – mind szerveroldalon validálva
RegisterNUICallback('bcx:managerAction', function(data, cb)
    local action = data and data.action
    local res
    if action == 'unlockDepot' then
        res = lib.callback.await('bc_express:unlockDepot', false, tonumber(data.id))
    elseif action == 'hire' then
        res = lib.callback.await('bc_express:hireDriver', false, tonumber(data.id))
    elseif action == 'fire' then
        res = lib.callback.await('bc_express:fireDriver', false, tonumber(data.id))
    elseif action == 'deposit' then
        res = lib.callback.await('bc_express:deposit', false, tonumber(data.amount))
    elseif action == 'withdraw' then
        res = lib.callback.await('bc_express:withdraw', false, tonumber(data.amount))
    -- telephely üzemeltetés
    elseif action == 'buyMachine' then
        res = lib.callback.await('bc_express:buyMachine', false, tonumber(data.id))
    elseif action == 'repairMachine' then
        res = lib.callback.await('bc_express:repairMachine', false, tonumber(data.id))
    elseif action == 'hireWorker' then
        res = lib.callback.await('bc_express:hireWorker', false, tonumber(data.id))
    elseif action == 'fireWorker' then
        res = lib.callback.await('bc_express:fireWorker', false, tonumber(data.id))
    elseif action == 'formConnection' then
        res = lib.callback.await('bc_express:formConnection', false, tonumber(data.id))
    elseif action == 'nurtureConnection' then
        res = lib.callback.await('bc_express:nurtureConnection', false, tonumber(data.id))
    elseif action == 'buyPermit' then
        res = lib.callback.await('bc_express:buyPermit', false)
    -- cég eladása
    elseif action == 'sellCompany' then
        res = lib.callback.await('bc_express:sellCompany', false)
    -- cég eladása/átadása a legközelebbi játékosnak (opcionális ár, a fogadó esetleges cégét felülírja)
    elseif action == 'transferCompany' then
        local sid = nearestPlayerId()
        if not sid then res = { ok = false, reason = 'no_target' }
        else res = lib.callback.await('bc_express:transferCompany', false, sid, tonumber(data.amount)) end
    -- valódi alkalmazottak (tulaj oldal)
    elseif action == 'hireEmployee' then
        local sid = nearestPlayerId()
        if not sid then res = { ok = false, reason = 'no_target' }
        else res = lib.callback.await('bc_express:hireEmployee', false, sid) end
    elseif action == 'fireEmployee' then
        res = lib.callback.await('bc_express:fireEmployee', false, tonumber(data.id))
    -- alkalmazotti karbantartás (a tulaj nevében)
    elseif action == 'empRepair' then
        res = lib.callback.await('bc_express:empRepairMachine', false, tonumber(data.id))
    elseif action == 'empNurture' then
        res = lib.callback.await('bc_express:empNurtureConnection', false, tonumber(data.id))
    -- a felhalmozott saját bér felvétele a bankba
    elseif action == 'collectWage' then
        res = lib.callback.await('bc_express:collectWage', false)
    end
    cb({ result = res or { ok = false }, data = fetchPanelData() })
end)

-- NPC spawn: modell betöltés (max ~5 mp) + ped + ox_target. Hibánál false — a loop következő körben újrapróbálja.
local function spawnStatsNpc()
    local model = joaat(Config.StatsNpc.model)
    RequestModel(model)
    local t = 0
    while not HasModelLoaded(model) and t < 500 do Wait(10) t = t + 1 end
    if not HasModelLoaded(model) then
        SetModelAsNoLongerNeeded(model)
        return false
    end
    local c = Config.StatsPanel
    local ped = CreatePed(4, model, c.x, c.y, c.z, c.w, false, true)
    SetModelAsNoLongerNeeded(model)
    if not ped or ped == 0 then return false end
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports.ox_target:addLocalEntity(ped, {
        { name = 'bcx_stats', icon = 'fa-solid fa-chart-simple',
          label = 'BC Express – Statisztika / Menedzsment', distance = 2.5,
          onSelect = function() OpenStatsPanel() end },
    })
    statsNpc = ped
    return true
end

local function deleteStatsNpc()
    if not statsNpc then return end
    exports.ox_target:removeLocalEntity(statsNpc, 'bcx_stats')
    if DoesEntityExist(statsNpc) then DeleteEntity(statsNpc) end
    statsNpc = nil
end

-- A blipet csak a jatekos spawnja utan (+1-2 mp) hozzuk letre: a betolteskori
-- torlodasban a blip neve elveszhet a terkep jelmagyarazatabol. A firstName-et az
-- ESX a karakter betoltesekor allitja be; a spawn es a SpawnSelector alatt a kep el
-- van sotetitve, vagy player switch / spawnSelecting fut. Az 1-2 mp resource-onkent mas.
local function WaitForSpawnBeforeBlips()
    while LocalPlayer.state.firstName == nil
        or not IsScreenFadedIn()
        or IsPlayerSwitchInProgress()
        or LocalPlayer.state.spawnSelecting == true do
        Wait(500)
    end
    Wait(1000 + GetHashKey(GetCurrentResourceName()) % 1000)
end

CreateThread(function()
    -- térkép blip ("Futár Munka")
    if Config.Blip then
        CreateThread(function()
            WaitForSpawnBeforeBlips()
            local b = AddBlipForCoord(Config.Blip.coords.x, Config.Blip.coords.y, Config.Blip.coords.z)
            SetBlipSprite(b, Config.Blip.sprite)
            SetBlipColour(b, Config.Blip.color)
            SetBlipScale(b, Config.Blip.scale)
            SetBlipAsShortRange(b, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Blip.label)
            EndTextCommandSetBlipName(b)
            MunkaBlip('futar_munka', b)
        end)
    end

    -- Statisztika/menedzsment NPC csak a depó közelében él (Config.StatsNpc.radius):
    -- közeledéskor spawnol, távozáskor törlődik. Közelben a loop watchdog is — ha a pedet
    -- bármi törölte (pl. admin takarítás), újraspawnolja.
    local pos    = vector3(Config.StatsPanel.x, Config.StatsPanel.y, Config.StatsPanel.z)
    local radius = Config.StatsNpc.radius or 20.0
    while true do
        local dist = #(GetEntityCoords(PlayerPedId()) - pos)
        if dist <= radius then
            if not statsNpc or not DoesEntityExist(statsNpc) then spawnStatsNpc() end
            Wait(2500)
        else
            -- +15 m hiszterézis: a határon mozogva ne spawn/despawn pattogjon
            if statsNpc and dist > radius + 15.0 then deleteStatsNpc() end
            Wait(dist > 150.0 and 5000 or 1500)
        end
    end
end)

-- CÉGELADÁSI AJÁNLAT: a fogadónál felugró ablak – el kell fogadnia, hogy megtörténjen az átadás.
-- FIGYELEM: ha a fogadónak már van saját cége, az elfogadással véglegesen TÖRLŐDIK (felülíródik).
RegisterNetEvent('bc_express:transferOffer', function(data)
    local fromName = (data and data.fromName) or 'Egy játékos'
    local sm = (data and data.summary) or {}
    local price = tonumber(data and data.price) or 0

    -- a fogadó lássa, mit kap: mi mennyin áll
    local content = table.concat({
        ('**%s** felajánlja neked a teljes BC Express cégét. Ezt kapnád:'):format(fromName),
        '',
        ('- **Ár:** %s'):format(price > 0 and money(price) or 'Ingyenes'),
        ('- **Telepek:** %s (%d/%d szint)'):format(sm.depotLabel or '—', sm.depots or 0, sm.maxDepots or 3),
        ('- **Ranglétra (szint):** %d — %s'):format(sm.level or 0, sm.tierLabel or 'Gyakornok'),
        ('- **Cégkassza:** %s'):format(money(sm.company)),
        ('- **Törékeny-engedély:** %d/%d'):format(sm.permit or 0, sm.maxPermit or 3),
        ('- **Sofőrök:** %d  •  **Alkalmazottak:** %d'):format(sm.drivers or 0, sm.employees or 0),
        ('- **Gépek:** %d  •  **Munkások:** %d  •  **Kapcsolatok:** %d'):format(sm.machines or 0, sm.workers or 0, sm.connections or 0),
        ('- **Becsült érték:** %s'):format(money(sm.value)),
        '',
        '**Figyelem:** ha jelenleg van saját céged VAGY saját ranglétra-előrehaladásod, mindkettő véglegesen',
        'törlődik/felülíródik ezzel (kompenzáció nélkül) — a fenti szintet és cégadatokat kapod helyette. Az',
        'ajánlattevő ezzel MINDENT elveszít (telepek, kassza, fuvarszám, szint is nulláról indul).',
        '',
        price > 0 and ('Elfogadod %s-ért?'):format(money(price)) or 'Elfogadod?',
    }, '\n')

    local accepted = lib.alertDialog({
        header = 'Cégeladási ajánlat',
        content = content,
        centered = true,
        size = 'md',
        cancel = true,
        labels = { confirm = 'Elfogadom', cancel = 'Elutasítom' },
    })
    if accepted == 'confirm' then
        local res = lib.callback.await('bc_express:acceptTransfer', false)
        if res and res.ok then
            Core.phoneNotify('BC Express', ('Átvetted %s cégét!'):format(res.from or fromName))
        else
            local msg = ({
                no_offer = 'Az ajánlat már nem érvényes.',
                expired  = 'Az ajánlat lejárt.',
                target_no_money = 'Nincs elég pénzed a bankszámládon az ár kifizetéséhez.',
                owner_left = 'Az eladó időközben kilépett.',
                owner_gone = 'Az eladónak már nincs cége.',
            })[res and res.reason] or 'A cégátvétel nem sikerült.'
            Core.phoneNotify('BC Express', msg)
        end
    else
        TriggerServerEvent('bc_express:declineTransfer')
    end
end)

-- resource leállásakor: fókusz elengedése + NPC törlése
function Panel.onStop()
    if panelOpen then SetNuiFocus(false, false) end
    deleteStatsNpc()
end

return Panel
