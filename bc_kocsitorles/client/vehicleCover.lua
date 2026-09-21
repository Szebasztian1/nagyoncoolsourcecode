---@type table<string, number>
local localCoverObjects = {}

---@type table<string, {plate: string, model: number, coords: {x: number, y: number, z: number}, heading: number, coverModel: string}>
local coveredVehiclesList = {}

local LOAD_DISTANCE <const> = 80.0
local UNLOAD_DISTANCE <const> = 100.0


local COVER_ANIM   = { dict = "amb@world_human_bum_wash@male@low@idle_a", anim = "idle_a", duration = 3000 }
local UNCOVER_ANIM = { dict = "mini@repair", anim = "fixing_a_ped", duration = 3000 }

--------------------------------------------------------------------------------
-- Halott állapot: halottan nem lehet járművet letakarni, sem a takarást levenni.
-- A `esxdead` statebag-et az esx_ambulancejob állítja szerveroldalon (replikált),
-- az IsEntityDead csak végső biztosíték, ha a bag még nem ért át.
--------------------------------------------------------------------------------

---@return boolean
local function IsPlayerDeadNow()
    return LocalPlayer.state.esxdead == true or IsEntityDead(PlayerPedId())
end

local function NotifyDead()
    lib.notify({
        type        = "error",
        icon        = "fas fa-skull",
        title       = "Halott vagy",
        description = "Halottan nem tudsz járművet letakarni, sem a takarást levenni!",
        duration    = 4000,
    })
end


local LOCALVEHICLES = {}
AddEventHandler('bc:localVehSpawn', function(veh) 
    LOCALVEHICLES[veh] = true 
end)

--------------------------------------------------------------------------------
-- JELÖLETLEN LOKÁLIS JÁRMŰ FIGYELŐ
--
-- Minden legális lokális (nem networked) jármű-spawn kiadja a `bc:localVehSpawn`
-- eventet: garázs- és autószalon-előnézet (bc_garage, bc_vehshop, bc_egyedibolt),
-- aukció (bc_auction), bérlés (mate-rentveh), admin fotózás/rajtrács (mate_admin),
-- és maga az ESX.Game.SpawnLocalVehicle is (es_extended/client/functions.lua).
-- Amiben a játékos ÜL, annak tehát benne kell lennie a LOCALVEHICLES táblában.
--
-- A lokális járműről a szerver semmit nem tud (nincs netId, nincs entitás), ezért
-- a szerveroldali mod-menu figyelő (server/anticheat.lua, [sg] ág) sem látja --
-- egy mod menüvel lokálisan spawnolt autó ott vakfolt. Ezt a lyukat tömi be ez a
-- szál: ha a játékos jelöletlen lokális járműben ül, jelenti a szervernek.
--
-- A türelmi idő azért kell, mert a spawnoló script előbb hozza létre a járművet,
-- mint ahogy a játékost beülteti és a jelzést kiadja. A türelmi idő alatt minden
-- körben újranézzük a táblát, tehát a késve érkező jelölés még felmenti a kocsit.
--------------------------------------------------------------------------------

local LVG_TICK <const>  = 500   -- ellenőrző kör
local LVG_GRACE <const> = 3000  -- ennyi ideje van a jelölésnek megérkeznie
local LVG_SWEEP <const> = 60000 -- a megszűnt handle-ök takarítási köre

---@type table<integer, boolean> már jelentett járművek -- egy járműre egyszer szólunk
local lvgReported = {}

CreateThread(function()
    ---@type integer
    local pendingVehicle = 0
    ---@type integer
    local pendingSince = 0

    while true do
        Wait(LVG_TICK)

        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        -- A hálózati járművekkel a szerveroldali figyelő foglalkozik, azokat itt
        -- meg sem nézzük (különben minden sima autó duplán lenne vizsgálva).
        local suspicious = NetworkIsSessionStarted()
            and vehicle ~= 0
            and DoesEntityExist(vehicle)
            and not NetworkGetEntityIsNetworked(vehicle)
            and not LOCALVEHICLES[vehicle]

        if not suspicious then
            pendingVehicle, pendingSince = 0, 0
        elseif pendingVehicle ~= vehicle then
            pendingVehicle, pendingSince = vehicle, GetGameTimer()
        elseif GetGameTimer() - pendingSince >= LVG_GRACE and not lvgReported[vehicle] then
            lvgReported[vehicle] = true

            local coords = GetEntityCoords(vehicle)

            exports.gs_eventprotect:GS_TriggerServerEvent("bc_kocsitorles:localVehIllegal", {
                model  = GetEntityModel(vehicle),
                plate  = GetVehicleNumberPlateText(vehicle) or "",
                driver = GetPedInVehicleSeat(vehicle, -1) == PlayerPedId(),
                coords = {
                    x = math.floor(coords.x * 100) / 100,
                    y = math.floor(coords.y * 100) / 100,
                    z = math.floor(coords.z * 100) / 100,
                },
            })
        end
    end
end)

-- A handle-öket a játék újrahasznosítja: egy törölt jármű handle-jét később egy
-- másik entitás kapja meg. Takarítás nélkül egy régi, jelölt jármű handle-je
-- csendben felmentene egy mod menüs autót -- és a tábla se szabadulna fel soha.
CreateThread(function()
    while true do
        Wait(LVG_SWEEP)

        for handle in pairs(LOCALVEHICLES) do
            if not DoesEntityExist(handle) then
                LOCALVEHICLES[handle] = nil
            end
        end

        for handle in pairs(lvgReported) do
            if not DoesEntityExist(handle) then
                lvgReported[handle] = nil
            end
        end
    end
end)


--------------------------------------------------------------------------------
-- A takarás levételekor a járművet a SZERVER hozza létre (CreateVehicleServerSetter),
-- ezért az VÉLETLEN rendszámmal születik. A valódi rendszám csak az es_extended
-- `VehicleProperties` statebag-jén keresztül kerül fel, azt viszont csak az az egy
-- kliens teszi meg, amelyik entity owner lesz — és 10 mp után csendben feladja
-- (es_extended/client/main.lua).
--
-- Az ox_inventory a csomagtartót a RENDSZÁM alapján azonosítja (`trunk<rendszám>`),
-- ezért amíg nincs fenn a helyes rendszám, a játékos egy idegen csomagtartót nyit ki:
-- ilyenkor az ox `randomloot`-ja tölti fel szeméttel — innen jött az
-- "eltűnt a csomagtartóból minden" hibajelenség.
--
-- A garázs pont ezért nem hibázik: ott a kliens hozza létre a járművet, és még
-- ugyanabban a frame-ben rárakja a rendszámot. Itt ugyanezt csináljuk meg.
--------------------------------------------------------------------------------
RegisterNetEvent("bc_kocsitorles:applyUncoveredProps", function(netId, props, plate)
    if type(netId) ~= "number" or type(props) ~= "table" then return end

    local vehicle  = 0
    local deadline = GetGameTimer() + 10000

    while GetGameTimer() < deadline do
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local entity = NetToVeh(netId)
            if entity ~= 0 and DoesEntityExist(entity) then
                vehicle = entity
                break
            end
        end
        Wait(0)
    end

    if vehicle == 0 then return end

    -- Kontroll elkérése: enélkül a SetVehicle* natívok nem érvényesülnek.
    deadline = GetGameTimer() + 3000
    while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < deadline do
        NetworkRequestControlOfEntity(vehicle)
        Wait(0)
    end

    if not NetworkHasControlOfEntity(vehicle) then return end
    if not DoesEntityExist(vehicle) then return end

    if plate and plate ~= "" then
        SetVehicleNumberPlateText(vehicle, plate)
    end

    ESX.Game.SetVehicleProperties(vehicle, props)

    -- A propok után is: a SetVehicleProperties bármelyik ága felülírhatja.
    if plate and plate ~= "" then
        SetVehicleNumberPlateText(vehicle, plate)
    end

    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)

    -- Rövid utóellenőrzés: az es_extended statebag-kezelője is rárak(hat)ja a propokat,
    -- illetve kontroll-váltásnál visszaugorhat a véletlen rendszám. 3 mp-ig figyeljük.
    if not plate or plate == "" then return end

    CreateThread(function()
        for _ = 1, 15 do
            Wait(200)

            if not DoesEntityExist(vehicle) then return end

            local current = (GetVehicleNumberPlateText(vehicle) or ""):gsub("^%s*(.-)%s*$", "%1")
            if current ~= plate then
                NetworkRequestControlOfEntity(vehicle)
                if NetworkHasControlOfEntity(vehicle) then
                    SetVehicleNumberPlateText(vehicle, plate)
                end
            end
        end
    end)
end)

local function PlayAnimAndWait(animData)
    lib.requestAnimDict(animData.dict)
    lib.playAnim(PlayerPedId(), animData.dict, animData.anim, 8.0, -8.0, animData.duration, 1, 0, false, false, false)
    Wait(animData.duration)
end

local function SpawnCoverObject(plate, data)
    local offset    = Config.VehicleCover.CoverOffsets[data.coverModel] or vec3(0.0, 0.0, 0.0)
    local objCoords = vector3(data.coords.x + offset.x, data.coords.y + offset.y, data.coords.z + offset.z)
    local hash      = lib.requestModel(data.coverModel) --[[@as number]]
    local obj       = CreateObjectNoOffset(hash, objCoords.x, objCoords.y, objCoords.z, false, false, false)

    SetEntityHeading(obj, data.heading)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, true, true)
    SetModelAsNoLongerNeeded(hash)

    localCoverObjects[plate] = obj

    exports.ox_target:addLocalEntity(obj, {
        {
            name     = "uncover_vehicle_" .. plate,
            label    = "Takarás eltávolítása",
            icon     = "fas fa-car",
            distance = 1.4,
            onSelect = function()
                if IsPlayerDeadNow() then return NotifyDead() end

                PlayAnimAndWait(UNCOVER_ANIM)

                -- Az anim alatt is meghalhatott: újraellenőrzés a server event előtt.
                if IsPlayerDeadNow() then return NotifyDead() end

                TriggerEvent('interact:playsound', "carcover.mp3")
                exports.gs_eventprotect:GS_TriggerServerEvent("bc_kocsitorles:uncoverVehicle", plate)
                -- TriggerServerEvent("bc_kocsitorles:uncoverVehicle", plate)
            end,
        },
        {
            name     = "impound_vehicle_" .. plate,
            label    = "Jármű lefoglalása",
            icon     = "fas fa-car-crash",
            distance = 1.4,
            canInteract = function()
                local job = ESX.GetPlayerData().job
                return job and Config.MechanicJobs[job.name] == true
            end,
            onSelect = function()
                if IsPlayerDeadNow() then return NotifyDead() end

                PlayAnimAndWait(UNCOVER_ANIM)

                if IsPlayerDeadNow() then return NotifyDead() end

                TriggerEvent('interact:playsound', "carcover.mp3")
                exports.gs_eventprotect:GS_TriggerServerEvent("bc_kocsitorles:impoundVehicle", plate)
            end,
        }
    })
end

local function RemoveCoverObject(plate)
    local obj = localCoverObjects[plate]
    if not obj then return end
    exports.ox_target:removeLocalEntity(obj)
    if DoesEntityExist(obj) then DeleteObject(obj) end
    localCoverObjects[plate] = nil
end

RegisterNetEvent("bc_kocsitorles:syncCoveredVehicles", function(data)
    coveredVehiclesList = data or {}

    for plate in pairs(localCoverObjects) do
        if not coveredVehiclesList[plate] then
            RemoveCoverObject(plate)
        end
    end
end)

RegisterNetEvent("bc_kocsitorles:vehicleCovered", function(plate, data)
    if not plate or not data then return end
    coveredVehiclesList[plate] = data
end)

RegisterNetEvent("bc_kocsitorles:vehicleUncovered", function(plate)
    if not plate then return end
    coveredVehiclesList[plate] = nil
    RemoveCoverObject(plate)
end)

CreateThread(function()
    while true do
        Wait(1000)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for plate, data in pairs(coveredVehiclesList) do
            local objCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
            local dist      = #(playerCoords - objCoords)

            if dist < LOAD_DISTANCE and not localCoverObjects[plate] then
                SpawnCoverObject(plate, data)
            elseif dist > UNLOAD_DISTANCE and localCoverObjects[plate] then
                RemoveCoverObject(plate)
            end
        end
    end
end)

CreateThread(function()
    Wait(4000)
exports.ox_target:addGlobalVehicle({
    {
        name        = "cover_vehicle",
        label       = "Jármű letakarása",
        icon        = "fas fa-car-side",
       -- items       = Config.VehicleCover.item,
        distance    = 2.4,
        onSelect    = function(data)
            if IsPlayerDeadNow() then return NotifyDead() end

            local vehicle = data.entity
            if not DoesEntityExist(vehicle) then return end

            local can = lib.callback.await('canCoverVehicle', false)
            if not can then 
                return TriggerEvent("esx:showNotification", "Neked már van letakart autód!")
            end 

            local plate        = GetVehicleNumberPlateText(vehicle):match("^%s*(.-)%s*$")
            local vehicleClass = GetVehicleClass(vehicle)
            local coverModel   = Config.VehicleCover.CoverTypes[vehicleClass]

            if not coverModel or coverModel == "" then
                coverModel = Config.VehicleCover.CoverModels[1]
            end

            local coords  = GetEntityCoords(vehicle)
            local heading = GetEntityHeading(vehicle)
            local model   = GetEntityModel(vehicle)

            local data = ESX.Game.GetVehicleProperties(vehicle)

            PlayAnimAndWait(COVER_ANIM)

            -- Az anim alatt is meghalhatott: újraellenőrzés a server event előtt.
            if IsPlayerDeadNow() then return NotifyDead() end

            TriggerEvent('interact:playsound', "carcover.mp3")
            exports.gs_eventprotect:GS_TriggerServerEvent("bc_kocsitorles:coverVehicle", plate, {
                model   = model,
                coords  = { x = coords.x, y = coords.y, z = coords.z },
                heading = heading,
                data = data
            }, coverModel)

            -- TriggerServerEvent("bc_kocsitorles:coverVehicle", plate, {
            --     model   = model,
            --     coords  = { x = coords.x, y = coords.y, z = coords.z },
            --     heading = heading,
            -- }, coverModel)
        end,
        canInteract = function(vehicle)
            --print("doesexists")
            if not DoesEntityExist(vehicle) then return false end

            local vehState = Entity(vehicle).state
            local myData = ESX.GetPlayerData()

            --print("fromgarage")
            if not vehState.fromGarage then return false end

            --print("idcheck")
            if myData.identifier == vehState.owner or myData.job.name == vehState.owner then
                --print("ok")
                return true
            end

            return false
        end,
    }
})
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    TriggerServerEvent("bc_kocsitorles:requestCoveredVehicles")
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for plate, obj in pairs(localCoverObjects) do
        exports.ox_target:removeLocalEntity(obj)
        if DoesEntityExist(obj) then DeleteObject(obj) end
        localCoverObjects[plate] = nil
    end
end)

--------------------------------------------------------------------------------
-- Letakart járművek 3D felirata (admin nametag rajzolási + streaming logika alapján).
-- Mindenki látja, aki <= 8 m-re van egy takart járműtől. NINCS új net event:
-- a már szinkronizált `coveredVehiclesList` cache-ből dolgozik.
--------------------------------------------------------------------------------

local TAG_RENDER_DISTANCE <const> = 8.0
local isTagRendering = false

---@param text string
---@param scale number
---@param yOffset number
local function DrawTagLine(text, scale, yOffset, r, g, b, a)
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 205)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.0, yOffset)
end

local function TagRenderLoop()
    isTagRendering = true

    while true do
        local myPos  = GetEntityCoords(PlayerPedId())
        local hasAny = false

        for plate, data in pairs(coveredVehiclesList) do
            if data.coords then
                local pos  = vector3(data.coords.x, data.coords.y, data.coords.z)
                local dist = #(myPos - pos)

                if dist <= TAG_RENDER_DISTANCE then
                    hasAny = true

                    -- A felirat a TÉNYLEGES takaró objektum tetejéhez igazodik (modellenként
                    -- eltérő magasság, a bounding boxból számolva), nem a tárolt jármű-koordinátához.
                    local headPos
                    local obj = localCoverObjects[plate]
                    if obj and DoesEntityExist(obj) then
                        local oc        = GetEntityCoords(obj)
                        local _, dimMax = GetModelDimensions(GetEntityModel(obj))
                        headPos = vector3(oc.x, oc.y, oc.z + dimMax.z + 0.30)
                    else
                        headPos = vector3(pos.x, pos.y, pos.z + 1.0)
                    end

                    if IsSphereVisible(headPos.x, headPos.y, headPos.z, 0.2) then
                        SetDrawOrigin(headPos.x, headPos.y, headPos.z, 0)
                        DrawTagLine("LETAKART AUTÓ", 0.30, -0.018, 170, 170, 170, 200)
                        DrawTagLine(plate, 0.45, 0.0, 255, 255, 255, 235)
                        ClearDrawOrigin()
                    end
                end
            end
        end

        if not hasAny then break end
        Wait(0)
    end

    isTagRendering = false
end

-- Nagy-wait figyelő thread: csak akkor indítja a 0-tick rajzoló loopot, ha
-- ténylegesen van takart jármű a közelben (mint az admin nametagnél).
CreateThread(function()
    while true do
        local myPos  = GetEntityCoords(PlayerPedId())
        local nearby = false

        for _, data in pairs(coveredVehiclesList) do
            if data.coords and #(myPos - vector3(data.coords.x, data.coords.y, data.coords.z)) <= TAG_RENDER_DISTANCE then
                nearby = true
                break
            end
        end

        if nearby and not isTagRendering then
            CreateThread(TagRenderLoop)
        end

        Wait(500)
    end
end)
