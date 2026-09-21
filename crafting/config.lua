crafting                = {}

crafting.Version        = '1.0.11'

crafting.LearnOnCraft   = false

crafting.RequireRecipes = false

crafting.DrawTextDist   = 3.0
crafting.InteractDist   = 6.0
crafting.LoadTableDist  = 50.0
crafting.BenchModel     = 'prop_tool_bench02_ld'
crafting.BoostPrice     = 50000
crafting.BoostCooldown  = 5000
crafting.BoostReduction = 10

-- Kotegelt craftolas: egy racskirakasbol legfeljebb ennyi darab keszitheto el
-- egyben. Ez csak a FELSO hatar -- a csuszka ennel kevesebbet enged, ha nincs
-- hozza alapanyag (fegyvernel kulcs es keszpenz sem).
--
-- A craftolasi ido NEM csokken kotegelve: minden darab a sajat teljes idejet
-- futja le, egymas utan. Amit a koteg megsporol, az a racs ujra-kirakasa.
crafting.MaxCraftAmount = 10

-- Blueprint ("munkapad terv") purchase: reveals the 3x3 layout of one recipe
-- for the buying player, until the next layout reset.
crafting.BlueprintPriceWeapon = 500000000 -- full weapon
crafting.BlueprintPriceItem   = 10000000   -- component

-- How often every recipe's 3x3 arrangement is reshuffled. All bought blueprints are
-- wiped on reset, so they have to be bought again.
crafting.LayoutResetInterval  = 2592000 -- seconds = 30 nap. Teszteléshez pl. 60 (1 perc).

---Weapon recipes cost the extra cash fee and the pricier blueprint.
---@param name string recipe name
---@return boolean
function crafting:IsWeapon(name)
    return type(name) == 'string' and name:sub(1, 7) == 'weapon_'
end

---@param name string recipe name
---@return number price
function crafting:GetBlueprintPrice(name)
    if self:IsWeapon(name) then
        return self.BlueprintPriceWeapon
    end
    return self.BlueprintPriceItem
end

-- Faction craft types. A faction crafts the set matching its own type (resolved through
-- as_cooldowns:AuthJob) unless its leader paid to switch it to the other one.
crafting.CraftFactionTypes  = { 'banda', 'maffia' }
-- The leader picks one of the two; they are alternatives, not a combined price.
crafting.FactionSwitchPrice = 5000000000 -- $
crafting.FactionSwitchPP    = 10000      -- PP (bc_ppshop)

---Which faction types may craft this recipe. CraftAllowedJobs mixes type names with
---personal identifier whitelists, so filter to the known types.
---@param name string recipe name
---@return table list of type names
function crafting:GetRequiredCraftTypes(name)
    local allowed = CraftAllowedJobs[name]
    if type(allowed) ~= 'table' then return {} end

    local types = {}
    for _, entry in ipairs(allowed) do
        for _, known in ipairs(self.CraftFactionTypes) do
            if entry == known then types[#types + 1] = entry end
        end
    end
    return types
end

---Explains WHY a craft was refused, naming the type(s) that may make it.
---@param name string recipe name
---@param currentType string|nil the player's faction craft type
---@return string
function crafting:GetDenyMessage(name, currentType)
    local required = self:GetRequiredCraftTypes(name)
    if #required == 0 then return 'Ezt a tárgyat nem craftolhatod!' end

    local msg = 'Ezt csak ' .. table.concat(required, ' vagy ') .. ' frakció craftolhatja!'
    if currentType then
        return msg .. ' (a frakciód most: ' .. currentType .. ')'
    end
    return msg .. ' (a frakciód egyik sem)'
end

---Shared craft permission check, so client and server always agree.
---@param jobName string
---@param identifier string
---@param factionType string|nil the faction's switched type; nil = use its natural one
---@param name string recipe name
---@return boolean
function crafting:IsCraftAllowed(jobName, identifier, factionType, name)
    local allowed = CraftAllowedJobs[name]
    if type(allowed) ~= 'table' then return true end

    for _, entry in ipairs(allowed) do
        if identifier == entry then return true end -- personal whitelist

        if factionType then
            -- switched: the chosen type replaces the natural one entirely
            if factionType == entry then return true end
        elseif exports["as_cooldowns"]:AuthJob(jobName, entry) then
            return true
        end
    end
    return false
end
