--! filename: button
Class = require 'libs.hump.class'
Button = Class{BASE_DX = 300, SPACER = 50, SCALE_DOWN = 0.6, PATH = 'asset/sprites/combat/',
moveDuration = 0.25, SIDE_BUTTON_SCALE = 0.75, BACK_BUTTON_SCALE = 0.5, MOVE_SCALE=0.5}

function Button:init(pos, index, path)
    -- self.centerX = x
    -- self.x = x
    -- self.y = y
    self.pos = {
      x = pos.x,
      y = pos.y,
      scale = pos.scale
    }
    self.index = index
    local buttonPath = Button.PATH .. path
    self.button = love.graphics.newImage(buttonPath)
    local width, height = self.button:getDimensions()
    self.dims = {w=width,h=height}

    self.tX = nil
    self.tY = nil

    self.dX = 0
    -- self.scaleFactor = Button.SCALE_DOWN
    self.active = false
    self.targets = {}
    self.displaySkillList = false
    self.isRotatingRight = false
    self.isRotatingLeft = false
    self.description = ''
    self.descriptionPos = {x = 200, y = 300}
    self.moveDuration = Button.moveDuration
    self.easeType = 'linear'
    
end;

function Button:tween(landingPos, duration, easeType)
  print(landingPos.x, landingPos.y, landingPos.scale, duration, easeType)
  flux.to(self.pos, duration, 
    {
      x     = landingPos.x,
      y     = landingPos.y,
      scale = landingPos.scale 
    })
    :ease(easeType)
end;

function Button:idxToLayer()
  local layer

  if self.index == 1 then
    layer = 1
  elseif self.index == 2 or self.index == 5 then
    layer = 2
  else
    layer = 3
  end

  return layer
end;

function Button:setTargetPos(tX, speedMul)
    self.tX = tX
    self.dX = Button.BASE_DX * speedMul
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

-- cant set members of class in this context
function Button.rotateRight(self, dt)
  self.x = self.x + self.dX * dt
  if self.active then
    self.scaleFactor = self.scaleFactor + dt
  else
    self.scaleFactor = self.scaleFactor - dt
  end
    
    if self.x > self.tX then
      self.x = self.tX
      if self.active then
        self.scaleFactor = 1
      else
        self.scaleFactor = Button.SCALE_DOWN
      end
    end
end;

function Button.rotateLeft(self, dt)
  self.x = self.x - self.dX * dt
  if self.active then
    self.scaleFactor = self.scaleFactor + dt
  else
    self.scaleFactor = math.max(self.scaleFactor - dt, Button.SCALE_DOWN)
  end
  if self.x < self.tX then
    self.x = self.tX
    if self.active then
      self.scaleFactor = 1
    else
      self.scaleFactor = Button.SCALE_DOWN
    end
  end
end;


-- function Button:update(dt)
--   if Button.isRotatingRight(self) then
--     Button.rotateRight(self, dt)
--   elseif Button.isRotatingLeft(self) then
--     Button.rotateLeft(self, dt)
--   end
-- end;

function Button:draw()
    love.graphics.draw(self.button, self.pos.x, self.pos.y, 0, self.pos.scale, self.pos.scale)
end;
