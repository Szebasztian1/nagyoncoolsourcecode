-- ============================================================
--  HASZNÁLTOK - KLIENS
--   * Megnyitás parancs / billentyű / tárgy.
--   * NUI <-> szerver híd ESX callbackeken (nincs felesleges net event).
--   * owned_vehicles -> JÁTÉKBELI név (nem valós márka) feloldás kliensoldalon.
--   * (16) fMass olvasás, ha a játékos a kiválasztott autóban ül.
--   * In-game screenshot a screenshot-basic + fivemanage segítségével.
-- ============================================================

local ESX = exports['es_extended']:getSharedObject()
local isOpen = false

local function trim(s) return type(s) == 'string' and (s:gsub('^%s+', ''):gsub('%s+$', '')) or s end

-- model hash -> "Márka Modell" játékbeli címke (NEM valós márkanév) (3)(12)
local function vehLabel(model)
    if not model then return nil end
    model = math.floor(model + 0.0)
    -- addon/streamelt modelleknél is a display nevet próbáljuk (az IsModelInCdimage nem feltétel)
    local disp = GetDisplayNameFromVehicleModel(model)
    if not disp or disp == '' or disp == 'CARNOTFOUND' then return nil end
    local modelLbl = GetLabelText(disp)
    if not modelLbl or modelLbl == 'NULL' or modelLbl == '' then modelLbl = disp end
    local makeKey = GetMakeNameFromVehicleModel(model)
    local makeLbl = makeKey and makeKey ~= '' and GetLabelText(makeKey) or nil
    if makeLbl == 'NULL' then makeLbl = nil end
    if makeLbl and makeLbl ~= '' then return trim(makeLbl .. ' ' .. modelLbl) end
    return modelLbl
end

local function spawnName(model)
    if not model then return nil end
    return GetDisplayNameFromVehicleModel(math.floor(model + 0.0))
end

-- (16) a játékos aktuális járműve (rendszám + fMass), ha ül valamiben
local function currentVehicleInfo()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return nil end
    return {
        plate = trim(GetVehicleNumberPlateText(veh)),
        mass  = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fMass'),
    }
end

local function openApp()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)
    -- Minden statikus config-adat egyszerre megy ki nyitáskor.
    -- A szerver getState-ben lévő cfg blokk is ugyanezt csinálja az iframe-módhoz
    -- (ahol nincs 'open' üzenet Lua-ból). Így standalone módban CFG teljes lesz boot() előtt.
    SendNUIMessage({ action = 'open', config = {
        categories     = Config.Categories,
        promoPrice     = Config.PromoWeeklyPrice,
        maxWeeks       = Config.MaxPromoWeeks,
        maxImages      = Config.MaxImages,
        accessPrice    = Config.AccessWeeklyPrice,
        maxDesc        = Config.MaxDescription,
        maxReview      = Config.MaxReviewLength,
        phoneRes       = Config.Phone.Resource,
        massCategories = Config.MassCategories,   -- [[min,max,key,label],...] → massCatLabel() JS helper
        tiers          = Config.Tiers,            -- tagság szintek → renderMembership()
        tasks          = Config.Tasks,            -- feladatok → renderMembership()
        points         = Config.Points,           -- pont-értékek → renderMembership()
    }})
end

local function closeApp()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

-- ---------- Megnyitás ----------
if Config.Command then
    RegisterCommand(Config.Command, function() openApp() end, false)
    if Config.UseKeyMapping then
        RegisterKeyMapping(Config.Command, 'Használtautó megnyitása', 'keyboard', Config.OpenKey)
    end
end
if Config.OpenItem then
    RegisterNetEvent('autosapp:client:openFromItem', function() openApp() end)
end
exports('open', openApp)

-- ---------- NUI <-> szerver híd ----------
local function bridge(nuiName, cbName, ...)
    local keys = { ... }
    RegisterNUICallback(nuiName, function(data, cb)
        local args = {}
        for i = 1, #keys do args[i] = data and data[keys[i]] end
        ESX.TriggerServerCallback(cbName, function(r) cb(r or false) end, table.unpack(args, 1, #keys))
    end)
end

bridge('getState',     'autosapp:getState')
bridge('buyAccess',    'autosapp:buyAccess')
bridge('getMembership','autosapp:getMembership')
bridge('getCars',      'autosapp:getCars',      'filter')
bridge('getCar',       'autosapp:getCar',       'id')
bridge('getMyCars',    'autosapp:getMyCars')
bridge('getFavorites', 'autosapp:getFavorites')
bridge('getContact',   'autosapp:getContact',   'id')
bridge('createCar',    'autosapp:createCar',    'car')   -- megj.: a teljes objektum a 'car' kulcson
bridge('toggleLike',   'autosapp:toggleLike',   'id')
bridge('toggleFavorite','autosapp:toggleFavorite','id')
bridge('markSold',     'autosapp:markSold',     'id', 'sold')
bridge('deleteCar',    'autosapp:deleteCar',    'id')
bridge('promote',      'autosapp:promote',      'id', 'weeks')
bridge('cancelPromo',  'autosapp:cancelPromo',  'id')
-- Eladói profil + értékelés
bridge('getProfileByCar',  'autosapp:getProfileByCar', 'id')
bridge('getMyProfile',     'autosapp:getMyProfile')
bridge('submitReview',     'autosapp:submitReview',    'id', 'rating', 'comment')
bridge('deleteMyReview',   'autosapp:deleteMyReview',  'id')
bridge('adminDeleteReview','autosapp:adminDeleteReview','reviewId', 'id')
bridge('adminClearProfile','autosapp:adminClearProfile','id')

-- (12) owned_vehicles + kliensoldali név/fMass feloldás
RegisterNUICallback('getMyVehicles', function(_, cb)
    ESX.TriggerServerCallback('autosapp:getMyVehicles', function(r)
        if r and r.vehicles then
            local cur = currentVehicleInfo()
            for _, v in ipairs(r.vehicles) do
                v.label     = vehLabel(v.model) or ('Jármű ' .. (v.plate or ''))
                v.spawnName = spawnName(v.model)
                if cur and cur.plate == v.plate then
                    v.inside = true
                    v.mass = cur.mass
                end
            end
            r.current = cur
        end
        cb(r or false)
    end)
end)

RegisterNUICallback('close', function(_, cb) closeApp(); cb(true) end)

-- ---------- In-game fotó (screenshot-basic + fivemanage) (6) ----------
RegisterNUICallback('takePhoto', function(_, cb)
    if Config.Fivemanage.ApiKey == '' then
        return cb({ ok = false, msg = 'Hiányzik a fivemanage API kulcs (config.lua).' })
    end
    SendNUIMessage({ action = 'hideForPhoto' })
    -- A fókuszhoz CSAK standalone módban nyúlunk. A RoadPhone telefonban (isOpen=false)
    -- a telefon birtokolja a NUI fókuszt — ha mi is SetNuiFocus-t hívnánk, eltörnénk
    -- a telefon fókuszát, és a fotó után minden befagyna.
    if isOpen then SetNuiFocus(false, false) end
    Wait(Config.PhotoHideDelayMs)

    exports['screenshot-basic']:requestScreenshotUpload(Config.Fivemanage.Url, 'file', {
        headers = { Authorization = Config.Fivemanage.ApiKey }
    }, function(data)
        local url
        local ok, resp = pcall(json.decode, data)
        if ok and resp then url = resp.url or (resp.data and resp.data.url) end
        if isOpen then SetNuiFocus(true, true) end
        SendNUIMessage({ action = 'showAfterPhoto' })
        cb({ ok = url ~= nil, url = url })
    end)
end)

-- ---------- Push értesítés (szerverről) ----------
RegisterNetEvent('autosapp:client:notify', function(title, text)
    local ok = pcall(function()
        TriggerEvent('roadphone:sendNotification', {
            apptitle = Config.Phone.SystemNumber or 'Használtautó',
            title    = title or 'Használtautó',
            message  = text,
            img      = '/public/img/Apps/light_mode/hasznaltauto.svg'
        })
    end)

    if not ok then
        ESX.ShowNotification(('%s: %s'):format(title or 'Használtautó', text or ''))
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and isOpen then SetNuiFocus(false, false) end
end)
