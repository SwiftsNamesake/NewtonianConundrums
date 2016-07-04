-- vec.lua - 2D vectors
-- June 27 2016

-- TODO: Promoting scalars to vectors (?)

local vec_mt = {}
local vec_ops = {}

-- print(('vec.fromPolar: polar(mag=%.02f, arg=%.02f)'):format(p.mag, p.arg))
-- TODO: There might be a bug lurking here somewhere
function vec_ops.fromPolar(p) return vec(p.mag*math.cos(p.arg), p.mag*math.sin(p.arg)) end
function vec_ops:normal() return vec(self.y, -self.x) end
function vec_ops:scale(by) return vec(self.x*by, self.y*by) end
function vec_ops:unit() return self:scale(1/(self:abs() or 1)) end
function vec_ops:rotate(angle) return vec.fromPolar({ mag=self:abs(), arg=self:arg()+angle }) end
function vec_ops:rotateAround(angle, p) return (self-p):rotate(angle) + p end
function vec_ops:horizontal() return vec(self.x, 0) end
function vec_ops:vertical() return vec(0, self.y) end
function vec_ops:polar() return { mag=self:abs(), arg=self:arg() } end
function vec_ops:abs() return math.sqrt(self.x^2 + self.y^2) end
function vec_ops:arg() return math.asin(self.y/self:abs()) end
function vec_ops:dot(other) return self.x*other.x + self.y+other.y end
function vec_ops:angle(other) return math.atan2(unpack(self-other)) end
function vec_ops:hadamard(other) return vec(self.x*other.x, self.y*other.y) end
function vec_ops:dotwise(f) return vec(f(self.x), f(self.y)) end
-- function vec_ops.cross(self, other) return end
function vec_ops:unpack() return unpack(self) end

function vec_mt:__unm() return vec(-self.x, -self.y) end
function vec_mt:__add(other) return vec(self.x+other.x, self.y+other.y) end
function vec_mt:__sub(other) return vec(self.x-other.x, self.y-other.y) end
function vec_mt:__mul(other) return vec(self.x*other.x - self.y*other.y, self.x*other.y + self.y*other.x) end
function vec_mt:__div(other) error('Division operator has not yet been implemented!') end
function vec_mt:__pow(other) error('Exponentiation has not been implemented!') end
function vec_mt:__eq(other) return (self.x == other.x) and (self.y == other.y) end
function vec_mt:__tostring() return ('vec(x=%.02f, y=%.02f)'):format(self.x, self.y) end

function vec_mt:__index(key)
    if key == 'x' then return self[1] end
    if key == 'y' then return self[2] end
    return vec_ops[key]
end

local vec = function(x, y)
    local new_vector = {x or 0, y or 0}
    return setmetatable(new_vector, vec_mt)
end

return vec