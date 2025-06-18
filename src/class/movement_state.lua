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

function MovementState:moveTowards(tX, tY, isEnemy)
  self.state = 'move'
  print('tX', tX, 'tY', tY)
  self.isEnemy = isEnemy

  -- enemies stop to right of character, characters stop to left of enemy
  local offset = MovementState.SPRITE_SPACE
  if not isEnemy then
    offset = -1 * offset
  end
  self.targetX = tX - offset
  self.targetY = tY
end;

function MovementState:moveBack()
  self.state = 'moveback'
  self.targetX = self.oX
  self.targetY = self.oY
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
  
  if self.state == 'move' or self.state == 'moveback' then
    self.dx = self.targetX - self.x
    self.dy = self.targetY - self.y
    local distance = math.sqrt(self.dx * self.dx + self.dy * self.dy)
    
    if distance < MovementState.DIST_MARGIN then
      self.x = self.targetX
      self.y = self.targetY

      if self.state == 'move' then
        Signal.emit('Attack', self.x, self.y)
      end
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

