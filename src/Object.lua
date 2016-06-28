-- Object.lua


class  = require 'src.lib.30log-llama'

vec    = require 'src.vec'
shapes = require 'src.shapes'
render = require 'src.render'



local Object = class()

function Object:__init(state, pos, shape, density, body_type)
    self._state = state -- Cache for later
    self.body    = love.physics.newBody(state.world, pos.x, pos.y, body_type) -- Body type is either 'dynamic', 'static' or 'kinematic'
    self.shape   = shape
    self.fixture = love.physics.newFixture(self.body, self.shape, density)
    self.color = {50, 50, 50}

    self.fixture:setUserData(self)
end


Object:property(
    'x',
    function(self) return self.body:getX() end,
    function(self, v) return self.body:setX(v) end
)


Object:property(
    'y',
    function(self) return self.body:getY() end,
    function(self, v) return self.body:setY(v) end
)


function Object:render(options)
    love.graphics.setColor(unpack(self.color))
    local shape_type = self.shape:getType()
    if shape_type == 'circle' then
        love.graphics.circle('fill', self.x, self.y, self.shape:getRadius())
    elseif shape_type == 'polygon' then
        love.graphics.polygon('fill', self.body:getWorldPoints(self.shape:getPoints()))
    end

    local vx, vy = self.body:getLinearVelocity()
    love.graphics.setColor(118, 185, 8, 255)
    -- print(#shapes.flatten(shapes.arrow(vec(x1, y1), vec(x2, y2), 0.7, 1, 2)))

    if vec(vx, vy) ~= vec(0,0) then
        print(vx, vy)
        local arrow = shapes.arrow(vec(self.x, self.y), vec(self.x, self.y)+vec(vx, vy):scale(0.5), 0.7, 10, 20)
        render.debug.polygon(arrow, { triangulate=true, font=assets.fonts.elixia[10] })
    end

    if self._state.mode == 'editor' then
        love.graphics.setColor(255, 255, 255, 255)
        local vx, vy = self.body:getLinearVelocity()
        local av = self.body:getAngularVelocity()

        local x1, y1, x2, y2 = self.x, self.y, self.x + vx / 2, self.y + vy / 2
        local angle = - math.angle(x1, y1, x2, y2) - math.pi/2

        -- love.graphics.setColor(2, 12, 228, 255)
        -- love.graphics.line(x1, y1, x2, y2)

        love.graphics.arc('line', 'open', self.x, self.y, 16, angle, angle + av / 2)
    end
end


Object:property(
  'x',
  function(self) return self.body:getX() end,
  function(self, v) return self.body:setX(v) end
)


Object:property(
  'y',
  function(self) return self.body:getY() end,
  function(self, v) return self.body:setY(v) end
)



function Object:testPoint(x, y)
    return self.shape:testPoint(self.x, self.y, self.body:getAngle(), x, y)
end


return Object
