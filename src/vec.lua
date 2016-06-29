-- vec.lua - 2D vectors
-- June 27 2016

-- TODO: Promoting scalars to vectors (?)


class = require 'src.lib.30log-llama'


local vec = class()


function vec:__init(x, y)
    -- TODO: Ensure const
    -- assert(type(x) == 'number' and type(y) == 'number')
    self.x = x
    self.y = y

    self.operators = {
        __unm=vec.negate,
        __add=vec.add,
        __sub=vec.subtract,
        __mul=vec.mult,
        __div=vec.divide,
        __pow=vec.pow,

        __eq=vec.equals,

        __tostring=vec.tostring
    }


    -- table.extend(getmetatable(self), self.operators)
    setmetatable(self, self.operators)
    -- self.table = { x=x, y=y } -- Hmmmm
end


function vec.fromPolar(p)
    print(('vec.fromPolar: polar(mag=%.02f, arg=%.02f)'):format(p.mag, p.arg))
    -- TODO: There might be a bug lurking here somewhere
    return vec(p.mag*math.cos(p.arg), p.mag*math.sin(p.arg))
end


function vec:normal()
    -- Yields a perpendicular vector
    -- I'm assuming this is faster than using trig functions, although they're probably optimised for right angles
    -- TODO: Test
    return vec(self.y, -self.x)
end


function vec:unit()
    -- Yields a vector of length that points in the same direction
    -- TODO: Test
    return self:scale(1/(self:abs() or 1))
end


function vec:rotate(angle)
    return vec.fromPolar({ mag=self:abs(), arg=self:arg()+angle })
end




function vec:polar()
    -- Polar coordinates (the argument is in radians)
    return { mag=self:abs(), arg=self:arg() }
end


function vec:abs()
    return math.sqrt(self.x^2 + self.y^2)
end


function vec:arg()
    return math.asin(self.y/self:abs())
    -- return math.atan(self.x, self.y)
end


function vec:negate()
    return vec(-self.x, -self.y)
end


function vec:add(other)
    return vec(self.x+other.x, self.y+other.y)
end


function vec:subtract(other)
    return vec(self.x-other.x, self.y-other.y)
end


function vec:scale(by)
    return vec(self.x*by, self.y*by)
end


function vec:mult(other)
    return vec(self.x*other.x - self.y*other.y, self.x*other.y + self.y*other.x)
end


function vec:divide(other)
    print('vec:divide has not been implemented!')
    return -- TODO: Implement (multiply by conjugate, yada yada yawn)
end


function vec:dot(other)
    -- TODO: Return scalar (?)
    return vec(self.x*other.x + self.y+other.y, 0)
end



function vec:angle(other)
    -- return math.atan2( x1 - x2,  y1 - y2 )
    -- I'll help myself to this lovely trig function. Thanks, Arek!
    return math.atan2((self-other):unpack())
end


function vec:hadamard(other)
    -- Multiplies two vectors component-wise
    return vec(self.x*other.x, self.y*other.y)
end


function vec:dotwise(f)
    -- Maps a function onto each component. Not to be confused with the dot product.
    return vec(f(self.x), f(self.y))
end

-- function vec.cross(self, other) return end


function vec:pow(other)
    -- TODO: Implement (with de Moivre's formula?)
    print('vec.pow has not been implemented')
    return
end


function vec:equals(other)
    return (self.x == other.x) and (self.y == other.y)
end


function vec:unpack()
    return self.x, self.y
end


function vec:tostring()
    return ('vec(x=%.02f, y=%.02f)'):format(self.x, self.y)
end





return vec
