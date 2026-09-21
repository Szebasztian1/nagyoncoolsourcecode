Config = {}

Config.Debug = false
Config.ZoneRadius = 2.2
Config.NPC = {
    model = 'a_m_m_business_01',                                  -- NPC model
    coords = vector4(228.56471, -786.5593, 29.678998, 248.4673), -- NPC koordináta (x, y, z, h)
}

Config.Storage = {
    price = 5000,                   -- Bérlés ára / hónap
    slots = 100,                    -- Stash slotok száma
    weight = 250000,                -- Stash súlya (grammban)
    db_table = 'bc_rented_storages' -- Adatbázis tábla neve
}

Config.Labels = {
    text_label = 'Prémium Raktár Bérlés',
    target_label = 'Raktárkezelő',
    open_storage = 'Bérelt Raktár Megnyitása',
    rent_storage = 'Raktár Bérlése',
    renew_storage = 'Bérlés Hosszabbítása',
    storage_expired = 'A bérlésed lejárt! Hosszabbítsd meg a hozzáféréshez.',
    rent_info = 'Ár: %s PP / 30 nap',
    confirm_rent = 'Biztosan ki szeretnéd bérelni a raktárat %s PP-ért 30 napra?',
    confirm_renew = 'Biztosan meg szeretnéd hosszabbítani a bérlést %s PP-ért 30 nappal?',
    success_rent = 'Sikeresen kibérelted a raktárat!',
    success_renew = 'Sikeresen meghosszabbítottad a bérlést!',
    not_enough_money = 'Nincs elég pénzed!',
    expiry_date = 'Lejárat dátuma: %s',
    not_rented = 'Jelenleg nincs bérelt raktárad.'
}
