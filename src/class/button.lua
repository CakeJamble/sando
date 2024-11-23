--! filename: button
Class = require 'libs.hump.class'
Button = Class{BASE_DX = 150, SPACER = 50, SCALE_DOWN = 0.6, PATH = 'asset/sprites/combat/'}

function Button:init(x, y, path)
    self.centerX = x
    self.x = x
    self.y = y
    self.tX = nil
    self.tY = nil
    local buttonPath = Button.PATH .. path
    self.button = love.graphics.newImage(buttonPath)
    self.tX = nil
    self.dX = 0
    self.scaleFactor = 1
    self.isActiveButton = false
    self.targets = {}
end;

function Button:getButton()
    return self.button
end;

function Button:getPos()
    return {self.x, self.y}
end;

function Button:setTargetPos(tX, speedMul)
    self.tX = self.x + tX
    self.dX = Button.BASE_DX * speedMul
end;

function Button:setPos(x, y)
    self.x = x
    self.y = y
end;

function Button:isRotatingRight()
  return self.x < self.tX
end;

function Button:setIsActiveButton(isActive)
    if isActive then
        self.scaleFactor = 1
    else
        self.scaleFactor = Button.SCALE_DOWN
    end
    self.isActiveButton = isActive
end;

function Button:update(dt)
    -- TODO
end;

function Button:draw()
    love.graphics.draw(self.button, self.x, self.y, 0, self.scaleFactor, self.scaleFactor)
end;
