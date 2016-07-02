--


moses = require 'src.lib.moses.moses'


local named_colors = {
    red   = { 255,   0,   0, 255 },
    green = {   0, 255,   0, 255 },
    blue  = {   0,   0, 255, 255 },
    white = { 255, 255, 255, 255 }
}


local function fromHexString(s)
    -- error('Hex color codes not yet implemented: ' .. arg, 2)
    -- TODO: Refactor
    return { tonumber(s:sub(2, 3), 16), tonumber(s:sub(4, 5), 16), tonumber(s:sub(6, 7), 16), tonumber(s:sub(8, 9), 16) or 255 }
end


local function parseColor(color, ...)
    local args = type(color) == 'table' and color or {color, ...}

    if #args == 1 then
        local arg = args[1]
        if string.startswith(arg, '#') and (#arg == (1+3*2) or #arg == (1+4*2)) then
            return fromHexString(arg)
        else
            return named_colors[arg] or error('Unknown color name', 2)
        end
    elseif #args == 3 then
        return unpack(args) -- Can(should) only be RGB
    elseif #args == 4 then
        if type(args[1]) == 'string' then
            error('Other color spaces not yet implemented: ' .. args[1], 2)
        else
            return unpack(args) -- Can(should) only be RGBA
        end
    elseif #args == 5 then
        error('Other color spaces not yet implemented: ' .. args[1], 2)
    end
end


local function Color(color, ...)
    local r, g, b, a = parseColor(color, ...) --
    return { red=r, green=g, blue=b, alpha=a }
end


return Color
