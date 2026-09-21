Config = {}

Config.Locale = "hu" -- en, hu

Config.Positions = {
    vector4(-543.7744, -195.7882, 37.226955, 72.66217)
}

Config.Blip = { --set to false if you don't want
    sprite = 408,
    color = 26
}

Config.Jobs = {
--    ['unemployed'] = {label = "Munkanélküli", desc = "Ezzel átállítod a munkád munkanélkülivé!", setjob = true},
    ['miner'] = {label = "Bányász munka", desc = "Merülj alá a föld mélyére és termelj ki értékes érceket a város iparának!", coords = vector3(-596.5556, 2090.9079, 131.41285)},
    ['lumberjack'] = {label = "Favágó munka", desc = "Vágd ki a legerősebb fákat és szállítsd le őket a fűrésztelepre! Kitartás és izomerő kell hozzá.", coords = vector3(-574.6677, 5329.039, 70.21450)},
  --  ['fruitpicking'] = {label = "Almaszedés", desc = "Almaszedés", coords = vector3(231.55619, 6517.0571, 31.27027)},
    ['detector'] = {label = "Fémdetektorozás", desc = "Kutasd át a partokat és mezőket fémdetektoroddal, hátha egy kincset rejt a föld!", coords = vector3(-1742.511, -725.2033, 10.43330)},
    ['funyiras'] = {label = "Buszozás", desc = "Vezesd a város lakóit biztonságosan A-ból B-be. A pontos járatvezetőket mindig megjutalmazzák!", coords = vector3(977.5404, -1500.15, 31.369262)},
    ['trucker'] = {label = "Kamionozás", desc = "Szállíts rakományokat az ország minden pontjára, legyél te a fuvarozás királya!", coords = vector3(1204.0429, -3099.038, 5.851551)},
    ['meheszet'] = {label = "Méhészet", desc = "Gondozd a méhcsaládokat, gyűjtsd be az aranyló mézet és add el a legjobb árért!", coords = vector3(426.61276, 6478.3271, 28.823898)},
    ['vadasz'] = {label = "Vadászat", desc = "A térképen 3 blip van jelölve: az első a bolt, a második a küldetésfelvevő (nem kötelező), a harmadik pedig a vadászterület. Irány vadászni!", coords = vector3(956.96264, -2108.609, 30.551551)},
    ['rakaszat'] = {label = "Rákászat", desc = "Bérelj hajót, menj ki a vízre, és fogj rákokat hálóval vagy csapdákkal. Gyűjtsd be a zsákmányt, majd add el a kikötőben a profitért!", coords = vector3(-484.1256, -2919.488, 5.9929165)},
--    ['epito'] = {label = "Épitő Munkás", desc = "Épitő Munkás", coords = vector3(925.9672, -1560.2788, 30.7405)},
    ['buvarkodas'] = {label = "Búvárkodás", desc = "Merülj a víz alá és gyűjts értékes tárgyakat, kincseket a tóban vagy a tengerben. Figyelj az oxigénre és a veszélyekre!", coords = vector3(-1264.021, -1436.435, 4.3520655)},
    ['kukas'] = {label = "Kukás Munka", desc = "Gyűjtsd össze a szemetet a kijelölt területeken, és szállítsd a hulladéklerakóba. Tartsd tisztán a várost, miközben pénzt keresel.", coords = vector3(939.63928, -1458.066, 31.37747)},
--   ['szellemvadaszat'] = {label = "Szellem Vadászat", desc = "Keresd meg és fotózd le a szellemeket, hogy jutalmakat szerezhess!", coords = vector3(-1680.851, -290.5841, 51.883548)},
}

Config.KickMessage = "Hekker" --set to false to don't kick

if not IsDuplicityVersion() then 
    Config.Notify = function(msg)
        TriggerEvent("esx:showNotification", msg)
    end 
end 