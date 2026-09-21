-- Blip-szűrő: kategóriánként ÉS tételenként is kapcsolható.
--
-- Három forrásból jönnek a tételek:
--   * a blipek saját blipjei (Config.Blips), cím szerint összevonva -> id: "t:<cím>"
--   * az egységesített munka-blipek (Config.WorkBlips)              -> id: "w:<id>"
--   * más resource-ok blipjei (Config.ForeignBlips), sprite szerint -> id: "f:<id>"
--
-- Egy blip akkor látszik, ha a KATEGÓRIÁJA és a saját TÉTELE is be van kapcsolva.
-- Az állapot kliensenként, KVP-ben marad meg; main.lua a Filter.IsShown-on
-- keresztül alkalmazza, és az onChange visszahíváskor újrarajzolja a blipeket.
local Filter = {}

local KVP_KEY = 'blipek_filter'    -- régi: csak kategóriák (tömb)
local KVP_KEY2 = 'blipek_filter2'  -- új: kategóriák + tételek

local disabled = {}        -- [categoryKey] = true, ha rejtve
local disabledEntry = {}   -- [entryId]     = true, ha rejtve
local onChange             -- Filter.Init állítja (main.lua refreshBlips)
local countProvider        -- Filter.Init állítja, [categoryKey] = blip darabszám

local validKeys = {}
for _, cat in ipairs(Config.Categories) do
    validKeys[cat.key] = true
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- TÉTELEK
-- Sorrend: a saját blipek a config sorrendjében, utána az idegenek.
-- Egy cím többször is szerepelhet a Config.Blips-ben (pl. 8 Rendvédelem) --
-- ezek egyetlen sort adnak a menüben, és együtt kapcsolódnak.
-----------------------------------------------------------------------------------------------------------------------------------------
local entries = {}      -- tömb: { id, label, category, own, count }
local entryById = {}
local entryByTitle = {}

local function addEntry(entry)
    entries[#entries + 1] = entry
    entryById[entry.id] = entry
    return entry
end

do
    for _, blip in ipairs(Config.Blips or {}) do
        local title = blip.title
        local existing = entryByTitle[title]

        if existing then
            existing.count = existing.count + 1
        else
            entryByTitle[title] = addEntry({
                id       = 't:' .. title,
                label    = title,
                category = Config.BlipCategories[title] or 'egyeb',
                own      = true,
                count    = 1,
            })
        end
    end

    -- egységesített munka-blipek (a blipeket a munka-resource-ok hozzák
    -- létre, mi csak a stílust és a kapcsolást adjuk -- lásd client/work.lua)
    for _, w in ipairs(Config.WorkBlips or {}) do
        addEntry({
            id       = 'w:' .. w.id,
            label    = w.label,
            category = 'munkak',
            own      = false,
            count    = 0,        -- futásidőben számoljuk (work.lua)
            resource = w.resource,
        })
    end

    for _, f in ipairs(Config.ForeignBlips or {}) do
        if validKeys[f.category] then
            addEntry({
                id       = 'f:' .. f.id,
                label    = f.label,
                category = f.category,
                own      = false,
                count    = 0,        -- futásidőben számoljuk (external.lua)
                sprite   = f.sprite,
                colours  = f.colours,
            })
        else
            print(('[blipek] ismeretlen kategória a ForeignBlips-ben: %s (%s)'):format(tostring(f.category), tostring(f.id)))
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- MENTÉS
-- Csak a KIKAPCSOLT kulcsok kerülnek mentésre, így egy új kategória/tétel
-- alapból látszik. A régi (csak kategóriás) mentést egyszer beolvassuk.
-----------------------------------------------------------------------------------------------------------------------------------------
local function loadState()
    disabled, disabledEntry = {}, {}

    local raw = GetResourceKvpString(KVP_KEY2)
    if raw then
        local ok, data = pcall(json.decode, raw)
        if ok and type(data) == 'table' then
            for _, key in ipairs(data.categories or {}) do
                if validKeys[key] then disabled[key] = true end
            end
            for _, id in ipairs(data.entries or {}) do
                if entryById[id] then disabledEntry[id] = true end
            end
            return
        end
    end

    -- visszaesés a régi formátumra (csak kategóriák)
    local legacy = GetResourceKvpString(KVP_KEY)
    if not legacy then return end

    local ok, list = pcall(json.decode, legacy)
    if not ok or type(list) ~= 'table' then return end

    for _, key in ipairs(list) do
        if validKeys[key] then disabled[key] = true end
    end
end

local function saveState()
    local cats, ents = {}, {}
    for key in pairs(disabled) do cats[#cats + 1] = key end
    for id in pairs(disabledEntry) do ents[#ents + 1] = id end
    SetResourceKvp(KVP_KEY2, json.encode({ categories = cats, entries = ents }))
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- LEKÉRDEZÉSEK
-----------------------------------------------------------------------------------------------------------------------------------------

---@param title string
---@return string categoryKey
function Filter.CategoryOf(title)
    return Config.BlipCategories[title] or 'egyeb'
end

--- A blipek SAJÁT blipjeire: látszik-e ez a cím?
---@param title string
---@return boolean
function Filter.IsShown(title)
    if disabled[Filter.CategoryOf(title)] then return false end
    return not disabledEntry['t:' .. title]
end

--- Idegen blipekre (external.lua): látszik-e ez a tétel?
---@param entryId string a tétel id-je ("f:...")
---@return boolean
function Filter.IsEntryShown(entryId)
    local entry = entryById[entryId]
    if not entry then return true end
    if disabled[entry.category] then return false end
    return not disabledEntry[entryId]
end

---@param key string
---@return boolean
function Filter.IsCategoryEnabled(key)
    return not disabled[key]
end

---@return table[] a menü tételei (belső tábla, ne módosítsd kívülről)
function Filter.Entries()
    return entries
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ÁLLÍTÁS
-----------------------------------------------------------------------------------------------------------------------------------------

---@param key string
---@param enabled boolean
---@return boolean success
function Filter.SetCategory(key, enabled)
    if not validKeys[key] then return false end

    disabled[key] = not enabled or nil

    -- A kategória-gomb a benne lévő tételeket is állítja, különben egy korábban
    -- egyedileg kikapcsolt sor rejtve maradna, és a gomb "nem csinálna semmit".
    for _, entry in ipairs(entries) do
        if entry.category == key then
            disabledEntry[entry.id] = not enabled or nil
        end
    end

    saveState()
    if onChange then onChange() end
    return true
end

---@param id string
---@param enabled boolean
---@return boolean success
function Filter.SetEntry(id, enabled)
    local entry = entryById[id]
    if not entry then return false end

    disabledEntry[id] = not enabled or nil

    -- Egy tétel bekapcsolása felold a kategórián is, különben láthatatlan maradna
    if enabled and disabled[entry.category] then
        disabled[entry.category] = nil
        for _, other in ipairs(entries) do
            if other.category == entry.category and other.id ~= id then
                disabledEntry[other.id] = true
            end
        end
    end

    saveState()
    if onChange then onChange() end
    return true
end

---@param enabled boolean
function Filter.SetAll(enabled)
    for _, cat in ipairs(Config.Categories) do
        disabled[cat.key] = not enabled or nil
    end
    for _, entry in ipairs(entries) do
        disabledEntry[entry.id] = not enabled or nil
    end
    saveState()
    if onChange then onChange() end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- KIMENET A FELÜLETEKNEK
-----------------------------------------------------------------------------------------------------------------------------------------

---@return table[] categories { key, label, enabled, count }
function Filter.GetCategories()
    local counts = countProvider and countProvider() or {}
    local result = {}

    for i, cat in ipairs(Config.Categories) do
        result[i] = {
            key     = cat.key,
            label   = cat.label,
            enabled = not disabled[cat.key],
            count   = counts[cat.key] or 0,
        }
    end

    return result
end

--- Teljes panel-adat: kategóriák + a hozzájuk tartozó tételek.
---@return table { categories = {...}, entries = {...} }
function Filter.GetPanel()
    -- FONTOS: a kategóriák lekérése frissíti az idegen tételek darabszámát
    -- (countProvider -> External.Counts), ezért ez megy előre.
    local categories = Filter.GetCategories()
    local list = {}

    for i, entry in ipairs(entries) do
        list[i] = {
            id       = entry.id,
            label    = entry.label,
            category = entry.category,
            enabled  = not disabledEntry[entry.id],
            count    = entry.count or 0,
            source   = entry.own and 'blipek' or 'kulso',
        }
    end

    return { categories = categories, entries = list }
end

--- Futásidőben felvett tétel (a /blipmiez parancs használja). A configba
--- bemásolt sor a restart után ugyanezt az id-t kapja, így a mentés megmarad.
---@param id string       teljes tétel-id, pl. "f:sprite361"
---@param label string
---@param category string
function Filter.AddEntry(id, label, category)
    if entryById[id] or not validKeys[category] then return false end

    addEntry({ id = id, label = label, category = category, own = false, count = 0 })
    return true
end

---@param changeCb fun() újrarajzolja a blipeket egy kapcsolás után
---@param countCb fun(): table<string, number> blip darabszám kategóriánként
function Filter.Init(changeCb, countCb)
    onChange = changeCb
    countProvider = countCb
    loadState()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTOK (a pause menü Blip füle használja)
-----------------------------------------------------------------------------------------------------------------------------------------
exports('GetBlipCategories', Filter.GetCategories)
exports('GetBlipPanel', Filter.GetPanel)

exports('SetBlipCategoryEnabled', function(key, enabled)
    return Filter.SetCategory(key, enabled == true)
end)

exports('SetBlipEntryEnabled', function(id, enabled)
    return Filter.SetEntry(id, enabled == true)
end)

exports('SetAllBlipCategories', function(enabled)
    Filter.SetAll(enabled == true)
end)

return Filter
