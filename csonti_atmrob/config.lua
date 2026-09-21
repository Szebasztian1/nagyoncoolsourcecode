Config = {}

Config.atm = {   -- ATM propok amiket kilehet rabolni
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
}

Config.policeJobs = {"police", "fbiuj", "uss", "irs", "atf", "navi", "fbi", "detective", "guardarmy", "usms", "servicess"} -- jobok amik értesítést kapnak és beleszámítanak a minimum rendőrbe
Config.policeRequired = 0 -- menyi rendőre van szükség a rabláshoz

Config.atmCooldown = 2400000 -- ms ben, 1200000 = 20perc, menyi idő után lehet ugyan azt az atm-et kirabolni

Config.weldSpeed = 1 -- x százalék plusz minden helyes gomb nyomas utan. 100% nal tovabb enged
Config.weldError = 30 -- x százalék minusz minden helytelen gomb nyomas utan. 

Config.cellOpenSpeed = 450 -- 450re vissza hány ms-enként megy fell 1%-t
Config.cellMoney = {500000, 700000} -- pénz range amit egy cella adhat
