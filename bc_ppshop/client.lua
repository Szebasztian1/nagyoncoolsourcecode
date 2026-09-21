ESX = nil
local CacheTime = {
    CharData = 0,
    PlayerData = 0,
    PremiumPoint = 0,
    Cars = 0,
    Counters = 0,
    Uptime = 0,
    Vip = 0,
    PPItems = 0,
    OtherPlayerData = 0,
    WeeklyDiscount = 0
}
local active = false
local spawned = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- ARLISTA: A KATALOGUS A KLIENSNEL MARAD
--
-- A szerver eddig minden lekeresnel a TELJES premium-katalogust kuldte at
-- (Config.PPItems + a premiumcars.json ~241 elo tetele, egyutt tobb szaz KB) --
-- azert, mert a kedvezmenyes arat mar rakalkulalva adta vissza. A merés szerint
-- a `villamos_ppshop:PPItems` 270 ms-os hitchet a valasz szerializalasa okozta.
--
-- Most a katalogus csak akkor jon at, ha valtozott (a szerver verziószamot ad
-- melle), a kedvezmenyt pedig itt szamoljuk ra a mar meglevo peldanyra.
-----------------------------------------------------------------------------------------------------------------------------------------

local ppCatalog = nil
local ppCatalogVersion = -1

local function ApplyPPItems(mult, label)
    if not ppCatalog then return end

    -- nincs kedvezmeny: a katalogus valtozatlanul mehet a NUI-nak
    if not mult then
        return SetNUIValue('premiumItems', ppCatalog)
    end

    local out = {}

    for i = 1, #ppCatalog do
        local entry = ppCatalog[i]
        local copy = {}

        for k, v in pairs(entry) do copy[k] = v end

        copy.price = math.floor((entry.price or 0) * mult)
        copy.label = (label or '') .. " " .. (entry.label or '')

        out[i] = copy
    end

    SetNUIValue('premiumItems', out)
end

function RefreshPPItems()
    ESX.TriggerServerCallback('villamos_ppshop:PPItems', function(data)
        if type(data) ~= 'table' then return end

        -- a szerver csak akkor teszi bele az `items`-t, ha a mi verziónk elavult
        if data.items then
            ppCatalog = data.items
            ppCatalogVersion = data.version or -1
        end

        ApplyPPItems(data.mult, data.label)
    end, ppCatalogVersion)
end

-- HETI AKCIÓ: a szerver adja a heti tételeket a már kiszámolt akciós árral
function RefreshWeekly()
    ESX.TriggerServerCallback('bc_ppshop:weeklyDiscount', function(data)
        if type(data) ~= 'table' then return end
        SetNUIValue('weeklyDiscount', data)
    end)
end

AddEventHandler('playerSpawned', function(spawn)
    spawned = true
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end

    TriggerEvent('chat:addSuggestion', '/ppadd', 'PP addolása játékosnak', {
        { name = "id",     help = "A játékos id-je" },
        { name = "amount", help = "PP mennyisége" }
    })
    TriggerEvent('chat:addSuggestion', '/pputal', 'PP utalása játékosnak', {
        { name = "id",     help = "A játékos id-je" },
        { name = "amount", help = "PP mennyisége" }
    })
    TriggerEvent('chat:addSuggestion', '/ppremove', 'PP elvétele játékostól', {
        { name = "id",     help = "A játékos id-je" },
        { name = "amount", help = "PP mennyisége" }
    })
    TriggerEvent('chat:addSuggestion', '/ppget', 'Játékos PP egyenlegének ellenőrzése', {
        { name = "id", help = "A játékos id-je" }
    })
    TriggerEvent('chat:addSuggestion', '/timeget', 'Játékos szerveren eltöltött idejének ellenőrzése', {
        { name = "id", help = "A játékos id-je" }
    })

    while not spawned do Wait(100) end

    Wait(10000)

    SetNUIValue('infos', Config.Infos)
    SetNUIValue('premiumItems', Config.PPItems)
    SetNUIValue('premiumCategories', Config.PPCategories)

    ESX.TriggerServerCallback('villamos_ppshop:News', function(data)
        SetNUIValue('news', data)
        --print(json.encode(data))
    end)

    RefreshPPItems()
    RefreshWeekly()
    CacheTime.WeeklyDiscount = GetGameTimer()

    --local newsonstart = GetResourceKvpInt('bcnews')
    --if newsonstart ~= 1 and newsonstart ~= 2 then
    --	SetResourceKvpInt('bcnews', 1)
    --elseif newsonstart == 1 then
    --	OpenDashboard()
    --else
    --	--print(newsonstart)
    --end
end)

RegisterCommand('pp_panel', function(s, a, r)
    if not active then
        OpenDashboard()
    else
        CloseDashboard()
    end
end)

RegisterKeyMapping("pp_panel", "Dashboard megnyitasa", "keyboard", "F11")

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(1)
--         if IsControlJustReleased(0, 344) then
--             Citizen.Wait(100)
--             OpenDashboard()
--         end
--     end
-- end)

Citizen.CreateThread(function()
    while true do
        -- 8-12 perc kozotti szorassal, hogy restart utan a kliensek lekeresei
        -- ne szinkron hullamokban erkezzenek a szerverre
        Citizen.Wait((480 + (GetGameTimer() % 240)) * 1000)
        ESX.TriggerServerCallback('villamos_ppshop:Uptime', function(data)
            local minutes = data % 60
            local hours = math.floor((data - minutes) / 60)
            SetNUIValue('playtime', hours .. "h " .. minutes .. "m")
            CacheTime.Uptime = GetGameTimer()
        end)
    end
end)

function OpenDashboard()
    TriggerEvent("interact:sound")
    SetNUIState(true)
    if IsPlayerSwitchInProgress() then
        return
    end
    ESX.TriggerServerCallback('villamos_ppshop:Counters', function(data)
        local counters = data

        TriggerEvent('as_cooldowns:getRobberies', function(cooldown)
            if cooldown < 0 then
                cooldown = 0
            end
            for k, v in pairs(counters) do
                if v.name == "r" then
                    v.count = cooldown
                    break
                end
            end
            SetNUIValue('counters', counters)
        end, 'rablas')
    end)

    while active do
        UpdateCache()
        Citizen.Wait(Config.WhileOpenUpdateTick)
    end
end

function CloseDashboard()
    SetNUIState(false)
end

RegisterNUICallback('exit', function(data, cb)
    SetNUIState(false)
    cb('ok')
end)

function BuyPhoneNum()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'newplate', {
        title = "Mi legyen az új telefonszámod?"
    }, function(data2, menu2)
        local newnum = data2.value
        if not tonumber(newnum) then
            ESX.ShowNotification("A telefonszám csak számokból állhat!")
        else
            newnum = tonumber(newnum)
            if newnum > 999999 then
                menu2.close()
                TriggerServerEvent("villamos_ppshop:BuyPhoneNum", newnum)
            else
                ESX.ShowNotification("A telefonszám maximum 7 számjegy hosszú lehet!")
            end
        end
    end, function(data2, menu2)
        menu2.close()
    end)
end

function BuyPlate()
    local oldplate
    local newplate
    ESX.TriggerServerCallback('villamos_ppshop:Cars', function(data)
        for _, v in pairs(data) do
            v.model = GetDisplayNameFromVehicleModel(v.model)
        end
        SetNUIValue('cars', data)
        CacheTime.Cars = GetGameTimer()

        local elementss = {}

        for _, v in pairs(data) do
            table.insert(elementss, { label = v.plate .. " - " .. v.model, value = v.plate })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'carselect', {
            title    = 'Melyik autód rendszámát szeretnéd cserélni?',
            align    = 'bottom-right',
            elements = elementss
        }, function(data, menu)
            menu.close()
            oldplate = data.current.value
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'newplate', {
                title = "Mi legyen az új rendszám?"
            }, function(data2, menu2)
                ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function(isPlateTaken)
                    if isPlateTaken then
                        ESX.ShowNotification("Ez a rendszám már foglalt!")
                    else
                        if string.len(data2.value) <= 7 then
                            menu2.close()
                            newplate = data2.value
                            TriggerServerEvent("villamos_ppshop:BuyPlate", oldplate, newplate)
                        else
                            ESX.ShowNotification("A rendszám maximum 7 karakter hosszú lehet!")
                        end
                    end
                end, data2.value)
            end, function(data2, menu2)
                menu2.close()
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function BuyArmor()
    ESX.TriggerServerCallback('villamos_ppshop:Cars', function(data)
        for _, v in pairs(data) do
            v.model = GetDisplayNameFromVehicleModel(v.model)
        end
        SetNUIValue('cars', data)
        CacheTime.Cars = GetGameTimer()

        local elementss = {}

        for _, v in pairs(data) do
            table.insert(elementss, { label = v.plate .. " - " .. v.model, value = v.plate })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'carselect2', {
            title    = 'Melyik autódra szeretnél extra páncélt venni?',
            align    = 'bottom-right',
            elements = elementss
        }, function(data, menu)
            menu.close()
            TriggerServerEvent("villamos_ppshop:BuyArmor", data.current.value)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function BuyExtraspeed(espeed)
    ESX.TriggerServerCallback('villamos_ppshop:Cars', function(data)
        for _, v in pairs(data) do
            v.model = GetDisplayNameFromVehicleModel(v.model)
        end
        SetNUIValue('cars', data)
        CacheTime.Cars = GetGameTimer()

        local elementss = {}

        for _, v in pairs(data) do
            table.insert(elementss, { label = v.plate .. " - " .. v.model, value = v.plate })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'carselect2', {
            title    = 'Melyik autódra szeretnél extra sebességet?',
            align    = 'bottom-right',
            elements = elementss
        }, function(data, menu)
            menu.close()
            TriggerServerEvent("villamos_ppshop:buyExtraSpeed", espeed, data.current.value)
        end, function(data, menu)
            menu.close()
        end)
    end)
end 

function CustomRank()
    local input = lib.inputDialog("Egyedi rang", {
        { type = 'color', format = "rgba",                               label = "A neved színe", required = true },
        { type = 'input', label = "A rangod, ami a neved előtt szerepel" },
    })
    if not input then return end
    local rgb = lib.math.torgba(input[1])
    --local alpha = GetAlphaFromString(input[6])
    if input[2] and string.len(input[2]) > 10 then
        return ESX.ShowNotification("A rang maximum 8 karakter hosszú lehet és nem tartalmazhat speciális karaktereket!")
    end
    TriggerServerEvent("villamos_ppshop:BuyCustomRank", input[2],
        { r = math.ceil(rgb.x), g = math.ceil(rgb.y), b = math.ceil(rgb.z) })

    --ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'customrank', {
    --	title = "Mi legyen az egyedi rangod neve a fejed felett?"
    --}, function(data2, menu2)
    --			if string.len(data2.value) <= 8 and string.len(data2.value) > 0 then
    --				menu2.close()
    --				TriggerServerEvent("villamos_ppshop:BuyCustomRank", data2.value)
    --			else
    --				ESX.ShowNotification("A rang maximum 8 karakter hosszú lehet és muszáj valamiből állnia és nem tartalmazhat speciális karaktereket!")
    --			end
    --end, function(data2, menu2)
    --	menu2.close()
    --end)
end

RegisterNUICallback('buy', function(data, cb)
    if data.name == "csgocase" then
        TriggerEvent("bc_caseopening_open", "Weapons")
        CloseDashboard()
    elseif data.name == "csgocase2" then
        TriggerEvent("bc_caseopening_open", "Cars")
        CloseDashboard()
    elseif data.name == "csgocase3" then
        TriggerEvent("bc_caseopening_open", "Cars2")
        CloseDashboard()
    elseif data.name == "plate" then
        BuyPlate()
        CloseDashboard()
    elseif data.name == "extraspeed5" then
        BuyExtraspeed(5)
        CloseDashboard()
    elseif data.name == "extraspeed10" then
        BuyExtraspeed(10)
        CloseDashboard()
    elseif data.name == "extraarmor" then
        BuyArmor()
        CloseDashboard()
    elseif data.name == "phonenum" then
        BuyPhoneNum()
        CloseDashboard()
    elseif data.name == "customrank" then
        CustomRank()
        CloseDashboard()
    else
        if data.event == "villamos_pp:buyPremiumSound" then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirmshit', {
                title    = 'Arra az autóra szeretnéd rakni amiben éppen ülsz?',
                align    = 'bottom-center',
                elements = {
                    { label = "Mégse", value = "no" },
                    { label = "Igen",  value = "yes" },
                }
            }, function(data2, menu)
                menu.close()
                if data2.current.value == "yes" then
                    TriggerServerEvent('villamos_ppshop:BuyPPItem', data.name)
                end
            end, function(data2, menu)
                menu.close()
            end)
            CloseDashboard()
            return
        end
        TriggerServerEvent('villamos_ppshop:BuyPPItem', data.name)
    end

    cb('ok')
end)

-- HETI AKCIÓ vásárlás: külön szerver esemény, csak a tétel nevét küldjük,
-- az árat és a jogosultságot a szerver számolja/ellenőrzi
RegisterNUICallback('buyWeekly', function(data, cb)
    if type(data) == 'table' and type(data.name) == 'string' then
        TriggerServerEvent('bc_ppshop:buyWeeklyDiscount', data.name)
    end
    cb('ok')
end)

local testing = false

RegisterNUICallback('testcar', function(data, cb)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    local dist = #(coords - Config.VehShopCoords.coords)
    if dist < Config.VehShopCoords.radius then
        local hash = GetHashKey(data.model)
        if not IsModelInCdimage(hash) or testing then
            TriggerEvent('esx:showNotification', "Ez az autó nem tesztelhető!")
            return
        end
        while not HasModelLoaded(hash) do
            RequestModel(hash)
            Citizen.Wait(10)
        end
        local vehicle = CreateVehicle(hash, Config.TestCoords.x, Config.TestCoords.y, Config.TestCoords.z,
            Config.TestCoords.h, false, false)
        -- bc_kocsitorles: legalis spawn jelolese
        if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
        if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
        Citizen.Wait(1000)
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
        SetModelAsNoLongerNeeded(hash)
        if data.model == "oycs680w222" then
            SetVehicleMod(vehicle, 8, 0, false)
        end
        local start = GetGameTimer()
        testing = true
        Citizen.CreateThread(function()
            while testing do
                Citizen.Wait(0)
                local rem = Config.TestTime - (GetGameTimer() - start)
                if rem <= 0 then
                    testing = false
                end
                if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= vehicle then
                    testing = false
                end
                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextCentre(1)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentString("Hátra van ~g~" .. math.floor(rem / 1000) .. " mp")
                EndTextCommandDisplayText(0.5, 0.9)
            end
            ESX.Game.DeleteVehicle(vehicle)
            ESX.Game.Teleport(GetPlayerPed(-1), Config.VehShopCoords.coords)
        end)
    else
        TriggerEvent('esx:showNotification', "A tesztelés csak az Autóspiacról indítható!")
    end
    cb('ok')
end)


RegisterNUICallback('testsound', function(data, cb)
    local coords = GetEntityCoords(GetPlayerPed(-1))
    local dist = #(coords - Config.VehShopCoords.coords)
    if dist < Config.VehShopCoords.radius then
        local hash = GetHashKey("GODzIMOLAVIP")
        if not IsModelInCdimage(hash) or testing then
            TriggerEvent('esx:showNotification', "Ez az autó nem tesztelhető!")
            return
        end
        while not HasModelLoaded(hash) do
            RequestModel(hash)
            Citizen.Wait(10)
        end
        local vehicle = CreateVehicle(hash, Config.TestCoords.x, Config.TestCoords.y, Config.TestCoords.z,
            Config.TestCoords.h, false, false)
        -- bc_kocsitorles: legalis spawn jelolese
        if vehicle and vehicle ~= 0 and NetworkGetEntityIsNetworked(vehicle) then Entity(vehicle).state:set('bc_spawned', true, true) end
        if vehicle and vehicle ~= 0 then TriggerEvent("bc:localVehSpawn", vehicle) end
        Citizen.Wait(1000)
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
        SetModelAsNoLongerNeeded(hash)
        ForceUseAudioGameObject(vehicle, data.soundid)
        local start = GetGameTimer()
        testing = true
        Citizen.CreateThread(function()
            while testing do
                Citizen.Wait(0)
                local rem = Config.TestTime - (GetGameTimer() - start)
                if rem <= 0 then
                    testing = false
                end
                if GetVehiclePedIsIn(GetPlayerPed(-1), false) ~= vehicle then
                    testing = false
                end
                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextCentre(1)
                BeginTextCommandDisplayText("STRING")
                AddTextComponentString("Hátra van ~g~" .. math.floor(rem / 1000) .. " mp")
                EndTextCommandDisplayText(0.5, 0.9)
            end
            ESX.Game.DeleteVehicle(vehicle)
            ESX.Game.Teleport(GetPlayerPed(-1), Config.VehShopCoords.coords)
        end)
    else
        TriggerEvent('esx:showNotification', "A tesztelés csak az Autóspiacról indítható!")
    end
    cb('ok')
end)

RegisterNUICallback('newchange', function(data, cb)
    local newsonstart = GetResourceKvpInt('bcnews')
    if newsonstart then
        if newsonstart == 1 then
            SetResourceKvpInt('bcnews', 2)
            TriggerEvent('esx:showNotification', "Hírek autómatikus megjelenítése kikapcsolva!")
        else
            SetResourceKvpInt('bcnews', 1)
            TriggerEvent('esx:showNotification', "Hírek autómatikus megjelenítése bekapcsolva!")
        end
    end
    cb('ok')
end)

function SetNUIState(state)
    SetNuiFocus(state, state)
    active = state
    SendNUIMessage({
        event = "show",
        enable = state
    })
end

function SetNUIValue(name, value)
    SendNUIMessage({
        event = "set",
        name = name,
        value = value
    })
end

local isvip = false
function UpdateCache()
    local time = GetGameTimer()
    if CacheTime.CharData == 0 or time > CacheTime.CharData + Config.CacheTimeout.CharData then
        ESX.TriggerServerCallback('villamos_ppshop:CharData', function(data)
            SetNUIValue('cahracterData', data)
            CacheTime.CharData = time
        end)
    end
    if CacheTime.PlayerData == 0 or time > CacheTime.PlayerData + Config.CacheTimeout.PlayerData then
        ESX.TriggerServerCallback('villamos_ppshop:PlayerData', function(data)
            SetNUIValue('playerData', data)
            CacheTime.PlayerData = time
        end)
    end
    if CacheTime.PremiumPoint == 0 or time > CacheTime.PremiumPoint + Config.CacheTimeout.PremiumPoint then
        ESX.TriggerServerCallback('villamos_ppshop:PremiumPoint', function(data)
            SetNUIValue('premiumPont', data)
            CacheTime.PremiumPoint = time
        end)
    end
    if CacheTime.Cars == 0 or time > CacheTime.Cars + Config.CacheTimeout.Cars then
        ESX.TriggerServerCallback('villamos_ppshop:Cars', function(data)
            for _, v in pairs(data) do
                v.model = GetDisplayNameFromVehicleModel(v.model)
            end
            SetNUIValue('cars', data)
            CacheTime.Cars = time
        end)
    end
    if CacheTime.Uptime == 0 or time > CacheTime.Uptime + Config.CacheTimeout.Uptime then
        ESX.TriggerServerCallback('villamos_ppshop:Uptime', function(data)
            local minutes = data % 60
            local hours = math.floor((data - minutes) / 60)
            SetNUIValue('playtime', hours .. "h " .. minutes .. "m")
            CacheTime.Uptime = time
        end)
    end
    -- Az árlista a kedvezményt is tartalmazza, ezért nyitáskor is frissítjük:
    -- e nélkül a spawn utáni egyetlen lekérés dönt egész sessionre.
    if CacheTime.PPItems == 0 or time > CacheTime.PPItems + Config.CacheTimeout.PPItems then
        CacheTime.PPItems = time
        RefreshPPItems()
    end
    if CacheTime.WeeklyDiscount == 0 or time > CacheTime.WeeklyDiscount + Config.CacheTimeout.WeeklyDiscount then
        CacheTime.WeeklyDiscount = time
        RefreshWeekly()
    end
    if CacheTime.OtherPlayerData == 0 or time > CacheTime.OtherPlayerData + Config.CacheTimeout.OtherPlayerData then
        -- A cache kulcsa: e nelkul a felteteles orokke igaz, es minden nyitott
        -- dashboard 2 mp-enkent (WhileOpenUpdateTick) lekeri a teljes
        -- jatekoslistat a szervertol (merve: 123-11512 valasz/frame). A PPItems
        -- mintajara a keres ELOTT allitjuk, igy futo keres alatt sem indul uj.
        CacheTime.OtherPlayerData = time
        ESX.TriggerServerCallback('villamos_ppshop:Players', function(otdata)
            SetNUIValue('players', otdata)
        end)
    end
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.TriggerServerCallback('villamos_ppshop:PlayerData', function(data)
        SetNUIValue('playerData', data)
    end)
end)

RegisterNetEvent('villamos_ppshop:UpdatePont')
AddEventHandler('villamos_ppshop:UpdatePont', function()
    ESX.TriggerServerCallback('villamos_ppshop:PremiumPoint', function(data)
        SetNUIValue('premiumPont', data)
    end)
end)

RegisterNetEvent('villamos_ppshop:newitems')
AddEventHandler('villamos_ppshop:newitems', function()
    -- Ez az esemeny MINDENKINEK megy (-1), es ilyenkor tenyleg valtozott a
    -- katalogus, tehat mindenki ujra le is tolti. Szetteritjuk par masodpercre,
    -- hogy ne egyetlen frame-ben kelljen N darab teljes listat szerializalni.
    CreateThread(function()
        Wait(math.random(0, 3000))
        RefreshPPItems()
    end)
end)

RegisterNetEvent('bc_ppshop:weeklyUpdated')
AddEventHandler('bc_ppshop:weeklyUpdated', function()
    -- mindenkinek megy (-1): szétterítjük, mint a newitems-t
    CreateThread(function()
        Wait(math.random(0, 3000))
        RefreshWeekly()
        CacheTime.WeeklyDiscount = GetGameTimer()
    end)
end)

RegisterNetEvent('villamos_ppshop:UpdateCars')
AddEventHandler('villamos_ppshop:UpdateCars', function()
    ESX.TriggerServerCallback('villamos_ppshop:Cars', function(data)
        for _, v in pairs(data) do
            v.model = GetDisplayNameFromVehicleModel(v.model)
        end
        SetNUIValue('cars', data)
        CacheTime.Cars = GetGameTimer()
    end)
end)

--[[RegisterNetEvent('villamos_ppshop:UpdatePlayers')
AddEventHandler('villamos_ppshop:UpdatePlayers', function(data)
	SetNUIValue('players', data)
end)]]

--[[RegisterNetEvent('villamos_ppshop:UpdateCounters')
AddEventHandler('villamos_ppshop:UpdateCounters', function(data)
	--SetNUIValue('counters', data)
	counters = data
end)]]

local ppmodel = `a_m_y_business_02`
local isBuying = false
local ppPed = nil
local ppPedCoords = vector4(121.99013, 6622.312, 30.833974, 224.50938)

CreateThread(function()
    Wait(10000)
    lib.zones.sphere({
        coords = vector3(ppPedCoords.x, ppPedCoords.y, ppPedCoords.z),
        radius = 50.0,
        onEnter = function()
            if not IsModelInCdimage(ppmodel) then
                print("FIGYELEM! Érvénytelen ped model hash: " .. ppmodel)
                return
            end

            RequestModel(ppmodel)
            while not HasModelLoaded(ppmodel) do
                Wait(1)
            end
            ppPed = CreatePed(1, ppmodel, ppPedCoords, false, false)
            PlaceObjectOnGroundProperly(ppPed)
            FreezeEntityPosition(ppPed, true)
            SetEntityInvincible(ppPed, true)
            SetBlockingOfNonTemporaryEvents(ppPed, true)
            TaskStartScenarioInPlace(ppPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
            SetModelAsNoLongerNeeded(ppmodel)

            exports.ox_target:addLocalEntity(ppPed, {
                {
                    name = 'silvervip_buy',
                    icon = 'fas fa-star',
                    label = '30 napos Silver VIP vásárlás - 7.500.000$',
                    distance = 2.5,
                    onSelect = function()
                        if isBuying then return end
                        isBuying = true
                        TriggerServerEvent("bc_ppshop:buySVIP")
                        Wait(7000)
                        isBuying = false
                    end,
                },
            })
        end,
        onExit = function()
            if ppPed and DoesEntityExist(ppPed) then
                exports.ox_target:removeLocalEntity(ppPed)
                DeleteEntity(ppPed)
                ppPed = nil
            end
        end,
    })
end)
