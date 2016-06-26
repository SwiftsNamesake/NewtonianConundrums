-- main.lua
-- Jonatan H Sundqvist
-- June 25 2016

require "src.love_utils"
require "src.utils"

class = require "src.lib.30log-llama"

local Object = class()

function Object:__init(state, pos, shape, density, body_type)
    self._state = state -- Cache for later
    
    self.body    = love.physics.newBody(state.world, pos.x, pos.y, body_type) -- Body type is either 'dynamic', 'static' or 'kinematic'
    self.shape   = shape
    self.fixture = love.physics.newFixture(self.body, self.shape, density)
    self.color = {50, 50, 50}
end

Object:property(
    "x", 
    function(self) return self.body:getX() end,
    function(self, v) return self.body:setX(v) end
)
Object:property(
    "y", 
    function(self) return self.body:getY() end,
    function(self, v) return self.body:setY(v) end
)

function Object:render(options)
    love.graphics.setColor(unpack(self.color))
    local shape_type = self.shape:getType()
    if shape_type == "circle" then
        love.graphics.circle('fill', self.x, self.y, self.shape:getRadius())
    elseif shape_type == "polygon" then
        love.graphics.polygon('fill', self.body:getWorldPoints(self.shape:getPoints()))
    end
end


function love.load()
    assets = {}
    assets.fonts = {}
    assets.fonts.alameda = love.graphics.newFont('assets/fonts/alameda/alameda.ttf', 30)
    assets.fonts.kust = love.graphics.newFont('assets/fonts/Kust_Free_Brush_Font/kust.otf', 30)

    state = {}
    state.mode = "interactive"
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    state.world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
    
    -- table to hold all our physical objects
    local w, h = love.graphics.getDimensions()

    state.objects = {}
    state.objects.ground = Object(state, { x=w/2, y=h-50/2 },       love.physics.newRectangleShape(w, 50),  3, 'static')
    state.objects.ground.color = {25, 190, 105}
    state.objects.ball = Object(state, { x=w/2, y=h/2},           love.physics.newCircleShape(20),         3, 'dynamic')
    state.objects.ball.fixture:setRestitution(0.8) -- Let the ball bounce
    state.objects.ball.color = {193, 47, 14}
    state.objects.block1 = Object(state, { x=w/2, y=h-100/2 },      love.physics.newRectangleShape(50, 100), 5, 'dynamic')
    state.objects.block2 = Object(state, { x=w/2, y=h-100/2-50/2 }, love.physics.newRectangleShape(100, 50), 5, 'dynamic')

    for i=1,8 do
        local new_object = Object(state, { x=(i*60)+(w/2)-600, y=h-140/2 }, love.physics.newRectangleShape(24, 140), 8, 'dynamic')
        table.insert(state.objects, new_object)
    end

    love.graphics.setBackgroundColor(104, 136, 248) -- Set the background color to a nice blue
    love.graphics.setFont(assets.fonts.kust)
end


function love.update(dt)
    state.world:update(dt) --this puts the world into motion
    
    --here we are going to create some keyboard events
    if love.keyboard.isDown('right') then --press the right arrow key to push the ball to the right
        state.objects.ball.body:applyForce(400, 0)
    elseif love.keyboard.isDown('left') then --press the left arrow key to push the ball to the left
        state.objects.ball.body:applyForce(-400, 0)
    elseif love.keyboard.isDown('up') then --press the up arrow key to set the ball in the air
        state.objects.ball.body:setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    elseif love.keyboard.isDown('space') then --press the left arrow key to push the ball to the left
        state.objects.ball.body:applyForce(0, -400)
    end
    
    state.mode = love.keyboard.isDown('tab') and 'editor' or 'interactive'
end

function love.draw()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(state.mode, 40, 24)

    for _, obj in pairs(state.objects) do
        obj:render()
    end
end
