local Config = require("lua.shared.Config")
local eStorageUnit = require("lua.shared.enums.eStorageUnit")
local ePermission = require("lua.shared.enums.ePermission")
local InstanceTimecycleService = require("lua.client.Instance.InstanceTimecycleService")
local InstanceService = require("lua.client.Instance.InstanceService")
local InstancePresenceService = require("lua.client.Instance.InstancePresenceService")
local InstanceCheckerService = require("lua.client.Instance.InstanceCheckerService")
local CompostService = require("lua.client.Compost.CompostService")
local PitchforkService = require("lua.client.Pitchfork.PitchforkService")
local PitchforkStateService = require("lua.client.Pitchfork.PitchforkStateService")
local StorageService = require("lua.client.Storage.StorageService")
local WarehouseService = require("lua.client.Warehouse.WarehouseService")
local WaterTroughService = require("lua.client.WaterTrough.WaterTroughService")
local FoodTroughService = require("lua.client.FoodTrough.FoodTroughService")
local WatertipService = require("lua.client.Watertip.WatertipService")
local TileService = require("lua.client.Tile.TileService")
local LivestockService = require("lua.client.Livestock.LivestockService")
local ComputerService = require("lua.client.Computer.ComputerService")
local BucketService = require("lua.client.Bucket.BucketService")
local BucketStateService = require("lua.client.Bucket.BucketStateService")
local StrawService = require("lua.client.Straw.StrawService")
local InstanceEntranceService = require("lua.client.Instance.InstanceEntranceService")
local LobbyService = require("lua.client.Lobby.LobbyService")

-- Registering & Loading the DrawSprite txd textures
local txd = CreateRuntimeTxd("aquiver_farmhouse")
CreateRuntimeTextureFromImage(txd, "cog_roll", "txd/cog_roll.png")
CreateRuntimeTextureFromImage(txd, "farmhouse", "txd/farmhouse.png")
CreateRuntimeTextureFromImage(txd, "use", "txd/use.png")
CreateRuntimeTextureFromImage(txd, "computer", "txd/computer.png")
CreateRuntimeTextureFromImage(txd, "water_drop_icon", "txd/water_drop_icon.png")
CreateRuntimeTextureFromImage(txd, "composter", "txd/composter.png")
-------------------------------

-- Main initialization
Citizen.CreateThread(function()
    lib.locale()

    AddTextEntry("BLIP_CAT_" .. Config.BLIP_CATEGORY_ID, locale("BLIP_CATEGORY_NAME"))

    InstanceService:fetch()

    LobbyService:onResourceStart()
end)

local Application = {}
Application._ambientSoundId = -1

---@param instance IFarmhouse
function Application:onEnteringInstance(instance)
    lib.requestAudioBank("audiodirectory/aquiver_farmhouse_sounds", 5000)

    self:playAmbientSound()

    InstanceTimecycleService:onEnteringInstance()
    InstanceCheckerService:onEnteringInstance()
    CompostService:onEnteringInstance()
    PitchforkService:onEnteringInstance()
    StorageService:onEnteringInstance()
    WarehouseService:onEnteringInstance()
    WaterTroughService:onEnteringInstance()
    FoodTroughService:onEnteringInstance()
    WatertipService:onEnteringInstance()
    TileService:onEnteringInstance()
    LivestockService:onEnteringInstance()
    ComputerService:onEnteringInstance()
    BucketService:onEnteringInstance()
    StrawService:onEnteringInstance()

    local entity = InstanceService:get(instance.id)
    if entity then
        InstanceEntranceService:createExit(entity)
    end
end

function Application:onLeavingInstance(house)
    ReleaseNamedScriptAudioBank("audiodirectory/aquiver_farmhouse_sounds")

    self:stopAmbientSound()

    InstanceTimecycleService:onLeavingInstance()
    InstanceCheckerService:onLeavingInstance()
    CompostService:onLeavingInstance()
    PitchforkService:onLeavingInstance()
    StorageService:onLeavingInstance()
    WarehouseService:onLeavingInstance()
    WaterTroughService:onLeavingInstance()
    FoodTroughService:onLeavingInstance()
    WatertipService:onLeavingInstance()
    TileService:onLeavingInstance()
    LivestockService:onLeavingInstance()
    ComputerService:onLeavingInstance()
    BucketService:onLeavingInstance()
    StrawService:onLeavingInstance()

    InstanceEntranceService:removeExit()
end

function Application:playAmbientSound()
    if self._ambientSoundId ~= -1 then return end

    self._ambientSoundId = GetSoundId()

    PlaySoundFrontend(self._ambientSoundId, "animal_farm_ambient", "aquiver_farmhouse_sounds", false)
end

function Application:stopAmbientSound()
    if self._ambientSoundId == -1 then return end

    StopSound(self._ambientSoundId)
    self._ambientSoundId = -1
end

RegisterNuiCallback("NUI::Mounted", function(_, cb)
    SendNUIMessage({
        eventName = "Locale:Set",
        args = { lib.getLocales() }
    })

    cb("ok")
end)

lib.callback.register("Farmhouse::EnteringTransition", function()
    SetPlayerControl(PlayerId(), false, 0)

    SetEntityVisible(PlayerPedId(), false, false)

    --DoScreenFadeOut(500)

    --while not IsScreenFadedOut() do
    --    Citizen.Wait(0)
    --end

    if GetResourceState("rota_loading") == "started" then 
        exports["rota_loading"]:LoadingShow(700, "Betöltés a farmra...", true)
    end

    Citizen.Wait(1500)

    --DoScreenFadeIn(3000)
    if GetResourceState("rota_loading") == "started" then 
        exports["rota_loading"]:LoadingHide(3000)
    end 

    SetPlayerControl(PlayerId(), true, 0)

    SetEntityVisible(PlayerPedId(), true, true)

    return true
end)

RegisterNetEvent("Farmhouse::Create", function(...)
    InstanceService:create(...)
end)

RegisterNetEvent("Farmhouse::OnEnteringInstance", function(...)
    Application:onEnteringInstance(...)
end)
RegisterNetEvent("Farmhouse::OnLeavingInstance", function(...)
    Application:onLeavingInstance(...)
end)

RegisterNetEvent("Farmhouse::Presence::SetState", function(...)
    InstancePresenceService:set(...)
end)

RegisterNetEvent("Farmhouse::Warehouse::Create", function(...)
    WarehouseService:create(...)
end)
RegisterNetEvent("Farmhouse::Storage::Create", function(...)
    StorageService:create(...)
end)
RegisterNetEvent("Farmhouse::Pitchfork::Create", function(...)
    PitchforkService:create(...)
end)
RegisterNetEvent("Farmhouse::Compost::Create", function(...)
    CompostService:create(...)
end)
RegisterNetEvent("Farmhouse::WaterTrough::Create", function(...)
    WaterTroughService:create(...)
end)
RegisterNetEvent("Farmhouse::FoodTrough::Create", function(...)
    FoodTroughService:create(...)
end)
RegisterNetEvent("Farmhouse::WaterTip::Create", function(...)
    WatertipService:create(...)
end)
RegisterNetEvent("Farmhouse::Tile::Create", function(...)
    TileService:create(...)
end)
RegisterNetEvent("Farmhouse::Livestock::Create", function(...)
    LivestockService:create(...)
end)
RegisterNetEvent("Farmhouse::Bucket::Create", function(...)
    BucketService:create(...)
end)
RegisterNetEvent("Farmhouse::Pitchfork::Set", function(...)
    PitchforkStateService:set(...)
end)
RegisterNetEvent("Farmhouse::Pitchfork::Clear", function()
    PitchforkStateService:clear()
end)
RegisterNetEvent("Farmhouse::Bucket::Set", function(...)
    BucketStateService:set(...)
end)
RegisterNetEvent("Farmhouse::Bucket::Clear", function()
    BucketStateService:clear()
end)
RegisterNetEvent("Farmhouse::Straw::Create", function(...)
    StrawService:create(...)
end)

-- Nui callbacks
RegisterNuiCallback("Farmhouse::Fetch", function(data, cb)
    cb(lib.callback.await("Farmhouse::Fetch"))
end)
RegisterNuiCallback("Warehouse::Fetch", function(data, cb)
    cb(lib.callback.await("Warehouse::Fetch"))
end)
RegisterNuiCallback("Storage::Fetch", function(data, cb)
    cb(lib.callback.await("Storage::Fetch"))
end)
RegisterNuiCallback("Livestock::Fetch", function(data, cb)
    cb(lib.callback.await("Livestock::Fetch"))
end)
RegisterNuiCallback("Compost::Fetch", function(data, cb)
    cb(lib.callback.await("Compost::Fetch"))
end)
RegisterNuiCallback("Compost::FetchCompostPrice", function(data, cb)
    cb(Config.COMPOST_PRICE)
end)
RegisterNuiCallback("Storage::FetchPrice", function(data, cb)
    cb({
        [eStorageUnit.EGG] = Config.EGG_PRICE,
        [eStorageUnit.MILK] = Config.MILK_PRICE
    })
end)
RegisterNuiCallback("Shop::GetEntities", function(data, cb)
    cb(lib.callback.await("Shop::GetEntities"))
end)
RegisterNuiCallback("Farmhouse::Shop::Purchase", function(data, cb)
    cb(lib.callback.await("Farmhouse::Shop::Purchase", false, data))
end)
RegisterNuiCallback("LivestockShop::GetMany", function(data, cb)
    cb(lib.callback.await("LivestockShop::GetMany"))
end)
RegisterNuiCallback("LivestockShop::Purchase", function(data, cb)
    cb(lib.callback.await("LivestockShop::Purchase", false, data))
end)
RegisterNuiCallback("LivestockService::Sell", function(data, cb)
    cb(lib.callback.await("LivestockService::Sell", false, data))
end)
RegisterNuiCallback("LivestockShop::GetRestockAt", function(data, cb)
    cb(lib.callback.await("LivestockShop::GetRestockAt", false))
end)
RegisterNuiCallback("Farmhouse::Permission::Fetch", function(data, cb)
    cb(lib.callback.await("Farmhouse::Permission::Fetch"))
end)
RegisterNuiCallback("Farmhouse::Permission::RemoveUser", function(data, cb)
    cb(lib.callback.await("Farmhouse::Permission::RemoveUser", false, data))
end)
RegisterNuiCallback("Farmhouse::Permission::ToggleUserPermission", function(data, cb)
    cb(lib.callback.await("Farmhouse::Permission::ToggleUserPermission", false, data.identifier, data.permission))
end)
RegisterNuiCallback("Farmhouse::SellStorage", function(data, cb)
    cb(lib.callback.await("Farmhouse::SellStorage", false, data.id, data.quantity))
end)
RegisterNuiCallback("Farmhouse::SellCompost", function(data, cb)
    cb(lib.callback.await("Farmhouse::SellCompost", false, data.id, data.quantity))
end)
RegisterNuiCallback("Farmhouse::Permission::AddUser", function(data, cb)
    cb(lib.callback.await("Farmhouse::Permission::AddUser", false, data))
end)
RegisterNuiCallback("Farmhouse::Permissions::Fetch", function(data, cb)
    cb(ePermission)
end)
RegisterNuiCallback("Farmhouse::Lobby::OnMounted", function(_, cb)
    LobbyService:onMounted()
    cb("ok")
end)
RegisterNuiCallback("Farmhouse::Lobby::OnUnmounted", function(_, cb)
    LobbyService:onUnmounted()
    cb("ok")
end)

RegisterNuiCallback("Farmhouse::Lobby::GetMany", function(_, cb)
    cb(lib.callback.await("Farmhouse::Lobby::GetMany", false))
end)
RegisterNuiCallback("Farmhouse::Purchase", function(data, cb)
    cb(lib.callback.await("Farmhouse::Purchase", false, data.id))
end)
RegisterNuiCallback("Farmhouse::ChangeLockState", function(data, cb)
    cb(lib.callback.await("Farmhouse::ChangeLockState", false, data.id))
end)
RegisterNuiCallback("Farmhouse::Entering", function(data, cb)
    cb(lib.callback.await("Farmhouse::Entering", false, data.id))
end)
