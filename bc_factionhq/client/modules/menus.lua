--[[
    FactionHQ - in-game menu screens (client)

    Every HQ menu built on the animated NUI menu: entry (member/guest),
    invite, access management, allied factions, police breach,
    vacant-spot purchase and the admin spot manager. Pure UI flow - all decisions are re-validated
    server-side. Main injects the live state getters via Menus.Init().
]]

local HQMenu = require 'client.modules.menu'
local HQShell = require 'client.modules.shell'
local HQMarker = require 'client.modules.marker'
local HQMinigame = require 'client.modules.minigame'

local Menus = {}

-- Injected by client/main.lua: { getMyJob = fn }
local deps = {
    getMyJob = function() return nil end,
}

function Menus.Init(d)
    deps = d
end

local function notify(msg)
    if ESX and ESX.ShowNotification then ESX.ShowNotification(msg) else
        TriggerEvent('esx:showNotification', msg) end
end

-- Native on-screen keyboard: the NUI menu is select-only, so free text
-- (e.g. a job name) is typed here. cb(text) on confirm, cb(nil) on cancel.
local function promptText(key, title, maxLen, cb)
    AddTextEntry(key, title)
    DisplayOnscreenKeyboard(1, key, '', '', '', '', '', maxLen or 30)
    CreateThread(function()
        while UpdateOnscreenKeyboard() == 0 do Wait(0) end
        if UpdateOnscreenKeyboard() == 1 then
            cb(GetOnscreenKeyboardResult())
        else
            cb(nil)
        end
    end)
end

--======================================================================
-- Guest invite / access management (owned HQ, member side)
--======================================================================
local function openInviteMenu(s)
    local pc = GetEntityCoords(PlayerPedId())
    local ids = {}
    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local d = #(pc - GetEntityCoords(GetPlayerPed(playerId)))
            if d < Config.InviteMaxDistance then
                ids[#ids + 1] = GetPlayerServerId(playerId)
            end
        end
    end
    if #ids == 0 then
        notify('Nincs jatekos a kozelben.')
        return Menus.OpenEntry(s)
    end

    ESX.TriggerServerCallback('FactionHQ:Server:GetNearbyInvitable', function(list)
        if not list or #list == 0 then
            notify('Nincs behivhato jatekos a kozelben.')
            return Menus.OpenEntry(s)
        end
        local items = {}
        for _, p in ipairs(list) do
            items[#items + 1] = {
                id = tostring(p.serverId), label = p.label,
                desc = 'Állandó belépési engedély', icon = 'invite',
            }
        end
        HQMenu.Open({
            title = 'Játékos behívása',
            subtitle = 'A közelben álló játékosok',
            items = items,
        }, function(id)
            if not id then return Menus.OpenEntry(s) end
            TriggerServerEvent('FactionHQ:Server:GrantAccess', tonumber(id))
        end)
    end, ids)
end

local function openAccessMenu(s)
    ESX.TriggerServerCallback('FactionHQ:Server:GetAccessList', function(list)
        if list == nil then return notify('Ehhez boss rang kell.') end
        if #list == 0 then
            notify('Nincs kiadott engedely.')
            return Menus.OpenEntry(s)
        end
        local items = {}
        for _, a in ipairs(list) do
            items[#items + 1] = { id = a.identifier, label = a.name, desc = a.identifier, icon = 'access' }
        end
        HQMenu.Open({
            title = 'Belépési engedélyek',
            subtitle = 'Válassz a visszavonáshoz',
            items = items,
        }, function(identifier)
            if not identifier then return Menus.OpenEntry(s) end
            HQMenu.Open({
                title = 'Engedély visszavonása',
                subtitle = 'Biztos vagy benne?',
                items = {
                    { id = 'yes', label = 'Igen, visszavonom', icon = 'trash', danger = true },
                    { id = 'no', label = 'Mégse', icon = 'back' },
                },
            }, function(v)
                if v == 'yes' then
                    TriggerServerEvent('FactionHQ:Server:RevokeAccess', identifier)
                else
                    openAccessMenu(s)
                end
            end)
        end)
    end)
end

--======================================================================
-- Allied factions (owned HQ, boss side): a whole faction gets entry,
-- no per-player invite. One-way - it only opens OUR door.
--======================================================================
local openAllyMenu

local function confirmAddAlly(s, job, label)
    HQMenu.Open({
        title = 'Szövetséges hozzáadása',
        subtitle = ('%s — biztos vagy benne?'):format(label or job),
        items = {
            { id = 'yes', label = 'Igen, szövetséges lesz', desc = 'Minden tagjuk beléphet a HQ-ba', icon = 'check' },
            { id = 'no', label = 'Mégse', icon = 'back' },
        },
    }, function(v)
        if v == 'yes' then
            TriggerServerEvent('FactionHQ:Server:AddAlly', job)
        else
            openAllyMenu(s)
        end
    end)
end

local function openAllyAdd(s)
    ESX.TriggerServerCallback('FactionHQ:Server:GetAlliableJobs', function(list)
        if list == nil then return notify('Ehhez boss rang kell.') end

        local items = {
            { id = '__manual', label = 'Frakció nevének beírása', desc = 'Ha nincs a listában (job név)', icon = 'access' },
        }
        for _, j in ipairs(list) do
            items[#items + 1] = { id = j.job, label = j.label, desc = j.job, icon = 'users' }
        end

        HQMenu.Open({
            title = 'Szövetséges frakció',
            subtitle = ('%d frakció közül választhatsz'):format(#list),
            items = items,
        }, function(job)
            if not job then return openAllyMenu(s) end
            -- The picker only carries the job name, so the label is looked
            -- up from the same list (typed input is normalized first, the
            -- server lowercases it the same way)
            local function labelOf(name)
                for _, j in ipairs(list) do
                    if j.job == name then return j.label end
                end
                return name
            end

            if job == '__manual' then
                return promptText('FHQ_ALLY', 'Szovetseges frakcio (job) neve', 50, function(typed)
                    if not typed or typed == '' then return openAllyAdd(s) end
                    typed = typed:gsub('%s+', ''):lower()
                    if typed == '' then return openAllyAdd(s) end
                    confirmAddAlly(s, typed, labelOf(typed))
                end)
            end
            confirmAddAlly(s, job, labelOf(job))
        end)
    end)
end

openAllyMenu = function(s)
    ESX.TriggerServerCallback('FactionHQ:Server:GetAllyList', function(list)
        if list == nil then return notify('Ehhez boss rang kell.') end

        -- The limit is enforced server-side too; here it only greys the
        -- add row out so the boss sees WHY it is unavailable
        local max = Config.Allies.max or 1
        local full = #list >= max

        local items = {
            {
                id = '__add', label = 'Szövetséges hozzáadása', icon = 'invite',
                desc = full and ('Betelt: maximum %d szövetséges — előbb bontsd fel'):format(max)
                    or 'Egy teljes frakció kap belépést',
                disabled = full,
            },
        }
        for _, a in ipairs(list) do
            items[#items + 1] = {
                id = a.job, label = a.label, desc = 'Szövetség felbontása', icon = 'users', danger = true,
            }
        end
        items[#items + 1] = { id = '__back', label = 'Vissza', icon = 'back' }

        HQMenu.Open({
            title = 'Szövetséges frakciók',
            subtitle = #list == 0 and ('Jelenleg nincs szövetséges · max %d'):format(max)
                or ('%d / %d szövetséges frakció'):format(#list, max),
            items = items,
        }, function(id)
            if not id or id == '__back' then return Menus.OpenEntry(s) end
            if id == '__add' then return openAllyAdd(s) end

            local label = id
            for _, a in ipairs(list) do
                if a.job == id then label = a.label break end
            end
            HQMenu.Open({
                title = 'Szövetség felbontása',
                subtitle = ('%s — biztos vagy benne?'):format(label),
                items = {
                    { id = 'yes', label = 'Igen, felbontom', desc = 'A tagjaik nem léphetnek be többé', icon = 'trash', danger = true },
                    { id = 'no', label = 'Mégse', icon = 'back' },
                },
            }, function(v)
                if v == 'yes' then
                    TriggerServerEvent('FactionHQ:Server:RemoveAlly', id)
                else
                    openAllyMenu(s)
                end
            end)
        end)
    end)
end

--======================================================================
-- Entry menu (member/guest at an owned HQ)
--======================================================================
function Menus.OpenEntry(s)
    local items = {
        { id = 'enter', label = 'Belépés', desc = 'Belépés a frakció HQ-jába', icon = 'enter' },
    }
    if deps.getMyJob() == s.job then
        -- Shown to every member; the server enforces boss/coboss rank
        items[#items + 1] = { id = 'invite', label = 'Játékos behívása', desc = 'Állandó engedély külsősnek', icon = 'invite' }
        items[#items + 1] = { id = 'access', label = 'Engedélyek kezelése', desc = 'Kiadott engedélyek visszavonása', icon = 'access' }
        items[#items + 1] = { id = 'allies', label = 'Szövetséges frakciók', desc = 'Egész frakció beengedése', icon = 'users' }
    end

    HQMenu.Open({
        title = ('%s HQ'):format(s.label or 'Frakció'),
        subtitle = 'Frakció főhadiszállás',
        items = items,
    }, function(id)
        if id == 'enter' then
            HQShell.Enter(s.job)
        elseif id == 'invite' then
            openInviteMenu(s)
        elseif id == 'access' then
            openAccessMenu(s)
        elseif id == 'allies' then
            openAllyMenu(s)
        end
    end)
end

--======================================================================
-- Police breach + cop menu (whitelisted jobs at an owned HQ)
--======================================================================
-- Must stay at the door and stay alive for the whole breach
local function breachGuardBroken(entry)
    local pc = GetEntityCoords(PlayerPedId())
    return #(pc - entry) > Config.EnterMaxDistance or IsEntityDead(PlayerPedId())
end

local function startBreach(s)
    if HQMinigame.IsActive() then return end
    ESX.TriggerServerCallback('FactionHQ:Server:RaidBegin', function(ok, breakTimeOrMsg)
        if not ok then
            if type(breakTimeOrMsg) == 'string' then notify(breakTimeOrMsg) end
            return
        end
        local breakTime = tonumber(breakTimeOrMsg) or Config.Raid.breakTime
        local entry = vector3(s.coords.x, s.coords.y, s.coords.z)
        local startedAt = GetGameTimer()
        local aborted = false

        local function cancel(msg)
            if aborted then return end
            aborted = true
            HQMinigame.Abort()
            TriggerServerEvent('FactionHQ:Server:RaidCancel', s.job)
            if msg then notify(msg) end
        end

        -- Distance/alive guard runs alongside the minigame: leaving the door
        -- or dying cancels the breach.
        CreateThread(function()
            while HQMinigame.IsActive() and not aborted do
                Wait(200)
                if breachGuardBroken(entry) then cancel('A feltores megszakadt.') end
            end
        end)

        HQMinigame.Start(Config.Raid.minigame, function(success)
            if aborted then return end
            if not success then
                aborted = true
                -- failed = true -> the faction gets a chat warning server-side
                TriggerServerEvent('FactionHQ:Server:RaidCancel', s.job, true)
                return notify('Nem sikerult feltorni a bejaratot. Probald ujra.')
            end

            -- The server enforces a minimum breach time (anti-cheat). If the
            -- minigame was cleared faster, hold at the door for the remainder
            -- so a quick run is never silently rejected.
            CreateThread(function()
                while not aborted and (GetGameTimer() - startedAt) < (breakTime * 1000) do
                    Wait(100)
                    if breachGuardBroken(entry) then return cancel('A feltores megszakadt.') end
                    HQMarker.DrawText2D(0.5, 0.10, 'Bejarat feltorese... ~g~majdnem kesz~s~', 0.45, true)
                end
                if aborted then return end
                ESX.TriggerServerCallback('FactionHQ:Server:RaidFinish', function(ok2, msg)
                    if not ok2 and msg then notify(msg) end
                end, s.job)
            end)
        end)
    end, s.job)
end

function Menus.OpenCop(s)
    HQMenu.Open({
        title = ('%s HQ'):format(s.label or 'Frakció'),
        subtitle = 'Házkutatás — rendvédelem',
        items = {
            { id = 'breach', label = 'Bejárat feltörése', desc = 'Zárfeltörő minigame — maradj a bejáratnál', icon = 'breach', danger = true },
            { id = 'enter', label = 'Belépés', desc = 'Csak aktív házkutatás alatt', icon = 'enter' },
        },
    }, function(id)
        if id == 'breach' then
            startBreach(s)
        elseif id == 'enter' then
            HQShell.Enter(s.job)
        end
    end)
end

--======================================================================
-- Vacant spot: choose interior -> preview / buy
--======================================================================
function Menus.OpenBuy(s)
    local items = {}
    for _, def in ipairs(Config.Interiors) do
        items[#items + 1] = { id = def.key, label = def.label, desc = 'Megtekintés vagy vásárlás', icon = 'house' }
    end

    HQMenu.Open({
        title = 'Eladó Frakció HQ',
        subtitle = ('Ár: %s $ a frakciókasszából'):format(ESX.Math.GroupDigits(Config.HQPrice)),
        items = items,
    }, function(key)
        if not key then return end
        local def = Config.GetInterior(key)
        if not def then return end
        HQMenu.Open({
            title = def.label,
            subtitle = 'Frakció HQ interior',
            items = {
                { id = 'preview', label = 'Megtekintés', desc = 'Bejárás vásárlás előtt (Backspace: vissza)', icon = 'preview' },
                { id = 'buy', label = 'Megvásárlás', desc = 'A frakciókasszából, végleges', right = ESX.Math.GroupDigits(Config.HQPrice) .. ' $', icon = 'buy' },
                { id = 'back', label = 'Vissza', icon = 'back' },
            },
        }, function(v)
            if v == 'preview' then
                HQShell.Preview(key)
            elseif v == 'buy' then
                ESX.TriggerServerCallback('FactionHQ:Server:BuyHQ', function(_, msg)
                    if msg then notify(msg) end
                end, s.id, key)
            elseif v == 'back' or v == nil then
                Menus.OpenBuy(s)
            end
        end)
    end)
end

--======================================================================
-- Admin spot manager (/fkhqadmin; the list arrives ace-validated)
--======================================================================
function Menus.OpenAdmin(list)
    local items = {}
    for i, s in ipairs(list) do
        local label, desc
        if s.job then
            label = ('#%d — %s'):format(s.id, s.jobLabel or s.job)
            desc = ('%s · bent: %d'):format(s.interiorLabel or '?', s.occupancy or 0)
        else
            label = ('#%d — szabad'):format(s.id)
            desc = 'Megvásárolható pont'
        end
        items[#items + 1] = { id = tostring(i), label = label, desc = desc, icon = 'house' }
    end

    HQMenu.Open({
        title = 'Frakció HQ pontok',
        subtitle = ('%d pont · /%s: új pont lerakása'):format(#list, Config.Commands.place),
        items = items,
    }, function(idx)
        local s = idx and list[tonumber(idx)]
        if not s then return end

        local sub = {
            { id = 'tp', label = 'Teleport ide', desc = ('%.1f, %.1f, %.1f'):format(s.coords.x, s.coords.y, s.coords.z), icon = 'tp' },
            { id = 'move', label = 'Áthelyezés ide', desc = 'A pont a jelenlegi pozíciódra kerül', icon = 'house' },
        }
        if s.job then
            sub[#sub + 1] = { id = 'reassign', label = 'Frakció átírása', desc = 'Másik frakció kapja meg ezt a HQ-t', icon = 'invite' }
            sub[#sub + 1] = { id = 'free', label = 'Frakció eltávolítása', desc = 'A HQ felszabadul, a bentiek kikerülnek', icon = 'trash', danger = true }
        else
            sub[#sub + 1] = { id = 'assign', label = 'Frakció hozzáadása', desc = 'Üres pontra frakció + interior (ingyen)', icon = 'house' }
            sub[#sub + 1] = { id = 'delete', label = 'Pont törlése', desc = 'Csak szabad pont törölhető', icon = 'trash', danger = true }
        end
        sub[#sub + 1] = { id = 'back', label = 'Vissza', icon = 'back' }

        HQMenu.Open({
            title = ('#%d kezelése'):format(s.id),
            subtitle = s.job and (s.jobLabel or s.job) or 'Szabad pont',
            items = sub,
        }, function(v)
            if v == 'tp' then
                local c = s.coords
                SetEntityCoords(PlayerPedId(), c.x, c.y, c.z + 0.5, false, false, false, false)
                if c.h then SetEntityHeading(PlayerPedId(), c.h + 0.0) end
            elseif v == 'move' then
                TriggerServerEvent('FactionHQ:Server:AdminMoveSpot', s.id)
            elseif v == 'reassign' then
                promptText('FHQ_REASSIGN', 'Uj frakcio (job) neve', 50, function(newJob)
                    if not newJob or newJob == '' then return Menus.OpenAdmin(list) end
                    HQMenu.Open({
                        title = ('#%d átírása'):format(s.id),
                        subtitle = ('Új frakció: %s'):format(newJob),
                        items = {
                            { id = 'yes', label = 'Igen, átírom', desc = 'A HQ a beírt frakcióhoz kerül', icon = 'check', danger = true },
                            { id = 'no', label = 'Mégse', icon = 'back' },
                        },
                    }, function(c)
                        if c == 'yes' then
                            TriggerServerEvent('FactionHQ:Server:AdminReassign', s.id, newJob)
                        else
                            Menus.OpenAdmin(list)
                        end
                    end)
                end)
            elseif v == 'assign' then
                promptText('FHQ_ASSIGN', 'Frakcio (job) neve', 50, function(newJob)
                    if not newJob or newJob == '' then return Menus.OpenAdmin(list) end
                    local items = {}
                    for _, def in ipairs(Config.Interiors) do
                        items[#items + 1] = { id = def.key, label = def.label, desc = 'Belső kinézet', icon = 'house' }
                    end
                    HQMenu.Open({
                        title = ('#%d — frakció hozzáadása'):format(s.id),
                        subtitle = ('Frakció: %s · válassz interiort'):format(newJob),
                        items = items,
                    }, function(interiorKey)
                        if not interiorKey then return Menus.OpenAdmin(list) end
                        TriggerServerEvent('FactionHQ:Server:AdminCreateHQ', s.id, newJob, interiorKey)
                    end)
                end)
            elseif v == 'free' then
                TriggerServerEvent('FactionHQ:Server:AdminRemoveFaction', s.id)
            elseif v == 'delete' then
                TriggerServerEvent('FactionHQ:Server:AdminDeleteSpot', s.id)
            elseif v == 'back' or v == nil then
                Menus.OpenAdmin(list)
            end
        end)
    end)
end

return Menus
