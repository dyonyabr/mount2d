world = {}

function world:new()
    local obj = {}

    obj.snow_top = love.graphics.newQuad(0, 0, 8, 8, 128, 128);
    obj.snow = love.graphics.newQuad(0, 8, 8, 8, 128, 128);
    obj.snow2stone = love.graphics.newQuad(0, 16, 8, 8, 128, 128);
    obj.stone = love.graphics.newQuad(0, 24, 8, 8, 128, 128);
    obj.spike_top = love.graphics.newQuad(8, 8, 8, 8, 128, 128);
    obj.spike_bottom = love.graphics.newQuad(8, 16, 8, 8, 128, 128);
    obj.wood_top = love.graphics.newQuad(16, 8, 8, 8, 128, 128);
    obj.wood_bottom = love.graphics.newQuad(16, 16, 8, 8, 128, 128);
    obj.ice = love.graphics.newQuad(8, 0, 8, 8, 128, 128);
    obj.dirt = love.graphics.newQuad(16, 0, 8, 8, 128, 128);

    obj.last_step_pos = {x = 0, y = 0}

    obj.player = nil
    obj.steps = {}

    function obj:load()
        obj:create_step({x = 0, y = 0}, "default");
        obj:create_step({x = 0, y = 0}, "default");
    end

    function obj:update(dt)
        for i = 1, #obj.steps do
            obj.steps[i].draw_pos_y = lerp(obj.steps[i].draw_pos_y, obj.steps[i].pos.y, dt * 15)
        end
    end

    
    function obj:draw()
        love.graphics.setBackgroundColor(0,0,0)
        love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
        love.graphics.scale(5)
        love.graphics.translate(-4, 0)

        love.graphics.setColor(1, 1, 1)
        for i = 1, #obj.steps do
            love.graphics.draw(atlas, obj.snow_top, obj.steps[i].pos.x, obj.steps[i].draw_pos_y)
            for a = 1, obj.steps[i].snow-1 do
                love.graphics.draw(atlas, obj.snow, obj.steps[i].pos.x, obj.steps[i].draw_pos_y + 8*a)
            end
            love.graphics.draw(atlas, obj.snow2stone, obj.steps[i].pos.x, obj.steps[i].draw_pos_y + 8*obj.steps[i].snow)
            for a = obj.steps[i].snow + 1, 20 do
                love.graphics.draw(atlas, obj.stone, obj.steps[i].pos.x, obj.steps[i].draw_pos_y + 8*a)
            end
        end
    end

    function obj:create_step(pos, type)
        local step = {}
        step.pos = pos
        step.draw_pos_y = pos.y + 100
        step.last_step_pos = pos;
        step.snow = love.math.random(1, 4);
        obj.steps[#obj.steps+1] = step
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end