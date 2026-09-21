-- Shop name plates — configuration.
-- Everything lives under one `NameTags` global on purpose: this file runs inside
-- shops_creator, and a loose `Config` would collide with the escrow-encrypted code.

NameTags = NameTags or {}

NameTags.Config = {

    -- ── Where the shops come from ────────────────────────────────────────────
    -- shops_creator creates its tables at runtime and its Lua is encrypted, so the
    -- table names cannot be read from the code. On start we scan the schema once
    -- and recognise the tables by the JSON shape of their `data` column. The
    -- startup log prints what it found — pin the names here and set
    -- autoDetect = false to skip the scan.
    database = {
        autoDetect = true,

        adminShops = {
            table = nil,        -- e.g. 'shops_creator_admin_shops'
            id    = 'id',
            label = 'label',
            data  = 'data',
        },

        playerShops = {
            table = nil,        -- e.g. 'shops_creator_players_shops'
            id    = 'id',
            label = 'label',
            data  = 'data',
            owner = nil,        -- column holding the owner identifier, e.g. 'owner'
        },
    },

    -- Our own table. shops_creator's tables are only ever read, never written.
    namesTable = 'shops_creator_nametags',

    -- ── What gets a name plate ───────────────────────────────────────────────
    onlyWhereNpc  = true,   -- true: only shop points that have a ped enabled

    -- false: a shop with no custom name shows nothing. It still gets its
    -- ox_target option, so the owner can give it one.
    showShopLabel = false,

    -- ── Rendering ────────────────────────────────────────────────────────────
    drawDistance = 5.0,     -- the plate appears this close, in units
    scanDistance = 40.0,    -- scanner switches to its fast tick inside this
    textOffsetZ  = 2.25,    -- height above the shop point; shop coords sit at the
                            -- ped's feet, so this clears the head like a nametag
    textScale    = 0.42,    -- base size; the plate still shrinks with distance
    scanFastTick = 250,     -- in ms, used while a shop is within scanDistance
    scanSlowTick = 1500,    -- in ms, used when the player is nowhere near a shop

    -- ── Setting the name at the NPC ──────────────────────────────────────────
    interactDistance = 2.5, -- how close you stand to the NPC to interact (keys mode)

    -- ox_target attaches to the shop's ped, the same way shops_creator does, so
    -- two shops standing next to each other do not both answer at once. The ped
    -- is spawned by their encrypted code, so it is matched by position instead.
    pedSearchDistance = 25.0,   -- start looking for the ped inside this
    pedMatchDistance  = 1.4,    -- how close a ped must be to the shop point to be it

    -- 'auto' uses ox_target when it is running and falls back to the keys below.
    -- 'ox_target' or 'keys' forces one of them.
    targeting = 'auto',

    -- The ox_target entries. A sphere zone is placed on the shop point, so no ped
    -- handle is needed — shops_creator spawns those from its encrypted code. Only
    -- one of the two is ever visible, depending on whether the plate is unlocked.
    -- The icons must be Font Awesome: ox_target's own NUI loads FA, not the
    -- Bootstrap Icons that shops_creator's page uses.
    target = {
        icon         = 'fa-solid fa-signature',
        label        = 'Bolt névtáblája',
        lockedIcon   = 'fa-solid fa-lock',
        lockedLabel  = 'Névtábla feloldása',
    },

    -- ── Unlocking the plate ──────────────────────────────────────────────────
    -- Buying it is per shop, not per player: when the shop changes hands the
    -- unlock and the name are both wiped, and the new owner has to buy it again.
    -- A `staffGroups` member skips the fee only on shops that are not theirs; on
    -- a shop they own themselves they pay like any other owner.
    unlock = {
        enabled  = true,
        price    = 2000000000,
        currency = 'Ft',

        -- Tried in order: the first account that covers the whole price pays it.
        -- Cash first, bank as the fallback.
        accounts = { 'money', 'bank' },
        accountLabels = { money = 'készpénz', bank = 'bank' },

        ppPrice  = 5000,            -- false to disable paying with PP
        ppResource = 'bc_ppshop',   -- exports getpp / removepp, soft dependency
    },

    -- Only used in 'keys' mode.
    keyName = 38,           -- E — opens the editor

    -- The prompt shown at the NPC. If you change the key above, change the
    -- ~INPUT_*~ token here too — the game resolves it to the player's bind.
    interactHelp = '~INPUT_CONTEXT~ Bolt névtáblája',

    maxNameLength   = 24,   -- in characters (not bytes), enforced server-side
    commandDistance = 5.0,  -- range of the chat commands, kept as an admin fallback
    commandCooldown = 3000, -- in ms, per player; a rename writes to the DB and syncs everyone

    -- ESX groups (xPlayer.getGroup()) that may edit any shop's plate. This is a
    -- moderation bypass, not a perk — see `unlock` below. Deliberately narrower
    -- than the shops_creator ace, which every admin tends to hold.
    -- Owner only, on purpose: 'coowner' and 'serverdirector' are not on this list.
    staffGroups = { 'owner' },

    -- Honour shops_creator's own "the shop owner can rename the shop" switch.
    -- false: any player shop owner may set a plate name regardless of that setting.
    --
    -- 2026-09-03: false-ra állítva. A 60 játékos-boltból 58-nál nincs bepipálva
    -- az "üzlet tulajdonosa átnevezheti az üzletet" kapcsoló, így a tulajok nem
    -- látták a névtábla lehetőséget az NPC-nél — csak a staff. A névtábla saját
    -- feloldással (fizetéssel) jár, a bolt címkéjét ettől továbbra sem tudják
    -- átírni, azt a shops_creator saját kapcsolója dönti el.
    respectRenamePermission = false,

    commands = {
        setName  = 'boltnev',
        setColor = 'boltszin',
        clear    = 'boltnevtorol',
    },

    -- Colour keys are what players type in the chat command, so they stay
    -- accent-free. `colorOrder` is also the order of the swatch grid in the panel.
    defaultColor = 'feher',
    colorOrder = {
        'feher', 'ezust', 'sarga', 'arany', 'narancs', 'piros',
        'korall', 'rozsaszin', 'magenta', 'lila', 'ibolya', 'kek',
        'vilagoskek', 'cian', 'turkiz', 'zold', 'sotetzold', 'fekete',
    },
    colors = {
        feher      = { label = 'fehér',       rgb = { 255, 255, 255 } },
        ezust      = { label = 'ezüst',       rgb = { 201, 209, 217 } },
        sarga      = { label = 'sárga',       rgb = { 245, 197,  24 } },
        arany      = { label = 'arany',       rgb = { 224, 179,  77 } },
        narancs    = { label = 'narancs',     rgb = { 240, 133,  33 } },
        piros      = { label = 'piros',       rgb = { 219,  40,  40 } },
        korall     = { label = 'korall',      rgb = { 255, 107,  91 } },
        rozsaszin  = { label = 'rózsaszín',   rgb = { 255, 105, 180 } },
        magenta    = { label = 'magenta',     rgb = { 233,  30, 140 } },
        lila       = { label = 'lila',        rgb = { 165,  94, 234 } },
        ibolya     = { label = 'ibolya',      rgb = { 123,  91, 240 } },
        kek        = { label = 'kék',         rgb = {  47, 128, 237 } },
        vilagoskek = { label = 'világoskék',  rgb = { 127, 176, 246 } },
        cian       = { label = 'cián',        rgb = {  38, 222, 200 } },
        turkiz     = { label = 'türkiz',      rgb = {  26, 188, 156 } },
        zold       = { label = 'zöld',        rgb = {  76, 219,  40 } },
        sotetzold  = { label = 'sötétzöld',   rgb = {  39, 174,  96 } },
        fekete     = { label = 'fekete',      rgb = {  20,  20,  20 } },
    },
}
