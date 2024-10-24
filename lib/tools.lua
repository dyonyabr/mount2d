function lerp(a, b, t)
    return a + (b - a) * t
end

function posmod(a, b)
    return ((a % b) + b) % b
end
