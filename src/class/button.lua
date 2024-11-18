--! filename: button
Class = require 'libs.hump.class'
Button = Class{}

Button.static.BASE_DX = 150

function Button:initialize(x, y, path)
    self.x = x
    self.y = y
    self.button = love.graphics.newImage(path)
    self.tX = nil
    self.dX = Button.static.BASE_DX
    self.scaleFactor = 1
end;

function Button:getButton()
    return self.button
end;

function Button:getPos()
    return {self.x, self.y}
end;

function Button:setPos(x, y)
    self.x = x
    self.y = y
end;

function Button:setScaleFactor(scale)
    self.scaleFactor = scale
end;

function Button:update(dt)
    -- TODO
end;

function Button:draw()
    --TODO
end;
