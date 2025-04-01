--! filename: button
Class = require 'libs.hump.class'
Button = Class{BASE_DX = 300, SPACER = 50, SCALE_DOWN = 0.6, PATH = 'asset/sprites/combat/'}

function Button:init(x, y, layer, path)
    self.centerX = x
    self.x = x
    self.y = y
    self.layer = layer
    self.tX = nil
    self.tY = nil
    local buttonPath = Button.PATH .. path
    self.button = love.graphics.newImage(buttonPath)
    self.dX = 0
    self.scaleFactor = Button.SCALE_DOWN
    self.isActiveButton = false
    self.targets = {}
    self.displaySkillList = false
end;

function Button:getButton()
    return self.button
end;

function Button:getPos()
    return {self.x, self.y}
end;

function Button:setTargetPos(tX, speedMul)
    self.tX = tX
    self.dX = Button.BASE_DX * speedMul
end;

function Button:setPos(x, y)
    self.x = x
    self.y = y
end;

function Button:isRotatingRight()
  return self.x < self.tX
end;

function Button:isRotatingLeft()
  return self.x > self.tX
end;

function Button:setIsActiveButton(isActive)
  self.isActiveButton = isActive
  if isActive then
    self.scaleFactor = 1
  else
      self.scaleFactor = Button.SCALE_DOWN
  end
end;

function Button:isFinishedRotating() --> boolean
  return self.x == self.tX
end;

function Button:rotateRight(dt)
  self.x = self.x + self.dX * dt
  if self.isActiveButton then
    self.scaleFactor = self.scaleFactor + dt
  else
    self.scaleFactor = self.scaleFactor - dt
  end
    
    if self.x > self.tX then
      self.x = self.tX
      if self.isActiveButton then
        self.scaleFactor = 1
      else
        self.scaleFactor = Button.SCALE_DOWN
      end
    end
end;

function Button:rotateLeft(dt)
  self.x = self.x - self.dX * dt
  if self.isActiveButton then
    self.scaleFactor = self.scaleFactor + dt
  else
    self.scaleFactor = self.scaleFactor - dt
  end
  if self.x < self.tX then
    self.x = self.tX
    if self.isActiveButton then
      self.scaleFactor = 1
    else
      self.scaleFactor = Button.SCALE_DOWN
    end
  end
end;


function Button:update(dt)
  if Button.isRotatingRight(self) then
    Button.rotateRight(self, dt)
  elseif Button.isRotatingLeft(self) then
    Button.rotateLeft(self, dt)
  end
end;

function Button:draw()
    love.graphics.draw(self.button, self.x, self.y, 0, self.scaleFactor, self.scaleFactor)
    if self.displaySkillList then
      love.graphics.rectangle('fill', self.x + 150, self.y, 50, 20)
    end
end;
