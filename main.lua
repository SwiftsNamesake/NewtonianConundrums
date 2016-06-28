-- main.lua
-- Jonatan H Sundqvist
-- June 25 2016


require 'src.love_utils'
require 'src.utils'
require 'src.utils.collections'

class  = require 'src.lib.30log-llama'
Camera = require 'src.Camera'

vec    = require 'src.vec'
shapes = require 'src.shapes'
render = require 'src.render'
Object = require 'src.Object'


assets = {}

function assets.loadFont(fn)
    -- TODO: Rename (?)
    return defaultdict(function (size) return love.graphics.newFont(fn, size) end)
end


function love.load()
    assets.fonts = {}
    assets.fonts.alameda  = assets.loadFont('assets/fonts/alameda/alameda.ttf')
    assets.fonts.elixia   = assets.loadFont('assets/fonts/elixia.ttf')
    assets.fonts.aclonica = assets.loadFont('assets/fonts/aclonica.ttf')
    assets.fonts.kust     = assets.loadFont('assets/fonts/Kust_Free_Brush_Font/kust.otf')

    state = {}
    state.mode = 'interactive'
    state.editor = {}
    state.editor.tool = 'drag'
    state.editor.dragged_object = nil
    state.running = true
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    state.world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
    state.camera = Camera()

    state.world:setCallbacks(callbacks.beginContact, callbacks.endContact, callbacks.preSolve, callbacks.postSolve)

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
    love.graphics.setFont(assets.fonts.kust[30])
end


callbacks = {}

function callbacks.beginContact(a, b, coll)
    local obj_a, obj_b = a:getUserData(), b:getUserData()
    local cb_a, cb_b = (obj_a.beginContact or noop), (obj_b.beginContact or noop)

    cb_a(obj_a, obj_b, coll)
    cb_b(obj_b, obj_a, coll)
end


function callbacks.endContact(a, b, coll)
    local obj_a, obj_b = a:getUserData(), b:getUserData()
    local cb_a, cb_b = (obj_a.endContact or noop), (obj_b.endContact or noop)

    cb_a(obj_a, obj_b, coll)
    cb_b(obj_b, obj_a, coll)
end


function callbacks.preSolve(a, b, coll)
    local obj_a, obj_b = a:getUserData(), b:getUserData()
    local cb_a, cb_b = (obj_a.preSolve or noop), (obj_b.preSolve or noop)

    cb_a(obj_a, obj_b, coll)
    cb_b(obj_b, obj_a, coll)
end


function callbacks.postSolve(a, b, coll, normalimpulse, tangentimpulse)
    local obj_a, obj_b = a:getUserData(), b:getUserData()
    local cb_a, cb_b = (obj_a.postSolve or noop), (obj_b.postSolve or noop)

    cb_a(obj_a, obj_b, coll, normalimpulse, tangentimpulse)
    cb_b(obj_b, obj_a, coll, normalimpulse, tangentimpulse)
end


function love.update(dt)

    -- Universal events

    -- Mode-specific events
    if state.running and state.mode == 'interactive' then
        state.world:update(dt) --this puts the world into motion

        --here we are going to create some keyboard events
        if love.keyboard.isDown('right') then --press the right arrow key to push the ball to the right
            state.objects.ball.body:applyForce(400, 0)
        elseif love.keyboard.isDown('left') then --press the left arrow key to push the ball to the left
            state.objects.ball.body:applyForce(-400, 0)
        elseif love.keyboard.isDown('up') then --press the up arrow key to set the ball in the air
            state.objects.ball.body:setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
            state.objects.ball.body:setLinearVelocity(0, 0)
        elseif love.keyboard.isDown('space') then --press the left arrow key to push the ball to the left
            state.objects.ball.body:applyForce(0, -400)
        end
    end
end


function love.mousepressed(mx, my, button, istouch)
    local wx, wy = state.camera:getMousePosition()
    if state.mode == 'editor' then
        if state.editor.tool == 'random_shape' and button == 1 then
            local shape = (math.random() > 0.5) and love.physics.newRectangleShape(math.random(20, 120), math.random(20, 120)) or love.physics.newCircleShape(math.random(10, 60))
            local o = Object(state, { x=wx, y=wy }, shape, 5, 'dynamic')
            o.color = { math.random(0, 255), math.random(0, 255), math.random(0, 255), 255 }
            table.insert(state.objects, o)
        end

        if state.editor.tool == 'drag' and button == 1 then
            local closest = 999
            local obj_to_drag = nil
            for _, obj in pairs(state.objects) do
                local d = math.dist(wx, wy, obj.x, obj.y)
                if d < closest and obj:testPoint(wx, wy) then
                    closest = d
                    obj_to_drag = obj
                end
            end

            state.editor.dragged_object = obj_to_drag
        end
    end
end


function love.mousereleased(mx, my, button, istouch)
    if button == 1 then
        state.editor.dragged_object = nil
    end
end


function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(2) then
        state.camera:move(-dx * state.camera.sx, -dy * state.camera.sy)
    end

    local dragged_object = state.editor.dragged_object
    if state.mode == 'editor' and dragged_object ~= nil then
        dragged_object.x = dragged_object.x + dx * state.camera.sx
        dragged_object.y = dragged_object.y + dy * state.camera.sy
    end
end


function love.wheelmoved(x, y)
    local dragged_object = state.editor.dragged_object
    if state.mode == 'editor' and dragged_object ~= nil then
        dragged_object.body:setAngle(dragged_object.body:getAngle() + y * 0.1)
    else
        local wx, wy = state.camera:getMousePosition()
        if y >= 0 then
            state.camera:scaleAround(wx, wy, 0.8, 0.8)
        else
            state.camera:scaleAround(wx, wy, 1.25, 1.25)
        end
    end
end


function love.keypressed(key, scancode, isrepeat)

    -- TODO: Does Lua cache local constants?
    local keymap = {
        escape = function(key, scancode, isrepeat) love.event.quit(0) end,
        p      = function(key, scancode, isrepeat) state.running = not state.running end,
        tab    = function(key, scancode, isrepeat) state.mode = (state.mode == 'interactive') and 'editor' or 'interactive' end,
        ['1']  = function(key, scancode, isrepeat) state.editor.tool = 'drag' end,
        ['2']  = function(key, scancode, isrepeat) state.editor.tool = 'random_shape' end
    }

    -- TODO: Use safeget...
    if not isrepeat and keymap[key] then
        keymap[key](key, scancode, isrepeat)
    end
end


function love.draw()
    local w, h   = love.graphics.getDimensions()

    state.camera:set()
    for _, obj in pairs(state.objects) do
        obj:render()
    end
    state.camera:unset()

    -- GUI Overlay
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(assets.fonts.kust[30])
    love.graphics.print(state.mode, 40, 24)
    if state.mode == 'editor' then
        love.graphics.print('Tool: ' .. state.editor.tool, 40, 48)
    end

    -- Ball tag
    local ball = state.objects.ball
    local name = 'ball'
    local r    = ball.shape:getRadius()
    local font = assets.fonts.kust[22]
    local dx, dy = unpack({ font:getWidth(name), font:getHeight(name) })

    love.graphics.setColor(46, 13, 52, 255)
    love.graphics.setFont(font)
    love.graphics.print(name, ball.x-dx/2, ball.shape:getPoint()-r-5)

    -- Paused
    if not state.running then
        local font = assets.fonts.kust[128]
        love.graphics.setFont(font)
        local dx, dy = unpack({ font:getWidth('Paused'), font:getHeight('Paused') })

        love.graphics.setColor(0, 0, 0, 160)
        love.graphics.rectangle('fill', 0, 0, w, h)
        love.graphics.setColor(21, 185, 126, 255)
        love.graphics.print('Paused', (w-dx)/2, (h-dy)/2)
    end

    -- Test arrow
    -- print(#shapes.flatten(shapes.arrow(vec(x1, y1), vec(x2, y2), 0.7, 1, 2)))
    local fr = vec(w, h):scale(0.5)
    local to = fr+vec.fromPolar({ mag=80, arg=math.fmod(love.timer.getTime(), 2*math.pi) })
    local ratio = 0.6 --0.2 + 0.7*0.5*(1+math.sin(love.timer.getTime()))
    local arrow = shapes.arrow(fr, to, ratio, 20, 40)

    -- love.graphics.setColor(118, 185, 8, 255)
    -- love.graphics.setColor(8, 50, 8, 255)
    -- love.graphics.setFont(assets.fonts.elixia[10])
    render.debug.polygon(arrow, { triangulate=true, dotColor={118, 185, 8, 255}, textColor={8, 50, 8, 255}, font=assets.fonts.elixia[10] })

end
