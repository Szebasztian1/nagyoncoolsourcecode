--░█████╗░░██████╗██████╗░░░░░█████╗░░██████╗██████╗░
--██╔══██╗██╔════╝██╔══██╗░░░██╔══██╗██╔════╝██╔══██╗
--███████║╚█████╗░██║░░██║░░░███████║╚█████╗░██║░░██║
--██╔══██║░╚═══██╗██║░░██║░░░██╔══██║░╚═══██╗██║░░██║
--██║░░██║██████╔╝██████╔╝██╗██║░░██║██████╔╝██████╔╝
--╚═╝░░╚═╝╚═════╝░╚═════╝░╚═╝╚═╝░░╚═╝╚═════╝░╚═════╝░

Config = {}

Config.Cooldown = 7200 -- mennyi időközönként váltson árat egy tárgynál (másodperc)

--------- Drog NPC Beállítások --------
Config.NPCPosition = vector4(4447.9467, -4479.004, 3.3032441, 197.88508) -- PED(drogkereskedő) helye

Config.Settings = {
    ["cocaine"] = {       -- item lehívója
        label = "Kokain", -- item neve a menüben
        minprice = 10250,   -- minimum ár alap:3500 10500
        maxprice = 21000   -- maximum ár alap:6800 20400
    },

    ["weed_lemonhaze"] = {
        label = "Sativa",
        minprice = 15000, --alap: 5000 15000
        maxprice = 22500  --alap: 7500 22500
    },

    ["lsd"] = {
        label = "LSD",
        minprice = 8655,
        maxprice = 16000
    },

    ["gatya"] = {       -- item lehívója
        label = "Gatya", -- item neve a menüben
        minprice = 5200,   -- minimum ár
        maxprice = 9000   -- maximum ár
    },

    ["varazsfagyi"] = {       -- item lehívója
        label = "Varázs Fagyi", -- item neve a menüben
        minprice = 5200,   -- minimum ár
        maxprice = 9000   -- maximum ár
    },

    ["varazsgomba"] = {       -- item lehívója
        label = "Varázs Gomba", -- item neve a menüben
           minprice = 5200,   -- minimum ár
        maxprice = 9000   -- maximum ár
    },

    ["ecstasy"] = {       -- item lehívója
        label = "Ecstasy", -- item neve a menüben
        minprice = 5200,   -- minimum ár
        maxprice = 9000   -- maximum ár
    },

    ["gomba"] = {       -- item lehívója
        label = "Gomba", -- item neve a menüben
        minprice = 5200,   -- minimum ár
        maxprice = 9000   -- maximum ár
    },

    ["lilacsoda"] = {       -- item lehívója
        label = "Lila Csoda", -- item neve a menüben
        minprice = 5200,   -- minimum ár
        maxprice = 9000   -- maximum ár
    },

    ["meth"] = {
        label = "Meth",
        minprice = 9000,
        maxprice = 13500
    }
}

Config.AllowedJobs = {
    "russian",
    "army",
    "asian",
    "bratva",
    "dd",
    "gomorra",
    "gorilla",
    "ssouls",
    "khc",
    "kingston",
    "mob",
    "ms",
    "tesztjob",
    "ms13",
    "offluxduty",
    "peakybb",
    "remmo",
    "soa",
    "ujfrakcio",
    "ujfrakciodawe3",
    "bahamas",
    "gentle",
    "loscuba",
    "orosz",
    "gym",
	"corleone",
    "szeged",
    "diavoltelepoff",
    "kingsman",
    "diablo",
    "uwu",
    "pearlsillegal",
    "conte",
    "rh"
}
