CONTAINERS = {}
CRYPTOPRICES = {}

local blips = {}
local contdata = false
local zchecked = {}     -- [container id] = true once its height was compared to the ground

local txd
local url = 'nui://'..GetCurrentResourceName()..'/html/dui.html'
local scale = 0.3;
local sfName = 'generic_texture_renderer';
local width = 800;
local height = 450;

-- Prompt/marker range, and how often the container list is rescanned for what falls inside it.
local NEARBY_RANGE         = 10.0
local NEARBY_SCAN_INTERVAL = 250

-- Containers currently within NEARBY_RANGE, refreshed on the interval above. Both arrays are
-- reused between scans so the loop never allocates.
local nearby      = {}
local nearbyDist  = {}
local nearbyCount = 0
local nextScan    = 0

-- Walking every container with a vector distance on every frame is what the marker loop used to
-- do, and it scales with the number of containers in the database rather than with what is
-- actually on screen. Do it four times a second instead, behind a cheap axis-aligned reject that
-- skips the square root for everything obviously out of range.
local function RefreshNearby(coords)
    nearbyCount = 0

    for _, v in pairs(CONTAINERS) do
        local c = v and v.coords
        if c and math.abs(coords.x - c.x) < NEARBY_RANGE and math.abs(coords.y - c.y) < NEARBY_RANGE then
            local dist = #(coords - c)
            if dist < NEARBY_RANGE then
                nearbyCount = nearbyCount + 1
                nearby[nearbyCount] = v
                nearbyDist[nearbyCount] = dist
            end
        end
    end

    for i = nearbyCount + 1, #nearby do
        nearby[i] = nil
        nearbyDist[i] = nil
    end
end

RegisterNetEvent("bc_crypto:refresh", function(id, data)
    CONTAINERS[id] = data
    zchecked[id] = nil
    nextScan = 0       -- the nearby list holds table references, drop it so a removed/replaced container cannot linger
    RefreshBlips()
end)

-- A belepesi ikon MINDIG a talajon alljon. Ket iranyban kell javitani:
--   - a regi konteneteket pont a talajszintre mentettuk, ott az [E] nem erheto el
--     (a ped kozeppontja ~1.0-val a talpa felett van) -> fel kell emelni,
--   - aki viszont letrahoz/falra nezve rakta le, annal az ikon a levegoben lebeg
--     (2026-09-18, Black City Cryptobanyaszat #34) -> le kell hozni a foldre.
-- Barmelyik iranyban a cel ugyanaz: talaj + ContainerGroundOffset.
local function FixContainerZ(container, coords)
    if not Config.ContainerAutoFixZ or zchecked[container.id] then
        return
    end

    local gz = GetSurfaceZ(container.coords.x, container.coords.y, coords.z)
    if not gz then      -- collision not loaded yet, try again next frame
        return
    end

    zchecked[container.id] = true

    local target = gz + Config.ContainerGroundOffset
    if math.abs(container.coords.z - target) <= 0.35 then
        return
    end

    -- correct it locally right away, the server confirms with a refresh
    container.coords = vector3(container.coords.x, container.coords.y, target)
    TriggerServerEvent('Crypto:Server:FixContainerZ', container.id, container.coords.z)
end

RegisterNetEvent("bc_crypto:refreshPrices", function(data)
    CRYPTOPRICES = data
end)

CreateThread(function()
    Wait(6000)
    while not IsPlayerLoaded() do
        Wait(100)
    end
   -- print("loaded")
    CONTAINERS = TriggerServerCallback("bc_crypto:getContainers")
    CRYPTOPRICES = TriggerServerCallback("bc_crypto:getCryptoPrices")
    RefreshBlips()
    --print("loaded containers", CONTAINERS, json.encode(CONTAINERS))

    txd = CreateRuntimeTxd('bc_crypto_dui');

    AddTextEntry('bc_crypto_leave_manage', Translate('leave_manage'))
    local lastScanCoords

    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local now = GetGameTimer()

        if now >= nextScan then
            nextScan = now + NEARBY_SCAN_INTERVAL
            RefreshNearby(coords)
        end

        -- placement/move mode draws its own ghost and uses [E], so the container prompts stay hidden
        local placing = IsPlacingCP()

        if nearbyCount == 0 or placing then
            -- A player who is not moving cannot bring a container into the 10m range, so
            -- the quarter-second rescan only has to keep up while actually moving.
            local moved = not lastScanCoords or #(coords - lastScanCoords) > 2.0
            lastScanCoords = coords

            Wait(moved and NEARBY_SCAN_INTERVAL or 1000)
        else
            for i = 1, nearbyCount do
                local v = nearby[i]

                if nearbyDist[i] < 8.0 then
                    FixContainerZ(v, coords)
                end

                if not v.owner then
                    DrawMarker(2, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 255, 50, 100, true, true, 2, false, false, false, false)
                    AddTextEntry('bc_crypto_buy_container', Translate('buy_container', v.label, v.id, v.price))
                    SetFloatingHelpTextWorldPosition(1, v.coords+vector3(0, 0, 0.7))
                    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
                    BeginTextCommandDisplayHelp('bc_crypto_buy_container')
                    EndTextCommandDisplayHelp(2, false, false, -1)
                    if IsControlJustPressed(0, 38) and IsAtContainer(coords, v.coords) then
                        BuyContainer(v.id, v.label, v.price)
                    end
                elseif v.isowner then
                    DrawMarker(2, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 255, 100, true, true, 2, false, false, false, false)
                    AddTextEntry('bc_crypto_enter_container', Translate('enter_container', v.label, v.id))
                    SetFloatingHelpTextWorldPosition(1, v.coords+vector3(0, 0, 0.7))
                    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
                    BeginTextCommandDisplayHelp('bc_crypto_enter_container')
                    EndTextCommandDisplayHelp(2, false, false, -1)
                    if IsControlJustPressed(0, 38) and IsAtContainer(coords, v.coords) then
                        EnterContainer(v.id)
                    end
                else
                    DrawMarker(2, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 255, 100, true, true, 2, false, false, false, false)
                    AddTextEntry('bc_crypto_info_container', Translate('info_container', v.label, v.id))
                    SetFloatingHelpTextWorldPosition(1, v.coords+vector3(0, 0, 0.7))
                    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
                    BeginTextCommandDisplayHelp('bc_crypto_info_container')
                    EndTextCommandDisplayHelp(2, false, false, -1)
                end
            end

            Wait(0)
        end
    end
end)


function RefreshBlips()
    for k,v in pairs(blips) do
        RemoveBlip(v)
    end
    blips = {}
    for k,v in pairs(CONTAINERS) do
        if v and v.coords then
            local blip = AddBlipForCoord(v.coords)
            SetBlipSprite(blip, 521)
            SetBlipScale(blip, 0.7)
            if not v.owner then 
                SetBlipColour(blip, 2)
            elseif v.isowner then
                SetBlipColour(blip, 3)
            else 
                SetBlipColour(blip, 1)
            end
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            if not v.owner then 
                AddTextComponentSubstringPlayerName("Megvásárolható crypto bányászat")
            elseif v.isowner then
                AddTextComponentSubstringPlayerName("Saját crypto bányászat")
            else 
                AddTextComponentSubstringPlayerName("Foglalt crypto bányászat")
            end
            EndTextCommandSetBlipName(blip)
            blips[k] = blip
        end
    end
end 


function BuyContainer(id, label, price)
    local alert = lib.alertDialog({
        header = Translate('buy_container_header'),
        content = Translate('buy_container_content', label, id, price),
        centered = true,
        cancel = true
    })
  --  print(alert)
    if alert == 'confirm' then
        TriggerServerEvent("bc_crypto:buyContainer", id)
    end
end

RegisterNetEvent("bc_crypto:refreshInside", function(id, data)
    if contdata and contdata.id == id then
        contdata.details = data
        RefreshInside()
        contdata.closestpc = false
    end
end)

function EnterContainer(id)
    if contdata then
        return false
    end

    local container = TriggerServerCallback("bc_crypto:getContainer", id)
    if not container then
        return false
    end

    contdata = {
        id = id,
        type = container.type,
        details = container,
        shell = 0,
        coords = container.coords,
        basecoords = container.coords+Config.Containers[container.type].spawn,
        outsidecoords = GetEntityCoords(PlayerPedId()),
        spawnedpcs = {},
        closestpc = false,
    }

    local sfHandle = LoadScaleform(sfName)

    local duiObj = CreateDui(url, width, height);
    local dui = GetDuiHandle(duiObj);
    local tx = CreateRuntimeTextureFromDuiHandle(txd, 'pcstats', dui);

    PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')
    PushScaleformMovieMethodParameterString('bc_crypto_dui')
    PushScaleformMovieMethodParameterString('pcstats')
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(width)
    PushScaleformMovieFunctionParameterInt(height)
    PopScaleformMovieFunctionVoid()


    local outsidecoords = contdata.outsidecoords

    local smodel = Config.Containers[container.type].shell
    RequestModel(smodel)
    while not HasModelLoaded(smodel) do
        Wait(100)
    end
    contdata.shell = CreateObject(smodel, contdata.basecoords, false, false, false)
    while not DoesEntityExist(contdata.shell) do
        Wait(1)
    end
    FreezeEntityPosition(contdata.shell, true)
    RefreshInside()

    Wait(3000)

    SetEntityCoords(PlayerPedId(), contdata.basecoords+Config.Containers[container.type].tp)

    CreateThread(function()
        while contdata do
            Wait(1)
            -- the manage menu (move/sell) can leave the container while this thread is waiting,
            -- so re-check before the body touches contdata again
            if not contdata then break end

            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            DrawMarker(2, contdata.basecoords+Config.Containers[container.type].tp, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 255, 100, true, true, 2, false, false, false, false)
            if #(coords - (contdata.basecoords+Config.Containers[container.type].tp)) < 1.0 then
                DisplayHelpTextThisFrame('bc_crypto_leave_manage')
                if IsControlJustPressed(0, 38) then 
                    ManageContainer()
                elseif IsControlJustPressed(0, 73) then 
                    for k, v in pairs(contdata.spawnedpcs) do
                        if v then
                            DeleteEntity(v)
                        end
                    end
                    DeleteEntity(contdata.shell)
                    contdata.shell = 0
                    contdata = false
                    break
                end 
            end

            local cpc, cdis = false, 1000

            for slot, data in pairs(Config.Containers[contdata.type].slots) do
                if contdata.spawnedpcs[slot] then
                    if #(coords - (contdata.basecoords+data.offset)) < cdis then
                        cdis = #(coords - (contdata.basecoords+data.offset))
                        cpc = slot
                    end
                end
            end

            if cpc and cdis < 1.6 then
                if contdata.closestpc ~= cpc then
                    contdata.closestpc = cpc

                    local minedCrypto = "NONE"
                    if contdata.details.pc[cpc] and contdata.details.pc[cpc].running and Config.Cryptos[contdata.details.pc[cpc].running] then
                        minedCrypto = Config.Cryptos[contdata.details.pc[cpc].running].symbol
                    end

                    local temp = 35
                    if contdata.details.pc[cpc] and contdata.details.pc[cpc].damage then
                        local td = contdata.details.pc[cpc].damage - 1 
                        td = math.floor(td*100)
                        temp = temp + td
                    end
                    PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')
                    PushScaleformMovieMethodParameterString('bc_crypto_dui')
                    PushScaleformMovieMethodParameterString('pcstats')
                    PushScaleformMovieFunctionParameterInt(0)
                    PushScaleformMovieFunctionParameterInt(0)
                    PushScaleformMovieFunctionParameterInt(width)
                    PushScaleformMovieFunctionParameterInt(height)
                    PopScaleformMovieFunctionVoid()
                   -- print("update pc data", minedCrypto, contdata.details.pc[cpc].hashrate, temp, contdata.details.pc[cpc].durability)
                    SendDuiMessage(duiObj, json.encode({
                        type = 'updateUI', 
                        minedCrypto = minedCrypto,
                        hashrate = contdata.details.pc[cpc].hashrate or 0,
                        temperature = temp,
                        durability = contdata.details.pc[cpc].durability,
                    }))
                end
            else 
                contdata.closestpc = false
            end

            if contdata.closestpc then
                if IsControlJustPressed(0, 38) then 
                    ManagePc(contdata.closestpc)
                end 
                local modscale = (1/cdis)*2
                local fov = (1/GetGameplayCamFov())*100
                modscale = modscale*fov

                local pos = contdata.basecoords+Config.Containers[contdata.type].slots[contdata.closestpc].offset
                local pcmodel = Config.Computers[contdata.details.pc[contdata.closestpc].pctype].model 
                local minimum, maximum = GetModelDimensions(pcmodel)
        
                DrawScaleformMovie_3dNonAdditive(
                    sfHandle,
                    pos.x-minimum.x, pos.y+minimum.y, pos.z+maximum.z,
                    0, (Config.Containers[contdata.type].slots[contdata.closestpc].heading*-1), 0,
                    255, 255, 255,
                    --scale * 1 * modscale, scale * (450/250) * modscale, 1,
                    scale * 1, scale * (450/800), 1,
                    2
                )
            end

            if #(coords - contdata.basecoords) > 150 then
                for k, v in pairs(contdata.spawnedpcs) do
                    if v then
                        DeleteEntity(v)
                    end
                end
                DeleteEntity(contdata.shell)
                contdata.shell = 0
                contdata = false
                break
            end
        end
        TriggerServerEvent("bc_crypto:leaveContainer", id)
        DestroyDui(duiObj)
        SetScaleformMovieAsNoLongerNeeded(sfHandle)
        SetEntityCoords(PlayerPedId(), outsidecoords)
    end)
end

function LoadScaleform(scaleform) 
    local scaleformHandle = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleformHandle) do
      --scaleformHandle = RequestScaleformMovie(scaleform)
      Wait(0)
    end

    return scaleformHandle
end


function RefreshInside()
    for k, v in pairs(contdata.spawnedpcs) do
        if v then
            DeleteEntity(v)
        end
    end
    contdata.spawnedpcs = {}

    for slot, data in pairs(Config.Containers[contdata.type].slots) do
        if contdata.details.pc[slot] then
            local pytype = contdata.details.pc[slot].pctype
            local pcmodel = Config.Computers[pytype].model
          --  print("pcmodel", pcmodel)

            RequestModel(pcmodel)
            while not HasModelLoaded(pcmodel) do
                Wait(10)
            end
          --  print("pcmodel loaded", pcmodel)
            local obj = CreateObject(pcmodel, contdata.basecoords+data.offset, false, false, false)
           -- print("pcmodel created", obj)
            while not DoesEntityExist(obj) do
                Wait(1)
            end
          --  print("pcmodel exists", obj)
            FreezeEntityPosition(obj, true)
            SetEntityHeading(obj, data.heading)
            contdata.spawnedpcs[slot] = obj
        end
    end
end 

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Leaves the container interior: despawn the shell + PCs and put the player back outside.
function LeaveContainer()
    if not contdata then
        return false
    end

    local outsidecoords = contdata.outsidecoords
    for k, v in pairs(contdata.spawnedpcs) do
        if v then
            DeleteEntity(v)
        end
    end
    DeleteEntity(contdata.shell)
    contdata.shell = 0
    contdata = false
    SetEntityCoords(PlayerPedId(), outsidecoords)
    return true
end

function ManageContainer()
    if not contdata then
        return false
    end

    local options = {
          {
            title = Translate('change_name_title'),
            description = Translate('change_name_description'),
            onSelect = function()
                local name = lib.inputDialog(Translate('change_name_dialog_title'), {
                    {type = 'input', label = Translate('change_name_label'), default = contdata.details.label, required = true},
                })
                if name then
                    TriggerServerEvent("bc_crypto:setname", contdata.id, name[1])
                end
            end,
          },
          {
            title = Translate('add_pc_title'),
            description = Translate('add_pc_description'),
            onSelect = function()
                local pcs = {}
                local items = exports.ox_inventory:GetPlayerItems()
                for k, v in pairs(items) do
                    if Config.Computers[v.name] then
                        local dur = 100
                        if v.metadata and v.metadata.durability then
                            dur = v.metadata.durability
                        end
                        table.insert(pcs, {label = Config.Computers[v.name].name.." | "..dur.."%", value = v.slot})
                    end
                end
                local pc = lib.inputDialog(Translate('add_pc_dialog_title'), {
                    {type = 'select', label = Translate('add_pc_label'), options = pcs, required = true},
                })
                if pc then
                    TriggerServerEvent("bc_crypto:addpc", contdata.id, nil, pc[1])
                end
            end,
          },
          {
            title = Translate('remove_pc_title'),
            description = Translate('remove_pc_description'),
            onSelect = function()
                local pcs = {}
                for k, v in pairs(contdata.details.pc) do
                    if v then
                        table.insert(pcs, {label = Config.Computers[v.pctype].name.." | "..v.durability.."%", value = k})
                    end
                end
                local pc = lib.inputDialog(Translate('remove_pc_dialog_title'), {
                    {type = 'select', label = Translate('remove_pc_label'), options = pcs, required = true},
                })
                if pc then
                    TriggerServerEvent("bc_crypto:removepc", contdata.id, pc[1])
                end
            end,
          },
          {
            title = Translate('check_balance_title'),
            description = Translate('check_balance_description'),
            onSelect = function()
                local balance = TriggerServerCallback("bc_crypto:getbalance", contdata.id)
              --  print("balance", json.encode(balance))
                local cont = ""
                for k, v in pairs(balance) do
                    if CRYPTOPRICES[k] then
                        v = round(v, 5)
                        --print(k, v)
                        cont = cont..Config.Cryptos[k].name..": "..v.." | "..CRYPTOPRICES[k].."$/"..Config.Cryptos[k].symbol.." | "..Translate('balance_sum', math.floor(v*CRYPTOPRICES[k])).."\n"
                    end
                end

             --   print(cont)
                local alert = lib.alertDialog({
                    header = Translate('balance_header'),
                    content = cont,
                    centered = true,
                    cancel = true
                })
            end,
          },
          {
            title = Translate('sell_crypto_title'),
            description = Translate('sell_crypto_description'),
            onSelect = function()
                local balance = TriggerServerCallback("bc_crypto:getbalance", contdata.id)
                --print("balance", json.encode(balance))
                local cryptos = {}
                for k, v in pairs(balance) do
                    if CRYPTOPRICES[k] then
                        v = round(v, 5)
                        --print(k,v)
                        table.insert(cryptos, {label = Config.Cryptos[k].name.." | "..v.." | "..Config.Cryptos[k].symbol, value = k})
                    end
                end

                local crypto = lib.inputDialog(Translate('sell_crypto_dialog_title'), {
                    {type = 'select', label = Translate('sell_crypto_label'), options = cryptos, required = true},
                    {type = 'input', label = Translate('sell_crypto_amount_label'), default = 1, required = true},
                })

                if crypto then
                    local amount = tonumber(crypto[2])
                    if amount and amount > 0 then
                        TriggerServerEvent("bc_crypto:sellcrypto", contdata.id, crypto[1], amount)
                    else
                        lib.notify({
                            title = Translate('invalid_amount_title'),
                            description = Translate('invalid_amount_description'),
                            type = 'error'
                        })
                    end
                end
            end,
          },

          {
            title = "Konténer eladása",
            description = "Konténered eladása az eredeti árának feléért!",
            onSelect = function()
                local price  = contdata.details.price
                if not price or price < 10 then 
                    return TriggerEvent("esx:showNotification", "Ez a konténer nem eladható!")
                end 

                local alert = lib.alertDialog({
                    header = "Eladás",
                    content = "Eladod a konténered "..math.floor(price/2).."$-ért?",
                    centered = true,
                    cancel = true
                })
                if alert == true or alert == "confirm" then
                    TriggerServerEvent("bc_crypto:sellcontainer", contdata.id)
                    LeaveContainer()
                end
            end,
          },
    }

    -- the owner can reposition the container inside the zone the server sent with it
    -- (shop CP: the whole drop zone, otherwise a small radius around its original spot)
    if contdata.details.movezone then
        options[#options+1] = {
            title = "Bányászat áthelyezése",
            description = "Új helyre viheted a bányászatod a megengedett zónán belül.",
            onSelect = function()
                if not contdata then return end
                local id, zone = contdata.id, contdata.details.movezone
                LeaveContainer()
                StartCPMove(id, zone)
            end,
        }
    end

    lib.registerContext({
        id = 'bc_crypto_manage_container',
        title = Translate('manage_container_title'),
        options = options
    })
    lib.showContext('bc_crypto_manage_container')
end

function ManagePc(slot)
    if not contdata then
        return false
    end 

    local pc = contdata.details.pc[slot]
    if not pc then
        return false
    end 

    lib.registerContext({
        id = 'bc_crypto_manage_pc',
        title = Translate('manage_pc_title'),
        options = {
          {
            title = Translate('change_crypto_title'),
            description = Translate('change_crypto_description'),
            onSelect = function()
                local cryptos = {
                    {label = Translate('none_option'), value = false}
                }
                for k, v in pairs(Config.Cryptos) do
                    table.insert(cryptos, {label = v.name, value = k})
                end
                local crypto = lib.inputDialog(Translate('change_crypto_dialog_title'), {
                    {type = 'select', label = Translate('change_crypto_label'), options = cryptos, default = pc.running, required = true},
                })
                if crypto then
                    TriggerServerEvent("bc_crypto:setpcrunning", contdata.id, slot, crypto[1])
                end
            end,
          },
          {
            title = Translate('add_gpu_title'),
            description = Translate('add_gpu_description'),
            onSelect = function()
                local gpus = {}
                local items = exports.ox_inventory:GetPlayerItems()
                for k, v in pairs(items) do
                    if Config.GPUs[v.name] then
                        local dur = 100
                        if v.metadata and v.metadata.durability then
                            dur = v.metadata.durability
                        end
                        table.insert(gpus, {label = Config.GPUs[v.name].name.." | "..dur.."%", value = v.slot})
                    end
                end
                local gpu = lib.inputDialog(Translate('add_gpu_dialog_title'), {
                    {type = 'select', label = Translate('add_gpu_label'), options = gpus, required = true},
                })
                if gpu then
                    TriggerServerEvent("bc_crypto:addgpu", contdata.id, slot, gpu[1])
                end
            end,
          },
          {
            title = Translate('remove_gpu_title'),
            description = Translate('remove_gpu_description'),
            onSelect = function()
                local gpus = {}
                for k, v in pairs(pc.gpus) do
                    table.insert(gpus, {label = Config.GPUs[v.gpu].name.." | "..v.durability.."%", value = k})
                end
                local gpu = lib.inputDialog(Translate('remove_gpu_dialog_title'), {
                    {type = 'select', label = Translate('remove_gpu_label'), options = gpus, required = true},
                })
                if gpu then
                    TriggerServerEvent("bc_crypto:removegpu", contdata.id, slot, gpu[1])
                end
            end,
          },
          {
            title = Translate('add_cooler_title'),
            description = Translate('add_cooler_description'),
            onSelect = function()
                local coolers = {}
                local items = exports.ox_inventory:GetPlayerItems()
                for k, v in pairs(items) do
                    if Config.Coolers[v.name] then
                        local dur = 100
                        if v.metadata and v.metadata.durability then
                            dur = v.metadata.durability
                        end
                        table.insert(coolers, {label = Config.Coolers[v.name].name.." | "..dur.."%", value = v.slot})
                    end
                end
                local cooler = lib.inputDialog(Translate('add_cooler_dialog_title'), {
                    {type = 'select', label = Translate('add_cooler_label'), options = coolers, required = true},
                })
                if cooler then
                    TriggerServerEvent("bc_crypto:addcooler", contdata.id, slot, cooler[1])
                end
            end,
          },
          {
            title = Translate('remove_cooler_title'),
            description = Translate('remove_cooler_description'),
            onSelect = function()
                local coolers = {}
                for k, v in pairs(pc.coolers) do
                    table.insert(coolers, {label = Config.Coolers[v.cooler].name.." | "..v.durability.."%", value = k})
                end
                local cooler = lib.inputDialog(Translate('remove_cooler_dialog_title'), {
                    {type = 'select', label = Translate('remove_cooler_label'), options = coolers, required = true},
                })
                if cooler then
                    TriggerServerEvent("bc_crypto:removecooler", contdata.id, slot, cooler[1])
                end
            end,
          },
        }
    })

    lib.showContext('bc_crypto_manage_pc')
end