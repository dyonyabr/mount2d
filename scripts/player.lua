player = {}

function player:new()
    obj = {}

    obj.quad = love.graphics.newQuad(24, 0, 8, 8, 128, 128)

    obj.pos = {x =  0; y = 0}
    obj.draw_pos = {x =  0; y = 0}
    obj.side = 1

    function obj:load()
        
    end

    function obj:update(dt)
        obj.draw_pos.x = lerp(obj.draw_pos.x, obj.pos.x, dt * 20)
        obj.draw_pos.y = lerp(obj.draw_pos.y, obj.pos.y, dt * 20)
    end

    function obj:draw()
        love.graphics.draw(atlas, obj.quad, obj.draw_pos.x, obj.draw_pos.y, 0, obj.side, 1)
    end

    function obj:keypressed(k)
        if k == "a" then
            obj:do_step(-1)
        elseif k == "d" then
            obj:do_step(1)
        end
    end

    function obj:do_step(dir)
        side = dir
        _world:do_step()
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

