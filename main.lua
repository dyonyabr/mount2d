require "lib.tools"
Timer = require "lib.Timer"

require "scripts.world"

timer = Timer()
_world = world:new() 

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    atlas = love.graphics.newImage("assets/textures/atlas.png");
    _world:load()
end

function love.update(dt)
    timer:update(dt)
    _world:update(dt)
end

function love.keypressed(k)
    _world:keypressed(k)
end

function love.draw()
    _world:draw()
end