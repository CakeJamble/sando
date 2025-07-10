--! filename: movement state

Class = require 'libs.hump.class'
MovementState = Class{MOVE_SPEED = 400, GRAVITY = 30, JUMP_SPEED = 24, SPRITE_SPACE = 96, DIST_MARGIN = 5}

function MovementState:init(x, y)
  self.pos = {x=x,y=y}
  self.oPos = {x=x,y=y}
  self.dx = 0
  self.dy = 0
  self.targetPos = {x = 0, y = 0}
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

  self.targetPos = {x = tX - offset, y = tY}
  Timer.tween(2, self.pos, {x = self.targetPos.x, y = self.targetPos.y})
end;

function MovementState:moveBack()
  self.state = 'moveback'
  Timer.tween(2, self.pos, {x = self.oPos.x, y = self.oPos.y})
end;

function MovementState:isGrounded(groundLevel, y, frameHeight)
  return groundLevel < y + frameHeight
end;

function MovementState:applyGravity(dt)
  self.dy = self.dy - (MovementState.GRAVITY * dt)
end;

function MovementState:update(dt)
  if self.state == 'move' and self.pos == self.targetPos then
    Signal.emit('Attack', self.x, self.y)
  end
end;

