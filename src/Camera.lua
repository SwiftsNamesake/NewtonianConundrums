--


moses = require 'src.lib.moses.moses'
vec   = require 'src.vec'


local Camera = class()


function Camera:__init(position, scale, angle, pixel_perfect)
    self.position = position or vec(0,0) -- TODO: Use 'p' instead (?)
    self.scale    = scale    or vec(1,1) --
    self.angle    = angle or 0.0         -- TODO: This is in radians right (?)

    self.pixel_perfect   = pixel_perfect or false                              --
    self.pixel_operation = self.pixel_perfect and math.floor or moses.identity --
end


-- Push the camera onto the Love2D transformation stack
function Camera:set()
    love.graphics.push()
    love.graphics.scale(self.scale:unpack()) -- TODO: Finish
    love.graphics.rotate(-self.angle)
    love.graphics.translate((-self.position):dotwise(self.pixel_operation):unpack()) -- math.floor(-self.x), math.floor(-self.y)
end


-- Pop the camera from the Love2D transformation stack
function Camera:unset()
    love.graphics.pop()
end


function Camera:move(by)
    -- print('Camera:move', by)
    self.position = self.position + vec(by.x or 0, by.y or 0)
end


function Camera:rotate(dr)
    self.angle = self.angle + dr
end


-- TODO: Implement Camera:rotateAround
-- function Camera:rotateAround(x, y, dr) end


function Camera:scale(dscale)
    self.scale = self.scale:hadamard(vec(dscale.x or 1, dscale.y or 1))
end


function Camera:scaleAround(point, dscale)
    -- print('Camera:scaleAround', point, dscale, -point, -dscale)
    -- TODO: Use defaults for dscale (?)
    self.scale = self.scale:hadamard(dscale)       -- Calculate the new scaling factor
    self:move(-point)                              -- Move the 'pinned' point to the origin
    self.position = self.position:hadamard(dscale) -- Perform scaling
    self:move(point)                               -- Move back
end


function Camera:setPosition(p)
    self.position = vec(p.x or self.position.x, p.y or self.position.y)
end


function Camera:setScale(scale)
    self.position = vec(scale.x or self.scale.x, scale.y or self.scale.y)
end


function Camera:getMousePosition()
    -- print('Camera:getMousePosition', self)
    return self:toLocalPoint(vec(love.mouse.getX(), love.mouse.getY()))
end

-- Translate world coordinate into local coordinate
function Camera:toLocalPoint(world_p)
    if self.angle == 0 then
        -- return vec(world_p.x * self.scale.x + self.position.x, world_p.y * self.scale.y + self.position.y)
        return world_p:hadamard(self.scale) + self.position
    else
        -- TODO: Implement
        error("Rotation not yet fully implemented. Trigonometry is hard >__>")
    end
end


-- Translate local coordinate into world coordinate
function Camera:toWorldPoint(local_point)
    if self.angle == 0 then
        -- return vec(local_point.x/self.sx - self.x, local_point.y / self.sy - self.y)
        return local_point:hadamard(self.scale:dotwise(math.inverse)) - self.position
    else
        -- TODO: Implement
        error("Rotation not yet fully implemented. Trigonometry is hard <__<")
    end
end


function Camera:toLocalPoints(...)
    local result = {}
    local args = {...}
    for i=0,#args/2-1 do
        local x, y = args[i*2+1], args[i*2+2]
        table.extend(result, {self:toLocalPoint(x, y)})
    end
    return result
end

function Camera:toWorldPoints(...)
    local result = {}
    local args = {...}
    for i=0,#args/2-1 do
        local x, y = args[i*2+1], args[i*2+2]
        table.extend(result, {self:toWorldPoint(x, y)})
    end
    return result
end



return Camera
