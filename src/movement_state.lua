--! filename: movement state

local class = require 'libs/middleclass'

MovementState = class('MovementState')

MovementState.static.MOVE_SPEED = 20

function MovementState:initialize(x, y, tX, tY)
    -- Initialize position, defaulting to (0, 0) if not provided
    self.x = x or 0
    self.y = y or 0
    
    self.targetX = tX or 0
    self.targetY = tY or 0
    self.state = 'wait'
end

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

function MovementState:setState(state)
  self.state = state
end;

function MovementState:update(dt)
  if self.state == 'move' then
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    if distance < 1 then
      self.x = self.targetX
      self.y = self.targetY
      return
    end
    
    local directionX = dx / distance
    local directionY = dy / distance
    
    self.x = self.x + directionX * MovementState.static.MOVE_SPEED * dt
    self.y = self.y + directionY * MovementState.static.MOVE_SPEED * dt
  elseif self.state == 'jump' then
    -- need to implement gravity for entity class (make static if gravity is the same for all characters)
  end
  
end;

function MovementState:draw()
    -- Placeholder for drawing the state or any visual representation
end

return MovementState