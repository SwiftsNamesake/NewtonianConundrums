-- render.lua
-- June 28 2016


vec    = require 'src.vec'
shapes = require 'src.shapes'


local render = {}
render.debug = {}


function render.debug.polygon(polygon, options)

    print(options.label or '?')

    -- love.graphics.setColor(118, 185, 8, 255)
    love.graphics.setFont(options.font[64])
    love.graphics.print(options.label or '?', polygon[1].x, polygon[1].y)

    render.polygon(polygon, options)

    -- print('Length of arrow is: ', #arrow)
    for i, p in pairs(polygon) do
        love.graphics.setColor(unpack(options.dotColor or {118, 0, 8, 255}))
        love.graphics.circle('fill', p.x, p.y, 5, 50)
        love.graphics.setFont(options.font[12]) -- or assets.fonts.elixia[10]
        love.graphics.setColor(unpack(options.textColor or {8, 50, 8, 255}))
        love.graphics.print(i, p.x, p.y+6)
    end
end


function render.anchoredText(text, position, anchor)
    -- Render text that is not necessarily anchored by the top left corner
    local font = love.graphics:getFont() -- Use the selected font
    local size = vec(font:getWidth(text), font:getHeight(text))
    local p    = position - anchor:hadamard(size)
    love.graphics.print(text, p.x, p.y)
end


function render.polygon(polygon, options)

    local shapes = true and love.math.triangulate(shapes.flatten(polygon)) or { shapes.flatten(polygon) }

    for _, shape in pairs(shapes) do
        love.graphics.polygon('fill', shape)
    end
end


return render
