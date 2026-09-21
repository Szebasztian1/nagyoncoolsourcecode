--[[
    bc_tax - Műszaki Terminál (NUI) client entry

    Panel control only: open on the server's go-ahead (item used by a mechanic),
    resolve the closest customer for the mass/faction views, and forward an
    "issue" to the existing bc_tax inspection events. The diagnostic checklist is
    gated in the NUI; the server re-checks the passed flag before issuing.
]]

local uiOpen = false
--- @type number|nil  server id of the nearby customer chosen for mass/faction
local targetSid = nil

local function closeUI()
    if not uiOpen then return end
    uiOpen = false
    targetSid = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

-- Server told us this mechanic may open the terminal (item used + job checked).
RegisterNetEvent("Tax:Client:OpenTerminal", function()
    if uiOpen or IsNuiFocused() then return end
    uiOpen = true
    SetNuiFocus(true, true)

    local pd = ESX.GetPlayerData()
    SendNUIMessage({
        action    = "open",
        mechanic  = (pd and pd.name) or "Szerelő",
        job       = (pd and pd.job and (pd.job.label or pd.job.name)) or "-",
        fee       = INSPECTIONPERCAR,
        validDays = math.floor(INSPECTIONTIME / 86400),
        checklist = INSPECTION_CHECKLIST,
    })
end)

RegisterNUICallback("close", function(_, cb)
    closeUI()
    cb({ ok = true })
end)

-- Mass / faction view: find the closest customer and return their uninspected
-- vehicles. The closest-player check is client-side (needs local coords); the
-- server validates the target and owns the vehicle data.
RegisterNUICallback("getTarget", function(data, cb)
    local mode = (data and data.mode) or "mass"

    local closest, dist = ESX.Game.GetClosestPlayer()
    if closest == -1 or dist > 3.0 then
        return cb({ ok = false, reason = "no_target" })
    end

    ESX.TriggerServerCallback("Tax:Server:GetTargetVehicles", function(res)
        if not res then
            return cb({ ok = false, reason = "invalid" })
        end
        targetSid = res.id
        res.ok = true
        cb(res)
    end, mode, GetPlayerServerId(closest))
end)

-- Issue the inspection. Reuses the existing server events; the server enforces
-- the diagnostic gate (diagPassed) alongside job/ownership/price checks.
RegisterNUICallback("issue", function(data, cb)
    local mode = data and data.mode
    local diagPassed = (data and data.diagPassed) == true

    if mode == "single" then
        local plate = data and data.plate
        if type(plate) == "string" and #plate > 0 then
            TriggerServerEvent("bc_tax:addInspection", plate, diagPassed)
        end
    elseif mode == "mass" and targetSid then
        TriggerServerEvent("bc_tax:addMassInspection", targetSid, diagPassed)
    elseif mode == "faction" and targetSid then
        TriggerServerEvent("bc_tax:addJobInspection", targetSid, diagPassed)
    end

    closeUI()
    cb({ ok = true })
end)

--======================================================================
-- Fegyvertartási vizsga (clearance NPC)
--======================================================================

-- Client-internal event fired by the clearance NPC target (client.lua). The
-- server validates and charges before the panel opens; the correct answers stay
-- server-side, so the NUI only ever sees questions and options.
AddEventHandler("Tax:Client:OpenExam", function(kind)
    if uiOpen or IsNuiFocused() then return end
    kind = kind or "mechanic"

    ESX.TriggerServerCallback("Tax:Server:StartClearanceExam", function(res)
        if not res then return end

        if not res.ok then
            local msg = "A vizsga most nem indítható."
            if res.reason == "npc_inactive" then
                -- A két vizsga gate-je más létszámhoz kötött: mechanic → rendvédelmi,
                -- med → mentős (lásd IsClearanceNpcActive / IsAmbClearanceNpcActive).
                msg = (kind == "med")
                    and "Jelenleg elég mentős van szolgálatban, keresd meg őket!"
                    or "Jelenleg elég rendvédelmi van szolgálatban, keresd meg őket!"
            elseif res.reason == "has_clearance" then
                msg = "Már van érvényes engedélyed!"
            elseif res.reason == "cooldown" then
                -- Not necessarily a failed test: a perfect one can lose the roll too.
                msg = "A kérelmedet elutasították. Újra próbálhatod: " .. (res.retryAt or "-")
            elseif res.reason == "no_money" then
                msg = "Nincs elég pénzed a vizsgadíjra! ($" .. (res.cost or 0) .. ")"
            end
            return TriggerEvent("esx:showNotification", msg)
        end

        uiOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action      = "openExam",
            questions   = res.questions,
            cost        = res.cost,
            chance      = res.chance,
            retryHours  = res.retryHours,
            eyebrow     = res.eyebrow,
            title       = res.title,
            titleAccent = res.titleAccent,
        })
    end, kind)
end)

-- The server grades the answers, rolls the chance and returns the outcome,
-- which the panel shows on its result screen.
RegisterNUICallback("submitExam", function(data, cb)
    local answers = data and data.answers
    if type(answers) ~= "table" then
        return cb({ ok = false })
    end

    ESX.TriggerServerCallback("Tax:Server:SubmitClearanceExam", function(res)
        cb(res or { ok = false })
    end, answers)
end)

AddEventHandler("onClientResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    if uiOpen then SetNuiFocus(false, false) end
end)

--======================================================================
-- Üzembehelyezési engedély (panel, a jogosult identifierekhez — ugyanaz az
-- NPC nyitja meg, lásd client.lua onUzembeNpcInteract). Külön NUI
-- callbackek, a terminál open/getTarget/issue callbackjei változatlanok.
--======================================================================

--- @type number|nil  server id of the target chosen for tömeges/frakciós mód
local uzembeTargetSid = nil

AddEventHandler("Tax:Client:OpenUzembehelyezes", function()
    if uiOpen or IsNuiFocused() then return end
    uiOpen = true
    uzembeTargetSid = nil
    SetNuiFocus(true, true)

    local pd = ESX.GetPlayerData()
    SendNUIMessage({
        action          = "openUzembe",
        issuer          = (pd and pd.name) or "Ügyintéző",
        job             = (pd and pd.job and (pd.job.label or pd.job.name)) or "-",
        validDays       = math.floor(UZEMBEHELYEZESTIME / 86400),
        minFee          = UZEMBEHELYEZES_MIN_FEE,
        maxFee          = UZEMBEHELYEZES_MAX_FEE,
        feeRatePercent  = UZEMBEHELYEZES_FEE_RATE * 100,
        discountChance  = UZEMBEHELYEZES_BATCH_CHANCE,
        discountPercent = UZEMBEHELYEZES_BATCH_DISCOUNT,
    })
end)

-- Egyedi mód: rendszám alapján kér ár- és tulaj-előnézetet a szervertől.
RegisterNUICallback("uzembeGetPlateInfo", function(data, cb)
    local plate = data and data.plate
    if type(plate) ~= "string" or #plate == 0 then
        return cb({ ok = false, reason = "invalid_plate" })
    end

    ESX.TriggerServerCallback("bc_tax:uzembeGetPlateInfo", function(res)
        cb(res or { ok = false })
    end, plate)
end)

-- Tömeges / frakciós mód: a terminál getTarget mintáját követi (közeli
-- játékos, 3 m), de a bc_tax:uzembeGetTargetVehicles callbacket hívja.
RegisterNUICallback("uzembeGetTarget", function(data, cb)
    local mode = (data and data.mode) or "mass"

    local closest, dist = ESX.Game.GetClosestPlayer()
    if closest == -1 or dist > 3.0 then
        return cb({ ok = false, reason = "no_target" })
    end

    ESX.TriggerServerCallback("bc_tax:uzembeGetTargetVehicles", function(res)
        if not res then
            return cb({ ok = false, reason = "invalid" })
        end
        uzembeTargetSid = res.id
        res.ok = true
        cb(res)
    end, mode, GetPlayerServerId(closest))
end)

-- Kiállítás: a szerver kéri a tényleges (vagyon alapú) díj kifizetésének
-- megerősítését a tulajtól (bc_tax:payforuzembe), itt csak a megfelelő
-- eventet indítjuk el.
RegisterNUICallback("uzembeIssue", function(data, cb)
    local mode = data and data.mode

    if mode == "single" then
        local plates = data and data.plates
        if type(plates) == "table" and #plates > 0 then
            TriggerServerEvent("bc_tax:uzembeIssueBatch", plates)
        end
    elseif mode == "mass" and uzembeTargetSid then
        TriggerServerEvent("bc_tax:uzembeIssueMass", uzembeTargetSid)
    elseif mode == "faction" and uzembeTargetSid then
        TriggerServerEvent("bc_tax:uzembeIssueJob", uzembeTargetSid)
    end

    uzembeTargetSid = nil
    closeUI()
    cb({ ok = true })
end)
