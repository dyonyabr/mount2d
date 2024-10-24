require "lib.tools"

require "scripts.world"

_world = world:new() 

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    atlas = love.graphics.newImage("assets/textures/atlas.png");
    _world:load()
end

function love.update(dt)
    _world:update(dt)
end

function love.keypressed(k)
    if k == "a" then
        _world:do_step()
    end
end

function love.draw()
    _world:draw()
end