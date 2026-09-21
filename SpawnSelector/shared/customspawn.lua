-- Egyedi (megvásárolható) spawnhely beállításai.
-- A játékos ott veszi meg, ahol áll; a vásárlás egy hétig érvényes.
Config.CustomSpawn = {
    Price = 30000000,
    Duration = 7 * 24 * 60 * 60, -- 1 hét másodpercben
    Name = "Egyedi spawn",
    Image = "egyedispawn.webp",

    -- Itt nem lehet spawnhelyet venni (interiőrök, karakterválasztó zónák, börtön)
    Blacklist = {
        { coords = vector3(229.9559, -981.7928, -99.6607), radius = 60.0 },
        { coords = vector3(-186.4757, -581.4171, 141.34785), radius = 50.0 },
        { coords = vector3(-1505.783, -3012.587, -80.0), radius = 80.0 },
        { coords = vector3(-1266.802, -3014.837, -49.0), radius = 100.0 },
        { coords = vector3(1690.0, 2565.0, 45.0), radius = 300.0 }, -- Bolingbroke börtön
    },

    -- Ez alatt a magasság alatt (térkép alatti interiőrök) nem engedjük a vásárlást
    MinZ = -50.0,
}
