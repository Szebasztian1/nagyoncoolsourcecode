-- ===========================================================================
-- Bolti kedvezmények — beállítások (kliens + szerver)
--
-- A bolt tulajdonosa játékos-ID alapján adhat kedvezményt. A kedvezmény a
-- karakter identifierjéhez kötődik, tehát újracsatlakozás után is megmarad,
-- és bármikor visszavonható.
--
-- A tényleges pénzlevonás a utils/framework/sv_framework.lua két függvényén
-- megy át (hasPlayerEnoughOfGenericObject / removeGenericObjectFromPlayerId) —
-- ott hívunk vissza ide. A kliens SOHA nem küld árat, az összeget végig a
-- szerver számolja a shops_creator_players_shops_objects táblából.
-- ===========================================================================

Discounts = Discounts or {}

Discounts.Config = {
    -- A legnagyobb adható kedvezmény. A szerver mindenképp ide vágja le,
    -- akármit is küld a kliens.
    maxPercent = 20,

    -- Csak a bolt tulajdonosa kezelhet kedvezményt (false esetén a `manager`
    -- jogú alkalmazott is). A szerver minden művelet előtt újraellenőrzi.
    onlyOwner = true,

    -- A kedvezményt a bolt kasszája állja: a vásárlás után a különbözetet
    -- levonjuk a shops_creator_players_shops.stored_money oszlopból.
    -- false esetén a bolt a teljes árat kapja, a különbözet a semmiből jön —
    -- azt csak akkor kapcsold ki, ha tudod, mit csinálsz.
    deductFromShop = true,

    -- Melyik számlára megy a visszatérítés. A script nem árulja el, honnan
    -- vonta le a pénzt, ezért ezt itt kell megmondani.
    -- 'bank' = bankszámla, 'money' = készpénz.
    refundAccount = 'bank',

    -- Ennyivel a tárgy átadása után rendezzük a különbözetet. Addigra a script
    -- már jóváírta a boltnak a teljes árat, tehát ellenőrizni is tudjuk.
    settleDelay = 2500,   -- ms

    -- Ennyi ideig él a "függő kedvezmény", amit a vásárlás gomb hoz létre. Ha
    -- ez alatt nem érkezik meg a tárgy, a vásárlás teljes áron marad.
    -- A párosítás tárgynévre ÉS darabszámra megy, nem összegre, ezért ez az
    -- ablak nyugodtan lehet bőven elég egy akadó szerverhez is.
    pendingTtl = 8000,   -- ms

    -- Discord napló. nil esetén a menü Settings fülén beállított fő webhookot
    -- használjuk (current_config.json -> server.mainDiscordWebhook).
    webhook = nil,

    -- Lépésenkénti nyomkövetés a konzolra (előkészítés, kassza előtte/utána,
    -- visszatérítés). Csak bevizsgáláshoz kapcsold be.
    --
    -- FIGYELEM: a rendellenességek (elmaradt levonás vagy visszatérítés) ettől
    -- függetlenül MINDIG kiírnak, ahogy a hibák és a `shopsdiscounts` parancs is.
    debug = false,
}
