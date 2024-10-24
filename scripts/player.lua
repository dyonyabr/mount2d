player = {}

function player:new()
    obj = {}

    obj.quad = love.graphics.newQuad(24, 0, 8, 8, 128, 128)

    obj.pos = {x =  0; y = 0}
    obj.draw_pos = {x =  0; y = 0}
    obj.impact = {x = 0, y = 0}
    obj.side = 1

    function obj:load()
        
    end

    function obj:update(dt)
        obj.impact.x = lerp(obj.impact.x, 0, dt * 20)
        obj.impact.y = lerp(obj.impact.y, 0, dt * 20)

        obj.draw_pos.x = lerp(obj.draw_pos.x, obj.pos.x + obj.impact.x, dt * 20)
        obj.draw_pos.y = lerp(obj.draw_pos.y, obj.pos.y + obj.impact.y, dt * 20)
    end

    function obj:draw()
        love.graphics.draw(atlas, obj.quad, obj.draw_pos.x + (-obj.side + 1)/2 * 8, obj.draw_pos.y, 0, obj.side, 1)
    end

    function obj:keypressed(k)
        if k == "a" then
            obj:do_step(-1)
        elseif k == "d" then
            obj:do_step(1)
        end
    end

    function obj:do_step(dir)
        obj.impact.y = -10
        obj.side = dir
        _world:do_step()
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

