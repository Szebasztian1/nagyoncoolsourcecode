local Config = require("lua.shared.Config")
local GetOffsetFromCoord = require("lua.shared.GetOffsetFromCoord")

---@param offset vector3
local function GetOffsetFromOrigo(offset)
    return GetOffsetFromCoord(
        Config.INTERIOR_ORIGO,
        vector3(0, 0, 0),
        offset
    )
end

return GetOffsetFromOrigo
