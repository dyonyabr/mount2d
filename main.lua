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
    _world:keypressed(k)
end

function love.draw()
    love.graphics.print(love.timer.getFPS(), love.graphics.translate(0, 0))
    _world:draw()

end