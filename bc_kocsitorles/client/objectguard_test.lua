-- TESZT SEGED az objektum spawn-vedelemhez (server/objectguard.lua).
--
-- Csak a szerver-konzolbol inditott `osg_test <id> [1]` hivja: a jatekos elott
-- letrehoz egy HALOZATI terelobojat, jelolve vagy jeloletlenul. A jeloletlennek
-- a turelmi ido utan el kell tunnie, a jeloltnek meg kell maradnia.

local TEST_MODEL <const> = "prop_roadcone02a"

RegisterNetEvent("bc_kocsitorles:osgTest", function(marked)
    local model = GetHashKey(TEST_MODEL)

    RequestModel(model)

    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < deadline do
        Wait(0)
    end

    if not HasModelLoaded(model) then
        return print("[osg_test] a teszt-modell nem toltodott be")
    end

    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.5, 0.0)
    local object = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetModelAsNoLongerNeeded(model)

    if object == 0 then
        return print("[osg_test] a teszt-objektum nem jott letre")
    end

    PlaceObjectOnGroundProperly(object)

    if marked and NetworkGetEntityIsNetworked(object) then
        Entity(object).state:set('bc_spawned', true, true)
    end

    print(("[osg_test] %s teszt-objektum letrehozva, net=%s"):format(
        marked and "JELOLT" or "JELOLETLEN", NetworkGetNetworkIdFromEntity(object)))
end)
