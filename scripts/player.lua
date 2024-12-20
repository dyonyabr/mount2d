player = {}

function player:new()
    obj = {}

    obj.quad = love.graphics.newQuad(24, 0, 8, 8, 128, 128)
    obj.fall_timer = Timer()

    obj.pos = {x =  0; y = 0}
    obj.draw_pos = {x =  0; y = 0}
    obj.impact = {x = 0, y = 0}
    obj.side = 1
    obj.is_falling = false
    obj.can_move = true

    function obj:load()
        
    end

    function obj:update(dt)
        obj.fall_timer:update(dt)

        obj.impact.x = lerp(obj.impact.x, 0, dt * 20)
        obj.impact.y = lerp(obj.impact.y, 0, dt * 20)

        obj.draw_pos.x = lerp(obj.draw_pos.x, obj.pos.x + obj.impact.x, dt * 20)
        obj.draw_pos.y = lerp(obj.draw_pos.y, obj.pos.y + obj.impact.y, dt * 20)

        if obj.is_falling then
            obj.pos.y = obj.pos.y + 200 * dt 
        end
    end

    function obj:draw()
        love.graphics.draw(atlas, obj.quad, obj.draw_pos.x + (-obj.side + 1)/2 * 8, obj.draw_pos.y, 0, obj.side, 1)
    end

    function obj:keypressed(k)
        if obj.can_move then
            if k == "a" then
                obj:do_step(-1)
            elseif k == "d" then
                obj:do_step(1)
            end
        end
    end

    function obj:do_step(dir)
        local input_dir = dir
        local cur_step = _world.steps[_world.cur_step]
        if _world.cur_step_type == "add" then dir = -dir end
        local needed_step = {}
        local next_step = _world.steps[_world.cur_step + 1]
        local next_add_step = _world.steps[_world.cur_step + 1].add
        if next_add_step ~= nil and dir == next_add_step.side then
            if next_add_step.obstacle ~= nil then
                return
            end
            needed_step = next_add_step
        elseif dir == next_step.side then needed_step = next_step
        else obj:fall(input_dir); return end
        if (math.abs(obj.pos.x - needed_step.pos.x)) < 5 then 
            _world:set_score(_world.score + 1)
            obj.impact.y = -10
            obj.side = input_dir
            _world:do_step(needed_step.type)
            return
        end
        obj:fall(input_dir)
    end
    
    function obj:fall(dir)
        obj.side = dir
        obj.pos.x = obj.pos.x + dir * 4 
        obj.pos.y = obj.pos.y - 5
        obj.can_move = false
        _world.cur_step = _world.cur_step + 1
        obj.fall_timer:after(.05, function ()
            obj.is_falling = true
        end)
    end

    setmetatable(obj, self)
    self.__index = self
    return obj
end

