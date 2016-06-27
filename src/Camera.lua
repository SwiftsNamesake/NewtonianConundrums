local Camera = class()

function Camera:__init(x, y, sx, sy, angle, pixel_perfect)
    self.x = x or 0
    self.y = y or 0
    self.sx = sx or 1
    self.sy = sy or 1
    self.angle = angle or 0.0
    self.pixel_perfect = pixel_perfect or false
end



-- Push the camera onto the Love2D transformation stack
function Camera:set()
    love.graphics.push()
    love.graphics.scale(1 / self.sx, 1 / self.sy)
    love.graphics.rotate(-self.angle)
    if self.pixel_perfect then
        love.graphics.translate(math.floor(-self.x), math.floor(-self.y))
    else
        love.graphics.translate(-self.x, -self.y)
    end
end

-- Pop the camera from the Love2D transformation stack
function Camera:unset()
    love.graphics.pop()
end



function Camera:move(dx, dy)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
end

function Camera:rotate(dr)
    self.angle = self.angle + dr
end

-- TODO: Implement Camera:rotateAround
-- function Camera:rotateAround(x, y, dr) end

function Camera:scale(dsx, dsy)
    self.sx = self.sx * dsx
    self.sy = self.sy * (dsy or dsx)
end

function Camera:scaleAround(x, y, dsx, dsy)
    dsx = dsx or 1
    dsy = dsy or dsx
    self.sx = self.sx * dsx
    self.sy = self.sy * dsy
    self:move(-x, -y)
    self.x = self.x * dsx
    self.y = self.y * dsy
    self:move(x, y)
end

function Camera:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

function Camera:setScale(sx, sy)
    self.sx = sx or self.sx
    self.sy = sy or sx or self.sy
end



function Camera:getMousePosition()
    return self:getLocalPoint(love.mouse.getX(), love.mouse.getY())
end

-- Translate world coordinate into local coordinate
function Camera:getLocalPoint(world_x, world_y)
    if self.angle == 0 then
        return world_x * self.sx + self.x, world_y * self.sy + self.y
    else
        error("Rotation not yet fully implemented. Trigonometry is hard >__>")
    end
end

-- Translate local coordinate into world coordinate
function Camera:getWorldPoint(local_x, local_y)
    if self.angle == 0 then
        return local_x * self.sx - self.x, local_y / self.sy - self.y
    else
        error("Rotation not yet fully implemented. Trigonometry is hard <__<")
    end
end

function Camera:getLocalPoints(...)
    local result = {}
    local args = {...}
    for i=0,#args/2-1 do
        local x, y = args[i*2+1], args[i*2+2]
        table.extend(result, {self:getLocalPoint(x, y)})
    end
    return result
end

function Camera:getWorldPoints(...)
    local result = {}
    local args = {...}
    for i=0,#args/2-1 do
        local x, y = args[i*2+1], args[i*2+2]
        table.extend(result, {self:getWorldPoint(x, y)})
    end
    return result
end



return Camera