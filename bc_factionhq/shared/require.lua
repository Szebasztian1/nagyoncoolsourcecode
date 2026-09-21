--[[
    Minimal module loader: vanilla FiveM Lua has no resource-file-aware
    require, so this provides one (same contract as standard Lua):

        local M = require 'client.modules.marker'

    Dots map to folders, the module file must return its interface.
    Client-side the file must be listed in files{} so LoadResourceFile
    can read it. Results are cached; a module runs exactly once.
]]

local loaded = {}
local resourceName = GetCurrentResourceName()

function require(name)
    local key = tostring(name)
    local cached = loaded[key]
    if cached ~= nil then return cached end

    local path = key:gsub('%.', '/') .. '.lua'
    local src = LoadResourceFile(resourceName, path)
    if not src then
        error(("module '%s' not found (missing file or files{} entry: %s)"):format(key, path), 2)
    end

    local chunk, err = load(src, ('@@%s/%s'):format(resourceName, path))
    if not chunk then
        error(("module '%s' load error: %s"):format(key, tostring(err)), 2)
    end

    local result = chunk()
    if result == nil then result = true end
    loaded[key] = result
    return result
end
