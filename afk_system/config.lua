Config = {}

-- Ennyi masodperc mozdulatlansag utan lesz valaki AFK
Config.AfkTime = 60

-- Mekkora elmozdulast tekintunk "mozgasnak" (meterben).
-- Kis ertek -> erzekenyebb. Tul kicsi eseten a kamera/animacio remegese is mozgasnak szamithat.
Config.MoveThreshold = 0.20

-- A fej felett megjelenitett szoveg
Config.Label = 'AFK'

-- Kik hasznalhatjak a /afk teszt parancsot (ESX group alapjan, szerver oldalon ellenorizve).
-- Nem kell semmit a server.cfg-be irni, a szerver a jatekos ESX groupjat nezi.
Config.AllowedGroups = {
    ['owner'] = true,
}

-- Mutassa-e az AFK ido visszaszamlalojat (pl. 00:08) a felirat alatt
Config.ShowTimer = true

-- Milyen messzirol toltodjon be a felirat (meter). KIS ertek = csak nagyon kozelrol
-- rajzol -> nincs felesleges fogyasztas tavoli jatekosoknal.
Config.DrawDistance = 4.0

-- Milyen magasan legyen a felirat a jatekos felett (meter). Nagyobb ertek -> feljebb.
-- Eleg magasan kell legyen, hogy a szerver nev/ID plakatja fole keruljon (ne logjon bele).
Config.HeightOffset = 1.20
