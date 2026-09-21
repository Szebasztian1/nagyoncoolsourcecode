-- The old command-based inspection dialogs (openInspection / openMassInspection
-- / openJobInspection) are replaced by the Műszaki Terminál NUI (client_nui.lua),
-- which detects the nearby customer and issues the same server events.


local hasMedClearance = false

RegisterNetEvent("bc_tax:setMedClearance", function(state)
    hasMedClearance = state
end)

local hasMechanicClearance = false

RegisterNetEvent("bc_tax:setMechanicClearance", function(state)
    hasMechanicClearance = state
end)
exports("hasMechanicalClearance", function()
    return hasMechanicClearance
end)

-- NPC availability, pushed by the server whenever the online job counts change.
-- These must be declared BEFORE the handler below: a local declared later in the
-- file is not in scope here, so the assignments would silently create globals
-- while canInteract keeps reading the (never updated) locals.
--- @type boolean
local npcInspectionActive = false
--- @type boolean
local npcClearanceActive = false
--- @type boolean
local npcAmbClearanceActive = false

RegisterNetEvent("bc_tax:setNpcState", function(mechActive, copActive, ambActive)
    npcInspectionActive   = mechActive
    npcClearanceActive    = copActive
    npcAmbClearanceActive = ambActive
end)

AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    if not weapon then return end
    if MEDCLEARANCE_WEAPON_WHITELIST[weapon.name] then return end
    if MEDCLEARANCE_JOB_WHITELIST[ESX.PlayerData.job.name] then return end
    if not hasMedClearance then
        TriggerEvent("esx:showNotification",
            "Nincs érvényes alkalmassági vizsgálatod! Nem használhatsz fegyvert. Keress fel egy kórházi vezetőt.")
        TriggerServerEvent("bc_tax:requestDisarm")
    end
end)

RegisterNetEvent("bc_tax:openMedClearance", function()
    local input = lib.inputDialog('Alkalmassági vizsgálat (2 hétre érvényes)', { 'Játékos ID' })
    if not input then return end
    TriggerServerEvent("bc_tax:addMedClearance", input[1])
end)

RegisterNetEvent("bc_tax:openMechanicClearance", function()
    local input = lib.inputDialog('Szerelési engedély (2 hétre érvényes)', { 'Játékos ID' })
    if not input then return end
    TriggerServerEvent("bc_tax:addMechanicClearance", input[1])
end)

RegisterNetEvent("bc_tax:giveDocument", function(data)
    TriggerServerEvent('k5_documents:createServerDocument', data)
end)

--- @type number|nil
local npcInspectionPed = nil
--- @type number|nil
local npcInspectionBlip = nil

--- @type number|nil
local npcClearancePed = nil
--- @type number|nil
local npcClearanceBlip = nil

--- @type number|nil
local npcAmbClearancePed = nil
--- @type number|nil
local npcAmbClearanceBlip = nil


--- @param plate string
--- @param cost number
local function openNpcInspectionConfirm(plate, cost)
    local result = lib.alertDialog({
        header   = "NPC Műszaki Vizsga",
        content  = ("Rendszám: %s\n\nÁr: $%s\n\nA műszaki 2 hónapig lesz érvényes."):format(plate, cost),
        confirm  = "Kiváltom ($" .. cost .. ")",
        cancel   = "Mégse",
        centered = true,
        size     = "md",
    })
    if result ~= "confirm" then return end

    if lib.progressBar({
            duration     = NPC_INSPECTION.progressTime,
            label        = "Műszaki vizsga folyamatban...",
            useWhileDead = false,
            canCancel    = false,
            disable      = { car = true, move = true, combat = true },
            anim         = { scenario = "WORLD_HUMAN_CLIPBOARD" },
        }) then
        TriggerServerEvent("bc_tax:npcInspection", plate)
    else
        lib.notify({ title = "Műszaki", description = "Megszakítva!", type = "error" })
    end
end

--- @param plates string[]
--- @param totalCost number
local function openNpcMassInspectionConfirm(plates, totalCost)
    local result = lib.alertDialog({
        header   = "NPC Tömeges Műszaki Vizsga",
        content  = ("Összes autó: %d\n\nTeljes ár: $%s\n\nA műszaki 2 hónapig lesz érvényes.\n\nIdőtartam: 15 perc")
            :format(#plates, totalCost),
        confirm  = "Kifizetem ($" .. totalCost .. ")",
        cancel   = "Mégse",
        centered = true,
        size     = "md",
    })
    if result ~= "confirm" then return end

    if lib.progressBar({
            duration     = 15 * 60 * 1000,
            label        = "Tömeges műszaki vizsga folyamatban...",
            useWhileDead = false,
            canCancel    = false,
            disable      = { car = true, move = true, combat = true },
            anim         = { scenario = "WORLD_HUMAN_CLIPBOARD" },
        }) then
        TriggerServerEvent("bc_tax:npcMassInspection")
    else
        lib.notify({ title = "Műszaki", description = "Megszakítva!", type = "error" })
    end
end

local function openNpcInspectionMenu()
    ESX.TriggerServerCallback("bc_tax:getMyCars", function(mycars)
        if not mycars or #mycars == 0 then
            lib.notify({ title = "Nincs autód", description = "Nincs autód.", type = "error" })
            return
        end

        --- @type table[]
        local options = {}
        local cost = NPC_INSPECTION.cost

        --- @type string[]
        local uninspectedPlates = {}
        for _, v in pairs(mycars) do
            if v.insptimeleft == "-" then
                uninspectedPlates[#uninspectedPlates + 1] = v.plate
            end
        end

        if #uninspectedPlates > 1 then
            local totalCost = #uninspectedPlates * cost
            options[#options + 1] = {
                title       = "Összes autó műszakiztatása egyszerre",
                description = #uninspectedPlates .. " autó | Teljes ár: $" .. totalCost .. " | 15 perc",
                onSelect    = function()
                    openNpcMassInspectionConfirm(uninspectedPlates, totalCost)
                end,
            }
        end

        for _, v in pairs(mycars) do
            if v.insptimeleft == "-" then
                local plate = v.plate
                options[#options + 1] = {
                    title       = "Rendszám: " .. plate,
                    description = "Műszaki: nincs érvényes | Ár: $" .. cost,
                    onSelect    = function()
                        openNpcInspectionConfirm(plate, cost)
                    end,
                }
            end
        end

        if #options == 0 then
            lib.notify({ title = "NPC Műszaki", description = "Minden autódon van érvényes műszaki!", type = "inform" })
            return
        end

        lib.registerContext({
            id      = "npc_inspection_menu",
            title   = "NPC Műszaki Vizsga ($" .. cost .. ")",
            options = options,
        })
        lib.showContext("npc_inspection_menu")
    end)
end

-- The clearance NPCs run an exam instead of a straight purchase. The panel lives
-- in the NUI; client_nui.lua handles this client-internal event. The kind picks
-- the question pool and the licence granted (see CLEARANCE_EXAMS in config.lua).
local function openNpcClearanceConfirm()
    TriggerEvent("Tax:Client:OpenExam", "mechanic")
end

-- Weapon (med) clearance NPC: firearms exam, same panel, different question pool.
local function openAmbNpcClearanceConfirm()
    TriggerEvent("Tax:Client:OpenExam", "med")
end

--- Create a frozen, client-side only NPC ped.
--- Returns nil when the model fails to stream in (lib.requestModel returns false
--- on timeout, and CreatePed then hands back 0 — which is truthy in Lua). The
--- caller must not cache that handle, otherwise the ped is gone for the rest of
--- the session and never retried.
--- @param cfg table
--- @return number|nil
local function createNpcPed(cfg)
    local ok, model = pcall(lib.requestModel, cfg.model, 10000)
    if not ok or not model then return nil end

    local ped = CreatePed(4, model, cfg.coords.x, cfg.coords.y, cfg.coords.z - 1.0, cfg.coords.w, false, true)
    SetModelAsNoLongerNeeded(model)

    if not ped or ped == 0 or not DoesEntityExist(ped) then return nil end

    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    return ped
end

--- @param ped number|nil
local function deleteNpcPed(ped)
    if not ped or not DoesEntityExist(ped) then return end
    exports.ox_target:removeLocalEntity(ped)
    DeleteEntity(ped)
end

local function spawnNpcInspection()
    if npcInspectionPed then return end
    npcInspectionPed = createNpcPed(NPC_INSPECTION)
    if not npcInspectionPed then return end
    exports.ox_target:addLocalEntity(npcInspectionPed, {
        {
            name        = "npc_inspection",
            label       = "Műszaki Vizsga Kiváltása ($" .. NPC_INSPECTION.cost .. ")",
            icon        = "fas fa-wrench",
            -- Szándékosan nincs canInteract: a target akkor is látszik, amíg
            -- elég szerelő van fent, hogy a játékos üzenetet kapjon a néma
            -- eltűnés helyett. A tényleges kiváltást a szerver újra ellenőrzi.
            onSelect    = function()
                if not npcInspectionActive then
                    lib.notify({
                        title       = "Műszaki",
                        description = "Jelenleg elég szerelő van fent, keresd meg őket!",
                        type        = "inform",
                    })
                    return
                end
                openNpcInspectionMenu()
            end,
        },
    })
end

local function spawnNpcClearance()
    if npcClearancePed then return end
    npcClearancePed = createNpcPed(NPC_MECHANIC_CLEARANCE)
    if not npcClearancePed then return end
    exports.ox_target:addLocalEntity(npcClearancePed, {
        {
            name        = "npc_clearance",
            label       = "Szerelési vizsga ($" .. NPC_MECHANIC_CLEARANCE.cost .. ")",
            icon        = "fas fa-id-card",
            -- Szándékosan nincs canInteract (lásd npc_inspection): látszó
            -- target + üzenet a néma eltűnés helyett; a szerver újra ellenőriz.
            onSelect    = function()
                if not npcClearanceActive then
                    lib.notify({
                        title       = "Szerelési vizsga",
                        description = "Jelenleg elég rendvédelmi van szolgálatban, keresd meg őket!",
                        type        = "inform",
                    })
                    return
                end
                openNpcClearanceConfirm()
            end,
        },
    })
end

local function spawnAmbNpcClearance()
    if npcAmbClearancePed then return end
    npcAmbClearancePed = createNpcPed(NPC_AMBULANCE_CLEARANCE)
    if not npcAmbClearancePed then return end
    exports.ox_target:addLocalEntity(npcAmbClearancePed, {
        {
            name        = "amb_npc_clearance",
            label       = "Fegyvertartási vizsga ($" .. NPC_AMBULANCE_CLEARANCE.cost .. ")",
            icon        = "fas fa-id-card",
            -- Szándékosan nincs canInteract (lásd npc_inspection): látszó
            -- target + üzenet a néma eltűnés helyett; a szerver újra ellenőriz.
            onSelect    = function()
                if not npcAmbClearanceActive then
                    lib.notify({
                        title       = "Fegyvertartási vizsga",
                        description = "Jelenleg elég mentős van szolgálatban, keresd meg őket!",
                        type        = "inform",
                    })
                    return
                end
                openAmbNpcClearanceConfirm()
            end,
        },
    })
end

local function setNpcInspectionBlip(visible)
    if visible and not npcInspectionBlip then
        local cfg = NPC_INSPECTION
        if cfg.blipSprite == 0 then return end -- 0 = no blip (config.lua)
        npcInspectionBlip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(npcInspectionBlip, cfg.blipSprite)
        SetBlipDisplay(npcInspectionBlip, 4)
        SetBlipScale(npcInspectionBlip, cfg.blipScale)
        SetBlipColour(npcInspectionBlip, cfg.blipColour)
        SetBlipAsShortRange(npcInspectionBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(cfg.blipLabel)
        EndTextCommandSetBlipName(npcInspectionBlip)
    elseif not visible and npcInspectionBlip then
        RemoveBlip(npcInspectionBlip)
        npcInspectionBlip = nil
    end
end

local function setNpcClearanceBlip(visible)
    if visible and not npcClearanceBlip then
        local cfg = NPC_MECHANIC_CLEARANCE
        if cfg.blipSprite == 0 then return end -- 0 = no blip (config.lua)
        npcClearanceBlip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(npcClearanceBlip, cfg.blipSprite)
        SetBlipDisplay(npcClearanceBlip, 4)
        SetBlipScale(npcClearanceBlip, cfg.blipScale)
        SetBlipColour(npcClearanceBlip, cfg.blipColour)
        SetBlipAsShortRange(npcClearanceBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(cfg.blipLabel)
        EndTextCommandSetBlipName(npcClearanceBlip)
    elseif not visible and npcClearanceBlip then
        RemoveBlip(npcClearanceBlip)
        npcClearanceBlip = nil
    end
end

local function setAmbNpcClearanceBlip(visible)
    if visible and not npcAmbClearanceBlip then
        local cfg = NPC_AMBULANCE_CLEARANCE
        if cfg.blipSprite == 0 then return end -- 0 = no blip (config.lua)
        npcAmbClearanceBlip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(npcAmbClearanceBlip, cfg.blipSprite)
        SetBlipDisplay(npcAmbClearanceBlip, 4)
        SetBlipScale(npcAmbClearanceBlip, cfg.blipScale)
        SetBlipColour(npcAmbClearanceBlip, cfg.blipColour)
        SetBlipAsShortRange(npcAmbClearanceBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(cfg.blipLabel)
        EndTextCommandSetBlipName(npcAmbClearanceBlip)
    elseif not visible and npcAmbClearanceBlip then
        RemoveBlip(npcAmbClearanceBlip)
        npcAmbClearanceBlip = nil
    end
end

-- The handle is always cleared, even when the entity is already gone: keeping a
-- stale handle would block every later spawn attempt.
local function despawnNpcInspection()
    deleteNpcPed(npcInspectionPed)
    npcInspectionPed = nil
end

local function despawnNpcClearance()
    deleteNpcPed(npcClearancePed)
    npcClearancePed = nil
end

local function despawnAmbNpcClearance()
    deleteNpcPed(npcAmbClearancePed)
    npcAmbClearancePed = nil
end

--- Pull the current NPC availability from the server.
--- Wrapped in pcall and retried: ox_lib rejects the callback promise when the
--- server-side callback is not registered yet (or the request times out), and an
--- uncaught error here would kill the init thread. Without a valid response every
--- NPC would stay disabled until the server pushes the next bc_tax:setNpcState.
local function refreshNpcState()
    for _ = 1, 5 do
        local ok, counts = pcall(lib.callback.await, 'bc_tax:getOnlineCounts', false)
        if ok and counts then
            npcInspectionActive   = counts.mechanics < NPC_MIN_MECHANICS
            npcClearanceActive    = counts.cops < NPC_MIN_CLEARANCE_COPS
            npcAmbClearanceActive = counts.amb < NPC_MIN_CLEARANCE_AMB
            return
        end
        Wait(2000)
    end
end

--- @type boolean
local npcsInitialised = false

local function initNpcs()
    -- Both esx:playerLoaded and onResourceStart fire on join, so this runs twice
    -- and would register every zone twice.
    if npcsInitialised then return end
    npcsInitialised = true

    Wait(2000)
    setNpcInspectionBlip(true)
    setNpcClearanceBlip(true)
    setAmbNpcClearanceBlip(true)

    -- Zones are registered before the state fetch on purpose: the fetch may retry
    -- for several seconds, and a failure there must never stop the NPCs spawning.
    local cfgInsp = NPC_INSPECTION
    lib.zones.sphere({
        coords  = vector3(cfgInsp.coords.x, cfgInsp.coords.y, cfgInsp.coords.z),
        radius  = 50.0,
        onEnter = function()
            spawnNpcInspection()
        end,
        onExit  = function()
            despawnNpcInspection()
        end,
    })

    local cfgClr = NPC_MECHANIC_CLEARANCE
    lib.zones.sphere({
        coords  = vector3(cfgClr.coords.x, cfgClr.coords.y, cfgClr.coords.z),
        radius  = 50.0,
        onEnter = function()
            spawnNpcClearance()
        end,
        onExit  = function()
            despawnNpcClearance()
        end,
    })

    local cfgAmb = NPC_AMBULANCE_CLEARANCE
    lib.zones.sphere({
        coords  = vector3(cfgAmb.coords.x, cfgAmb.coords.y, cfgAmb.coords.z),
        radius  = 50.0,
        onEnter = function()
            spawnAmbNpcClearance()
        end,
        onExit  = function()
            despawnAmbNpcClearance()
        end,
    })

    refreshNpcState()
end

-- ===================== Hamis Műszaki NPC =====================

---@param plate string
local function openFakeInspectionConfirm(plate)
    local result = lib.alertDialog({
        header   = "Hamis Műszaki Vásárlás",
        content  = ("Rendszám: %s\n\nÁr: $200,000\n\nAz igazolás 5 napig lesz érvényes.\n\n Figyelem: Ez az igazolás HAMIS, illegálisan kiállított dokumentum!")
            :format(plate),
        confirm  = "Megveszem ($200,000)",
        cancel   = "Mégse",
        centered = true,
        size     = "md",
    })
    if result ~= "confirm" then return end
    TriggerServerEvent("bc_tax:buyFakeInspection", plate)
end

local function openFakeInspectionMenu()
    ESX.TriggerServerCallback("bc_tax:getMyCars", function(mycars)
        if not mycars or #mycars == 0 then
            lib.notify({ title = "Nincs autód", description = "Nincs autód.", type = "error" })
            return
        end

        ---@type table[]
        local options = {}
        for _, v in pairs(mycars) do
            if v.insptimeleft == "-" then
                local plate = v.plate
                options[#options + 1] = {
                    title       = "Rendszám: " .. plate,
                    description = "Műszaki: nincs érvényes",
                    onSelect    = function()
                        openFakeInspectionConfirm(plate)
                    end,
                }
            end
        end

        if #options == 0 then
            lib.notify({ title = "Hamis Műszaki", description = "Minden autódon van érvényes műszaki!", type = "inform" })
            return
        end

        lib.registerContext({
            id      = "fake_inspection_menu",
            title   = "Hamis Műszaki Vásárlás",
            options = options,
        })
        lib.showContext("fake_inspection_menu")
    end)
end

local fakeNpc = nil

local function spawnFakeNpc()
    if fakeNpc then return end
    fakeNpc = createNpcPed(FAKE_INSPECTION_NPC)
    if not fakeNpc then return end
    exports.ox_target:addLocalEntity(fakeNpc, {
        {
            name     = "fake_inspection",
            label    = "Hamis Műszaki Vásárlása",
            icon     = "fas fa-file-alt",
            onSelect = openFakeInspectionMenu,
        },
    })
end

local function despawnFakeNpc()
    deleteNpcPed(fakeNpc)
    fakeNpc = nil
end

--- @type boolean
local fakeNpcInitialised = false

local function init()
    if fakeNpcInitialised then return end
    fakeNpcInitialised = true

    while not ESX.PlayerLoaded do
        Wait(100)
    end

    local cfg = FAKE_INSPECTION_NPC
    lib.zones.sphere({
        coords  = vector3(cfg.coords.x, cfg.coords.y, cfg.coords.z),
        radius  = 50.0,
        onEnter = function()
            spawnFakeNpc()
        end,
        onExit  = function()
            despawnFakeNpc()
        end,
    })
end

AddEventHandler('esx:playerLoaded', function()
    init()
    initNpcs()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    init()
    initNpcs()
end)

lib.callback.register('bc_tax:payforinsp', function(price)
    local conf = lib.alertDialog({
		header = 'Fizetés megerősítése',
		content = 'Kifizetsz ' .. price .. '$ a műszakiért?',
		centered = true,
		cancel = true
	})
	if conf == "confirm" then 
		return true 
	end 
	return false
end)

lib.callback.register('bc_tax:payforc', function(price)
    local conf = lib.alertDialog({
		header = 'Fizetés megerősítése',
		content = 'Kifizetsz ' .. price .. '$ az engedélyért?',
		centered = true,
		cancel = true
	})
	if conf == "confirm" then
		return true
	end
	return false
end)

-- ===================== Üzembehelyezési Engedély (NPC + panel) =====================
--
-- Ugyanaz az NPC szolgálja ki mindkét útvonalat: a jogosult identifierek
-- (UZEMBEHELYEZESJOBS) tulajdonosainak a panelt nyitja meg (client_nui.lua),
-- másoknak rendszám alapú self-service kiváltást kínál, de csak amíg
-- egyikük sincs fent — egyébként értesíti az online jogosultakat, és nem
-- enged self-service-t.

lib.callback.register('bc_tax:payforuzembe', function(price)
    local conf = lib.alertDialog({
        header   = 'Fizetés megerősítése',
        content  = 'Kifizetsz ' .. price .. '$ az üzembehelyezési engedélyért?',
        centered = true,
        cancel   = true,
    })
    return conf == "confirm"
end)

-- Frakciós kiváltásnál a fizetés módja: a frakció számlája (FK, csak ha a
-- szerver szerint jogosult rá) vagy a saját bankszámla. nil = mégse.
lib.callback.register('bc_tax:uzembeChoosePayment', function(total, count, jobLabel, canFk)
    local options = {}
    if canFk then
        options[#options + 1] = { value = "fk", label = "Frakció számla (FK)" }
    end
    options[#options + 1] = { value = "bank", label = "Saját bankszámla" }

    local input = lib.inputDialog(("Üzembehelyezés: %s (%d autó)"):format(jobLabel, count), {
        {
            type        = "select",
            label       = "Fizetés módja",
            description = "Fizetendő: " .. ESX.Math.GroupDigits(total) .. " $",
            options     = options,
            default     = options[1].value,
            required    = true,
        },
    })
    return input and input[1] or nil
end)

--- @return boolean
local function isUzembeJobMember()
    local identifier = ESX.PlayerData and ESX.PlayerData.identifier
    if not identifier then return false end
    for _, id in pairs(UZEMBEHELYEZESJOBS) do
        if id == identifier then return true end
    end
    return false
end

-- true amíg egyetlen jogosult job-tag sincs fent (self-service engedélyezve).
local uzembeNpcActive = false

RegisterNetEvent("bc_tax:setUzembeNpcState", function(active)
    uzembeNpcActive = active
end)

--- @type number|nil
local npcUzembePed = nil
--- @type number|nil
local npcUzembeBlip = nil

local function openUzembeSelfServiceMenu()
    local options = {
        {
            title       = "Összes autóm egyszerre",
            description = "Kiváltja az összes saját (civil) autódnak, amelyiknek nincs érvényes üzembehelyezési engedélye",
            icon        = "fas fa-layer-group",
            onSelect    = function()
                TriggerServerEvent("bc_tax:uzembeNpcMass")
            end,
        },
    }

    local job = ESX.GetPlayerData().job
    if job and job.name ~= "unemployed" then
        options[#options + 1] = {
            title       = "Frakciós autók",
            description = ("A frakciód (%s) összes olyan autójára, amelyiknek nincs érvényes engedélye. " ..
                "Fizethetsz a frakció számlájáról (FK) vagy a saját bankszámládról."):format(job.label or job.name),
            icon        = "fas fa-users",
            onSelect    = function()
                TriggerServerEvent("bc_tax:uzembeNpcFaction")
            end,
        }
    end

    options[#options + 1] = {
        title       = "Egy adott rendszám",
        description = "Üzembehelyezési engedély kiváltása egyetlen rendszámra",
        icon        = "fas fa-file-signature",
        onSelect    = function()
            local input = lib.inputDialog('Üzembehelyezési engedély kiváltása', { 'Rendszám' })
            if not input or not input[1] or input[1] == '' then return end
            TriggerServerEvent("bc_tax:uzembeNpcSingle", input[1])
        end,
    }

    lib.registerContext({
        id      = "npc_uzembe_self_menu",
        title   = "Üzembehelyezési Engedély",
        options = options,
    })
    lib.showContext("npc_uzembe_self_menu")
end

local function onUzembeNpcInteract()
    if isUzembeJobMember() then
        TriggerEvent("Tax:Client:OpenUzembehelyezes")
    elseif not uzembeNpcActive then
        lib.notify({
            title       = "Üzembehelyezés",
            description = "Jelenleg van ügyintéző szolgálatban, keresd meg őket!",
            type        = "inform",
        })
        TriggerServerEvent("bc_tax:uzembeInquireBlocked")
    else
        openUzembeSelfServiceMenu()
    end
end

--- Only the license configured in UZEMBEHELYEZES_CP_LICENSE sees this option
--- at all — the server independently re-checks it before paying out.
--- @return boolean
local function isUzembeCpOwner()
    local pd = ESX.PlayerData
    return pd ~= nil and pd.identifier ~= nil and pd.identifier == UZEMBEHELYEZES_CP_LICENSE
end

local function withdrawUzembeCp()
    local balance = lib.callback.await('bc_tax:uzembeGetCpBalance', false)
    if not balance then
        lib.notify({ title = "Céges pénztárca", description = "Nincs jogosultságod.", type = "error" })
        return
    end
    if balance <= 0 then
        lib.notify({ title = "Céges pénztárca", description = "Üres a pénztárca.", type = "inform" })
        return
    end

    local result = lib.alertDialog({
        header   = "Céges pénztárca felvétele",
        content  = ("Jelenlegi egyenleg: $%s\n\nFelveszed a teljes összeget a bankszámládra?"):format(balance),
        confirm  = "Felveszem",
        cancel   = "Mégse",
        centered = true,
        size     = "md",
    })
    if result ~= "confirm" then return end

    TriggerServerEvent("bc_tax:uzembeWithdrawCp")
end

-- Kapcsoló a jogosult kiállítóknak: bekapcsolva az NPC akkor is kiszolgálja
-- a játékosokat, amíg ügyintéző van fent (pl. ha épp más dolga van). A
-- kapcsoló szerver-oldalon, csak memóriában él — restartkor automata
-- alapállásra tér vissza.
local function openUzembeForceMenu()
    local force = lib.callback.await('bc_tax:uzembeGetForceState', false)
    if force == nil then
        lib.notify({ title = "Üzembehelyezés", description = "Nincs jogosultságod.", type = "error" })
        return
    end

    local result = lib.alertDialog({
        header   = "NPC ügyintézés kapcsolása",
        content  = force
            and "Jelenlegi állapot: **NPC-s ügyintézés bekapcsolva** — az NPC akkor is kiszolgál, amíg ügyintéző van fent.  \n\nVisszakapcsolod automata módra (amíg ügyintéző van fent, az NPC hozzátok irányít)?"
            or "Jelenlegi állapot: **automata mód** — az NPC csak akkor szolgál ki, ha egyik ügyintéző sincs fent.  \n\nBekapcsolod az NPC-s ügyintézést (az NPC akkor is kiszolgál, amíg fent vagytok)?",
        centered = true,
        cancel   = true,
        size     = "md",
        labels   = { confirm = "Átkapcsolom", cancel = "Mégse" },
    })
    if result ~= "confirm" then return end

    TriggerServerEvent("bc_tax:uzembeToggleForce")
end

local function spawnNpcUzembe()
    if npcUzembePed then return end
    npcUzembePed = createNpcPed(NPC_UZEMBEHELYEZES)
    if not npcUzembePed then return end
    exports.ox_target:addLocalEntity(npcUzembePed, {
        {
            name     = "npc_uzembehelyezes",
            label    = "Üzembehelyezési Engedély",
            icon     = "fas fa-file-signature",
            onSelect = onUzembeNpcInteract,
        },
        {
            name        = "npc_uzembehelyezes_kapcsolo",
            label       = "NPC ügyintézés kapcsolása",
            icon        = "fas fa-toggle-on",
            canInteract = isUzembeJobMember,
            onSelect    = openUzembeForceMenu,
        },
        {
            name        = "npc_uzembehelyezes_cp",
            label       = "Céges pénztárca felvétele",
            icon        = "fas fa-vault",
            canInteract = isUzembeCpOwner,
            onSelect    = withdrawUzembeCp,
        },
    })
end

local function despawnNpcUzembe()
    deleteNpcPed(npcUzembePed)
    npcUzembePed = nil
end

local function setNpcUzembeBlip(visible)
    if visible and not npcUzembeBlip then
        local cfg = NPC_UZEMBEHELYEZES
        if cfg.blipSprite == 0 then return end -- 0 = no blip (config.lua)
        npcUzembeBlip = AddBlipForCoord(cfg.coords.x, cfg.coords.y, cfg.coords.z)
        SetBlipSprite(npcUzembeBlip, cfg.blipSprite)
        SetBlipDisplay(npcUzembeBlip, 4)
        SetBlipScale(npcUzembeBlip, cfg.blipScale)
        SetBlipColour(npcUzembeBlip, cfg.blipColour)
        SetBlipAsShortRange(npcUzembeBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(cfg.blipLabel)
        EndTextCommandSetBlipName(npcUzembeBlip)
    elseif not visible and npcUzembeBlip then
        RemoveBlip(npcUzembeBlip)
        npcUzembeBlip = nil
    end
end

--- Pull the current üzembehelyezés NPC availability from the server. Retried
--- like refreshNpcState, for the same reason (callback may not be registered
--- yet on a cold start).
local function refreshUzembeNpcState()
    for _ = 1, 5 do
        local ok, state = pcall(lib.callback.await, 'bc_tax:getUzembeNpcState', false)
        if ok and state ~= nil then
            uzembeNpcActive = state == true
            return
        end
        Wait(2000)
    end
end

--- @type boolean
local uzembeNpcInitialised = false

local function initUzembeNpc()
    if uzembeNpcInitialised then return end
    uzembeNpcInitialised = true

    Wait(2000)
    setNpcUzembeBlip(true)

    local cfg = NPC_UZEMBEHELYEZES
    lib.zones.sphere({
        coords  = vector3(cfg.coords.x, cfg.coords.y, cfg.coords.z),
        radius  = 50.0,
        onEnter = function()
            spawnNpcUzembe()
        end,
        onExit  = function()
            despawnNpcUzembe()
        end,
    })

    refreshUzembeNpcState()
end

AddEventHandler('esx:playerLoaded', function()
    initUzembeNpc()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    initUzembeNpc()
end)