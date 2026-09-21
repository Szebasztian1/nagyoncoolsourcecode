-- Shared utility – kliens és szerver egyaránt betölti

U = {}

function U.log(msg, ...)
    if not Config.Debug then return end
    local s = type(msg)=='string' and string.format(msg,...) or tostring(msg)
    local side = IsDuplicityVersion() and '^3[loadout-srv]' or '^5[loadout-cli]'
    print(side..'^0 '..s)
end

-- Megkeresi az item config bejegyzést név alapján.
-- Visszatér: cfg, catLabel  (vagy nil, nil ha nem találja)
function U.findItem(name)
    for _, cat in ipairs(Config.Items) do
        for _, it in ipairs(cat.items) do
            if it.name == name then return it, cat.cat end
        end
    end
end

-- Ellenőrzi, hogy az item configban szerepel-e
function U.itemAllowed(name) return U.findItem(name) ~= nil end

-- Összesített ár: items = { {unit_price, quantity}, ... }
function U.totalPrice(items)
    local t = 0
    for _, it in ipairs(items) do t = t + (it.unit_price or 0)*(it.quantity or 1) end
    return t
end

-- Formázott pénz string
function U.money(n) return '$'..math.floor(n) end

-- Job konfig lekérése
function U.jobCfg(name) return Config.Jobs[name] end

-- Alap permission check (tényleges ellenőrzés mindig szerveren!)
function U.hasAccess(jobName, grade)
    local j = Config.Jobs[jobName]
    return j and grade >= (j.minGrade or 0)
end
