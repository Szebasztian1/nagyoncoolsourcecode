local InstanceRegistry = {}
---@type table<number, C_Instance>
InstanceRegistry._entities = {}

---@param entity C_Instance
function InstanceRegistry:add(entity)
    self._entities[entity.id] = entity
end

function InstanceRegistry:remove(id)
    self._entities[id] = nil
end

function InstanceRegistry:get(id)
    return self._entities[id]
end

return InstanceRegistry
