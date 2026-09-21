local TagTxd <const> = CreateRuntimeTxd("mate-admin-tag-txd")
CreateRuntimeTextureFromImage(TagTxd, "admin_tag", "assets/logo.png")

---@type table<number, { name: string, group: string, tagHidden: boolean }>
local dutyAdmins = {}

---@param serverId integer
---@return boolean
function IsDutyAdmin(serverId)
    return dutyAdmins[serverId] ~= nil
end

local isRendering = false

---@type table<string, { label: string, color: integer }>
local groupCache = {}

---@param group string
---@return { label: string, color: integer }
local function getGroupData(group)
    local cached = groupCache[group]
    if cached then return cached end

    for _, g in ipairs(Config.AdminGroups) do
        if g.name == group then
            cached = { label = g.label, color = g.color }
            groupCache[group] = cached
            return cached
        end
    end

    cached = { label = group, color = 0xFFFFFF }
    groupCache[group] = cached
    return cached
end

---@param serverId integer
---@param data     { name: string, group: string, textNormal?: string, textTalking?: string }
local function ensureTagTexts(serverId, data)
    if data.textNormal then return end

    local groupData = getGroupData(data.group)
    local r         = (groupData.color >> 16) & 0xFF
    local g         = (groupData.color >> 8) & 0xFF
    local b         = groupData.color & 0xFF

    local rest      = (' <font color="#%02X%02X%02X">[%s]</font> %s'):format(r, g, b, groupData.label, data.name)

    data.textNormal  = ('[%d]'):format(serverId) .. rest
    data.textTalking = ('<font color="#228be6">[%d]</font>'):format(serverId) .. rest
end

---@param pos  vector3
---@param text string
-- Reused across every draw call; this runs per visible admin per frame.
local TAG_COLOR <const> = { r = 255, g = 255, b = 255, a = 255 }
local tagPos            = { x = 0, y = -5 }
local tagParams         = { outline = true, center = true, color = TAG_COLOR, pos = tagPos, scale = 0.6 }

local function drawAdminTag(pos, text)
    if Config.AdminTag.useImage then
        DrawMarker(
            43,
            pos + vector3(0.0, 0.0, 0.23),
            vector3(0.0, 0.0, 0.0),
            vector3(-89.9, 0.0, 180.0),
            Config.AdminTag.iconScale,
            255, 255, 255, 255,
            false, true, 0, true,
            "mate-admin-tag-txd",
            "admin_tag",
            false
        )
    end

    SetDrawOrigin(pos.x, pos.y, pos.z, 0)

    tagParams.value = text
    tagParams.font  = BebasNeueFont
    DrawText(tagParams)

    ClearDrawOrigin()
end

---@param ped integer
---@return vector3
local function getPredictedHeadCoords(ped)
    local bone   = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, 31086))
    local coords = (bone == vec3(0, 0, 0)) and (GetEntityCoords(ped) + vec3(0, 0, 0.9)) or (bone + vec3(0, 0, 0.35))
    local vel    = GetEntityVelocity(ped)
    local ft     = GetFrameTime()
    return vec3(coords.x + vel.x * ft, coords.y + vel.y * ft, coords.z + vel.z * ft)
end

local function renderLoop()
    isRendering = true

    while true do
        local myPed  = PlayerPedId()
        local myId   = PlayerId()
        local myPos  = GetEntityCoords(myPed)
        local hasAny = false

        for serverId, data in pairs(dutyAdmins) do
            if not data.tagHidden then
                local player = GetPlayerFromServerId(serverId)

                if player ~= -1 then
                    local ped = GetPlayerPed(player)

                    if DoesEntityExist(ped) then
                        local pedPos = GetEntityCoords(ped)
                        local dist   = #(pedPos - myPos)

                        if dist <= Config.AdminTag.renderDistance and IsEntityOnScreen(ped) then
                            local headPos = (getPredictedHeadCoords(ped)+vector3(0.0, 0.0, 0.2))

                            if IsSphereVisible(headPos.x, headPos.y, headPos.z, 0.01) then
                                ensureTagTexts(serverId, data)

                                local text = NetworkIsPlayerTalking(player)
                                    and data.textTalking
                                    or data.textNormal

                                drawAdminTag(headPos, text)

                                hasAny = true
                            end
                        end
                    end
                end
            end
        end

        if not hasAny then break end
        Wait(0)
    end

    isRendering = false
end

CreateThread(function()
    while true do
        -- Nothing to scan for until at least one admin is on duty: skip the coord
        -- lookup entirely and idle long instead of polling every 300ms forever.
        if not next(dutyAdmins) then
            Wait(2000)
            goto continue
        end

        local myPos  = GetEntityCoords(PlayerPedId())
        local nearby = false

        for serverId, data in pairs(dutyAdmins) do
            if not data.tagHidden then
                local player = GetPlayerFromServerId(serverId)

                if player ~= -1 then
                    local ped = GetPlayerPed(player)

                    if DoesEntityExist(ped) then
                        if #(GetEntityCoords(ped) - myPos) <= Config.AdminTag.renderDistance then
                            nearby = true
                            break
                        end
                    end
                end
            end
        end

        if nearby and not isRendering then
            CreateThread(renderLoop)
        end

        Wait(300)
        ::continue::
    end
end)

RegisterNetEvent('mate-admin:tag:onDuty')
AddEventHandler('mate-admin:tag:onDuty', function(serverId, name, group)
    dutyAdmins[serverId] = { name = name, group = group, tagHidden = false }
end)

RegisterNetEvent('mate-admin:tag:offDuty')
AddEventHandler('mate-admin:tag:offDuty', function(serverId)
    dutyAdmins[serverId] = nil
end)

RegisterNetEvent('mate-admin:tag:update')
AddEventHandler('mate-admin:tag:update', function(serverId, tagHidden)
    if dutyAdmins[serverId] then
        dutyAdmins[serverId].tagHidden = tagHidden
    end
end)

RegisterNetEvent('mate-admin:tag:sync')
AddEventHandler('mate-admin:tag:sync', function(syncData)
    dutyAdmins = {}
    for serverId, data in pairs(syncData) do
        dutyAdmins[serverId] = data
    end
end)
