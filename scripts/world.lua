world = {}

function world:new()
    local obj = {}

    obj.last_step_pos = vector(0,0)

    obj.player = nil
    obj.steps = {}

    function obj:create_step(pos, type)
        local step = {}
        step.pos = pos
        step.snow_top = love.math.random(1, 4);
        obj.steps["x"..pos.x.."y"..pos.y] = step
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end