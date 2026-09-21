Config = {}

-- Key that opens the radio panel. Registered via RegisterKeyMapping, so players
-- can rebind it in FiveM Settings > Key Bindings.
Config.OpenKey = 'Q'

-- How long (ms) the key must be HELD to open the panel where a hold is required.
Config.HoldTime = 600

-- Only require the hold where the key actually clashes: driving an emergency
-- (class 18) vehicle, where bc_siren uses the same key for the police lights.
-- There: tap = lights, hold = radio. In any other vehicle a tap opens instantly.
-- Set to false to always require the hold.
Config.HoldInEmergencyOnly = true

-- Only allow the panel to open while inside a vehicle (car-radio behaviour).
-- Pressing the key on foot does nothing (a short notice is shown).
Config.VehicleOnly = true

-- Block the panel from opening while inside an interior (building/MLO). Pressing
-- the key there does nothing (a short notice is shown). Uses the game's interior
-- lookup, so garages, apartments and drivable MLOs all count as "inside".
Config.BlockInInterior = true

-- Stop the player's own radio when they leave the vehicle (car-radio behaviour).
Config.StopOnExit = true

-- Silence GTA's built-in vehicle radio so only bc_radio plays in cars.
Config.DisableGtaRadio = true

-- 3D audio falloff: max distance (metres) at which ANOTHER player's radio is
-- audible to you. Your own radio is flat 2D (constant, no falloff). Bigger =
-- nearby players/passengers hear it from further. xsound rolls off within range.
Config.MaxDistance = 5.0

-- Base volume (0.0-1.0) other players' radios play at BEFORE the 3D falloff.
-- Independent of your personal slider so a car radio always carries outward;
-- keep it high or nobody outside the car hears it until they're right on top.
Config.OthersVolume = 0.1

-- How often (ms) each client repositions in-range radios so they follow moving
-- broadcasters (e.g. a driving car). Lower = smoother (less choppy) but heavier.
-- Only your own radio is 2D and needs no updates; this is for others' 3D radios.
Config.UpdateInterval = 150

-- Volume ceiling: the actual xsound volume the slider reaches at 100%. The
-- panel's 0-100% maps onto 0 .. Config.MaxVolume, so 100% = this value.
-- (1.0 would be full GTA-radio loudness; 0.5 makes the loudest half of that.)
Config.MaxVolume = 0.5

-- Default listening volume as an xsound value (0 .. Config.MaxVolume). At
-- MaxVolume the slider shows 100%. Applies to every radio you hear (KVP-saved).
Config.DefaultVolume = 0.5

-- Server-side anti-spam: minimum seconds between broadcast syncs per player.
-- Bursts are coalesced (newest state wins), never dropped — see server/main.lua.
Config.ChangeCooldown = 1.0

-- Station list. `id` is the stable wire/state key — reordering the table is fine,
-- changing an id is not. `icon` is a Font Awesome (free solid) class. Stream URLs
-- verified working 2026-07; replace freely.
-- NOTE: entries marked "http only" have no https source. FiveM's NUI/CEF plays
-- them, but if your setup blocks mixed content, swap in an https stream.
Config.Stations = {
    { id = 'kossuth',   name = 'Kossuth Rádió',  genre = 'Közszolgálati',  icon = 'fa-microphone-lines', url = 'https://mr-stream.connectmedia.hu/4736/mr1.mp3' },
    { id = 'petofi',    name = 'Petőfi Rádió',   genre = 'Pop / fiatalos', icon = 'fa-music',            url = 'https://icast.connectmedia.hu/4738/mr2.mp3' },
    { id = 'bartok',    name = 'Bartók Rádió',   genre = 'Klasszikus',     icon = 'fa-masks-theater',    url = 'https://mr-stream.connectmedia.hu/4742/mr3hq.mp3' },
    { id = 'danko',     name = 'Dankó Rádió',    genre = 'Magyar nóta',    icon = 'fa-guitar',           url = 'http://mr-stream.mediaconnect.hu/4747/mr7.aac' }, -- http only
    { id = 'retro',     name = 'Retro Rádió',    genre = 'Retro slágerek', icon = 'fa-record-vinyl',     url = 'https://icast.connectmedia.hu/5001/live.mp3' },
    { id = 'radio1',    name = 'Rádió 1',        genre = 'Mai slágerek',   icon = 'fa-1',                url = 'https://icast.connectmedia.hu/5201/live.mp3' },
    { id = 'rockfm',    name = 'Rock FM 103.9',  genre = 'Rock',           icon = 'fa-bolt',             url = 'https://icast.connectmedia.hu/5301/live.mp3' },
    { id = 'basefm',    name = 'Base FM',        genre = 'Dance / house',  icon = 'fa-compact-disc',     url = 'https://icast.connectmedia.hu/5401/live.mp3' },
    { id = 'slager',    name = 'Sláger FM',      genre = 'Sláger',         icon = 'fa-star',             url = 'http://92.61.114.159:7812/slagerfm256.mp3' }, -- http only
    { id = 'danubius',  name = 'Danubius Rádió', genre = 'Felnőtt pop',    icon = 'fa-water',            url = 'https://stream.danubiusradio.hu/danubius_128k' },
    { id = 'jazzy',     name = 'Jazzy Rádió',    genre = 'Jazz / soul',    icon = 'fa-headphones',       url = 'https://radio.musorok.org/listen/jazzy/jazzy.mp3' },
    { id = 'klub',      name = 'Klubrádió',      genre = 'Közéleti',       icon = 'fa-comments',         url = 'https://a7.asurahosting.com:8160/radio.mp3' },
    { id = 'poptari',   name = 'Poptarisznya',   genre = 'Magyar retro',   icon = 'fa-guitar',           url = 'http://adas.poptarisznya.hu:8200/live.mp3' }, -- http only
    { id = 'dancewave', name = 'Dance Wave!',    genre = 'EDM',            icon = 'fa-fire',             url = 'https://dancewave.online/dance.mp3' },
}

-- Fast id -> station lookup, built once and shared by client + server.
Config.StationById = {}
for _, s in ipairs(Config.Stations) do
    Config.StationById[s.id] = s
end
