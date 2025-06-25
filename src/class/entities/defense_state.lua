--! filename: defending_state

Class = require 'libs.hump.class'
-- Defending State of a Character is responsible for maintaining their blocking animation, dodging animation, and timed inputs for defense

DefenseState = Class{}

function DefenseState:init(x, y, actionButton, baseDefense)
  self.x = x
  self.y = y
  self.defense = baseDefense
  self.blockMod = nil
  self.blockWindow = nil
  self.isDodgeable = false
  self.isProjectile = false
  self.stance = 'idle'

  -- Data used for calculating timed input conditions and bonuses
  self.actionButton = actionButton
  self.frameCount = 0
  self.animFrameLength = nil
  -- self.frameWindow = nil
  self.isWindowActive = false
  self.actionButtonPressed = false
  self.badInputPenalty = 0
  self.bonusApplied = false
  self.blockNumFrames = 30
  self.jumpNumFrames = 40
  self.animations = nil
  self.blockTime = 20
  self.timer = 0
  self.isEnemyAttacking = false
  self.canBlock = false

  self.greatText = love.graphics.newImage('asset/sprites/combat/qte/feedback/great.png')
  self.greatPos = {
    x = self.x + 25,
    y = self.y - 25
  }
  self.feedbackFrameCount = 0
  self.numFeedbackFrames = 45
end;

function DefenseState:setup(incomingSkill)
  self.blockWindow = incomingSkill.qte_window
  self.isDodgeable = incomingSkill.is_dodgeable
  self.isProjectile = incomingSkill.is_projectile
  
  -- TODO will need to round this out and maybe refactor skill implementations
  if incomingSkill.skill.damage_type == 'physical' then
    self.blockMod = 1
  else
    self.blockMod = 0 -- placeholder for handling other types of damage
  end
end;

function DefenseState:reset()
  print('resetting defense state')
  self.isWindowActive = false
  self.actionButtonPressed = false
  self.badInputPenalty = 0
  self.bonusApplied = false
  self.stance = 'idle'
  self.feedbackFrameCount = 0
end;

function DefenseState:startFrameWindow()
  self.isWindowActive = true
  self.frameCounter = 0
  self.actionButtonPressed = false
end;

function DefenseState:updateBadInputPenalty(applyPenalty)
  if applyPenalty then
    self.badInputPenalty = self.badInputPenalty + 20
  elseif self.badInputPenalty > 0 then
    self.badInputPenalty = self.badInputPenalty - 1
  end
end;

function DefenseState:applyBonus()
  self.bonusApplied = true
  print('defense bonus applied')
end;

function DefenseState:keypressed(key)
  if key == 'rshift' or key == 'lshift' then
    self.canBlock = true
  end

  if key == 'z' and self.canBlock and self.badInputPenalty == 0 and (self.blockWindow[1] <= self.frameCount and self.blockWindow[2] > self.frameCount) and not self.bonusApplied then
    print('Block/Dodge window is between frame ' .. self.blockWindow[1] .. ' and ' .. self.blockWindow[2])
    print('Action Button pressed on frame ' .. self.frameCount)
    self:applyBonus()
  elseif key == self.actionButton and not self.isWindowActive then    -- cannot dodge or block when you flub an input, penalty must expire before action (but you can switch states)
    -- self:updateBadInputPenalty(true)
  end
end;

function DefenseState:keyreleased(key)
  if key == 'rshift' or key =='lshift' then
    self.canBlock = false
  end
end;

function DefenseState:gamepadpressed(joystick, button)
  if button == 'leftshoulder' or button == 'rightshoulder' then
    self.canBlock = true
  end
  if button == self.actionButton and self.badInputPenalty == 0 and (self.blockWindow[1] <= self.frameCount and self.blockWindow[2] > self.frameCount) and not self.bonusApplied then
    print('Block/Dodge window is between frame ' .. self.blockWindow[1] .. ' and ' .. self.blockWindow[2])
    print('Action Button pressed on frame ' .. self.frameCount)
    self:applyBonus()
  elseif button == self.actionButton and not self.isWindowActive then
    -- self:updateBadInputPenalty(true)
  end
end;

function DefenseState:gamepadreleased(joystick, button)
  if button == 'rightshoulder' or button == 'leftshoulder' then
    self.stance = 'dodge'
  end
end;

function DefenseState:update(dt)
  if self.isEnemyAttacking then
    self.frameCount = self.frameCount + 1
  end
  self:updateBadInputPenalty(false)

  if self.bonusApplied then
    self.feedbackFrameCount = self.feedbackFrameCount + 1
  end
end;

function DefenseState:draw()
  local spriteNum
  local animation

  if self.stance == 'block' then
    animation = self.animations.blockAnimation
  elseif self.stance =='dodge' then
    animation = self.animations.dodgeAnimation
  else
    animation = self.animations.idleAnimation
  end

  if self.bonusApplied and self.feedbackFrameCount < self.numFeedbackFrames then
    love.graphics.draw(self.greatText, self.greatPos.x, self.greatPos.y)
  end

  spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.x, self.y, 0, 1)
end;

