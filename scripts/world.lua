require "scripts.player"
require "assets.shaders"

world = {}

function world:new()
    local obj = {}

    obj.day_cycle_timer = Timer()

    obj.cycle_colors = {
        {color = {0.74, 0.86, 0.95}, duration = 6},   -- Pale Dawn (6 seconds)
        {color = {0.60, 0.78, 0.88}, duration = 6},   -- Soft Morning (6 seconds)
        {color = {0.42, 0.66, 0.82}, duration = 6},   -- Cool Mid Morning (6 seconds)
        {color = {0.30, 0.54, 0.76}, duration = 6},   -- Calm Late Morning (6 seconds)
        {color = {0.15, 0.10, 0.20}, duration = 6},  -- Very Dark Twilight (12 seconds)
        {color = {0.02, 0.02, 0.05}, duration = 12},   -- Almost Black Midnight (12 seconds)
        {color = {0.02, 0.02, 0.05}, duration = 3},  -- Night
        {color = {0.1, 0.1, 0.2}, duration = 3},    -- Twilight
        {color = {0.4, 0.2, 0.3}, duration = 3},    -- Warm Pink
        {color = {0.6, 0.4, 0.2}, duration = 3},    -- Soft Orange
        {color = {0.9, 0.7, 0.4}, duration = 3},    -- Golden Yellow
        {color = {0.74, 0.86, 0.95}, duration = 3}   -- Bright Day
    }
    obj.steps_to_cycle = 50
    obj.cur_cycle_grade = 0
    obj.gradation = obj.steps_to_cycle / #obj.cycle_colors
    obj.bg_color = obj.cycle_colors[obj.cur_cycle_grade + 1].color
    function obj:change_day_cycle()
        obj.day_cycle_timer:after(obj.cycle_colors[obj.cur_cycle_grade+1].duration, function ()
            obj.cur_cycle_grade = (obj.cur_cycle_grade + 1)%#obj.cycle_colors
            obj:change_day_cycle()
        end)
    end

    obj.step_shader = love.graphics.newShader(step_shader)
    obj._player = player:new()
    obj.score = 0
    function obj:set_score(value)
        obj.score = value
    end
    
    obj.scale = 5
    obj.shade_diff = .05
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
    obj.tree_quads = {}
    
    for i = 0, 11 do
        for j = 0, 3 do
            obj.tree_quads[i * 4 + j] = love.graphics.newQuad(i*8, 96 + j*8, 8, 8, 128, 128)
        end
    end

    obj.last_step_pos = {x = 0, y = 0}

    obj._player = player:new()
    obj.steps = {}

    obj.cur_step = 0
    obj.cur_step_type = ""
    obj.cam_pos = {x = 0, y = 0}
    obj.cam_pos_smooth = {x = 0, y = 0}

    function obj:load()
        for i = 1, 15 do
            obj:create_next_step()
        end
        for i = 1, 15 do
            obj:do_step("default")
        end
        obj.cam_pos_smooth = {x = obj.cam_pos.x, y = obj.cam_pos.y + 32}
        obj:change_day_cycle()

        -- obj._player.draw_pos = obj._player.pos
    end
    
    function obj:update(dt)
        obj.day_cycle_timer:update(dt)
        obj._player:update(dt)

        obj.bg_color[1] = lerp(obj.bg_color[1], obj.cycle_colors[obj.cur_cycle_grade + 1].color[1], dt/5)
        obj.bg_color[2] = lerp(obj.bg_color[2], obj.cycle_colors[obj.cur_cycle_grade + 1].color[2], dt/5)
        obj.bg_color[3] = lerp(obj.bg_color[3], obj.cycle_colors[obj.cur_cycle_grade + 1].color[3], dt/5)
        
        for i = 1, #obj.steps do
            obj.steps[i].draw_pos_y = lerp(obj.steps[i].draw_pos_y, obj.steps[i].pos.y, dt * 10)
            if obj.steps[i].add ~= nil then
                obj.steps[i].add.draw_pos_y = lerp(obj.steps[i].add.draw_pos_y, obj.steps[i].add.pos.y, dt * 8)
            end
        end
        
        obj.cam_pos_smooth.x = lerp(obj.cam_pos_smooth.x, obj.cam_pos.x, dt * 5)
        obj.cam_pos_smooth.y = lerp(obj.cam_pos_smooth.y, obj.cam_pos.y, dt * 5)
    end
    
    function obj:do_step(type)
        obj.cur_step = obj.cur_step + 1
        obj.cur_step_type = type
        obj:create_next_step()

        local step = {}
        if type == "default" then
            step = obj.steps[obj.cur_step]
        elseif type == "add" then
            step = obj.steps[obj.cur_step].add
        end
        local cur_step_pos = {x = step.pos.x, y = step.pos.y}
        
        obj._player.pos.x = cur_step_pos.x
        obj._player.pos.y = cur_step_pos.y - 5
        
        obj.cam_pos = {x = love.graphics.getWidth()/(2*obj.scale) - cur_step_pos.x - 4,
        y = love.graphics.getHeight()/(2*obj.scale) - cur_step_pos.y + 24}

        local j = 1
        for i = #obj.steps, 1, -1 do
            obj.steps[i].shade = j * obj.shade_diff
            j = j + 1
        end
    end
    
    function obj:create_next_step()
        -- if #obj.steps > obj.max_steps then table.remove(obj.steps, 1) end
        local lr = math.floor(love.math.random(0, 1)) * 2 - 1
        obj.steps[#obj.steps+1] = obj:create_step({x = obj.last_step_pos.x + lr * 4,
        y = obj.last_step_pos.y - 5}, "default", lr);
        
        if love.math.random(0, 10) < 4  and #obj.steps > 1 then
            local pos = {x = obj.last_step_pos.x - lr * 4, y = obj.last_step_pos.y - 5}
            obj.steps[#obj.steps].add = obj:create_step(pos, "add", -lr)
            if love.math.random(0, 10) < 7 then
                local chance = love.math.random(0, 10) 
                if chance < 5 then
                    obj.steps[#obj.steps].add.obstacle = {name = "spike"}
                elseif chance <= 10 then
                    obj.steps[#obj.steps].add.obstacle = {name = "tree"}
                    obj.steps[#obj.steps].add.obstacle.tree_type = love.math.random(0, 11)
                end
            end
        end

        obj.last_step_pos = obj.steps[#obj.steps].pos;
    end
    
    function obj:draw()
        love.graphics.setBackgroundColor(obj.bg_color[1], obj.bg_color[2], obj.bg_color[3])
        love.graphics.scale(obj.scale)
        love.graphics.translate(obj.cam_pos_smooth.x, obj.cam_pos_smooth.y)    
        
        for i =  #obj.steps, 1, -1 do
            obj:draw_step(obj.steps[i].pos.x, obj.steps[i].draw_pos_y, obj.steps[i].snow, obj.steps[i].shade)
            if obj.steps[i].add ~= nil then
                obj:draw_step(obj.steps[i].add.pos.x, obj.steps[i].add.draw_pos_y, obj.steps[i].add.snow, obj.steps[i].shade, obj.steps[i].add.obstacle)
            end
            if obj.cur_step == i then
                love.graphics.setShader()
                obj._player:draw()
            end
        end

        love.graphics.origin()
        love.graphics.setFont(default_font)
        love.graphics.print(obj.score, 4 * obj.scale, 4 * obj.scale, 0, obj.scale)
    end

    function obj:draw_step(x, y, snow, shade, obstacle)
        obj.step_shader:send("shade", shade)
        obj.step_shader:send("shade_r", obj.bg_color[1])
        obj.step_shader:send("shade_g", obj.bg_color[2])
        obj.step_shader:send("shade_b", obj.bg_color[3])
        love.graphics.setShader(obj.step_shader)
        if obstacle ~= nil then
            if obstacle.name == "spike" then
                love.graphics.draw(atlas, obj.spike_top, x, y-8)
                love.graphics.draw(atlas, obj.spike_bottom, x, y)
            elseif obstacle.name == "tree" then
                for i = 0, 3 do
                    love.graphics.draw(atlas, obj.tree_quads[obstacle.tree_type * 4 + 3 - i], x, y - i * 8)
                end 
            end
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
    
    function obj:create_step(pos, type, side)
        local step = {}
        step.pos = pos
        step.side = side
        step.type = type
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