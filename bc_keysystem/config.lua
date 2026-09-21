Config = {}

Config.Item = "carkey"

Config.CacheTime = 60*30 --sec

Config.Price = 2500

Config.Lockpick = "lockpick"
Config.SecuredVehClasses = {18, 19}

Config.PoliceJobs = {"fbi", "fbiuj", "uss", "irs", "atf", "navi", "police", "detective", "guardarmy", "usms", "servicess"}
Config.Alarms = {
    alarm = {
        price = 40000,
        label = "Riasztó"
    },
    alarmgps = {
        price = 100000,
        label = "Riasztó + GPS"
    }
}
Config.AlarmTimer = 10*60 --insec 

Config.AlarmRemover = "alarmremover"
Config.RemoveTime = 60000 --in ms
Config.NPCAlarmChance = 30
-- Sikertelen nyitási próbálkozásra megszólaló riasztó (a számlálás szerveroldalon fut)
Config.FailedUnlockAlarm = {
    enabled = true,
    attempts = 2,           -- hányadik sikertelen nyitási próbálkozásnál szólaljon meg
    resetTime = 30,         -- sec, ennyi tétlenség után nullázódik a számláló
    duration = 20,           -- sec, meddig szóljon a riasztó
    cooldown = 20,          -- sec, amíg ugyanarra a járműre nem indul újra
    horn = true,            -- dudáljon-e
    nativeAlarm = true,     -- játékbeli gyári riasztóhang
    notify = true,          -- kapjon-e értesítést aki próbálkozott
    enterAttempts = true,   -- az F-fel való beszállási kísérlet is számítson próbálkozásnak
    enterDistance = 10.0    -- m, ennyin belül fogadjuk el a beszállási kísérletet
}

-- Hibakereseshez: minden dontesi pontot kiir a konzolra (F8 kliensen, szerverkonzol szerveren)
Config.Debug = false

function BCDbg(fmt, ...)
    if not Config.Debug then
        return
    end
    -- select("#") kell, mert a nil ertekek lyukat hagynak a tablaban es elcsusznak az argumentumok
    local n = select("#", ...)
    local args = { ... }
    for i = 1, n do
        args[i] = tostring(args[i])
    end
    local ok, msg = pcall(string.format, fmt, table.unpack(args, 1, n))
    print(("[bc_keysystem] %s"):format(ok and msg or fmt))
end
