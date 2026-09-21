-- Egyedi spawnhely a választóban: ha a játékosnak él megvásárolt spawnja,
-- extra kártyaként kerül a beépített helyszínek mögé.
-- A lekérés a spawn-folyamat elején, háttérben indul, és a kártyalista
-- építésekor legfeljebb WAIT_TIMEOUT-ig várunk rá — így egy néma/hibás
-- szerverválasz sem tudja megakasztani a spawnválasztót.
CustomSpawn = {}

local WAIT_TIMEOUT <const> = 2000

local entry = nil
local state = 'idle' -- idle | pending | done

local function streetLabel(coords)
    local street = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local name = street ~= 0 and GetStreetNameFromHashKey(street) or nil

    return (name and name ~= '') and name or 'Ismeretlen helyszín'
end

local function formatMoney(amount)
    local text, replaced = tostring(math.floor(amount)), 0
    repeat
        text, replaced = text:gsub('^(%d+)(%d%d%d)', '%1 %2')
    until replaced == 0

    return text .. ' $'
end

-- "hét" / "3 nap" — a konfigos időtartam olvasható formában
local function durationLabel()
    local days = math.floor(Config.CustomSpawn.Duration / 86400)
    if days == 7 then
        return 'hét'
    end

    return ('%d nap'):format(days)
end

local function timeLeftLabel(seconds)
    if seconds <= 0 then
        return 'Lejárt'
    end

    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    if days > 0 then
        return ('%d nap %d óra van hátra'):format(days, hours)
    end

    return ('%d óra van hátra'):format(math.max(1, hours))
end

--- Elindítja a saját spawn lekérését a háttérben (nem blokkol).
function CustomSpawn.Prefetch()
    if state == 'pending' then return end

    state = 'pending'
    CreateThread(function()
        local ok, result = pcall(lib.callback.await, 'SpawnSelector:Server:GetCustomSpawn', false)
        entry = (ok and type(result) == 'table') and result or nil
        state = 'done'
    end)
end

--- A választóban megjelenítendő helyszínek: a konfigos lista + az egyedi spawn (ha van).
--- @return table locations
function CustomSpawn.BuildLocations()
    local locations = {}
    for i = 1, #Config.Location do
        locations[i] = Config.Location[i]
    end

    if state == 'idle' then
        CustomSpawn.Prefetch()
    end

    local waited = 0
    while state == 'pending' and waited < WAIT_TIMEOUT do
        Wait(50)
        waited = waited + 50
    end

    -- A kártya akkor is kikerül, ha nincs megvéve — ilyenkor zárolt, és leírja,
    -- hogyan lehet megszerezni
    if not entry then
        locations[#locations + 1] = {
            Name = Config.CustomSpawn.Name,
            Description = ('%s / %s — a pause menüben (ESC) veheted meg, ott ahol éppen állsz'):format(formatMoney(Config.CustomSpawn.Price), durationLabel()),
            Image = Config.CustomSpawn.Image,
            Custom = true,
            Locked = true,
            Badge = 'Zárolva',
        }

        return locations
    end

    locations[#locations + 1] = {
        Coords = vector4(entry.x, entry.y, entry.z, entry.heading),
        Name = Config.CustomSpawn.Name,
        Description = ('%s — %s'):format(streetLabel(entry), timeLeftLabel(entry.secondsLeft or 0)),
        Image = Config.CustomSpawn.Image,
        Custom = true,
        Badge = 'Egyedi',
    }

    return locations
end
