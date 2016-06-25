-- main.lua
-- Jonatan H Sundqvist
-- June 25 2016


function love.draw()
  path = 'C:/Users/Jonatan/Desktop/lua/NewtonianConundrums/'

  love.graphics.print(love.filesystem.getWorkingDirectory(), 400, 300-40)

  print(path .. 'assets/fonts/alameda/alameda.ttf')
  font = love.graphics.newFont(path .. 'assets/fonts/alameda/alameda.ttf', 34)
  -- love.graphics.setFont(font)

  love.graphics.print('Hello World', 400, 300)
  love.graphics.print('Salve mundi', 400, 360)
end
