local eLivestock = require("lua.shared.enums.eLivestock")

---@class C_Livestock : OxClass
---@field id number
---@field type eLivestock
---@field netId number
---@field age number
---@field health number
---@field quality number
---@field requirements number
---@field gather number
local Livestock = lib.class("C_Livestock")

---@param id number
---@param netId number
function Livestock:constructor(id, netId)
    self.id = id
    self.netId = netId
    self.age = 0
    self.health = 0
    self.quality = 0
    self.requirements = 0
    self.gather = 0
    self.type = eLivestock.PigLandrace
end

function Livestock:getEntity()
    return NetworkGetEntityFromNetworkId(self.netId)
end

function Livestock:getPosition()
    return GetEntityCoords(self:getEntity())
end

function Livestock:exists()
    return NetworkDoesEntityExistWithNetworkId(self.netId)
end

function Livestock:isDead()
    return self.health <= 0
end

function Livestock:initialize()
    local scriptId = self:getEntity()

    SetPedCanRagdoll(scriptId, false);
    SetPedCanRagdollFromPlayerImpact(scriptId, false);
    SetBlockingOfNonTemporaryEvents(scriptId, true);
    SetPedFleeAttributes(scriptId, 0, false);
    SetPedCombatAttributes(scriptId, 17, true);
    SetPedCombatAttributes(scriptId, 5, true);
    SetPedSeeingRange(scriptId, 0.0);
    SetPedHearingRange(scriptId, 0.0);
    SetPedAlertness(scriptId, 0);
    SetEntityInvincible(scriptId, true);
    SetPedCanBeTargetted(scriptId, false);
end

function Livestock:isLocalNetOwner()
    return NetworkGetEntityOwner(self:getEntity()) == PlayerId()
end

---@param dui Dui
function Livestock:refresh(dui)
    local data = {
        type = self.type,
        name = locale(self.type),
        entries = {
            { locale("AGE"),          self.age },
            { locale("HEALTH"),       self.health },
            { locale("QUALITY"),      self.quality },
            { locale("REQUIREMENTS"), self.requirements }
        },
        image = ("nui://%s/data/images/%s.png"):format(GetCurrentResourceName(), self.type)
    }

    if self.type == eLivestock.Cow or self.type == eLivestock.Chicken then
        table.insert(
            data.entries,
            { locale("GATHER"), self.gather }
        )
    end
    dui:sendMessage(data)
end

return Livestock
