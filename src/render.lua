-- render.lua
-- June 28 2016


vec    = require 'src.vec'
shapes = require 'src.shapes'


local render = {}
render.debug = {}


function render.debug.polygon(polygon, options)
    for i, p in polygon do
    print(polygon)
end
    local shapes = options.triangulate and love.math.triangulate(shapes.flatten(polygon)) or { shapes.flatten(polygon) }
    -- love.graphics.setColor(118, 185, 8, 255)
    for _, shape in pairs(shapes) do
        love.graphics.polygon('fill', shape)
    end

    -- print('Length of arrow is: ', #arrow)
    for i, p in pairs(polygon) do
        love.graphics.setColor(unpack(options.dotColor or {118, 0, 8, 255}))
        love.graphics.circle('fill', p.x, p.y, 5, 50)
        love.graphics.setFont(options.font) -- or assets.fonts.elixia[10]
        love.graphics.setColor(unpack(options.textColor or {8, 50, 8, 255}))
        love.graphics.print(i, p.x, p.y+6)
    end
end


return render
