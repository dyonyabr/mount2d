world = {}

function world:new()
    local obj = {}

    obj.scale = 5;

    obj.snow_top =     love.graphics.newQuad(0  , 0  , 8, 8, 128, 128);
    obj.snow =         love.graphics.newQuad(0  , 8  , 8, 8, 128, 128);
    obj.snow2stone =   love.graphics.newQuad(0  , 16 , 8, 8, 128, 128);
    obj.stone =        love.graphics.newQuad(0  , 24 , 8, 8, 128, 128);
    obj.spike_top =    love.graphics.newQuad(8  , 8  , 8, 8, 128, 128);
    obj.spike_bottom = love.graphics.newQuad(8  , 16 , 8, 8, 128, 128);
    obj.wood_top =     love.graphics.newQuad(16 , 8  , 8, 8, 128, 128);
    obj.wood_bottom =  love.graphics.newQuad(16 , 16 , 8, 8, 128, 128);
    obj.ice =          love.graphics.newQuad(8  , 0  , 8, 8, 128, 128);
    obj.dirt =         love.graphics.newQuad(16 , 0  , 8, 8, 128, 128);

    obj.last_step_pos = {x = 0, y = 0}

    obj.player = nil
    obj.steps = {}

    obj.cur_step = 1

    function obj:load()
        obj:create_step({x = 0, y = 0}, "default");
        for i = 1, 15 do
            local lr = math.floor(love.math.noise(#obj.steps*.2) + .5) * 2 - 1
            obj.steps[#obj.steps+1] = obj:create_step({x = obj.last_step_pos.x + lr * 4,
            y = obj.last_step_pos.y - 5}, "default");
        end
    end

    function obj:update(dt)
        for i = 1, #obj.steps do
            obj.steps[i].draw_pos_y = lerp(obj.steps[i].draw_pos_y, obj.steps[i].pos.y, dt * 15)
        end
    end

    function obj:draw()
        love.graphics.setBackgroundColor(0,0,0)
        love.graphics.scale(obj.scale)
        love.graphics.translate(obj.steps[obj.cur_step].pos.x - 12 + love.graphics.getWidth()/(2*obj.scale),
        obj.steps[obj.cur_step].pos.y + love.graphics.getHeight()/(2*obj.scale))    

        love.graphics.setColor(1, 1, 1)
        for i =  #obj.steps, 1, -1 do
            love.graphics.draw(atlas, obj.snow_top, obj.steps[i].pos.x, obj.steps[i].draw_pos_y)
            for j = 1, obj.steps[i].snow-1 do
                love.graphics.draw(atlas, obj.snow, obj.steps[i].pos.x, obj.steps[i].draw_pos_y + 8*j)
            end
            love.graphics.draw(atlas, obj.snow2stone, obj.steps[i].pos.x, obj.steps[i].draw_pos_y + 8*obj.steps[i].snow)
            for j = obj.steps[i].snow + 1, 20 do
                love.graphics.draw(atlas, obj.stone, obj.steps[i].pos.x, obj.steps[i].draw_pos_y + 8*j)
            end
        end
    end

    function obj:create_step(pos, type)
        local step = {}
        step.pos = pos
        step.draw_pos_y = pos.y + 100
        obj.last_step_pos = pos;
        step.snow = love.math.random(1, 4);
        return step
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end