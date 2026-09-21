Rpc:Register('buy', function(data)
    TriggerServerEvent('bc_uwu:buy', data.item, data.npcKey, data.count, data.bankcard)
    return true
end)



Rpc:Register('buyMenu', function(data)
    TriggerServerEvent('bc_uwu:buyMenu', data.npcKey, data.menuItems, data.bankcard)
    return true
end)

Rpc:Register('exit', function()
    SetNuiFocus(false, false)
    return true
end)



-- License-hez kötött boltok (cfg.managerLicenses), amiknek a helyi játékos a kezelője:
-- npcKey -> true. A szervertől egyszer kérjük le (a license nem változik).
---@type table<string, boolean>|nil
local licenseManaged = nil

-- Ha a válasz nem érkezik meg (pl. a szerver-oldal még nem állt fel egy
-- resource-restartkor), újrapróbáljuk; addig a bolt csak a job-alapú
-- jogosultságot ismeri, a Kezelés gomb a válasz megérkezésekor jelenik meg.
---@return table<string, boolean>
local function fetchLicenseManaged()
    if licenseManaged then return licenseManaged end
    for _ = 1, 10 do
        local result = lib.callback.await('bc_uwu:getLicenseManaged', false)
        if type(result) == 'table' and type(result.managed) == 'table' then
            licenseManaged = result.managed
            return licenseManaged
        end
        Wait(2000)
    end
    licenseManaged = {}
    return licenseManaged
end

---@param cfg SellNPCEntry
---@return string
local function buyDenyMessage(cfg)
    return cfg.jobsDenyMessage or 'Nem vásárolhatsz ettől az eladótól!'
end

---Kezelőpult: license-hez kötött boltnál KIZÁRÓLAG a felsorolt license-ek
---(job/rang nem számít); egyébként CSAK a managerjob boss. A cfg.jobs frakciók
---csak vásárolhatnak, kezelni nem (a boss-uk sem).
---@param npcKey string
---@param cfg SellNPCEntry
---@return boolean
local function canPriceNpc(npcKey, cfg)
    if cfg.managerLicenses then
        return licenseManaged ~= nil and licenseManaged[npcKey] == true
    end
    local job = ESX and ESX.PlayerData and ESX.PlayerData.job
    if not job or job.grade_name ~= 'boss' then return false end
    return cfg.managerjob ~= nil and job.name == cfg.managerjob
end

---Vásárolhat-e: nincs cfg.jobs -> bárki; különben a felsorolt jobok (min. rang),
---a license-es kezelők, illetve a managerjob boss.
---@param npcKey string
---@param cfg SellNPCEntry
---@param job? table -- ha nincs megadva, ESX.PlayerData.job alapján dönt
---@return boolean
local function hasNpcAccess(npcKey, cfg, job)
    if not cfg.jobs then return true end
    job = job or (ESX and ESX.PlayerData and ESX.PlayerData.job)
    if job then
        local minGrade = cfg.jobs[job.name]
        if minGrade and (tonumber(job.grade) or 0) >= minGrade then return true end
    end
    if cfg.managerLicenses and licenseManaged and licenseManaged[npcKey] then return true end
    return job ~= nil and cfg.managerjob ~= nil and job.name == cfg.managerjob and job.grade_name == 'boss'
end

---Látszik-e az NPC: jobsDenyMessage-es (mindenkinek látható) boltnál mindig,
---különben csak a vásárlásra jogosultnak.
---@param npcKey string
---@param cfg SellNPCEntry
---@param job? table
---@return boolean
local function isNpcVisible(npcKey, cfg, job)
    if not cfg.jobs or cfg.jobsDenyMessage then return true end
    return hasNpcAccess(npcKey, cfg, job)
end

---@param npcKey string
---@return table
local function buildTargetOptions(npcKey)
    local cfg = Config.SellNPCs[npcKey]
    local settings = Config.Settings.target
    local options = {
        {
            name = settings.buy.name .. '_' .. npcKey,
            icon = settings.buy.icon,
            label = settings.buy.label,
            distance = settings.buy.distance,
            onSelect = function()
                -- a mindenkinek látható (jobsDenyMessage) NPC-nél itt szűrünk: a jogosulatlan az üzenetet kapja
                if not hasNpcAccess(npcKey, cfg) then
                    lib.notify({ description = buyDenyMessage(cfg), type = 'error', duration = 5000 })
                    return
                end
                OpenSellMenu(npcKey)
            end,
        },
    }
    if cfg.managerjob or cfg.managerLicenses then
        options[#options + 1] = {
            name = settings.manage.name .. '_' .. npcKey,
            icon = settings.manage.icon,
            label = settings.manage.label,
            distance = settings.manage.distance,
            onSelect = function()
                OpenManageMenu(npcKey)
            end,
            canInteract = function()
                return canPriceNpc(npcKey, cfg)
            end,
        }
        options[#options + 1] = {
            name = settings.contract.name .. '_' .. npcKey,
            icon = settings.contract.icon,
            label = settings.contract.label,
            distance = settings.contract.distance,
            onSelect = function()
                OpenContractMenu(npcKey)
            end,
        }
    end
    return options
end

local spawnedPeds = {}
local insideZones = {}

---@param npcKey string
---@param job? table
local function spawnNpc(npcKey, job)
    if spawnedPeds[npcKey] then return end
    local cfg = Config.SellNPCs[npcKey]
    if not isNpcVisible(npcKey, cfg, job) then return end
    if not IsModelInCdimage(cfg.model) then
        print("^1[bc_eladorendszer] Invalid ped model hash for NPC: " .. npcKey)
        return
    end
    RequestModel(cfg.model)
    while not HasModelLoaded(cfg.model) do
        Wait(1)
    end
    local ped = CreatePed(1, cfg.model, cfg.coords, cfg.heading, false, false)
    PlaceObjectOnGroundProperly(ped)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, Config.Settings.npcScenario, 0, true)
    SetModelAsNoLongerNeeded(cfg.model)
    exports.ox_target:addLocalEntity(ped, buildTargetOptions(npcKey))
    spawnedPeds[npcKey] = ped
end

---@param npcKey string
local function deleteNpc(npcKey)
    local ped = spawnedPeds[npcKey]
    if ped then
        exports.ox_target:removeLocalEntity(ped)
        DeleteEntity(ped)
        spawnedPeds[npcKey] = nil
    end
end

-- A license-es kezelői jogokat egyszer, a háttérben kérjük le. Külön szálon fut,
-- hogy egy elakadt válasz se késleltethesse a zónák (és így az NPC-k) létrehozását.
CreateThread(function()
    for _, cfg in pairs(Config.SellNPCs) do
        if cfg.managerLicenses then
            Wait(Config.Settings.spawnDelay)
            fetchLicenseManaged()
            return
        end
    end
end)

CreateThread(function()
    Wait(Config.Settings.spawnDelay)
    for npcKey, cfg in pairs(Config.SellNPCs) do
        lib.zones.sphere({
            coords = cfg.coords,
            radius = 30.0,
            onEnter = function()
                insideZones[npcKey] = true
                spawnNpc(npcKey)
            end,
            onExit = function()
                insideZones[npcKey] = nil
                deleteNpc(npcKey)
            end,
        })
    end
end)

---@param job? table
local function refreshRestrictedNpcs(job)
    for npcKey in pairs(insideZones) do
        local cfg = Config.SellNPCs[npcKey]
        if cfg.jobs then
            if isNpcVisible(npcKey, cfg, job) then
                spawnNpc(npcKey, job)
            else
                deleteNpc(npcKey)
            end
        end
    end
end

RegisterNetEvent('esx:setJob', function(job)
    refreshRestrictedNpcs(job)
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    refreshRestrictedNpcs(xPlayer and xPlayer.job or nil)
    fetchLicenseManaged() -- cache-elt, a második hívástól kezdve azonnal visszatér
end)

---@param npc string
function OpenManageMenu(npc)
    local cfg = Config.SellNPCs[npc]
    if not canPriceNpc(npc, cfg) then
        lib.notify({ description = 'Nincs jogosultságod a kezelőpult megnyitásához!', type = 'error', duration = 4000 })
        return
    end
    local oxItems     = exports.ox_inventory:Items()
    local extraprices = lib.callback.await('bc_uwu:geteprices', false)
    local menuResult  = lib.callback.await('bc_uwu:getMenuData', false, npc)

    local allItems    = {}
    for k, v in pairs(cfg.items) do
        local meta = oxItems[k]
        allItems[#allItems + 1] = {
            name         = k,
            label        = meta and meta.label or k,
            defaultPrice = v,
            currentPrice = (extraprices and extraprices[npc .. '_' .. k]) or v,
        }
    end

    Rpc:Send('openManage', {
        npcKey       = npc,
        npcLabel     = cfg.label,
        allItems     = allItems,
        menus        = menuResult and menuResult.menus or {},
        activeMenuId = menuResult and menuResult.activeMenuId or nil,
    })
    SetNuiFocus(true, true)
end

---@param npc string
function OpenContractMenu(npc)
    local cfg = Config.SellNPCs[npc]
    Rpc:Send('openContract', {
        npcKey   = npc,
        npcLabel = cfg.label,
    })
    SetNuiFocus(true, true)
end

---@param npc string
function OpenSellMenu(npc)
    local cfg         = Config.SellNPCs[npc]
    local oxItems     = exports.ox_inventory:Items()
    local extraprices = lib.callback.await('bc_uwu:geteprices', false)
    local activeMenu  = lib.callback.await('bc_uwu:getActiveMenu', false, npc)
    local menuResult  = lib.callback.await('bc_uwu:getMenuData', false, npc)
    local npclabel  = lib.callback.await('bc_uwu:getlabel', false, cfg.managerjob)

    local shopItems   = {}

    if activeMenu then
        for _, mi in ipairs(activeMenu.items) do
            if cfg.items[mi.name] then
                local price               = (extraprices and extraprices[npc .. '_' .. mi.name]) or cfg.items[mi.name]
                local meta                = oxItems[mi.name]
                shopItems[#shopItems + 1] = {
                    name        = mi.name,
                    label       = meta and meta.label or mi.name,
                    description = meta and meta.description or nil,
                    price       = price,
                    quantity    = mi.quantity,
                }
            end
        end
    else
        for k, v in pairs(cfg.items) do
            local price               = (extraprices and extraprices[npc .. '_' .. k]) or v
            local meta                = oxItems[k]
            shopItems[#shopItems + 1] = {
                name        = k,
                label       = meta and meta.label or k,
                description = meta and meta.description or nil,
                price       = price,
            }
        end
    end

    local shopMenus = {}
    if menuResult and menuResult.menus then
        for _, menu in ipairs(menuResult.menus) do
            local totalPrice = 0
            local menuItems  = {}
            for _, mi in ipairs(menu.items) do
                if cfg.items[mi.name] then
                    local price               = (extraprices and extraprices[npc .. '_' .. mi.name]) or
                        cfg.items[mi.name]
                    local meta                = oxItems[mi.name]
                    totalPrice                = totalPrice + (price * mi.quantity)
                    menuItems[#menuItems + 1] = {
                        name     = mi.name,
                        label    = meta and meta.label or mi.name,
                        quantity = mi.quantity,
                        price    = price,
                    }
                end
            end
            if #menuItems > 0 then
                shopMenus[#shopMenus + 1] = {
                    id         = menu.id,
                    name       = menu.name,
                    items      = menuItems,
                    totalPrice = totalPrice,
                    daily      = menu.daily or false,
                    activeFrom = menu.activeFrom,
                    activeTo   = menu.activeTo,
                }
            end
        end
    end

    Rpc:Send('openShop', {
        npcKey = npc,
        label  = (npclabel or cfg.label),
        items  = shopItems,
        menus  = shopMenus,
    })
    SetNuiFocus(true, true)
end
