function crafting:Awake(...)
    while not ESX.IsPlayerLoaded() do Citizen.Wait(0); end
    self.Tables = {}
    self.CraftingItems = {}
    for k, v in pairs(Recipes) do
        for k, v in pairs(v) do
            if v and not self.CraftingItems[v] then
                self.CraftingItems[v] = v
            end
        end
    end
    self.Open = false;
    self.Blueprints = {}
    self.PlayerData = ESX.GetPlayerData();
    TriggerServerEvent('crafting:Start')
end

function crafting:Respond(...)
    local args = { ... }
    self.SpawnedTables = {}
    self.CraftingTables = args[3] or {}
    self.Learned = args[2] or {}
    self.Blueprints = args[4] or {} -- name -> 9-slot layout, bought ones only
    self:SetResetIn(args[5] or 0)
    self:SetupPoints()
    self:Update()
end

---Stores the reshuffle deadline locally so the countdown needs no server round trips.
function crafting:SetResetIn(seconds)
    self.ResetDeadline = GetGameTimer() + ((tonumber(seconds) or 0) * 1000)
end

---@return number seconds until the next reshuffle
function crafting:GetResetIn()
    if not self.ResetDeadline then return 0 end
    return math.max(0, math.floor((self.ResetDeadline - GetGameTimer()) / 1000))
end

function crafting:SetupPoints()
    if self.ActivePoints then
        for _, pt in pairs(self.ActivePoints) do
            pt:remove()
        end
    end
    self.ActivePoints = {}
    self.PointGeneration = (self.PointGeneration or 0) + 1

    -- Wipe the props before rebuilding. Removing a point does NOT fire its onExit, so a
    -- picked-up bench would stay in the world forever; and the keys below are the old
    -- position values, which no longer match the ones the server just sent, so surviving
    -- benches would be spawned a second time. Points re-spawn what is still in range.
    for pos in pairs(self.SpawnedTables or {}) do
        self:DespawnTable(pos)
    end
    self.SpawnedTables = {}

    for _, v in pairs(self.CraftingTables) do
        local tablePos = v
        local pt = lib.points.new({
            coords   = vector3(tablePos.x, tablePos.y, tablePos.z),
            distance = self.LoadTableDist,
            onEnter  = function()
                if not crafting.SpawnedTables[tablePos] then
                    crafting:SpawnTable(tablePos)
                end
            end,
            onExit   = function()
                crafting:DespawnTable(tablePos)
            end,
        })
        self.ActivePoints[#self.ActivePoints + 1] = pt
    end
end

function crafting:Update(...)
    local interactText = "Nyomj [~r~E~s~]-t a craftoláshoz. ~n~ [X] az asztal felvételéhez"
    CreateThread(function()
        while true do
            local closest, closestDist = self:GetClosestTable()
            if closestDist and closestDist < self.DrawTextDist then
                DrawText3D(closest.x, closest.y, closest.z + 1.5, interactText, 100.0, true)
                if IsControlJustPressed(0, 38) then
                    self:UseTable(closest)
                elseif IsControlJustPressed(0, 73) then
                    TriggerServerEvent('crafting:RemoveTable', vector3(closest.x, closest.y, closest.z))
                    Wait(5000)
                end
            else
                Wait(500)
            end
            Wait(1)
        end
    end)
end

function crafting:SpawnTable(pos)
    local generation = self.PointGeneration
    self.SpawnedTables[pos] = true
    local hash = GetHashKey(self.BenchModel)
    RequestModel(hash);
    local starttime = GetGameTimer()
    while not HasModelLoaded(hash) do
        RequestModel(hash); Citizen.Wait(0);
        if (GetGameTimer() - starttime) > 2000 then
            break
        end
    end

    -- SetupPoints may have rebuilt everything while the model loaded; this spawn is
    -- stale then, and creating it would leave a prop nothing can despawn.
    if generation ~= self.PointGeneration then
        SetModelAsNoLongerNeeded(hash)
        return
    end

    local newTable = CreateObject(hash, pos.x, pos.y, pos.z, false, false, false) or nil
    SetEntityHeading(newTable, pos.w)
    SetEntityAsMissionEntity(newTable, true, true)
    FreezeEntityPosition(newTable, true)
    self.SpawnedTables[pos] = newTable
    SetModelAsNoLongerNeeded(hash)
end

function crafting:DespawnTable(pos)
    local obj = self.SpawnedTables[pos]
    self.SpawnedTables[pos] = nil
    -- may still be `true` while the model is loading, so only delete a real handle
    if type(obj) ~= 'number' or not DoesEntityExist(obj) then return end
    SetEntityAsMissionEntity(obj, true, true)
    DeleteObject(obj)
    DeleteEntity(obj)
end

function crafting:UseTable(pos)
    print("using", pos)
    print(self.SpawnedTables[pos])
    if (type(self.SpawnedTables[pos]) == "table") then
        print(json.encode(self.SpawnedTables[pos]))
    end
    local right, fwd, up, posB = GetEntityMatrix(self.SpawnedTables[pos])
    local tPos = pos.xyz + (fwd * 0.8)
    local pPos = GetEntityCoords(PlayerPedId())
    --if (GetXYDist(pPos.x, pPos.y, pPos.z, tPos.x, tPos.y, tPos.z) > 1.1) then
    --    TaskGoStraightToCoord(PlayerPedId(), tPos.x, tPos.y, tPos.z, 10.0, 10, pos.w + 90.0, 0.5)
    --end
    -- while (GetXYDist(pPos.x, pPos.y, pPos.z, tPos.x, tPos.y, tPos.z) > 1.15) do
    --     pPos = GetEntityCoords(PlayerPedId()); Citizen.Wait(0);
    -- end

    Citizen.Wait(1500);

    -- pulled fresh on every open: the player's job (and their faction's type) can change
    self.Faction = lib.callback.await('crafting:GetFactionInfo', false)

    self.Open = false
    self.Crafting = true
    self:DoUi();
    -- Blocks the interaction thread while the panel is open so it stops drawing the
    -- prompt / re-triggering on E. Polled slowly on purpose: no Wait(0) busy loop.
    while self.Crafting do Citizen.Wait(150); end

    FreezeEntityPosition(PlayerPedId(), false)
end

function crafting:GetClosestTable()
    local closest, closestDist
    local pos = GetEntityCoords(PlayerPedId())
    for k, v in pairs(self.CraftingTables) do
        local dist = GetXYDist(pos.x, pos.y, pos.z, v.x, v.y, v.z)
        if not closestDist or dist < closestDist then
            closest = v
            closestDist = dist
        end
    end
    if closest then return closest, closestDist else return false, 999999; end
end

---Counts for the craft keys. They are kept out of the draggable ingredient list on
---purpose (they never go on the grid), but the catalog has to show whether you have one.
---@return table item name -> owned count
function crafting:GetExtraCounts()
    local counts = {}
    for _, key in pairs(ExtraNeedItems) do
        if type(key) == 'string' and not counts[key] then
            counts[key] = exports.ox_inventory:Search('count', key) or 0
        end
    end
    return counts
end

---Builds the NUI payload. Grid layouts are sent ONLY for blueprints the player
---has bought; every other recipe is positionless (ingredient counts only), so the
---arrangement stays a puzzle.
function crafting:BuildUiPayload()
    local craftingItems = {}
    for itemname, _ in pairs(self.CraftingItems) do
        local count = exports.ox_inventory:Search('count', itemname)
        if count > 0 then
            table.insert(craftingItems, { name = itemname, count = count })
        end
    end

    local oxItems = exports.ox_inventory:Items()
    local labels = {}
    local function addLabel(name)
        if not name or labels[name] then return end
        local it = oxItems[name]
        if not it and string.find(name, "weapon_") then
            it = oxItems[string.upper(name)]
        end
        labels[name] = (it and it.label) or name
    end

    local catalog = {}
    local blueprints = {}
    for name, recipe in pairs(Recipes) do
        addLabel(name)

        -- collapse the 9 slots into a positionless {item, count} list
        local counts, order = {}, {}
        for i = 1, 9 do
            local ing = recipe[i]
            if ing then
                addLabel(ing)
                if not counts[ing] then
                    counts[ing] = 0
                    order[#order + 1] = ing
                end
                counts[ing] = counts[ing] + 1
            end
        end

        local ingredients = {}
        for _, ing in ipairs(order) do
            ingredients[#ingredients + 1] = { name = ing, count = counts[ing] }
        end

        -- required but never placed on the grid, so it is not part of `ingredients`
        local extra = ExtraNeedItems[name]
        if type(extra) ~= 'string' then extra = nil end
        addLabel(extra)

        catalog[#catalog + 1] = {
            name        = name,
            weapon      = self:IsWeapon(name),
            price       = self:GetBlueprintPrice(name),
            reward      = RecipeRewards[name] or 1,        -- how many the craft yields
            types       = self:GetRequiredCraftTypes(name), -- banda / maffia, empty = anyone
            ingredients = ingredients,
            extra       = extra,
        }

        -- the real arrangement comes from the server's current shuffle, not from
        -- recipes.lua (which only defines WHICH ingredients a recipe needs)
        if self.Blueprints and self.Blueprints[name] then
            blueprints[name] = self.Blueprints[name]
        end
    end

    return {
        type       = 'openUI',
        items      = craftingItems,
        extras     = self:GetExtraCounts(),
        labels     = labels,
        catalog    = catalog,
        blueprints = blueprints,
        resetIn    = self:GetResetIn(),
        faction    = self.Faction,
        costs      = {
            weapon       = WEAPONPRICE,
            boost        = self.BoostPrice,
            boostSeconds = self.BoostReduction,

            -- A mennyiseg-csuszkahoz: a felso hatar es a keszpenz, amibol a
            -- fegyver-dijat fizetni kell. A csuszka ezekbol szamol maximumot,
            -- de ez CSAK kijelzes -- a szerver minden darabot kulon ellenoriz.
            maxAmount    = self.MaxCraftAmount or 1,
            cash         = (ESX.GetPlayerData() or {}).money or 0,
        },
    }
end

function crafting:DoUi(...)
    self.Open = not self.Open
    local payload = self:BuildUiPayload()
    payload.enable = self.Open
    SendNUIMessage(payload)
    SetNuiFocus(self.Open, self.Open)
end

---Re-sends the payload without toggling the open state (e.g. after a purchase).
function crafting:RefreshUi()
    if not self.Open then return end
    local payload = self:BuildUiPayload()
    payload.enable = true
    SendNUIMessage(payload)
end

---Brings the panel back after an aborted craft (progress cancelled, price declined).
---PostData hid the grid, and self.Open is still true, so DoUi() would toggle it CLOSED —
---refresh instead, which also restores the workbench contents and re-reads item counts.
function crafting:ReopenPanel()
    self.Crafting = true
    self:RefreshUi()
    SetNuiFocus(true, true)
end

---Asks the server what the arrangement makes. The layouts are reshuffled periodically and
---only live server-side, so this cannot be resolved on the client.
---@param grid table 9 entries, item name or false
---@return string? name matched recipe
function crafting:MatchRecipe(grid)
    return lib.callback.await('crafting:MatchRecipe', false, grid)
end

---@param data string matched recipe name
---@param amount number|nil how many to craft in one go (the panel's quantity slider)
function crafting:PostData(data, amount)
    --print(data)
    if data then
        amount = math.floor(tonumber(amount) or 1)
        if amount < 1 then amount = 1 end
        if amount > (self.MaxCraftAmount or 1) then amount = self.MaxCraftAmount or 1 end

        local plyPed = PlayerPedId()
        SendNUIMessage({ type = 'hideGrid' })

        local dict = 'anim@amb@business@coc@coc_unpack_cut_left@'
        local anim = 'coke_cut_v5_coccutter'
        while not HasAnimDictLoaded(dict) do
            RequestAnimDict(dict)
            Citizen.Wait(0);
        end;

        local plyData = ESX.GetPlayerData()
        local factionType = self.Faction and self.Faction.switched and self.Faction.type or nil
        if not self:IsCraftAllowed(plyData.job.name, plyData.identifier, factionType, data) then
            ESX.ShowNotification(self:GetDenyMessage(data, self.Faction and self.Faction.type))
            self:ReopenPanel()
            return
        end

        -- Key, cash and ingredients are checked BEFORE the timer: the refusal used to
        -- come after the full craft time (and after paid speed-ups).
        local check = lib.callback.await('crafting:PreCheck', false, data)
        if not check or not check.ok then
            ESX.ShowNotification((check and check.msg) or 'Most nem tudod ezt elkészíteni!')
            self:ReopenPanel()
            return
        end

        -- Asked up front for the same reason: nobody should wait out the craft only to
        -- decide about the fee afterwards.
        if self:IsWeapon(data) then
            -- Kotegnel a TELJES osszeget mondjuk meg. A darabarat kiirni es
            -- tizszer annyit levonni a legrosszabb fajta meglepetes lenne.
            local feeText = amount > 1
                and (amount .. ' db fegyver craftolása összesen ' .. (WEAPONPRICE * amount) ..
                     '$ ba kerül pluszba (' .. WEAPONPRICE .. '$ / db), csak készpénzbe')
                or  ('A fegyver craftolása ' .. WEAPONPRICE .. '$ ba kerül pluszba, csak készpénzbe')

            local conf = lib.alertDialog({
                header = 'Fegyver craft',
                content = feeText,
                centered = true,
                cancel = true
            })
            if conf ~= 'confirm' then
                self:ReopenPanel()
                return
            end
            -- the dialog drops NUI focus on close; the progress overlay's own
            -- speed-up / cancel buttons need it back
            SetNuiFocus(true, true)
        end

        local craftTime = (CraftTime[data] or 3.0)

        local modifieditem = data
        if string.find(data, "weapon_") then modifieditem = string.upper(data) end
        local itemLabel = (exports.ox_inventory:Items()[modifieditem] and exports.ox_inventory:Items()[modifieditem].label) or
            data

        -- KOTEGELT CRAFT: darabonként egy teljes korre-idozito. Megszakitaskor
        -- ami mar elkeszult, az megmarad -- a szervernek a TENYLEGESEN vegigvitt
        -- darabszamot kuldjuk, nem azt, amit a jatekos kert.
        local done = 0

        for i = 1, amount do
            TaskPlayAnim(plyPed, dict, anim, 8.0, 8.0, craftTime * 1000, 1, 1.0, 0, 0, 0);

            SendNUIMessage({
                type         = 'startProgress',
                itemName     = data or '',
                itemLabel    = itemLabel or data or '',
                duration     = craftTime,
                boostPrice   = self.BoostPrice,
                boostSeconds = self.BoostReduction,
                current      = i,
                total        = amount,
            })

            if not self:RunProgress(craftTime, data, itemLabel) then break end

            done = done + 1
        end

        ClearPedTasksImmediately(plyPed)

        if done == 0 then
            self:ReopenPanel()
            return
        end

        --local plyInv = ESX.GetPlayerData().inventory
        local itemName

        if exports.ox_inventory:Items()[modifieditem] then
            itemName = exports.ox_inventory:Items()[modifieditem].label
        end

        if itemName then
            local learn = false
            if self.LearnOnCraft and not self.Learned[data] then
                learn = true
                self.Learned[data] = true
                ESX.ShowNotification("Megtanultad a receptet: " .. itemName)
            end
            TriggerServerEvent('crafting:TryCraft', data, itemName, learn, done)
        end

        -- The ingredients are gone, so empty the grid — but keep the panel open so the
        -- player can craft again without walking back into the bench.
        SendNUIMessage({ type = 'clearGrid' })
        self:ReopenPanel()
    end
end

function crafting:PlaceTable(...)
    local plyPed = PlayerPedId()
    local forward, right, up, pPos = GetEntityMatrix(plyPed)
    local pos = (pPos + forward)
    local heading = GetEntityHeading(plyPed)
    local location = vector4(pos.x, pos.y, pos.z - 1.0, heading - 90.0)
    ESX.ShowNotification("Elhelyeztél egy kézműves Craft Asztalt. Betöltés...")
    TriggerServerEvent('crafting:TablePlaced', location)
end

function crafting:SyncTables(data)
    self.CraftingTables = data
    self:SetupPoints()
end

---@param count number|nil how many pieces were actually produced (batch craft)
function crafting:CraftRespond(response, label, items, count)
    if response then
        count = tonumber(count) or 0
        if count > 1 then
            ESX.ShowNotification("Te készítetted: " .. count .. " db " .. label)
        else
            ESX.ShowNotification("Te készítetted: " .. label)
        end
    else
        ESX.ShowNotification("Nem sikerült elkészíteni: " .. label)
        for _, v in pairs(items or {}) do
            ESX.ShowNotification(v)
        end
    end
    -- stock changed on the server side, pull the fresh counts into the open panel
    self:RefreshUi()
end

RegisterNetEvent('crafting:PlaceTable')
AddEventHandler('crafting:PlaceTable', function(...) crafting:PlaceTable(...); end)

RegisterNetEvent('crafting:CraftRespond')
AddEventHandler('crafting:CraftRespond', function(...) crafting:CraftRespond(...); end)

RegisterNetEvent('crafting:BlueprintBought')
AddEventHandler('crafting:BlueprintBought', function(name, layout)
    crafting.Blueprints = crafting.Blueprints or {}
    crafting.Blueprints[name] = layout
    ESX.ShowNotification("Megvetted a munkapad tervet!")
    crafting:RefreshUi()
end)

RegisterNetEvent('crafting:FactionTypeChanged')
AddEventHandler('crafting:FactionTypeChanged', function(newType)
    if crafting.Faction then
        crafting.Faction.type = newType
        crafting.Faction.switched = true
    end
    ESX.ShowNotification("A frakciód craft típusa mostantól: ~b~" .. newType)
    crafting:RefreshUi()
end)

RegisterNetEvent('crafting:LayoutReset')
AddEventHandler('crafting:LayoutReset', function(resetIn)
    crafting.Blueprints = {}
    crafting:SetResetIn(resetIn)
    ESX.ShowNotification("~o~A munkapad elrendezések megváltoztak!~s~ A megvett tervek elavultak.")
    crafting:RefreshUi()
end)

RegisterNetEvent('crafting:Respond')
AddEventHandler('crafting:Respond', function(...) crafting:Respond(...); end)

RegisterNetEvent('crafting:SyncTables')
AddEventHandler('crafting:SyncTables', function(...) crafting:SyncTables(...); end)

---@param duration number craft time in seconds
---@param itemName string item being crafted
---@param itemLabel string display label
---@return boolean completed true if finished normally, false if cancelled
function crafting:RunProgress(duration, itemName, itemLabel)
    self.InProgress        = true
    self.ProgressCancelled = false
    self.ProgressBoost     = false

    local startTime        = GetGameTimer()
    local totalMs          = duration * 1000
    local reductionMs      = 0
    local boostCooldown    = 0

    while true do
        local elapsed   = GetGameTimer() - startTime + reductionMs
        local remaining = totalMs - elapsed

        if elapsed >= totalMs or self.ProgressCancelled then break end

        SendNUIMessage({
            type      = 'updateProgress',
            elapsed   = elapsed,
            total     = totalMs,
            remaining = remaining,
        })

        if self.ProgressBoost and GetGameTimer() > boostCooldown then
            self.ProgressBoost = false
            -- The server charges and answers; the local money cache could be stale,
            -- which used to shorten the timer without anything being paid.
            if lib.callback.await('crafting:PayBoost', false) then
                boostCooldown = GetGameTimer() + self.BoostCooldown
                reductionMs   = reductionMs + (self.BoostReduction * 1000)
                ESX.ShowNotification("~g~-" .. self.BoostReduction .. " másodperc! ~s~(-" .. self.BoostPrice .. "$)")
            else
                ESX.ShowNotification("~r~Nincs elég pénzed!~s~ (" .. self.BoostPrice .. "$ szükséges)")
                boostCooldown = GetGameTimer() + 1500
            end
        end

        if IsControlJustPressed(0, Keys["BACKSPACE"]) then
            self.ProgressCancelled = true
            break
        end

        Wait(100)
    end

    SendNUIMessage({ type = 'stopProgress' })
    self.InProgress = false
    return not self.ProgressCancelled
end

RegisterNUICallback('progressCancel', function(data, cb)
    crafting.ProgressCancelled = true
    if cb then cb(true) end
end)

RegisterNUICallback('progressBoost', function(data, cb)
    crafting.ProgressBoost = true
    if cb then cb(true) end
end)

RegisterNUICallback('dopost', function(data, cb)
    if cb then cb(true) end
    local grid = data and data.grid
    local amount = data and data.amount
    -- own thread: the match is a server round trip and PostData yields for the whole craft
    CreateThread(function()
        local name = crafting:MatchRecipe(grid)
        if name then
            crafting:PostData(name, amount)
        else
            ESX.ShowNotification("Ez az elrendezés nem ad ki semmit.")
        end
    end)
end)

RegisterNUICallback('buyBlueprint', function(data, cb)
    if data and type(data.name) == 'string' then
        TriggerServerEvent('crafting:BuyBlueprint', data.name)
    end
    if cb then cb(true) end
end)

RegisterNUICallback('switchFaction', function(data, cb)
    if data and type(data.type) == 'string' then
        TriggerServerEvent('crafting:SwitchFactionType', data.type, data.pay)
    end
    if cb then cb(true) end
end)
RegisterNUICallback('close', function(data, cb)
    crafting:DoUi()
    crafting.Crafting = false
    if cb then cb(true) end
end)

---@param duration number seconds per item
---@param itemName string internal item name (used for icon)
---@param itemLabel string display label shown in the UI
---@param numberOfItemToCraft number how many items to craft in sequence
---@param onComplete function? fired when all items are crafted
---@param onCancelled function? fired when the player cancels mid-way
---@return boolean completed true if all finished, false if cancelled
exports('StartProgressBar', function(duration, itemName, itemLabel, numberOfItemToCraft, onComplete, onCancelled)
    if crafting.InProgress then return false end
    numberOfItemToCraft = numberOfItemToCraft or 1
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'hideGrid' })
    for i = 1, numberOfItemToCraft do
        SendNUIMessage({
            type         = 'startProgress',
            itemName     = itemName or '',
            itemLabel    = itemLabel or itemName or '',
            duration     = duration,
            boostPrice   = crafting.BoostPrice,
            boostSeconds = crafting.BoostReduction,
            current      = i,
            total        = numberOfItemToCraft,
        })
        local completed = crafting:RunProgress(duration, itemName, itemLabel)
        if not completed then
            SendNUIMessage({ type = 'closeUI' })
            SetNuiFocus(false, false)
            if type(onCancelled) == 'function' then onCancelled() end
            return false
        end
    end
    SendNUIMessage({ type = 'closeUI' })
    SetNuiFocus(false, false)
    if type(onComplete) == 'function' then onComplete() end
    return true
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if crafting.ActivePoints then
        for _, pt in pairs(crafting.ActivePoints) do
            pt:remove()
        end
    end
    if crafting.SpawnedTables then
        for _, obj in pairs(crafting.SpawnedTables) do
            if type(obj) == 'number' and DoesEntityExist(obj) then
                SetEntityAsMissionEntity(obj, true, true)
                DeleteObject(obj)
                DeleteEntity(obj)
            end
        end
    end
end)

Citizen.CreateThread(function(...) crafting:Awake(...); end)
