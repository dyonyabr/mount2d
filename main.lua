require "lib.tools"
Timer = require "lib.Timer"

require "scripts.world"

_world = world:new() 
default_font = love.graphics.newFont("assets/fonts/font.ttf", 16)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    default_font:setFilter("nearest", "nearest")
    atlas = love.graphics.newImage("assets/textures/atlas.png");
    _world:load()
end

function love.update(dt)
    _world:update(dt)
end

function love.keypressed(k)
    _world:keypressed(k)

    if k == "r" then
        _world = world:new()
        _world:load()
    end
end

function love.draw()
    _world:draw()
end