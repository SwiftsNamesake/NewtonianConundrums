-- Object.lua


class  = require 'src.lib.30log-llama'

vec    = require 'src.vec'
shapes = require 'src.shapes'
render = require 'src.render'



local Object = class()
local counter = 0

function Object:__init(state, pos, shape, density, body_type)
    self._state = state -- Cache for later
    self.body    = love.physics.newBody(state.world, pos.x, pos.y, body_type) -- Body type is either 'dynamic', 'static' or 'kinematic'
    self.shape   = shape
    self.fixture = love.physics.newFixture(self.body, self.shape, density)
    self.color = {50, 50, 50}

    self.label = counter -- Used for debugging
    counter = counter + 1

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


Object:property(
    'velocity',
    function(self) return vec(unpack({self.body:getLinearVelocity()})) end,
    function(self, v) return self.body:setLinearVelocity(v.x, v.y) end
)


Object:property(
    'position',
    function(self) return vec(self.x, self.y) end,
    function(self, p)
        -- TODO: What should this return (?)
        self.x = p.x
        self.y = p.y
    end
)


function Object:render(options)
    love.graphics.setColor(unpack(self.color))
    -- local shape_type = self.shape:getType()
    local whyNoAnonymousTables = ({
        circle  = function() love.graphics.circle('fill', self.x, self.y, self.shape:getRadius()) end,
        polygon = function() love.graphics.polygon('fill', self.body:getWorldPoints(self.shape:getPoints())) end
    })[self.shape:getType()]()

    local v = self.velocity
    love.graphics.setColor(118, 185, 8, 255)
    -- print(#shapes.flatten(shapes.arrow(vec(x1, y1), vec(x2, y2), 0.7, 1, 2)))

    if v:abs() > 0.01  then
        local fr = self.position
        local to = fr+v:scale(0.5)
        local arrow = shapes.arrow(fr, to, math.clamp(0.2, 1 - 30/(to-fr):abs(), 0.95), 10, 30)
        render.polygon(arrow, { triangulate=true, font=assets.fonts.elixia, label=self.label })
    end

    -- TODO: We need a less fragile way of dealing with modes
    if self._state.mode == 'editor' then
        love.graphics.setColor(255, 255, 255, 255)
        local av    = self.body:getAngularVelocity()
        local angle = -math.angle(self.x, self.y, self.x+v.x/2, self.y+v.y/2) - math.pi/2

        -- love.graphics.setColor(2, 12, 228, 255)
        -- love.graphics.line(x1, y1, x2, y2)

        love.graphics.arc('line', 'open', self.x, self.y, 16, angle, angle + av / 2)
    end
end


function Object:testPoint(x, y)
    return self.shape:testPoint(self.x, self.y, self.body:getAngle(), x, y)
end


return Object
