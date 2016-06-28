-- shapes.lua
-- June 27 2016


require 'src.vec'


shapes = {}


function shapes.arrow(fr, to, ratio, shaftWidth, headWidth)
    -- arrow :: Complex Double -> Complex Double -> Double -> Double -> Double -> [Complex Double]
    -- arrow from to sl sw hw = [from     + straight (sw/2), --
    --                           shaftEnd + straight (sw/2), --
    --                           shaftEnd + straight (hw/2), --
    --                           to,                         --
    --                           shaftEnd - straight (hw/2), --
    --                           shaftEnd - straight (sw/2), --
    --                           from     - straight (sw/2)] --
    --     where along a b distance = (a +) . mkPolar distance . snd . polar $ b-a -- Walk distance along the from a to b
    --           normal a b = let (mag, arg) = polar (b-a) in mkPolar mag (arg+π/2)
    --           shaftEnd = along from to sl --
    --           straight = along (0:+0) (normal from to) -- Vector perpendicular to the centre line
    local normal = (to-fr):normal():unit() -- (to-fr):arg() + math.pi*0.5
    print(normal)                     --
    local short  = normal:scale(shaftWidth/2) -- vec.fromPolar({ mag=shaftWidth/2, arg=normal }) --
    local long   = normal:scale(headWidth/2)  -- vec.fromPolar({ mag=headWidth/2,  arg=normal }) --
    local cutoff = fr + (to-fr)*vec(ratio, 0) --scale(ratio) --

    return { fr+short, cutoff+short, cutoff+long, to, cutoff-long, cutoff-short, fr-short }
end


function shapes.flatten(vertices)
    -- Converts a list of vecs to a list of individual coordinates
    -- TODO: Move (?)
    -- TODO: Refactor with FP idioms (?)
    local flat = {}
    for _, v in ipairs(vertices) do
        flat[#flat+1] = v.x
        flat[#flat+1] = v.y
    end
    return flat
end


return shapes
