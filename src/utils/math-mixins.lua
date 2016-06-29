--


function math.clamp(min, n, max)
    return math.min(math.max(min, n), max)
end


function math.inverse(n)
    return 1.0/n
end


function sign(n)
  return n>0 and 1 or n<0 and -1 or 0
end


function math.dist(x1, y1, x2, y2)
    x2 = x2 or 0; y2 = y2 or 0
    return math.sqrt(
        math.pow(x1 - x2, 2) +
        math.pow(y1 - y2, 2)
    )
end


function math.angle(x1, y1, x2, y2)
    x2 = x2 or 0; y2 = y2 or 0
    return math.atan2( x1 - x2,  y1 - y2 )
end


-- Not sure why I'd even need this but here it is
function math.polar(x, y)
    return math.dist(x, y), math.angle(x, y)
end


function math.cartesian(magnitude, angle)
    return math.sin(angle) * magnitude, math.cos(angle) * magnitude
end


function math.getNormal(x1, y1, x2, y2)
    return math.normalize(-(y2 - y1), (x2 - x1))
end


-- Following functions taken from the Love2D wiki, credit to Taehl. [https://love2d.org/wiki/General_math]


-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
	local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
	return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end


-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
	local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
	local det,x,y = a1*b2 - a2*b1
	if det==0 then return false, "The lines are parallel." end
	x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
	if seg1 or seg2 then
		local min,max = math.min, math.max
		if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
		   seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
			return false, "The lines don't intersect."
		end
	end
	return x,y
end
