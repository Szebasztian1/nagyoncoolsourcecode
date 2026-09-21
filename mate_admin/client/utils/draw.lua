screenX, screenY = GetActiveScreenResolution()

local function reMap(e, t, r, o, a)
    return ((e - t) * (a - o)) / (r - t) + o
end

local function resp(e)
    return e * reMap(screenX, 1080, 2560, 1.25, 1)
end

---@param params { value: string, scale?: number, font?: integer, outline?: boolean, color?: { r:integer, g:integer, b:integer, a:integer }, center?: boolean, pos?: { x:number, y:number } }
function DrawText(params)
    local scale = resp(params.scale or 1)

    SetTextScale(0.35 * scale, 0.35 * scale)
    SetTextFont(params.font or BebasNeueFont or 4)

    if params.outline then
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
    end

    local c = params.color
    SetTextColour(
        c and c.r or 255,
        c and c.g or 255,
        c and c.b or 255,
        math.floor(c and c.a or 255)
    )

    if params.center then
        SetTextWrap(0.0, 2.0)
        SetTextCentre(true)
    end

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(params.value or '')
    EndTextCommandDisplayText(
        (params.pos and params.pos.x or 0.0) / screenX,
        (params.pos and params.pos.y or 0.0) / screenY
    )
end

---@param font?  integer
---@param scale? number
---@return number
function GetTextHeight(font, scale)
    font = font or BebasNeueFont or 4
    return (GetRenderedCharacterHeight(resp(scale or 1.0), font) * screenY) + 0.007
end

local _widthCache = {}

---@param text  string
---@param font? integer
---@param scale? number
---@return number
function GetTextWidth(text, font, scale)
    font      = font or BebasNeueFont or 4
    scale     = tonumber(string.format("%.2f", scale or 1.0))
    local key = text .. '-' .. font .. '-' .. scale
    if _widthCache[key] then return _widthCache[key] end

    SetTextFont(font)
    SetTextScale(0.35 * scale, 0.35 * scale)
    BeginTextCommandWidth("STRING")
    AddTextComponentSubstringKeyboardDisplay(text)
    _widthCache[key] = EndTextCommandGetWidth(true)
    return _widthCache[key]
end

---@param params { pos: { x:number, y:number }, size: { x:number, y:number }, color: { r:integer, g:integer, b:integer, alpha:integer } }
function DrawRectangle(params)
    local drawW = (params.size and params.size.x or 0.0) / screenX
    local drawH = (params.size and params.size.y or 0.0) / screenY

    DrawRect(
        ((params.pos and params.pos.x or 0.0) / screenX) + (drawW / 2),
        ((params.pos and params.pos.y or 0.0) / screenY) + (drawH / 2),
        drawW,
        drawH,
        params.color and params.color.r or 255,
        params.color and params.color.g or 255,
        params.color and params.color.b or 255,
        math.floor(params.color and params.color.alpha or 255)
    )
end

---@param params { x:number, y:number, width?:number, height?:number, value:number, max:number, bg:{ r:integer,g:integer,b:integer,a:integer }, fill:{ r:integer,g:integer,b:integer,a:integer } }
function DrawWorldProgress(params)
    local width  = params.width or 0.05
    local height = params.height or 0.004

    if not params.value or not params.max or params.max <= 0 then return end
    local progress = math.min(1.0, math.max(0.0, params.value / params.max))

    DrawRect(params.x, params.y, width, height,
        params.bg.r, params.bg.g, params.bg.b, params.bg.a)

    DrawRect(
        params.x - (width / 2) + ((progress * width) / 2),
        params.y,
        progress * width,
        height - 0.001,
        params.fill.r, params.fill.g, params.fill.b, params.fill.a
    )
end

---@param params { dict:string, texture:string, pos:{ x:number, y:number }, size:{ x:number, y:number }, alpha?:integer }
function DrawImage(params)
    if not params.dict or not params.texture then return end

    local drawW = (params.size and params.size.x or 0.0) / screenX
    local drawH = (params.size and params.size.y or 0.0) / screenY

    DrawSprite(
        params.dict,
        params.texture,
        ((params.pos and params.pos.x or 0.0) / screenX) + (drawW / 2),
        ((params.pos and params.pos.y or 0.0) / screenY) + (drawH / 2),
        drawW,
        drawH,
        0.0,
        255, 255, 255,
        math.floor(params.alpha or 255)
    )
end
