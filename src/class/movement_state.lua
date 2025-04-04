--! filename: movement state

Class = require 'libs.hump.class'
MovementState = Class{MOVE_SPEED = 400, GRAVITY = 30, JUMP_SPEED = 24, SPRITE_SPACE = 96, DIST_MARGIN = 5}

function MovementState:init(x, y)
  self.x = x
  self.y = y
  self.oX = x
  self.oY = y
  self.dx = 0
  self.dy = 0
    
  self.targetX = 0
  self.targetY = 0
  self.state = 'idle'
end;

function MovementState:getPosition()
  return self.x, self.y
end

function MovementState:setPosition(x, y)
  self.x = x
  self.y = y
end;

function MovementState:moveTowards(tX, tY, isEnemy)
  self.state = 'move'
  self.isEnemy = isEnemy
  self.targetX = tX - MovementState.SPRITE_SPACE
  self.targetY = tY
end;

function MovementState:moveBack()
  self.state = 'move'
  self.targetX = self.oX
  self.targetY = self.oY
end;

function MovementState:getState()
  return self.state
end;

function MovementState:setState(state)
  self.state = state
end;

function MovementState:isGrounded(groundLevel, y, frameHeight)
  return groundLevel < y + frameHeight
end;

function MovementState:applyGravity(dt)
  self.dy = self.dy - (MovementState.GRAVITY * dt)
end;

function MovementState:update(dt)
--[[  if MovementState:isGrounded(self.groundLevel, self.y, self.frameHeight) then
    MovementState:applyGravity(dt)
  end]]
  
  if self.state == 'move' then
    self.dx = self.targetX - self.x
    self.dy = self.targetY - self.y
    local distance = math.sqrt(self.dx * self.dx + self.dy * self.dy)
    
    if distance < MovementState.DIST_MARGIN then
      self.x = self.targetX
      self.y = self.targetY
      self.state = 'idle'
      return
    end
    
    local directionX = self.dx / distance
    local directionY = self.dy / distance
    
    self.x = self.x + directionX * MovementState.MOVE_SPEED * dt
    self.y = self.y + directionY * MovementState.MOVE_SPEED * dt
  --[[elseif self.state == 'jump' then
    self.y = self.y + (MovementState.JUMP_SPEED * dt)]]
  end
  
end;

