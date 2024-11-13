--! filename: movement state

local class = require 'libs/middleclass'

MovementState = class('MovementState')

MovementState.static.MOVE_SPEED = 20
MovementState.static.GRAVITY = 30
MovementState.static.JUMP_SPEED = 24

function MovementState:initialize(x, y, frameHeight)
    self.x = x
    self.y = y
    self.dx = 0
    self.dy = 0
    self.frameHeight = frameHeight
    self.groundLevel = y + frameHeight
    
    self.targetX = 0
    self.targetY = 0
    self.state = 'wait'
end;

function MovementState:getPosition()
    return self.x, self.y
end

function MovementState:setPosition(x, y)
    self.x = x
    self.y = y
end;

function MovementState:moveTowards(tX, tY)
  self.state = 'move'
  self.targetX = tX
  self.targetY = tY
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
  self.dy = self.dy - (MovementState.static.GRAVITY * dt)
end;

function MovementState:update(dt)
  if MovementState:isGrounded(self.groundLevel, self.y, self.frameHeight) then
    MovementState:applyGravity(dt)
  end
  
  if self.state == 'move' then
    self.dx = self.targetX - self.x
    self.dy = self.targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance < 1 then
      self.x = self.targetX
      self.y = self.targetY
      return
    end
    
    local directionX = self.dx / distance
    local directionY = self.dy / distance
    
    self.x = self.x + directionX * MovementState.static.MOVE_SPEED * dt
    self.y = self.y + directionY * MovementState.static.MOVE_SPEED * dt
  elseif self.state == 'jump' then
    self.y = self.y + (MovementState.static.JUMP_SPEED * dt)
  end
  
end;

function MovementState:draw()

end;

