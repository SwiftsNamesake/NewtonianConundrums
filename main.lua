-- main.lua
-- Jonatan H Sundqvist
-- June 25 2016


require 'src.love_utils'
require 'src.utils'
require 'src.utils.collections'

moses = require 'src.lib.moses.moses'

json   = require 'src.lib.dkjson'
class  = require 'src.lib.30log-llama'
Camera = require 'src.Camera'

vec    = require 'src.vec'
shapes = require 'src.shapes'
render = require 'src.render'
Object = require 'src.Object'


assets = {}

function assets.loadFont(fn)
    -- TODO: Rename (?)
    return defaultdict(function (size) return love.graphics.newFont('assets/fonts/'..fn, size) end)
end


-- function assets.loadImage()


function love.load()
    assets.fonts = {}
    assets.fonts.alameda  = assets.loadFont('alameda/alameda.ttf')
    assets.fonts.elixia   = assets.loadFont('elixia.ttf')
    assets.fonts.aclonica = assets.loadFont('aclonica.ttf')
    assets.fonts.kust     = assets.loadFont('Kust_Free_Brush_Font/kust.otf')

    assets.images = defaultdict(function(fn) return love.graphics.newImage('assets/images/'..fn) end)
    assets.sounds = defaultdict(function(fn) return love.audio.newSource('assets/audio/'..fn, 'static') end)

    -- TODO: Move to conf.lua (?)
    love.window.setIcon(love.image.newImageData('icon.png'))

    state = {}
    state.mode = 'interactive'
    state.editor = {}
    state.editor.tool = 'drag'
    state.editor.dragged_object = nil
    state.running = true
    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    state.world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
    state.camera = Camera()

    state.interactive = {}
    state.interactive.pin = nil -- Object that is pinned by the mouse

    state.world:setCallbacks(callbacks.beginContact, callbacks.endContact, callbacks.preSolve, callbacks.postSolve)

    -- table to hold all our physical objects
    local w, h = love.graphics.getDimensions()
    state.objects = {}

    local ps = { vec(0,0), vec(200, 300):scale(4.2), vec(400, -30):scale(4.2), vec(250, -200):scale(4.2) }

    state.objects.ball = Object(state, vec(w/2, h/2), love.physics.newCircleShape(20), 3, 'dynamic')
    state.objects.ball.fixture:setRestitution(0.8) -- Let the ball bounce
    state.objects.ball.color = {193, 47, 14}

    for i, block in ipairs(love.filesystem.getDirectoryItems('assets/images/minecraft')) do
        if string.endswith(block, '.png') then
            local sz = vec(60, 60)
            local hs = sz:scale(0.5)
            local o = Object(state, vec(i*sz.x, sz.y), love.physics.newRectangleShape(sz.x, sz.y), 3, 'dynamic', 'mesh')
            o.mesh = love.graphics.newMesh({
                { -hs.x, -hs.y, 0.0, 0.0, 255, 255, 255, 255 },
                {  hs.x, -hs.y, 1.0, 0.0, 255, 255, 255, 255 },
                {  hs.x,  hs.y, 1.0, 1.0, 255, 255, 255, 255 },
                { -hs.x,  hs.y, 0.0, 1.0, 255, 255, 255, 255 },
            }, 'fan', 'dynamic')
            o.label = block:sub(1, #block+1-1-4)
            o.mesh:setTexture(assets.images['minecraft/'..block])
            table.insert(state.objects, o)
            print(o.label)
        end
    end

    for i, p in pairs(ps) do
        table.insert(state.objects, Object(state, p+vec(w/2, h-50/2), love.physics.newRectangleShape(w, 50),  3, 'static'))
        state.objects[#state.objects].color = {25, 190, 105}
        table.insert(state.objects, Object(state, p+vec(w/2, h-100/2),      love.physics.newRectangleShape(50, 100), 5, 'dynamic'))
        table.insert(state.objects, Object(state, p+vec(w/2, h-100/2-50/2), love.physics.newRectangleShape(100, 50), 5, 'dynamic'))

        for i=1,8 do
            local new_object = Object(state, p+vec((i*60)+(w/2)-600, h-140/2), love.physics.newRectangleShape(24, 140), 8, 'dynamic')
            table.insert(state.objects, new_object)
        end
    end

    state.joints = {}
    -- state.joints.mouse = love.physics.newMouseJoint(state.objects[#state.objects].body, love.mouse.getPosition())

    love.graphics.setBackgroundColor(104, 136, 248) -- Set the background color to a nice blue
    love.graphics.setFont(assets.fonts.kust[30])
end


callbacks = {}


function callbacks.delegate(a, b, coll, collisionType, ...)
    local obj_a, obj_b = a:getUserData(), b:getUserData()
    local cb_a, cb_b = (obj_a[collisionType] or noop), (obj_b[collisionType] or noop)

    cb_a(obj_a, obj_b, coll, ...)
    cb_b(obj_b, obj_a, coll, ...)
end


function callbacks.beginContact(a, b, coll)
    callbacks.delegate(a, b, coll, 'beginContact')
end


function callbacks.endContact(a, b, coll)
    callbacks.delegate(a, b, coll, 'endContact')
end


function callbacks.preSolve(a, b, coll)
    callbacks.delegate(a, b, coll, 'preSolve')
end


function callbacks.postSolve(a, b, coll, normalimpulse, tangentimpulse)
    callbacks.delegate(a, b, coll, 'postSolve', normalimpulse, tangentimpulse)
end


function love.update(dt)

    -- Universal update logic (independent of modes)
    -- state.joints.mouse:setTarget(state.camera:getMousePosition():unpack())

    -- Mode-specific events
    if state.running and state.mode == 'interactive' then
        state.world:update(dt) -- This puts the world into motion

        -- Here we are going to create some keyboard events
        if love.keyboard.isDown('right') then -- Press the right arrow key to push the ball to the right
            state.objects.ball.body:applyForce(400, 0)
        elseif love.keyboard.isDown('left') then -- Press the left arrow key to push the ball to the left
            state.objects.ball.body:applyForce(-400, 0)
        elseif love.keyboard.isDown('up') then -- Press the up arrow key to set the ball in the air
            state.objects.ball.body:setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
            state.objects.ball.body:setLinearVelocity(0, 0)
        elseif love.keyboard.isDown('space') then -- Press the left arrow key to push the ball to the left
            state.objects.ball.body:applyForce(0, -400)
        end
    end
end


function love.mousepressed(mx, my, button, istouch)
    local mouse = state.camera:getMousePosition()

    -- Editor mode
    if state.mode == 'editor' then
        if state.editor.tool == 'random_shape' and button == 1 then
            local shape = (math.random() > 0.5) and love.physics.newRectangleShape(math.random(20, 120), math.random(20, 120)) or love.physics.newCircleShape(math.random(10, 60))
            local o = Object(state, vec(wx, wy), shape, 5, 'dynamic')
            o.color = { math.random(0, 255), math.random(0, 255), math.random(0, 255), 255 }
            table.insert(state.objects, o)
        end

        if state.editor.tool == 'drag' and button == 1 then
            local closest = 999
            local obj_to_drag = nil
            for _, obj in pairs(state.objects) do
                -- TODO: You can simplify the distance check somewhat by squaring both sides
                local d = (obj.position - mouse):abs() -- math.dist(wx, wy, obj.x, obj.y)
                if d < closest and obj:testPoint(mouse) then
                    closest = d
                    obj_to_drag = obj
                end
            end

            state.editor.dragged_object = obj_to_drag
        end
    end

    -- Interactive mode
    if state.mode == 'editor' then

    end
end


function love.mousereleased(mx, my, button, istouch)
    if button == 1 then
        state.editor.dragged_object = nil
    end
end


function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(2) then
        -- state.camera:move(vec(-dx * state.camera.scale.x, -dy * state.camera.scale.y))
        state.camera:move(vec(-dx, -dy):hadamard(state.camera.scale))
    end

    local dragged_object = state.editor.dragged_object
    if state.mode == 'editor' and dragged_object ~= nil then
        dragged_object.position = dragged_object.position + vec(dx, dy):hadamard(state.camera.scale)
    end
end


-- function love.wheelmoved(x, y)
--     local dragged_object = state.editor.dragged_object
--     if state.mode == 'editor' and dragged_object ~= nil then
--         dragged_object.body:setAngle(dragged_object.body:getAngle() + y * 0.1)
--     else
--         state.camera:scaleAround(state.camera:getMousePosition(), (y >= 0) and vec(0.8, 0.8) or vec(1.25, 1.25))
--     end
-- end
function love.wheelmoved(x, y)
    local dragged_object = state.editor.dragged_object
    if state.mode == 'editor' and dragged_object ~= nil then
        dragged_object.body:setAngle(dragged_object.body:getAngle() + y * 0.1)
    else
        state.camera:scaleAround(state.camera:getMousePosition(), (y >= 0) and vec(0.8, 0.8) or vec(1.25, 1.25))
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
    local w, h = love.graphics.getDimensions()

    state.camera:set()

    for _, obj in pairs(state.objects) do
        obj:render()
    end

    -- Ball tag
    local ball = state.objects.ball
    love.graphics.setColor(46, 13, 52, 255)
    love.graphics.setFont(assets.fonts.kust[22])
    render.anchoredText('ball', ball.position-vec(0, ball.shape:getRadius()+2), vec(0.5, 1))

    state.camera:unset()

    -- GUI Overlay
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(assets.fonts.kust[30])
    love.graphics.print(state.mode, 40, 24)
    if state.mode == 'editor' then
        love.graphics.print('Tool: ' .. state.editor.tool, 40, 48)
    end

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

end
