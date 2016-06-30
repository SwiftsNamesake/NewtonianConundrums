--


moses = require 'src.lib.moses.moses'


local color_by_name = {
    red   = { 255,   0,   0, 255 },
    green = {   0, 255,   0, 255 },
    blue  = {   0,   0, 255, 255 },
    white = { 255, 255, 255, 255 }
}


local function fromHexString(s)
    -- error("Hex color codes not yet implemented: " .. arg, 2)
    -- TODO: Refactor
    return { tonumber(moses.slice(arg, 2, 4), 16), tonumber(moses.slice(arg, 4, 6), 16), tonumber(moses.slice(arg, 6, 8), 16) }
end


local function Color(color, ...)
    local args = type(color) == 'table' and color or {color, ...}

    if #args == 1 then
        local arg = args[1]
        if string.startswith(arg, "#") and #arg == (1+3*2) then
            return fromHexString(arg)
        else
            return color_by_name[arg] or error("Unknown color name", 2)
        end
    elseif #args == 3 then
        return unpack(args) -- Can(should) only be RGB
    elseif #args == 4 then
        if type(args[1]) == "string" then
            error("Other color spaces not yet implemented: " .. args[1], 2)
        else
            return unpack(args) -- Can(should) only be RGBA
        end
    elseif #args == 5 then
        error("Other color spaces not yet implemented: " .. args[1], 2)
    end
end

return Color
