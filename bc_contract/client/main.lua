--local mejobs = {"mechanic", "kingmaffia", "lifthouse", "themetalshop", "blackmamba", "exotic", "lostmc", "ujfrakciodawe3", "bennysservice", "alkaida", "exotic", "topgear", "sonsofanarchy"}
local mejobs = {}

-- ===================== Papír szerződés (web/contract) =====================
-- A korábbi lib.inputDialog / lib.alertDialog helyett egy aláírandó irat nyílik.
-- OpenContractDocument blokkol (Citizen.Await), amíg a játékos alá nem írja vagy el nem utasítja.

local contractPromise = nil

---@param text any
---@param maxChars number
---@return string
local function ClampText(text, maxChars)
    if type(text) ~= "string" then return "" end
    local len = utf8.len(text)
    if not len then return text:sub(1, maxChars) end
    if len <= maxChars then return text end
    return text:sub(1, utf8.offset(text, maxChars + 1) - 1)
end

---@param nameOrHash string|number modell hash vagy megjelenítési név
---@return string
local function VehicleLabel(nameOrHash)
    local name = type(nameOrHash) == "number" and GetDisplayNameFromVehicleModel(nameOrHash) or tostring(nameOrHash or "")
    local label = GetLabelText(name)
    if label and label ~= "NULL" then
        return label
    end
    return name
end

---@param result table|nil
local function CloseContractDocument(result)
    local p = contractPromise
    contractPromise = nil
    SendNUIMessage({ action = "bcc:close" })
    SetNuiFocus(false, false)
    if p then
        p:resolve(result)
    end
end

---@param mode "seller"|"buyer"
---@param doc table
---@return table|nil a kitöltött / aláírt adatok, nil ha elutasította vagy bezárta
local function OpenContractDocument(mode, doc)
    if contractPromise then
        -- egy korábban nyitva hagyott szerződés elutasítottnak számít
        local previous = contractPromise
        contractPromise = nil
        previous:resolve(nil)
    end
    local p = promise.new()
    contractPromise = p
    SendNUIMessage({ action = "bcc:open", data = { mode = mode, doc = doc } })
    SetNuiFocus(true, true)
    return Citizen.Await(p)
end

RegisterNUICallback("bccSubmit", function(data, cb)
    cb({ ok = true })
    CloseContractDocument(type(data) == "table" and data or nil)
end)

RegisterNUICallback("bccCancel", function(_, cb)
    cb({ ok = true })
    CloseContractDocument(nil)
end)

RegisterNetEvent("bc_contract:use", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or not DoesEntityExist(veh) then
        return ESX.ShowNotification("Ülj be az autóba amit át szeretnél ruházni")
    end
    local ismechanic = false
    for _, job in pairs(mejobs) do
        if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == job then
            ismechanic = true
            break
        end
    end
    local mycoords = GetEntityCoords(ped)
    if not Config.Debug and #(mycoords - vector3(-786.4081, -2389.731, 14.570746)) > 130 and not ismechanic then
        return ESX.ShowNotification("Csak az autópiacnál lehet átírni autót!")
    end
    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(veh))
    local model = GetEntityModel(veh)

    local elements = {
        {
            unselectable = true,
            title = "Autó átruházása"
        },
        {
            title = "Átírás a legközelebb álló játékosra (frakciós autónál nem lehetséges)",
            value = "toplayer"
        },
        {
            title = "Átírás frakció névre (csak általad birtokolt autónál lehetséges)",
            value = "tofaction"
        }
    }

    if ESX.PlayerData.job.name and Config.ResellFactions[ESX.PlayerData.job.name] then
        for _, v in pairs(Config.ResellFactions[ESX.PlayerData.job.name]) do
            if v == model then
                elements[#elements + 1] = {
                    title = "Átírás játékos névre, szerelőtelepi autó eladása esetén",
                    value = "toresell"
                }
                break
            end
        end
    end

    ESX.OpenContext("right", elements, function(menu, element)
        ESX.CloseContext()
        local data = { current = element }
        if data.current.value == "toplayer" then
            local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer() -- GetPlayerServerId(closestPlayer)
            if closestPlayer == -1 or playerDistance > 3.0 then
                return ESX.ShowNotification("Nincs senki a közeledben!")
            end
            ESX.OpenContext("right", {
                {
                    unselectable = true,
                    title = "Biztosan átírod az autót (" ..
                        plate .. ") " .. GetPlayerName(closestPlayer) .. " (" ..
                        GetPlayerServerId(closestPlayer) .. ") nevére?"
                },
                {
                    title = "Igen",
                    value = "yes"
                },
                {
                    title = "Nem",
                    value = "no"
                },
            }, function(menu, element)
                ESX.CloseContext()
                local data = { current = element }
                if data.current.value == "yes" then
                    -- Scan vehicles within 25m and check which ones belong to the buyer
                    local mycoords = GetEntityCoords(ped)
                    local nearbyVehicleData = {}
                    for _, entry in ipairs(lib.getNearbyVehicles(mycoords, 25.0, true)) do
                        local v = entry.vehicle
                        local vcoords = entry.coords
                        local dist = #(mycoords - vcoords)
                        local vplate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
                        if vplate and vplate ~= "" and vplate ~= plate then
                            local vmodel = GetEntityModel(v)
                            local vhdata = GetVehicleHandlingFloat(v, "CHandlingData", "fInitialDriveForce")
                            table.insert(nearbyVehicleData, {
                                plate = vplate,
                                model = GetDisplayNameFromVehicleModel(vmodel),
                                dist = math.floor(dist * 10) / 10,
                                hardHandling = (vhdata > 0.85)
                            })
                        end
                    end

                    -- Ask server which of these are owned by the buyer
                    local buyerServerId = GetPlayerServerId(closestPlayer)
                    local buyerVehResult = Rpc:CallServer("bc_contract:getBuyerVehicles", {
                        target = buyerServerId,
                        vehicles = nearbyVehicleData
                    })

                    local multiOptions = {}
                    local buyerVehicleMap = {}
                    if buyerVehResult and buyerVehResult.success and buyerVehResult.data then
                        for _, v in ipairs(buyerVehResult.data) do
                            table.insert(multiOptions, {
                                value = v.plate,
                                label = v.plate ..
                                " (" ..
                                v.model .. ") - " .. v.dist .. "m" .. (v.hardHandling and " [ERŐS HANDLING]" or "")
                            })
                            buyerVehicleMap[v.plate] = v
                        end
                    end

                    if #nearbyVehicleData == 0 then
                        ESX.ShowNotification("Nincs közelben lévő jármű")
                    elseif #multiOptions == 0 then
                        ESX.ShowNotification("Nincs közelben lévő jármű a vevőnek")
                    end

                    -- Papír szerződés a korábbi lib.inputDialog('Autó átadása') helyett
                    local exchangeOptions = {}
                    for _, option in ipairs(multiOptions) do
                        local vData = buyerVehicleMap[option.value]
                        exchangeOptions[#exchangeOptions + 1] = {
                            plate        = vData.plate,
                            model        = VehicleLabel(vData.model),
                            dist         = vData.dist,
                            hardHandling = vData.hardHandling
                        }
                    end

                    local signed = OpenContractDocument("seller", {
                        plate      = plate,
                        model      = VehicleLabel(model),
                        sellerName = (buyerVehResult and buyerVehResult.sellerName) or GetPlayerName(PlayerId()),
                        buyerName  = (buyerVehResult and buyerVehResult.buyerName) or GetPlayerName(closestPlayer),
                        exchange   = exchangeOptions
                    })
                    if not signed then return end

                    local reason = ClampText(signed.reason, 200)
                    if utf8.len(reason) == nil or utf8.len(reason) < 4 then
                        return ESX.ShowNotification('Az átruházás indokát kötelező kitölteni!')
                    end
                    local input          = { reason }
                    local bankAmount     = math.min(math.max(math.floor(tonumber(signed.bank) or 0), 0), 10000000000)
                    local ppAmount       = math.max(math.floor(tonumber(signed.pp) or 0), 0)

                    local selectedPlates = {}
                    if type(signed.exchange) == "table" then
                        for _, selPlate in ipairs(signed.exchange) do
                            if type(selPlate) == "string" then
                                selectedPlates[#selectedPlates + 1] = selPlate
                            end
                        end
                    end

                    if bankAmount <= 0 and ppAmount <= 0 and #selectedPlates == 0 then
                        return ESX.ShowNotification('Adj meg legalább egy összeget ($ vagy PP) vagy autót cserébe!')
                    end

                    -- Build exchange vehicle list with handling info
                    local exchangeVehicles = {}
                    local hasExchangeHardHandling = false
                    for _, selPlate in ipairs(selectedPlates) do
                        local vData = buyerVehicleMap[selPlate]
                        if vData then
                            table.insert(exchangeVehicles, {
                                plate        = vData.plate,
                                model        = vData.model,
                                hardHandling = vData.hardHandling
                            })
                            if vData.hardHandling then
                                hasExchangeHardHandling = true
                            end
                        end
                    end

                    local hdata = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce")
                    TriggerServerEvent("bc_contract:setplayer", plate, GetPlayerServerId(closestPlayer),
                        GetDisplayNameFromVehicleModel(model), input[1], bankAmount, ppAmount,
                        (hdata > 0.85 or hasExchangeHardHandling), exchangeVehicles, signed.signature)
                    return
                end
            end)
        elseif data.current.value == "toresell" then
            local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer() -- GetPlayerServerId(closestPlayer)
            if closestPlayer == -1 or playerDistance > 3.0 then
                return ESX.ShowNotification("Nincs senki a közeledben!")
            end
            ESX.OpenContext("right", {
                {
                    unselectable = true,
                    title = "Biztosan átírod az autót (" ..
                        plate .. ") " .. GetPlayerName(closestPlayer) .. " (" ..
                        GetPlayerServerId(closestPlayer) .. ") nevére?"
                },
                {
                    title = "Igen",
                    value = "yes"
                },
                {
                    title = "Nem",
                    value = "no"
                },
            }, function(menu, element)
                ESX.CloseContext()
                local data = { current = element }
                if data.current.value == "yes" then
                    TriggerServerEvent("bc_contract:setresell", plate, GetPlayerServerId(closestPlayer),
                        GetDisplayNameFromVehicleModel(model))
                end
            end)
        else
            ESX.OpenContext("right", {
                {
                    unselectable = true,
                    title = "Az autó a frakciódba fog kerülni és onnan többet nem tudod kivenni, biztosan ezt szeretnéd?"
                },
                {
                    title = "Igen",
                    value = "yes"
                },
                {
                    title = "Nem",
                    value = "no"
                },
            }, function(menu, element)
                ESX.CloseContext()
                local data = { current = element }
                if data.current.value == "yes" then
                    TriggerServerEvent("bc_contract:setfaction", plate, GetDisplayNameFromVehicleModel(model))
                end
            end)
        end
    end)
end)

RegisterNetEvent("bc_contract:timealert", function()
    local alert = lib.alertDialog({
    header = 'FIGYELEM!!!',
    content = 'A szerződés moderátori felülbírásra szorul! A szerződés elfogadása/elutasítása 24 órán belül megtörténik ha bármelyik staffot fel keresed vele vagy ticketet írsz 500 közmunkában részesülsz!!',
    centered = true,
    cancel = false
})
end)

--- A vevő oldali papír szerződés (a korábbi lib.alertDialog helyett).
---@param extra table|nil { sellerName, buyerName, reason, signature } a szervertől
local function BuyerContract(plate, modname, bankPrice, ppPrice, exchangeVehicles, extra)
    extra = type(extra) == "table" and extra or {}
    local exchange = {}
    for _, v in ipairs(type(exchangeVehicles) == "table" and exchangeVehicles or {}) do
        if type(v) == "table" then
            exchange[#exchange + 1] = { plate = v.plate, model = VehicleLabel(v.model), hardHandling = v.hardHandling == true }
        end
    end
    local result = OpenContractDocument("buyer", {
        plate      = plate,
        model      = VehicleLabel(modname),
        bank       = tonumber(bankPrice) or 0,
        pp         = tonumber(ppPrice) or 0,
        exchange   = exchange,
        sellerName = extra.sellerName or "Ismeretlen eladó",
        buyerName  = extra.buyerName or GetPlayerName(PlayerId()),
        reason     = extra.reason,
        signature  = extra.signature
    })
    return result ~= nil and result.accepted == true
end

lib.callback.register('bc_contract:confbuy', function(plate, modname, bankPrice, ppPrice, extra)
    return BuyerContract(plate, modname, bankPrice, ppPrice, {}, extra)
end)

lib.callback.register('bc_contract:confbuydetailed', function(plate, modname, bankPrice, ppPrice, exchangeVehicles, extra)
    return BuyerContract(plate, modname, bankPrice, ppPrice, exchangeVehicles, extra)
end)

--[[RegisterNetEvent('bc_contract:showAnim', function()
	loadAnimDict('anim@amb@nightclub@peds@')
	TaskStartScenarioInPlace(PlayerPedId(), 'WORLD_HUMAN_CLIPBOARD', 0, false)
	Citizen.Wait(20000)
	ClearPedTasks(PlayerPedId())
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(0)
	end
end]]







---@return void
function OpenContractPanel()
    local response = Rpc:CallServer("bc_contract:openPanel", {})
    if response.success then
        SendNUIMessage({
            action = "openPanel",
            data = response.data
        })
        SetNuiFocus(true, true)
    else
        ESX.ShowNotification("Hiba a panel megnyitása során!")
    end
end

RegisterNetEvent("bc_contract:openAdminPanel", function()
    OpenContractPanel()
end)

RegisterNetEvent("bc_contract:openReviewPanel", function(tradeId)
    SendNUIMessage({
        action = "openReviewModal",
        data = { tradeId = tradeId }
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("closePanel", function(data, cb)
    SetNuiFocus(false, false)
    cb({ success = true })
end)

local npcHandle = nil

---@param model number
local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
end

local contractPoint = lib.points.new({
    coords = vec3(Config.NpcPosition.x, Config.NpcPosition.y, Config.NpcPosition.z),
    distance = Config.NpcLoadDistance,
})

function contractPoint:onEnter()
    local model = GetHashKey("a_m_m_business_01")
    loadModel(model)
    local pos = Config.NpcPosition
    npcHandle = CreatePed(4, model, pos.x, pos.y, pos.z - 1.0, pos.w, false, true)
    SetEntityInvincible(npcHandle, true)
    FreezeEntityPosition(npcHandle, true)
    SetBlockingOfNonTemporaryEvents(npcHandle, true)
    SetPedFleeAttributes(npcHandle, 0, 0)
    SetPedCombatAttributes(npcHandle, 46, true)
    SetModelAsNoLongerNeeded(model)
    exports.ox_target:addLocalEntity(npcHandle, {
        {
            name = "bc_contract:open",
            icon = "fas fa-file-contract",
            label = "Szerződéses panel megnyitása",
            onSelect = function()
                OpenContractPanel()
            end,
        }
    })
end

function contractPoint:onExit()
    if npcHandle and DoesEntityExist(npcHandle) then
        exports.ox_target:removeLocalEntity(npcHandle)
        DeleteEntity(npcHandle)
        npcHandle = nil
    end
end

CreateThread(function()
    while not ESX or not ESX.PlayerData or not ESX.PlayerData.job do
        Wait(100)
    end
    while true do
        Wait(0)

        local coords = GetEntityCoords(PlayerPedId())
        local sleep = true

        for k, v in pairs(Config.BuyResellCars) do
            local dis = #(coords - v.coords)
            if dis < 20 then
                if k == ESX.PlayerData.job.name and v.minrank <= ESX.PlayerData.job.grade then
                    sleep = false
                    DrawMarker(20, v.coords, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 213, 144, 20, 100, true, true, 2,
                        false, false, false, false)
                    if dis < 1.1 then
                        ESX.ShowHelpNotification("Nyomd [E], hogy megnyisd a kocsi import menüt", true)
                        if IsControlJustReleased(0, 38) then
                            OpenResellCarShop()
                            Wait(1000)
                        end
                    end
                end
            end
        end

        if sleep then
            Wait(1000)
        end
    end
end)

function OpenResellCarShop()
    local job = ESX.PlayerData.job.name
    if not Config.BuyResellCars or not job then
        return
    end
    if not Config.BuyResellCars[job] or not Config.ResellFactions[job] then
        return
    end

    local elements = {
        { unselectable = true, title = "Minden autó ára: 100.000$ (fizetés csak készpénzben)" }
    }
    for i = 1, #Config.ResellFactions[job] do
        local veh = Config.ResellFactions[job][i]
        local modellabel = GetDisplayNameFromVehicleModel(veh)
        elements[#elements + 1] = {
            icon = "fas fa-car",
            title = modellabel,
            value = veh
        }
    end

    ESX.OpenContext("right", elements, function(menu, element)
        ESX.CloseContext()
        local data = { current = element }
        if not data.current.value then return end
        TriggerServerEvent("bc_contract:buyresellcar", data.current.value)
    end)
end
