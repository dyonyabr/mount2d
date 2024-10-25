function lerp(a, b, t)
    return a + (b - a) * t
end

function posmod(a, b)
    return ((a % b) + b) % b
end

function clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end 
    return math.max(lower, math.min(upper, val))
end

