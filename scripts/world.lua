require "scripts.player"

world = {}

function world:new()
    local obj = {}

    obj._player = player:new()

    obj.scale = 5
    obj.shade_diff= .05
    obj.max_steps = 40

    obj.snow_top =     love.graphics.newQuad(0  , 0  , 8, 8, 128, 128)
    obj.snow =         love.graphics.newQuad(0  , 8  , 8, 8, 128, 128)
    obj.snow2stone =   love.graphics.newQuad(0  , 16 , 8, 8, 128, 128)
    obj.stone =        love.graphics.newQuad(0  , 24 , 8, 8, 128, 128)
    obj.spike_top =    love.graphics.newQuad(8  , 8  , 8, 8, 128, 128)
    obj.spike_bottom = love.graphics.newQuad(8  , 16 , 8, 8, 128, 128)
    obj.wood_top =     love.graphics.newQuad(16 , 8  , 8, 8, 128, 128)
    obj.wood_bottom =  love.graphics.newQuad(16 , 16 , 8, 8, 128, 128)
    obj.ice =          love.graphics.newQuad(8  , 0  , 8, 8, 128, 128)
    obj.dirt =         love.graphics.newQuad(16 , 0  , 8, 8, 128, 128)

    obj.last_step_pos = {x = 0, y = 0}

    obj._player = player:new()
    obj.steps = {}

    obj.cur_step = 0
    obj.cam_pos = {x = 0, y = 0}
    obj.cam_pos_smooth = {x = 0, y = 0}

    function obj:load()
        for i = 1, 15 do
            obj:create_next_step()
        end
        for i = 1, 15 do
            obj:do_step()
        end
    end
    
    function obj:update(dt)
        obj._player:update(dt)
        
        for i = 1, #obj.steps do
            obj.steps[i].draw_pos_y = lerp(obj.steps[i].draw_pos_y, obj.steps[i].pos.y, dt * 15)
            if obj.steps[i].add ~= nil then
                obj.steps[i].add.draw_pos_y = lerp(obj.steps[i].add.draw_pos_y, obj.steps[i].add.pos.y, dt * 15)
            end
        end
        
        obj.cam_pos_smooth.x = lerp(obj.cam_pos_smooth.x, obj.cam_pos.x, dt * 10)
        obj.cam_pos_smooth.y = lerp(obj.cam_pos_smooth.y, obj.cam_pos.y, dt * 10)
    end
    
    function obj:do_step()
        obj.cur_step = obj.cur_step + 1
        obj:create_next_step()
        
        local j = 1
        for i = #obj.steps, 1, -1 do
            obj.steps[i].shade = j * obj.shade_diff
            j = j + 1
        end

        local cur_step_pos = {x = obj.steps[obj.cur_step].pos.x, y = obj.steps[obj.cur_step].pos.y}

        obj._player.pos.x = cur_step_pos.x
        obj._player.pos.y = cur_step_pos.y - 5
        
        obj.cam_pos = {x = love.graphics.getWidth()/(2*obj.scale) - cur_step_pos.x - 4,
        y = love.graphics.getHeight()/(2*obj.scale) - cur_step_pos.y + 24}
    end
    
    function obj:create_next_step()
        -- if #obj.steps > obj.max_steps then table.remove(obj.steps, 1) end
        local lr = math.floor(love.math.noise(#obj.steps*.2) + .5) * 2 - 1
        obj.steps[#obj.steps+1] = obj:create_step({x = obj.last_step_pos.x + lr * 4,
        y = obj.last_step_pos.y - 5}, "default");
        
        if love.math.random(0, 10) < 4  and #obj.steps > 1 then
            local pos = {x = obj.last_step_pos.x - lr * 4, y = obj.last_step_pos.y - 5}
            obj.steps[#obj.steps].add = obj:create_step(pos, "add")
            if love.math.random(0, 10) < 7 then
                obj.steps[#obj.steps].add.obstacle = "spike"
            end
        end

        obj.last_step_pos = obj.steps[#obj.steps].pos;
    end
    
    function obj:draw()
        love.graphics.setBackgroundColor(0,0,0)
        love.graphics.scale(obj.scale)
        love.graphics.translate(obj.cam_pos_smooth.x, obj.cam_pos_smooth.y)    
        
        for i =  #obj.steps, 1, -1 do
            obj:draw_step(obj.steps[i].pos.x, obj.steps[i].draw_pos_y, obj.steps[i].snow, obj.steps[i].shade)
            if obj.steps[i].add ~= nil then
                obj:draw_step(obj.steps[i].add.pos.x, obj.steps[i].add.draw_pos_y, obj.steps[i].add.snow, obj.steps[i].shade, obj.steps[i].add.obstacle)
            end
            if obj.cur_step == i then
                obj._player:draw()
            end
        end
    end

    function obj:draw_step(x, y, snow, shade, obstacle)
        love.graphics.setColor(1 * shade, 1 * shade, 1 * shade)
        if obstacle == "spike" then
            love.graphics.draw(atlas, obj.spike_top, x, y-8)
            love.graphics.draw(atlas, obj.spike_bottom, x, y)
        else
            love.graphics.draw(atlas, obj.snow_top, x, y)
        end
        for j = 1, snow-1 do
            love.graphics.draw(atlas, obj.snow, x, y + 8*j)
        end
        love.graphics.draw(atlas, obj.snow2stone, x, y + 8*snow)
        for j = snow + 1, 20 do
            love.graphics.draw(atlas, obj.stone, x, y + 8*j)
        end
    end
    
    function obj:create_step(pos, type)
        local step = {}
        step.pos = pos
        step.draw_pos_y = pos.y + 100
        step.snow = love.math.random(1, 4);
        if type == "add" then
            --da
        elseif type == "default" then
            step.shade = 1
        end
        return step
    end

    function obj:keypressed(k)
        obj._player:keypressed(k)
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end