-- main.lua
-- Jonatan H Sundqvist
-- June 25 2016



function createObject(world, pos, shape, density, type)
  --
  o = {}
  o.body    = love.physics.newBody(world, pos.x, pos.y, type) -- Body type is either 'dynamic', 'static' or 'kinematic'
  o.shape   = shape
  o.fixture = love.physics.newFixture(o.body, o.shape, density)
  return o
end


function renderObject(o, options)
  --
  love.graphics.setColor(50, 50, 50) -- set the drawing color to grey for the blocks
  love.graphics.polygon('fill', o.body:getWorldPoints(o.shape:getPoints()))
end


function love.load()
  --
  fonts = {
    alameda=love.graphics.newFont('assets/fonts/alameda/alameda.ttf', 30),
    kust=love.graphics.newFont('assets/fonts/Kust_Free_Brush_Font/kust.otf', 30)
  }

  love.graphics.setFont(fonts.kust)

  settings = {
    mode='interactive',
    screenSize={ cx=720, cy=480 }
  }

  --
  love.physics.setMeter(64) --the height of a meter our worlds will be 64px
  world = love.physics.newWorld(0, 9.81*64, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81

  -- table to hold all our physical objects
  cx = settings.screenSize.cx
  cy = settings.screenSize.cy

  objects = {
    ground = createObject(world, { x=cx/2, y=cy-50/2 }, love.physics.newRectangleShape(650, 50),       3, 'static'),
    ball   = createObject(world, { x=cx/2, y=cy/2},     love.physics.newCircleShape(20),               3, 'dynamic'),
    block1 = createObject(world, { x=200,  y=550 },     love.physics.newRectangleShape(0, 0, 50, 100), 5, 'dynamic')

    -- car = {
    --   frame      = createObject(world, { x=410, y=260 }, love.physics.newRectangleShape(0, 0, 120, 70), 5, 'dynamic'),
    --   leftWheel  = createObject(world, { x=360, y=260 }, love.physics.newCircleShape(50),               5, 'dynamic'),
    --   rightWheel = createObject(world, { x=460, y=260 }, love.physics.newCircleShape(50),               5, 'dynamic')
    -- }
  }

  for i=1,8 do
    print('Adding object ' .. i)
    objects[i] = createObject(world, { x=(i*60)+(cx/2)-600, y=cy-120/2 }, love.physics.newRectangleShape(30, 120), 4, 'dynamic')
  end

  -- Additional settings
  objects.ball.fixture:setRestitution(0.8) -- Let the ball bounce

  -- Initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248) -- Set the background color to a nice blue
  love.window.setMode(cx, cy)                     -- Set the window dimensions to 650 by 650

end


function love.update(dt)
  world:update(dt) --this puts the world into motion

  --here we are going to create some keyboard events
  if love.keyboard.isDown('right') then --press the right arrow key to push the ball to the right
    objects.ball.body:applyForce(400, 0)
  elseif love.keyboard.isDown('left') then --press the left arrow key to push the ball to the left
    objects.ball.body:applyForce(-400, 0)
  elseif love.keyboard.isDown('up') then --press the up arrow key to set the ball in the air
    objects.ball.body:setPosition(dx/2, dy/2)
    objects.ball.body:setLinearVelocity(0, 0) --we must set the velocity to zero to prevent a potentially large velocity generated by the change in position
  elseif love.keyboard.isDown('space') then --press the left arrow key to push the ball to the left
    objects.ball.body:applyForce(0, -400)
  end

  if love.keyboard.isDown('tab') then
    settings.mode = 'editor'
  else
    settings.mode = 'interactive'
  end

end

function love.draw()
  love.graphics.setColor(25, 190, 105)
  love.graphics.polygon('fill', objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a 'filled in' polygon using the ground's coordinates

  love.graphics.setColor(193, 47, 14) --set the drawing color to red for the ball
  love.graphics.circle('fill', objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())

  love.graphics.print(settings.mode, 40, 24)

  -- , objects.car.leftWheel, objects.car.rightWheel, objects.car.frame
  local renderables = { objects.block1, objects.block2, objects[1], objects[2], objects[3], objects[4], objects[5], objects[6], objects[7], objects[8] }
  for i, o in ipairs(renderables) do
    -- print(i, o)
    renderObject(o)
  end
end
