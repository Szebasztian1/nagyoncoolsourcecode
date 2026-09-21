Keys = {
    ["ESC"] = 322,
    ["F1"] = 288,
    ["F2"] = 289,
    ["F3"] = 170,
    ["F5"] = 166,
    ["F6"] = 167,
    ["F7"] = 168,
    ["F8"] = 169,
    ["F9"] = 56,
    ["F10"] = 57,
    ["~"] = 243,
    ["1"] = 157,
    ["2"] = 158,
    ["3"] = 160,
    ["4"] = 164,
    ["5"] = 165,
    ["6"] = 159,
    ["7"] = 161,
    ["8"] = 162,
    ["9"] = 163,
    ["-"] = 84,
    ["="] = 83,
    ["BACKSPACE"] = 177,
    ["TAB"] = 37,
    ["Q"] = 44,
    ["W"] = 32,
    ["E"] = 38,
    ["R"] = 45,
    ["T"] = 245,
    ["Y"] = 246,
    ["U"] = 303,
    ["P"] = 199,
    ["["] = 39,
    ["]"] = 40,
    ["ENTER"] = 18,
    ["CAPS"] = 137,
    ["A"] = 34,
    ["S"] = 8,
    ["D"] = 9,
    ["F"] = 23,
    ["G"] = 47,
    ["H"] = 74,
    ["K"] = 311,
    ["L"] = 182,
    ["LEFTSHIFT"] = 21,
    ["Z"] = 20,
    ["X"] = 73,
    ["C"] = 26,
    ["V"] = 0,
    ["B"] = 29,
    ["N"] = 249,
    ["M"] = 244,
    [","] = 82,
    ["."] = 81,
    ["LEFTCTRL"] = 36,
    ["LEFTALT"] = 19,
    ["SPACE"] = 22,
    ["RIGHTCTRL"] = 70,
    ["HOME"] = 213,
    ["PAGEUP"] = 10,
    ["PAGEDOWN"] = 11,
    ["DELETE"] = 178,
    ["LEFT"] = 174,
    ["RIGHT"] = 175,
    ["TOP"] = 27,
    ["DOWN"] = 173,
    ["NENTER"] = 201,
    ["N4"] = 108,
    ["N5"] = 60,
    ["N6"] = 107,
    ["N+"] = 96,
    ["N-"] = 97,
    ["N7"] = 117,
    ["N8"] = 61,
    ["N9"] = 118
}

local FirstSpawn, PlayerLoaded = true, false

IsDead = false
DeathCalled = false
CanEarlyRespawn = false      -- true once the bleedout phase begins
DeathRespawnRequested = false -- set by NUI when player presses E during bleedout
-- Azonnali eledes PP-ert (K). A varakozasi idot ugorja at; minden mas ugyanaz,
-- mint egy normal ujraeledesnel. A szerver mar levonta a PP-t, mire ez igaz lesz.
InstantReviveRequested = false
local instantRevivePending = false -- amig a szerver valasza uton van
ESX = exports['es_extended']:getSharedObject()

local function safeHideLoadingScreen(time)
    if GetResourceState("rota_loading") == "started" then
        pcall(function()
            exports["rota_loading"]:LoadingHide(time or 500)
        end)
    end
end

local function safeShowLoadingScreen(time, msg, blur)
    if GetResourceState("rota_loading") == "started" then
        pcall(function()
            exports["rota_loading"]:LoadingShow(time or 700, msg or "Újraéledés...", blur)
        end)
    end
end


local wcoords = {
    vector3(3611.2568, 3728.4055, 29.6894),
    vector3(1397.6791, -2613.064, 49.674),
    vector3(-613.5429, -1627.791, 33.010),
    vector3(4466.2089, -4460.044, 4.2984),
    vector3(-2078.887, -1016.588, 5.884131),
}

local bcs = {
    { c = vector3(5182.8837, -5163.389, 4.4876952), r = 800.0 },
    { c = vector3(-2730.564, 6603.2695, 26.895294), r = 300.0 },
    { c = vector3(-1668.639, -186.973, 57.680355),  r = 150.0 },
}

RegisterNUICallback('checkAmbulance', function(data, cb)
    if DeathCalled then
        cb({ available = false, already_called = true })
        return
    end
    local mc = GetEntityCoords(PlayerPedId())
    local cancall = true
    for _, c in pairs(wcoords) do
        if #(mc - c) < 100 then cancall = false end
    end
    for _, c in pairs(bcs) do
        if #(mc - c.c) < c.r then cancall = false end
    end
    if GetResourceState("bc_ffa") == "started" then
        if exports["bc_ffa"]:inffa() then cancall = false end
    end
    if not cancall then
        cb({ available = false, zone_restricted = true })
        return
    end
    DeathCalled = true
    cb({ available = true })
end)

RegisterNUICallback('callNPC', function(data, cb)
    if DeathCalled then
        cb({})
        return
    end
    -- Carryzés közben nem indulhat NPC-mentő: a cipelés elviszi a hívás helyéről, és a
    -- kórházba teleportálás nem érvényesül csatolt peden -> a helyszínen éledne újra.
    if GetResourceState("bc_carry") == "started" and exports["bc_carry"]:IsCarry() then
        ESX.ShowNotification("Jelenleg cipelnek téged, ezért nem tudsz NPC mentőt hívni!")
        cb({ cancall = false })
        return
    end
    local mc = GetEntityCoords(PlayerPedId())
    local cancall = true
    for _, c in pairs(wcoords) do
        if #(mc - c) < 100 then cancall = false end
    end
    for _, c in pairs(bcs) do
        if #(mc - c.c) < c.r then cancall = false end
    end
    if GetResourceState("bc_ffa") == "started" then
        if exports["bc_ffa"]:inffa() then cancall = false end
    end
    if cancall then
        -- A szerver dönt: ő látja, cipelnek-e minket, és ő jegyzi be a hívást,
        -- amíg tart, addig a bc_carry nem engedi felvenni a játékost.
        ESX.TriggerServerCallback('esx_ambulancejob:tryCallNPC', function(allowed)
            if not allowed then
                cb({ cancall = false })
                return
            end

            DeathCalled = true
            cb({ cancall = true })
            CreateThread(StartNPC)
        end)
        return
    end
    cb({ cancall = cancall })
end)

RegisterNUICallback('setNuiFocus', function(data, cb)
    SetNuiFocus(data.focus, data.cursor)
    cb({})
end)

RegisterNUICallback('submitCallModal', function(data, cb)
    SendDistressSignal()
    ESX.ShowNotification("Értesítettük a mentőszolgálatot!")
    TriggerServerEvent('esx_ambulancejob:setCalled', true, data.message or "")
    cb({})
end)

RegisterNUICallback('cancelCallModal', function(data, cb)
    DeathCalled = false
    cb({})
end)

RegisterNUICallback('respawnEarly', function(data, cb)
    -- only honoured once the bleedout phase has begun (see StartDeathTimer)
    if CanEarlyRespawn then
        DeathRespawnRequested = true
    end
    cb({})
end)

-- Azonnali eledes PP-ert. A fizetes a szerveren tortenik (o latja a PP-t es o
-- vonja le), a kliens csak akkor ugrik at a varakozason, ha az sikerult.
RegisterNUICallback('instantRevive', function(data, cb)
    if not IsDead then
        return cb({ ok = false, msg = "Nem vagy halott." })
    end

    if instantRevivePending or InstantReviveRequested then
        return cb({ ok = false })
    end

    instantRevivePending = true

    ESX.TriggerServerCallback('esx_ambulancejob:buyInstantRevive', function(ok, msg, cost)
        instantRevivePending = false

        if ok then
            InstantReviveRequested = true
        end

        cb({ ok = ok == true, msg = msg, cost = cost })
    end)
end)

Citizen.CreateThread(function()
    while ESX == nil do
        --TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(200)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

    PlayerLoaded = true
    ESX.PlayerData = ESX.GetPlayerData()
end)
local disablemenu = false 
Citizen.CreateThread(function()
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(xPlayer)
        disablemenu = true 
        while ESX == nil do
            Citizen.Wait(0)
        end
        ESX.PlayerData = xPlayer
        PlayerLoaded = true
        Wait(30000)
        disablemenu = false 
    end)
end)
local skinmale = {
    ["shoes"] = 25,
    ["arms"] = 151,

    ["pants_1"] = 25,
    ["pants_2"] = 0,

    --["decals_1"] = 60,
    --["decals_2"] = 0,

    ["tshirt_1"] = 15,
    ["tshirt_2"] = 0,

    --["helmet_1"] = 8,
    --["helmet_2"] = 0,

    ["torso_1"] = 790,
    ["torso_2"] = 0,
}
local skinfemale = {
    --["shoes"] = 241,
    ["arms"] = 305,

    ["pants_1"] = 246,
    ["pants_2"] = 0,

    --["decals_1"] = 60,
    --["decals_2"] = 0,

    ["tshirt_1"] = 304,
    ["tshirt_2"] = 8,

    --["helmet_1"] = 8,
    --["helmet_2"] = 0,

    ["torso_1"] = 845,
    ["torso_2"] = 17,
}

CreateThread(function()
    while true do
        if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ambulance" and ESX.PlayerData.job.grade == 0 then
            local clothesApplied = false
            while ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ambulance" and ESX.PlayerData.job.grade == 0 do
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                if DoesEntityExist(veh) then
                    local model = GetEntityModel(veh)
                    if model ~= GetHashKey("Bran7") then
                        ClearPedTasksImmediately(PlayerPedId())
                        TriggerEvent("esx:showNotification",
                            "Beugrós mentősként csak az erre kijelölt autót használhatod!")
                    end
                end
                if exports["pma-voice"]:getRadioChannel() ~= 2 then
                    exports["pma-voice"]:setRadioChannel(2)
                end
                if not clothesApplied then
                    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
                        exports["illenium-appearance"]:setPedComponents(PlayerPedId(), json.decode([[
						[{"drawable":0,"texture":0,"component_id":0},{"drawable":262,"texture":1,"component_id":1},{"drawable":79,"texture":0,"component_id":2},{"drawable":205,"texture":0,"component_id":3},{"drawable":20,"texture":0,"component_id":4},{"drawable":0,"texture":0,"component_id":5},{"drawable":7,"texture":0,"component_id":6},{"drawable":126,"texture":0,"component_id":7},{"drawable":15,"texture":0,"component_id":8},{"drawable":0,"texture":0,"component_id":9},{"drawable":57,"texture":0,"component_id":10},{"drawable":0,"texture":0,"component_id":11}]
						]]))
                    else
                        exports["illenium-appearance"]:setPedComponents(PlayerPedId(), json.decode([[
						[{"drawable":0,"component_id":0,"texture":0},{"drawable":341,"component_id":1,"texture":0},{"drawable":495,"component_id":2,"texture":0},{"drawable":98,"component_id":3,"texture":0},{"drawable":23,"component_id":4,"texture":0},{"drawable":0,"component_id":5,"texture":0},{"drawable":132,"component_id":6,"texture":0},{"drawable":96,"component_id":7,"texture":0},{"drawable":3,"component_id":8,"texture":0},{"drawable":0,"component_id":9,"texture":0},{"drawable":65,"component_id":10,"texture":0},{"drawable":286,"component_id":11,"texture":0}]
						]]))
                    end
                    clothesApplied = true
                end
                Wait(1000)
            end
            TriggerEvent("illenium-appearance:client:reloadSkin", true)
        else
            -- job test first: Lua evaluates left to right, so this export into pma-voice
            -- used to cross the resource boundary once a second for every non-medic
            if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name ~= "ambulance" and exports["pma-voice"]:getRadioChannel() == 2 then
                exports["pma-voice"]:removePlayerFromRadio()
            end
        end
        Wait(1000)
    end
end)

ESX.RegisterClientCallback("bc_ambulance:headshot", function(cb)
    if GetResourceState("rrp_bodybag") == "started" then
        if exports["rrp_bodybag"]:isinbodybag() then
            return cb(false)
        end
    end
    --[[if GetResourceState("mate-dmgsys") == "started" then
		if exports["mate-dmgsys"]:IsLocalZoneDamaged("head") then
			return cb(false)
		else
			return cb(true)
		end
	end ]]
    cb(true)
    --[[local found, bone = GetPedLastDamageBone(PlayerPedId())
	if not found then
		cb(true)
	else
		if bone == GetPedBoneIndex(PlayerPedId(), 31086) or bone == GetPedBoneIndex(PlayerPedId(), 12844) then
			TriggerEvent("esx:showNotification", "Fejsérülést szenvedtél ezt nem lehet meggyógyítani!")
			cb(false)
		else
			cb(true)
		end
	end]]
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

AddEventHandler('playerSpawned', function()
    --LocalPlayer.invBusy = true
    IsDead = false
    DeathCalled = false
    CanEarlyRespawn = false
    InstantReviveRequested = false
    DeathRespawnRequested = false

    -- A halal alatt letiltott radial menu (K gomb) visszaengedese.
    pcall(lib.disableRadial, false)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "show", enable = false })

    TriggerServerEvent('esx_ambulancejob:setCalled', false)

    if FirstSpawn then
        exports.spawnmanager:setAutoSpawn(false) -- disable respawn
        FirstSpawn = false

        ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(isDead)
           -- LocalPlayer.invBusy = false 
            if isDead and Config.AntiCombatLog then
                TriggerEvent("bc:setDead")
                while not PlayerLoaded do
                    Citizen.Wait(1000)
                end
                Wait(5000)
                SetEntityHealth(PlayerPedId(), 0)
                --ESX.ShowNotification(_U('combatlog_message'))
                RemoveItemsAfterRPDeath()
            end
        end)
    end
end)

-- Create blips
Citizen.CreateThread(function()
    for k, v in pairs(Config.Hospitals) do
        local blip = AddBlipForCoord(v.Blip.coords)

        SetBlipSprite(blip, v.Blip.sprite)
        SetBlipScale(blip, v.Blip.scale)
        SetBlipColour(blip, v.Blip.color)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('St. Fiacre Kórház')
        EndTextCommandSetBlipName(blip)
    end
end)

local isinamb = false

Citizen.CreateThread(function()
    while true do
        if #(GetEntityCoords(PlayerPedId()) - vector3(299.762634, -581.195618, 43.248291)) < 70 then
            isinamb = true
        else
            isinamb = false
        end

        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isinamb then
            local wea = GetSelectedPedWeapon(PlayerPedId())

            if wea ~= GetHashKey("WEAPON_STUNGUN") then
                DisableControlAction(0, 45, true)
                DisableControlAction(0, 140, true)

                DisablePlayerFiring(PlayerId(), true)
                if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("WEAPON_UNARMED") then
                    SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)


-- Disable most inputs when dead
CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsDead then
            DisableAllControlActions(0)
            EnableControlAction(0, Keys['G'], true)
            EnableControlAction(0, Keys['H'], true)
            EnableControlAction(0, Keys['T'], true)
            EnableControlAction(0, Keys['E'], true)
            EnableControlAction(0, Keys['F'], true)
            EnableControlAction(0, Keys['K'], true)
            EnableControlAction(0, Keys['ESC'], true)

            if IsControlJustPressed(0, Keys['G']) then
                SendNUIMessage({
                    type = "pressKey",
                    key = "g"
                })
            end

            if IsControlJustPressed(0, Keys['H']) then
                SendNUIMessage({
                    type = "pressKey",
                    key = "h"
                })
            end

            if IsControlJustPressed(0, Keys['E']) then
                SendNUIMessage({
                    type = "pressKey",
                    key = "e"
                })
            end

            if IsControlJustPressed(0, Keys['K']) then
                SendNUIMessage({
                    type = "pressKey",
                    key = "k"
                })
            end
        else
            Citizen.Wait(750)
        end
    end
end)

-- Halottan csak a kórház területén szabad targetelni (ALT), különben a helyszínen
-- fekve is lehetne kocsit bezárni/feltörni. A jelzőt az ox_target olvassa.
local deadTargetZones = {}

CreateThread(function()
    for _, hospital in pairs(Config.Hospitals or {}) do
        if hospital.Blip and hospital.Blip.coords then
            deadTargetZones[#deadTargetZones + 1] = { coords = hospital.Blip.coords, radius = 100.0 }
        end
    end

    if Config.DeadPoint then
        deadTargetZones[#deadTargetZones + 1] = { coords = Config.DeadPoint, radius = 60.0 }
    end

    -- extra zónák a configból (pl. Paleto kórház)
    for _, zone in ipairs(Config.DeadTargetExtraZones or {}) do
        if zone.coords then
            deadTargetZones[#deadTargetZones + 1] = { coords = zone.coords, radius = zone.radius or 100.0 }
        end
    end

    -- nil kezdőérték: a resource újraindulása után is kiírjuk egyszer az állapotot
    local blocked = nil

    while true do
        local shouldBlock = false

        if IsDead then
            shouldBlock = true
            local mc = GetEntityCoords(PlayerPedId())

            for i = 1, #deadTargetZones do
                local zone = deadTargetZones[i]

                if #(mc - zone.coords) <= zone.radius then
                    shouldBlock = false
                    break
                end
            end
        end

        if shouldBlock ~= blocked then
            blocked = shouldBlock
            LocalPlayer.state:set('deadTargetBlocked', shouldBlock or nil, false)
        end

        Wait(IsDead and 500 or 2000)
    end
end)

local dmzones = {
    { c = vector3(3615.9567, 3737.998, 28.689374),  r = 150 },
    { c = vector3(1376.9473, -2624.946, 49.670768), r = 150 },
    { c = vector3(-610.1783, -1600.354, 26.74682),  r = 100 },
}

-- This used to be a thread ticking once a second for every player, for their whole session, and
-- every tick it made a cross-resource export call into dm_rablasok (which itself re-read the ped
-- coords once per bank). The answer is read in exactly one place -- the death handler below -- so
-- it is worked out on the spot now, when someone actually dies.
function IsInDmZone()
    local co = GetEntityCoords(PlayerPedId())

    for i = 1, #dmzones do
        if #(dmzones[i].c - co) < dmzones[i].r then
            return true
        end
    end

    if GetResourceState("dm_rablasok") == "started" then
        return exports["dm_rablasok"]:isInZone() and true or false
    end

    return false
end

CreateThread(function()
    SetPedConfigFlag(PlayerPedId(), 438, true)
end)

RegisterNetEvent("bc_ambulance:count", function(data)
    SendNUIMessage({
        type = "ambulance",
        count = data
    })
end)

function OnPlayerDeath(data)
    IsDead = true
    CanEarlyRespawn = false
    InstantReviveRequested = false
    DeathRespawnRequested = false

    -- Az ox_lib radial menu alapbol ugyanazon a K gombon nyilik, mint a
    -- halal-kepernyo "Azonnali eledes (1000 PP)" gombja -- fizetes kozben
    -- bejott a kerek menu is. Halottan letiltjuk (a nyitottat be is csukja),
    -- playerSpawned-nel visszakapcsoljuk.
    pcall(lib.disableRadial, true)
    ESX.UI.Menu.CloseAll()
    SetPauseMenuActive(false)
    SetFrontendActive(false)
    TriggerEvent('rota-pausemenu:hide')

    local hshot = false
    local found, bone = GetPedLastDamageBone(PlayerPedId())
    if not found then
        hshot = false
    else
        if bone == GetPedBoneIndex(PlayerPedId(), 31086) or bone == GetPedBoneIndex(PlayerPedId(), 12844) then
            TriggerEvent("esx:showNotification", "Fejsérülést szenvedtél ezt nem lehet meggyógyítani!")
            hshot = true
        else
            hshot = false
        end
    end

    TriggerServerEvent('esx_ambulancejob:setDeathStatus', true, hshot)

    --local ped = GetPlayerPed(-1)
    --local coords = GetEntityCoords(coords)
    --SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)

    StartDeathTimer()
    StartDistressSignal()

    --StartScreenEffect('DeathFailOut', 0, false)
    if data.killedByPlayer and data.killerServerId and IsInDmZone() then
        local playerId = GetPlayerFromServerId(data.killerServerId);

        if playerId ~= -1 then
            SendNUIMessage({
                type = "show",
                killer = GetPlayerName(playerId),
                enable = true
            })
        else
            SendNUIMessage({
                type = "show",
                enable = true
            })
        end
    else
        SendNUIMessage({
            type = "show",
            enable = true
        })
    end

    SetNuiFocus(false, false)

    Citizen.CreateThread(function()
        Wait(2000)
        while IsDead do
            if not IsEntityAttachedToEntity(PlayerPedId()) then
                ClearPedTasksImmediately(PlayerPedId())
            end
            Wait(30000)
        end
    end)
end

local usingdurgs = false
local plyState = LocalPlayer.state
plyState:set('usingDrugs', false, false)
AddStateBagChangeHandler('usingDrugs', stateId, function(_, _, value)
    usingdurgs = value
end)


RegisterNetEvent('esx_ambulancejob:useItem')
AddEventHandler('esx_ambulancejob:useItem', function(itemName)
    ESX.UI.Menu.CloseAll()

    if usingdurgs then
        ESX.ShowNotification("Jelenleg ezt nem használhatod!")
        return
    end

    if itemName == 'ujmedikit' then
        --local success = lib.skillCheck({'easy', 'easy'}, {'w', 'a', 's', 'd'})
        local success = true
        TriggerServerEvent("esx_ambulancejob:removeItem", "ujmedikit")
        if not success then
            return ESX.ShowNotification("Sikertelen használat!")
        end

        local libb, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.Streaming.RequestAnimDict(libb, function()
            LocalPlayer.state.usingMed = true
            TaskPlayAnim(playerPed, libb, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

            local animend = GetGameTimer() + 4000

            CreateThread(function()
                while GetGameTimer() < animend do
                    if not IsEntityPlayingAnim(playerPed, libb, anim, 3) then
                        TaskPlayAnim(playerPed, libb, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                    end
                    Wait(100)
                end
            end)

            Citizen.Wait(500)
            --[[while IsEntityPlayingAnim(playerPed, libb, anim, 3) do
				Citizen.Wait(0)
				DisableAllControlActions(0)
			end]]
            FreezeEntityPosition(PlayerPedId(), true)

            while GetGameTimer() < animend do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            FreezeEntityPosition(PlayerPedId(), false)
            if not IsDead then
                TriggerEvent('esx_ambulancejob:heal', 'big', true)
                ESX.ShowNotification(_U('used_medikit'))
            end
            LocalPlayer.state.usingMed = false
        end)
    elseif itemName == 'bandage' then
        TriggerServerEvent("esx_ambulancejob:removeItem", "bandage")
        local libb, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.Streaming.RequestAnimDict(libb, function()
            LocalPlayer.state.usingMed = true
            TaskPlayAnim(playerPed, libb, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, libb, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end

            if not IsDead then
                TriggerEvent('esx_ambulancejob:heal', 'small', true)
                ESX.ShowNotification(_U('used_bandage'))
            end
            LocalPlayer.state.usingMed = false
        end)
    elseif itemName == 'bandage' then
        local libb, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
        local playerPed = PlayerPedId()

        ESX.Streaming.RequestAnimDict(libb, function()
            TaskPlayAnim(playerPed, libb, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

            Citizen.Wait(500)
            while IsEntityPlayingAnim(playerPed, libb, anim, 3) do
                Citizen.Wait(0)
                DisableAllControlActions(0)
            end
            if not IsDead then
                TriggerEvent('esx_ambulancejob:heal', 'small', true)
                ESX.ShowNotification(_U('used_bandage'))
            end
        end)
    end
end)


function StartDistressSignal()
    Citizen.CreateThread(function()
        local timer = Config.BleedoutTimer
        DeathCalled = false

        while timer > 0 and IsDead do
            Citizen.Wait(100)
            timer = timer - 100

            --[[SetTextFont(4)
			SetTextScale(0.45, 0.45)
			SetTextColour(185, 185, 185, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('distress_send'))
			EndTextCommandDisplayText(0.175, 0.805)]]
            local cancall = true
            local mc = GetEntityCoords(PlayerPedId())
            for _, c in pairs(wcoords) do
                if #(mc - c) < 100 then
                    cancall = false
                end
            end
            for _, c in pairs(bcs) do
                if #(mc - c.c) < c.r then
                    cancall = false
                end
            end

            if GetResourceState("bc_ffa") == "started" then
                if exports["bc_ffa"]:inffa() then
                    cancall = false
                end
            end
        end
    end)
end

function SendDistressSignal()
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local position  = { x = coords.x, y = coords.y, z = coords.z }
    local anonym    = false

    --exports['thug-dispatch']:Alert("injury")

    --TriggerServerEvent("roadphone:sendDispatch", GetPlayerServerId(PlayerId()), "Sérült civil", "ambulance", position, anonym)

    --[[ESX.TriggerServerCallback("esx_ambulancejob:call", function(stat)
        if not stat then
            return
        end
        --called = true
        if stat == "ambulance" then
            TriggerServerEvent("roadphone:sendDispatch", GetPlayerServerId(PlayerId()), "Sérült civil", "ambulance", position, anonym)
        elseif stat == "npc" then
            StartNPC()
            --return ESX.ShowNotification("Hamarosan érkezik a segítség!")
        end
    end)]]
end

function IsAmbulanceValid(ped, basecoords)
    if IsPedDeadOrDying(ped) then
        return false
    end
    if not IsDead then
        return false
    end
    if not basecoords then
        return true
    end

    if #(GetEntityCoords(PlayerPedId()) - basecoords) > 20 then
        return false
    end

    return true
end

function ReviveByNPC()
    if not IsDead then return end
    --DoScreenFadeOut(1000)
    SetEntityCoords(PlayerPedId(), Config.DeadPoint.x, Config.DeadPoint.y, Config.DeadPoint.z)
    TriggerServerEvent("esx_ambulancejob:revivebynpc")

    safeShowLoadingScreen(700, "Újraéledés...")
    --Wait(10000)
    Wait(1000 * math.random(10, 30))
    --DoScreenFadeIn(1000)
    safeHideLoadingScreen(500)
end

function StartNPC()
    if GetResourceState("mate-dmgsys") == "started" then
        if exports["mate-dmgsys"]:IsLocalZoneDamaged('head') then
            -- a hívás nem indult el, engedjük vissza a carryzést
            TriggerServerEvent('esx_ambulancejob:clearNpcCall')
            return ESX.ShowNotification("Fejsérülést szenvedtél, ez nem gyógyítható!")
        end
    end

    ESX.ShowNotification("A mentős egység elindult a helyszínre!")


    local coords = GetEntityCoords(PlayerPedId())
    --local timeout = 1*60000 + (math.random(1,30)*1000)
    local timeout = 15 * 1000
    while timeout > 0 do
        if IsAnyPedShootingInArea(coords, 100.0, 100.0, 100.0, true, true) then
            TriggerServerEvent('esx_ambulancejob:clearNpcCall')
            return ESX.ShowNotification(
                "A mentős egység nem tudja megközelíteni a helyzeted, mivel lővések hallatszódnak a környéken!")
        end
        timeout = timeout - 100
        Wait(100)
    end
    print("npcspawn")
    local vehhash = GetHashKey("ambulance")
    local pedhash = GetHashKey("s_m_m_doctor_01")
    RequestModel(vehhash)
    while not HasModelLoaded(vehhash) do
        Wait(1)
    end
    RequestModel(pedhash)
    while not HasModelLoaded(pedhash) do
        Wait(1)
    end
    local _, todrivePos, _ = GetClosestVehicleNode(coords.x, coords.y, coords.z, 1, 3.0, 0)
    if #(todrivePos - coords) > 700 then
        TriggerServerEvent('esx_ambulancejob:clearNpcCall')
        return ESX.ShowNotification("A mentős egység nem tudja megközelíteni a helyzeted!")
    end
    --local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-500, 500), coords.y + math.random(-500, 500), coords.z, 0, 3, 0)
    local found, spawnPos = GetClosestVehicleNode(coords.x + math.random(-500, 500), coords.y + math.random(-500, 500),
        coords.z, 1, 3.0, 0)


    local mechVeh = CreateVehicle(vehhash, spawnPos, 10.0, true, false)
    -- bc_kocsitorles: legalis spawn jelolese
    if mechVeh and mechVeh ~= 0 then Entity(mechVeh).state:set('bc_spawned', true, true) end
    ClearAreaOfVehicles(GetEntityCoords(mechVeh), 5000, false, false, false, false, false)
    SetVehicleOnGroundProperly(mechVeh)
    SetEntityAsMissionEntity(mechVeh, true, true)
    SetVehicleEngineOn(mechVeh, true, true, false)

    exports["gs_eventprotect"]:GS_TriggerServerEvent("bc_amb:calledNPC", NetworkGetNetworkIdFromEntity(mechVeh))

    local mechPed = CreatePedInsideVehicle(mechVeh, 26, pedhash, -1, true, false)
    print(mechVeh, mechPed)

    timeout = 2 * 60000
    Wait(2000)
    TaskVehicleDriveToCoord(mechPed, mechVeh, todrivePos.x, todrivePos.y, todrivePos.z, 20.0, 0, GetEntityModel(mechVeh),
        524863, 2.0)
    while #(todrivePos - GetEntityCoords(mechPed)) > 15 and timeout > 0 and IsAmbulanceValid(mechPed, coords) do
        timeout = timeout - 100
        Wait(100)
    end
    if timeout <= 0 then
        DeleteEntity(mechVeh)
        DeleteEntity(mechPed)
        --return ESX.ShowNotification("A mentős egység nem tudja megközelíteni a helyzeted!")
        return ReviveByNPC()
    end
    if not IsAmbulanceValid(mechPed, coords) then
        DeleteEntity(mechVeh)
        DeleteEntity(mechPed)
        --return ESX.ShowNotification("A mentős egység nem tudja megközelíteni a helyzeted!")
        return ReviveByNPC()
    end

    TaskGoToCoordAnyMeans(mechPed, GetEntityCoords(PlayerPedId()), 1.0, 0, 0, 786603, 0xbf800000)
    timeout = 2 * 60000
    while #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(mechPed)) > 5 and timeout > 0 and IsAmbulanceValid(mechPed, coords) do
        timeout = timeout - 100
        Wait(100)
    end
    if timeout <= 0 then
        DeleteEntity(mechVeh)
        DeleteEntity(mechPed)
        --return ESX.ShowNotification("A mentős egység nem tudja megközelíteni a helyzeted!")
        return ReviveByNPC()
    end
    if not IsAmbulanceValid(mechPed, coords) then
        DeleteEntity(mechVeh)
        DeleteEntity(mechPed)
        --return ESX.ShowNotification("A mentős egység nem tudja megközelíteni a helyzeted!")
        return ReviveByNPC()
    end

    ClearPedTasksImmediately(mechPed)
    RequestAnimDict("missfinale_c2mcs_1")
    while not HasAnimDictLoaded("missfinale_c2mcs_1") do
        Wait(1000)
    end
    RequestAnimDict("nm")
    while not HasAnimDictLoaded("nm") do
        Wait(1000)
    end

    TaskPlayAnim(mechPed, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 8.0, -8.0, 100000, 49, 0, false, false, false)
    TaskPlayAnim(PlayerPedId(), "nm", "firemans_carry", 8.0, -8.0, 100000, 33, 0, false, false, false)
    AttachEntityToEntity(PlayerPedId(), mechPed, 0, 0.27, 0.15, 0.63, 0.5, 0.5, 180, false, false, false, false, 2, false)

    TaskEnterVehicle(mechPed, mechVeh, 60000, -1, 2.0, 1, 0)

    timeout = 1 * 60000
    while GetPedInVehicleSeat(mechVeh, -1) ~= mechPed and timeout > 0 and IsAmbulanceValid(mechPed, GetEntityCoords(mechPed)) do
        timeout = timeout - 100
        TaskPlayAnim(mechPed, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 8.0, -8.0, 100000, 49, 0, false, false, false)
        TaskPlayAnim(PlayerPedId(), "nm", "firemans_carry", 8.0, -8.0, 100000, 33, 0, false, false, false)
        Wait(100)
    end
    if timeout <= 0 then
        DeleteEntity(mechVeh)
        DeleteEntity(mechPed)
        --return ESX.ShowNotification("A mentős egység nem tud beszállítani!")
        return ReviveByNPC()
    end
    if not IsAmbulanceValid(mechPed, GetEntityCoords(mechPed)) then
        DeleteEntity(mechVeh)
        DeleteEntity(mechPed)
        --return ESX.ShowNotification("A mentős egység nem tud beszállítani!")
        return ReviveByNPC()
    end

    DetachEntity(PlayerPedId(), true, false)
    ClearPedSecondaryTask(PlayerPedId())
    ClearPedSecondaryTask(mechPed)

    SetPedIntoVehicle(PlayerPedId(), mechVeh, 0)

    TaskVehicleDriveToCoord(mechPed, mechVeh, Config.DeadPoint.x, Config.DeadPoint.y, Config.DeadPoint.z, 20.0, 0,
        GetEntityModel(mechVeh), 524863, 20.0)



    --DoScreenFadeOut(1000)
    --Wait(10000)
    DeleteEntity(mechVeh)
    DeleteEntity(mechPed)
    SetEntityCoords(PlayerPedId(), Config.DeadPoint.x, Config.DeadPoint.y, Config.DeadPoint.z)
    --Wait(1000 * math.random(10, 30))
    --DoScreenFadeIn(1000)
    TriggerServerEvent("esx_ambulancejob:revivebynpc")

    safeShowLoadingScreen(700, "Újraéledés...")
    --Wait(10000)
    Wait(1000 * math.random(10, 30))
    --DoScreenFadeIn(1000)
    safeHideLoadingScreen(500)


    --[[ClearPedTasksImmediately(mechPed)
    RequestAnimDict("mini@cpr@char_a@cpr_str")
	while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
		Wait(1000)
	end
    SetEntityCoordsNoOffset(mechPed, GetEntityCoords(PlayerPedId())+vector3(0.2, 0.3, 0.0), false, false, false)
	TaskPlayAnim(mechPed, "mini@cpr@char_a@cpr_str","cpr_pumpchest",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
    Wait(20000)
    ClearPedTasksImmediately(mechPed)
    TriggerServerEvent("esx_ambulancejob:revivebynpc")]]


    --[[SetTimeout(20000, function()
        DeleteEntity(mechVeh)
        DeleteEntity(mechPed)
    end)]]
end

--function SendDistressSignal()
--[[local playerPed = PlayerPedId()
	PedPosition		= GetEntityCoords(playerPed)

	--local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }

	--ESX.ShowNotification(_U('distress_sent'))
    --TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', _U('distress_message'), PlayerCoords, {

	--	PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
	--})


	local position = {x = PedPosition.x, y = PedPosition.y, z = PedPosition.z}

    --TriggerEvent("high_phone:sendNotification", "Messages", "Distress signal sent to available units!", 3000)
    TriggerEvent("high_phone:sendNotification", "Messages", "Visszajelzés elküldve az elérhető egységeknek!", 5000)
	TriggerServerEvent("high_phone:sendMessage", "02", "Segítségre szoruló páciens (GPS:" .. position.x .. "," .. position.y .. ")") ]]

--[[local playerPed = PlayerPedId()
  	local coords = GetEntityCoords(playerPed)
  	local message = "Sérült beteg" -- The message that will be received.
  	local alert = {
  	    message = message,
  	    -- img = "img url", -- You can add image here (OPTIONAL).
  	    location = coords,
  	}

  	TriggerServerEvent('qs-smartphone:server:sendJobAlert', alert, "ambulance") -- "Your ambulance job"
  	TriggerServerEvent('qs-smartphone:server:AddNotifies', {
  	    head = "Sérült beteg", -- Message name.
  	    msg = message,
  	    app = 'business'
  	})
end]]

function DrawGenericTextThisFrame()
    SetTextFont(4)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
end

function secondsToClock(seconds)
    local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

    if seconds <= 0 then
        return 0, 0
    else
        local hours = string.format("%02.f", math.floor(seconds / 3600))
        local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
        local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))

        return mins, secs
    end
end

function StartDeathTimer()
    local canPayFine = false

    if Config.EarlyRespawnFine then
        ESX.TriggerServerCallback('esx_ambulancejob:checkBalance', function(canPay)
            canPayFine = canPay
        end)
    end

    local earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer / 1000)
    local bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)

    local gymmult = 1.0
    if GetResourceState("vilmos_gym") == "started" then
        local bst = exports["vilmos_gym"]:getSkill("condition")
        local dif = 0.3 * (bst / 100)
        gymmult = gymmult - dif
        if gymmult < 0.7 then
            gymmult = 0.7
        end
    end

    earlySpawnTimer = math.floor(earlySpawnTimer * gymmult)

    local mycoords = GetEntityCoords(PlayerPedId())

    for k, v in pairs(Config.DeathTime) do
        if #(mycoords - v.coords) < v.radius then
            earlySpawnTimer = ESX.Math.Round(v.EarlyRespawnTimer / 1000)
            bleedoutTimer = ESX.Math.Round(v.BleedoutTimer / 1000)
            break
        end
    end

    Citizen.CreateThread(function()
        -- early respawn timer
        while earlySpawnTimer > 0 and IsDead do
            Citizen.Wait(1000)

            if earlySpawnTimer > 0 then
                earlySpawnTimer = earlySpawnTimer - 1
            end
            if GetResourceState("rrp_bodybag") == "started" then
                if exports["rrp_bodybag"]:isinbodybag() then
                    earlySpawnTimer = 0
                end
            end
        end

        -- bleedout timer
        while bleedoutTimer > 0 and IsDead do
            Citizen.Wait(1000)

            if bleedoutTimer > 0 then
                bleedoutTimer = bleedoutTimer - 1
            end
        end
    end)

    Citizen.CreateThread(function()
        local text

        -- early respawn timer
        while earlySpawnTimer > 0 and IsDead do
            Citizen.Wait(500)

            -- Kifizette a PP-t: a varakozas veget er, minden mas ugyanaz, mint egy
            -- normal ujraeledesnel. `return`, hogy a ciklus utani agak ne fussanak ra.
            if InstantReviveRequested then
                InstantReviveRequested = false
                CanEarlyRespawn = false
                DeathRespawnRequested = false
                RemoveItemsAfterRPDeath()
                return
            end

            text = _U('respawn_available_in', secondsToClock(earlySpawnTimer))

            SendNUIMessage({
                type = "respawntime",
                time = text
            })
            --[[DrawGenericTextThisFrame()

			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.8)

			DrawGenericTextThisFrame()

			SetTextEntry("STRING")
			AddTextComponentString("[F] 6.000.000$ az azonnali újraéledéshez")
			DrawText(0.5, 0.7)

			if not triedL and  IsControlJustReleased(0, Keys['F']) then
				triedL = true
				ESX.TriggerServerCallback("esx_ambulancejob:LLL", function(suc)
					if suc then
						ESX.ShowNotification("6.000.000$ fizettél az újraéledésedért")
					else
						ESX.ShowNotification("Nincs elég pénzed rá")
					end
				end)
			end ]]
        end

        -- bleedout timer — E respawn becomes available here
        CanEarlyRespawn = true
        DeathRespawnRequested = false
        SendNUIMessage({ type = "canRespawn", enable = true })

        while bleedoutTimer > 0 and IsDead do
            Citizen.Wait(100)

            if InstantReviveRequested then
                InstantReviveRequested = false
                CanEarlyRespawn = false
                DeathRespawnRequested = false
                RemoveItemsAfterRPDeath()
                return
            end

            text = _U('respawn_bleedout_in', secondsToClock(bleedoutTimer))

            if not Config.EarlyRespawnFine then
                if DeathRespawnRequested then
                    DeathRespawnRequested = false
                    CanEarlyRespawn = false
                    RemoveItemsAfterRPDeath()
                    break
                end
            elseif Config.EarlyRespawnFine and canPayFine then
                text = text .. _U('respawn_bleedout_fine', ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount))

                if DeathRespawnRequested then
                    DeathRespawnRequested = false
                    CanEarlyRespawn = false
                    TriggerServerEvent('esx_ambulancejob:payFine')
                    RemoveItemsAfterRPDeath()
                    break
                end
            end

            --[[if IsControlPressed(0, Keys['E']) then
				timeHeld = timeHeld + 100
			else
				timeHeld = 0
			end]]

            SendNUIMessage({
                type = "respawntime",
                time = text
            })

            --[[DrawGenericTextThisFrame()

			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.8)]]
        end

        if bleedoutTimer < 1 and IsDead then
            RemoveItemsAfterRPDeath()
        end
    end)
end

function RemoveItemsAfterRPDeath()
    Citizen.CreateThread(function()
        --DoScreenFadeOut(800)
        safeShowLoadingScreen(700, "Újraéledés...", true)
        Wait(1000)

        local callbackFinished = false

        -- Safety watchdog timer: force hide loading screen and reset UI if server callback hangs or fails
        Citizen.CreateThread(function()
            Wait(5000)
            if not callbackFinished then
                print("[esx_ambulancejob] Warning: removeItemsAfterRPDeath callback timed out, hiding loading screen.")
                safeHideLoadingScreen(500)
                SetNuiFocus(false, false)
                SendNUIMessage({ type = "show", enable = false })
            end
        end)

        ESX.TriggerServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function()
            if callbackFinished then return end
            callbackFinished = true

            local formattedCoords = {
                x = Config.RespawnPoint.coords.x,
                y = Config.RespawnPoint.coords.y,
                z = Config.RespawnPoint.coords.z
            }

            if GetResourceState("bc_communityservice") == "started" then
                if exports["bc_communityservice"]:isPlayerOnCommunityservice() then
                    formattedCoords = {
                        x = -1205.3660,
                        y = 47.5565,
                        z = 52.1200
                    }
                end
            end

            local forcerespawn = false
            local mycoords = GetEntityCoords(PlayerPedId())
            for asd, data in ipairs(Config.Respawns) do
                local dis = #(mycoords - data.coords)
                if dis < data.radius then
                    formattedCoords = {
                        x = data.respawn.x,
                        y = data.respawn.y,
                        z = data.respawn.z
                    }
                    forcerespawn = true
                    break
                end
            end

            ESX.SetPlayerData('loadout', {})

            safeHideLoadingScreen(500)

            SetNuiFocus(false, false)
            SendNUIMessage({ type = "show", enable = false })

            if not forcerespawn and not disablemenu and GetResourceState("mate-spawnselector") == "started" then
                local selectedCookie
                local respawned = false

                -- Shared by the picker handler and the fallback below so the
                -- respawn can only ever run once.
                local function completeRespawn(coords, heading)
                    if respawned then return end
                    respawned = true
                    RemoveEventHandler(selectedCookie)

                    ESX.SetPlayerData('lastPosition', coords)
                    TriggerServerEvent('esx:updateLastPosition', coords)
                    RespawnPed(PlayerPedId(), coords, heading)
                    SetEntityVisible(PlayerPedId(), true)
                    SetNuiFocus(false, false)
                    SendNUIMessage({ type = "show", enable = false })
                    -- A halál-állapotot a szerver már törölte a
                    -- removeItemsAfterRPDeath callbackben, ami ezt megelőzte.
                    TriggerEvent('esx_basicneeds:healPlayer')
                end

                selectedCookie = AddEventHandler('mate-spawnselector:selected', function(key, coords)
                    completeRespawn({ x = coords.x, y = coords.y, z = coords.z }, coords.w or Config.RespawnPoint.heading)
                end)

                TriggerEvent('mate-spawnselector:open')

                -- Fallback: if the selector never appears or no spawn gets picked
                -- (lost NUI 'open' message, revive race), the player must not stay
                -- dead on an empty screen — respawn at the default point instead.
                CreateThread(function()
                    local deadline = GetGameTimer() + 30000
                    while not respawned and IsDead and GetGameTimer() < deadline do
                        Wait(500)
                    end

                    if respawned then return end
                    if not IsDead then -- revived while the selector was open
                        RemoveEventHandler(selectedCookie)
                        return
                    end

                    completeRespawn(formattedCoords, Config.RespawnPoint.heading)
                end)
            else
                ESX.SetPlayerData('lastPosition', formattedCoords)
                TriggerServerEvent('esx:updateLastPosition', formattedCoords)
                RespawnPed(PlayerPedId(), formattedCoords, Config.RespawnPoint.heading)
                -- lásd fent: az állapotot a szerver-callback már törölte
                TriggerEvent('esx_basicneeds:healPlayer')

                Wait(2000)

                SetEntityVisible(PlayerPedId(), true)
            end
        end)
    end)
end

function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
    ClearPedBloodDamage(ped)

    ESX.UI.Menu.CloseAll()
    safeHideLoadingScreen(500)
end

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
    local specialContact = {
        name       = 'Ambulance',
        number     = 'ambulance',
        base64Icon =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAABp5JREFUWIW1l21sFNcVhp/58npn195de23Ha4Mh2EASSvk0CPVHmmCEI0RCTQMBKVVooxYoalBVCVokICWFVFVEFeKoUdNECkZQIlAoFGMhIkrBQGxHwhAcChjbeLcsYHvNfsx+zNz+MBDWNrYhzSvdP+e+c973XM2cc0dihFi9Yo6vSzN/63dqcwPZcnEwS9PDmYoE4IxZIj+ciBb2mteLwlZdfji+dXtNU2AkeaXhCGteLZ/X/IS64/RoR5mh9tFVAaMiAldKQUGiRzFp1wXJPj/YkxblbfFLT/tjq9/f1XD0sQyse2li7pdP5tYeLXXMMGUojAiWKeOodE1gqpmNfN2PFeoF00T2uLGKfZzTwhzqbaEmeYWAQ0K1oKIlfPb7t+7M37aruXvEBlYvnV7xz2ec/2jNs9kKooKNjlksiXhJfLqf1PXOIU9M8fmw/XgRu523eTNyhhu6xLjbSeOFC6EX3t3V9PmwBla9Vv7K7u85d3bpqlwVcvHn7B8iVX+IFQoNKdwfstuFtWoFvwp9zj5XL7nRlPXyudjS9z+u35tmuH/lu6dl7+vSVXmDUcpbX+skP65BxOOPJA4gjDicOM2PciejeTwcsYek1hyl6me5nhNnmwPXBhjYuGC699OpzoaAO0PbYJSy5vgt4idOPrJwf6QuX2FO0oOtqIgj9pDU5dCWrMlyvXf86xsGgHyPeLos83Brns1WFXLxxgVBorHpW4vfQ6KhkbUtCot6srns1TLPjNVr7+1J0PepVc92H/Eagkb7IsTWd4ZMaN+yCXv5zLRY9GQ9xuYtQz4nfreWGdH9dNlkfnGq5/kdO88ekwGan1B3mDJsdMxCqv5w2Iq0khLs48vSllrsG/Y5pfojNugzScnQXKBVA8hrX51ddHq0o6wwIlgS8Y7obZdUZVjOYLC6e3glWkBBVHC2RJ+w/qezCuT/2sV6Q5VYpowjvnf/iBJJqvpYBgBS+w6wVB5DLEOiTZHWy36nNheg0jUBs3PoJnMfyuOdAECqrZ3K7KcACGQp89RAtlysCphqZhPtRzYlcPx+ExklJUiq0le5omCfOGFAYn3qFKS/fZAWS7a3Y2wa+GJOEy4US+B3aaPUYJamj4oI5LA/jWQBt5HIK5+JfXzZsJVpXi/ac8+mxWIXWzAG4Wb4g/jscNMp63I4U5FcKaVvsNyFALokSA47Kx8PVk83OabCHZsiqwAKEpjmfUJIkoh/R+L9oTpjluhRkGSPG4A7EkS+Y3HZk0OXYpIVNy01P5yItnptDsvtIwr0SunqoVP1GG1taTHn1CloXm9aLBEIEDl/IS2W6rg+qIFEYR7+OJTesqJqYa95/VKBNOHLjDBZ8sDS2998a0Bs/F//gvu5Z9NivadOc/U3676pEsizBIN1jCYlhClL+ELJDrkobNUBfBZqQfMN305HAgnIeYi4OnYMh7q/AsAXSdXK+eH41sykxd+TV/AsXvR/MeARAttD9pSqF9nDNfSEoDQsb5O31zQFprcaV244JPY7bqG6Xd9K3C3ALgbfk3NzqNE6CdplZrVFL27eWR+UASb6479ULfhD5AzOlSuGFTE6OohebElbcb8fhxA4xEPUgdTK19hiNKCZgknB+Ep44E44d82cxqPPOKctCGXzTmsBXbV1j1S5XQhyHq6NvnABPylu46A7QmVLpP7w9pNz4IEb0YyOrnmjb8bjB129fDBRkDVj2ojFbYBnCHHb7HL+OC7KQXeEsmAiNrnTqLy3d3+s/bvlVmxpgffM1fyM5cfsPZLuK+YHnvHELl8eUlwV4BXim0r6QV+4gD9Nlnjbfg1vJGktbI5UbN/TcGmAAYDG84Gry/MLLl/zKouO2Xukq/YkCyuWYV5owTIGjhVFCPL6J7kLOTcH89ereF1r4qOsm3gjSevl85El1Z98cfhB3qBN9+dLp1fUTco+0OrVMnNjFuv0chYbBYT2HcBoa+8TALyWQOt/ImPHoFS9SI3WyRajgdt2mbJgIlbREplfveuLf/XXemjXX7v46ZxzPlfd8YlZ01My5MUEVdIY5rueYopw4fQHkbv7/rZkTw6JwjyalBCHur9iD9cI2mU0UzD3P9H6yZ1G5dt7Gwe96w07dl5fXj7vYqH2XsNovdTI6KMrlsAXhRyz7/C7FBO/DubdVq4nBLPaohcnBeMr3/2k4fhQ+Uc8995YPq2wMzNjww2X+vwNt1p00ynrd2yKDJAVN628sBX1hZIdxXdStU9G5W2bd9YHR5L3f/CNmJeY9G8WAAAAAElFTkSuQmCC'
    }

    TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    OnPlayerDeath(data)
end)

RegisterNetEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(reason)
    -- Ez az esemény innentől CSAK látvány. A halál-állapotot a szerver már
    -- átállította (server/revive_auth.lua -> DoRevive), mielőtt ideszólt.
    --
    -- A korábbi setDeathStatus(false) hívás volt az igazi lyuk: mivel ez
    -- RegisterNetEvent, egy executor lokális TriggerEvent-tel meghívta, és a
    -- kliens maga jelentette a szervernek, hogy márpedig él.
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- A halal alatt letiltott radial menu (K gomb) visszaengedese. A
    -- playerSpawned is megteszi, de az ujraeledesnek nem minden utja megy
    -- azon keresztul.
    pcall(lib.disableRadial, false)

    Citizen.CreateThread(function()
        if reason ~= "npc" then
            safeShowLoadingScreen(700, "Újraéledés...", true)
        end

        local formattedCoords = {
            x = ESX.Math.Round(coords.x, 1),
            y = ESX.Math.Round(coords.y, 1),
            z = ESX.Math.Round(coords.z, 1)
        }

        ESX.SetPlayerData('lastPosition', formattedCoords)

        TriggerServerEvent('esx:updateLastPosition', formattedCoords)

        RespawnPed(playerPed, formattedCoords, 0.0)

        Wait(3000)

        if reason ~= "npc" then
            safeHideLoadingScreen(1000)
        end

        --DoScreenFadeIn(800)
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "show",
            enable = false
        })
    end)
end)

-- Load unloaded IPLs
if Config.LoadIpl then
    Citizen.CreateThread(function()
        RequestIpl('Coroner_Int_on') -- Morgue
    end)
end

AddEventHandler('esx:onPlayerDeath', function(data)
    Wait(5000)
    ClearPedTasksImmediately(PlayerPedId())
end)

-- KIVÉVE 2026-09-07: ennek az eseménynek az egész szerveren nem volt egyetlen
-- hívója sem, viszont RegisterNetEvent lévén bárki meghívhatta lokálisan
-- (TriggerEvent('esx_ambulancejob_Revive_gangwar', x, y, z)) -- vagyis ingyen
-- önfelélesztés volt, tetszőleges koordinátára. Ha valaha kell gangwar-revive,
-- a szerveren keresztül menjen: exports['esx_ambulancejob']:RevivePlayer(src).
--[[
RegisterNetEvent('esx_ambulancejob_Revive_gangwar')
AddEventHandler('esx_ambulancejob_Revive_gangwar', function(x, y, z)
    local playerPed = PlayerPedId();
    TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
    TriggerServerEvent("esx_ambulancejob:setstabile", false)
    local formattedCoordss = { x = x, y = y, z = z }
    RespawnPed(playerPed, formattedCoordss, 120.0)
    StopScreenEffect('DeathFailOut')
    Wait(3000)
end)
]]

--[[local found, bone = GetPedLastDamageBone(CurrentPed)
	if not found then
		TriggerEvent('esx_ambulancejob:revive')
	else
		if bone == GetPedBoneIndex(PlayerPedId(), 31086) or bone == GetPedBoneIndex(PlayerPedId(), 12844) then
			TriggerEvent("esx:showNotification", "Fejsérülést szenvedtél ezt nem lehet meggyógyítani!")
			TriggerServerEvent("bc_carry:headShot", helper)
		else
			TriggerEvent('esx_ambulancejob:revive')
		end
	end]]
--[[
lib.callback.register('bc_amb:isheadshot', function()
    local found, bone = GetPedLastDamageBone(PlayerPedId())
	if not found then
		return false
	else
		if bone == GetPedBoneIndex(PlayerPedId(), 31086) or bone == GetPedBoneIndex(PlayerPedId(), 12844) then
			TriggerEvent("esx:showNotification", "Fejsérülést szenvedtél ezt nem lehet meggyógyítani!")
			return true
		else
			return false
		end
	end
end)]]



local jumpinPed = nil

local function SpawnJumpinPed()
    if jumpinPed and DoesEntityExist(jumpinPed) then return end

    local model = GetHashKey("mp_m_bogdangoon")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    jumpinPed = CreatePed(4, model, vector4(310.87976, -582.7048, 42.270977, 87.824508), false, true)
    FreezeEntityPosition(jumpinPed, true)
    SetEntityInvincible(jumpinPed, true)
    SetBlockingOfNonTemporaryEvents(jumpinPed, true)

    exports.ox_target:addLocalEntity(jumpinPed, {
        {
            name = 'bc_ambulance_jumpin',
            icon = 'fa-solid fa-circle',
            label = 'Beugrós mentőszolgálat felvétele/leadása',
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent("bc_ambulance:jumpin")
            end
        },
        {
            name = 'bc_ambulance_jumpin_sw',
            icon = 'fa-solid fa-circle',
            label = 'Beugrós mentőszolgálat engedélyzeése/letiltása',
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent("bc_ambulance:jumpinsw")
            end,
            canInteract = function(entity, distance, coords, name, bone)
                if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ambulance" and ESX.PlayerData.job.grade_name == "boss" then
                    return true
                end
                return false
            end
        },
        {
            name = 'bc_ambulance_jumpin_ban',
            icon = 'fa-solid fa-ban',
            label = 'Játékos letiltása beugrós mentőből',
            distance = 2.0,
            onSelect = function()
                local input = lib.inputDialog('Beugrós mentő tiltás', {
                    { type = 'number', label = 'Játékos ID', required = true, icon = 'fa-solid fa-user' }
                })
                if not input then return end
                local targetId = tonumber(input[1])
                if not targetId then return end
                TriggerServerEvent("bc_ambulance:banPlayer", targetId)
            end,
            canInteract = function(entity, distance, coords, name, bone)
                if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ambulance" and ESX.PlayerData.job.grade_name == "boss" then
                    return true
                end
                return false
            end
        },
        {
            name = 'bc_ambulance_jumpin_banlist',
            icon = 'fa-solid fa-list',
            label = 'Letiltott játékosok kezelése',
            distance = 2.0,
            onSelect = function()
                local bannedPlayers = lib.callback.await("bc_ambulance:getBannedPlayers", false)
                if not bannedPlayers or not next(bannedPlayers) then
                    return lib.notify({ title = 'Beugrós mentő', description = 'Nincs letiltott játékos!', type = 'info' })
                end

                local options = {}
                for identifier, data in pairs(bannedPlayers) do
                    options[#options + 1] = {
                        title = data.name or identifier,
                        description = identifier,
                        icon = 'fa-solid fa-user-slash',
                        onSelect = function()
                            local confirm = lib.alertDialog({
                                header = 'Tiltás feloldása',
                                content = 'Biztosan feloldod **' .. (data.name or identifier) .. '** tiltását?',
                                centered = true,
                                cancel = true
                            })
                            if confirm == 'confirm' then
                                TriggerServerEvent("bc_ambulance:unbanPlayer", identifier)
                            end
                        end
                    }
                end

                lib.registerContext({
                    id = 'bc_ambulance_banlist',
                    title = 'Letiltott játékosok',
                    options = options
                })
                lib.showContext('bc_ambulance_banlist')
            end,
            canInteract = function(entity, distance, coords, name, bone)
                if ESX and ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "ambulance" and ESX.PlayerData.job.grade_name == "boss" then
                    return true
                end
                return false
            end
        },
    })
end

local function DeleteJumpinPed()
    if jumpinPed and DoesEntityExist(jumpinPed) then
        exports.ox_target:removeLocalEntity(jumpinPed)
        DeleteEntity(jumpinPed)
        jumpinPed = nil
    end
end
CreateThread(function()
    Wait(10000)
    lib.zones.sphere({
        coords = vector3(310.87976, -582.7048, 42.270977),
        radius = 50.0,
        onEnter = function()
            SpawnJumpinPed()
        end,
        onExit = function()
            DeleteJumpinPed()
        end,
    })
end)


RegisterCommand("mentosszamlazas", function()
    local success, data = lib.callback.await('bc_ambulance:getFreeJobs', false)
    if not success then
        return ESX.ShowNotification(data)
    end
    local opt = {
        {
            title = 'Legközelebbi játékos',
            description = 'Legközelebbi játékos frakciójának felvétele a listára!',
            icon = 'circle',
            onSelect = function()
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 2.0 then
                    return ESX.ShowNotification(_U('no_players'))
                end

                local sid = GetPlayerServerId(closestPlayer)
                local success, data = lib.callback.await('bc_ambulance:getPlayerJob', false, sid)
                if not success then
                    return ESX.ShowNotification(data)
                end

                local alert = lib.alertDialog({
                    header = 'Felvétel ingyenes ellátásra',
                    content = 'Szeretnéd, hogy mostantól a ' ..
                        data.label .. ' frakció tagjai ingyenes ellátásban részesüljenek?',
                    centered = true,
                    cancel = true
                })

                if alert ~= "confirm" then return end

                TriggerServerEvent("bc_ambulance:addNewFreeJob", data.job, data.label)
            end,
        },
    }

    for k, v in pairs(data) do
        opt[#opt + 1] = {
            title = v,
            description = 'Kattints a törléshez!',
            icon = 'circle',
            onSelect = function()
                TriggerServerEvent("bc_ambulance:removeFreeJob", k)
            end,
        }
    end

    lib.registerContext({
        id = 'amb_billing',
        title = 'Ingyenes ellátás frakcióknak',
        position = 'top-right',
        options = opt
    })

    lib.showContext('amb_billing')
end)
