---@vararg any
function DebugPrint(...)
    if not Config.Debug then return end
    print(...)
end
