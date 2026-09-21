-- ===========================================================================
-- Bolti kirakat (hirdetés) — beállítások (kliens + szerver)
--
-- A bolt tulajdonosa megadhat egy külső képet és egy bemutatkozó szöveget,
-- ami a bolt megnyitásakor a bal oldali sávban jelenik meg a vásárlónak.
--
-- Minden mező ellenőrzése a szerveren történik (storefront/sv_storefront.lua),
-- a NUI csak megjeleníti, amit onnan kap.
-- ===========================================================================

Storefront = Storefront or {}

Storefront.Config = {
    -- Honnan fogadunk el képet. A játék böngészője CSAK https-t tölt be — a
    -- http:// képet vegyes tartalomként némán eldobja, ezért azt eleve
    -- visszautasítjuk. A gazdagépnek pontosan egyeznie kell az itteniekkel.
    allowedHosts = {
        'i.imgur.com',
        'imgur.com',
        'cdn.discordapp.com',
        'media.discordapp.net',
    },

    -- Hosszkorlátok. A leírás sortöréseket is tartalmazhat.
    maxUrlLength = 500,
    maxDescription = 600,
    maxTags = 3,
    maxTagLength = 24,
    maxShortField = 40,   -- nyitvatartás, telefonszám

    -- Csak a bolt tulajdonosa szerkesztheti. A szerver minden mentés előtt
    -- újraellenőrzi, a menüpont megléte önmagában nem jogosít semmire.
    onlyOwner = true,

    -- Discord napló. nil esetén a menü Settings fülén beállított fő webhook
    -- (current_config.json -> server.mainDiscordWebhook).
    webhook = nil,

    -- Extra konzol-log minden lépésről. Bevizsgálás idejére kapcsold true-ra;
    -- a hibák és a `shopsdiscounts` parancs ettől függetlenül mindig kiírnak.
    debug = false,
}
