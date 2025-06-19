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
  self.stance = 'block'

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
end;

function DefenseState:setup(incomingSkill)
  self.blockWindow = incomingSkill.qte_window
  self.isDodgeable = incomingSkill.is_dodgeable
  self.isProjectile = incomingSkill.is_projectile
  
  -- TODO will need to round this out and maybe refactor skill implementations
  if incomingSkill.damage_type == 'physical' then
    self.blockMod = 1
  else
    self.blockMod = 0 -- placeholder for handling other types of damage
  end
end;

function DefenseState:reset()
  self.isWindowActive = false
  self.actionButtonPressed = false
  self.badInputPenalty = 0
  self.bonusApplied = false
end;

function DefenseState:startFrameWindow()
  self.isWindowActive = true
  self.frameCounter = 0
  self.actionButtonPressed = false
end;

function DefenseState:updateBadInputPenalty(applyPenalty)
  if applyPenalty then
    self.badInputPenalty = self.badInputPenalty + 20
    print('applied penalty for missed input timing')
  elseif self.badInputPenalty > 0 then
    self.badInputPenalty = self.badInputPenalty - 1
  end
end;

function DefenseState:applyBonus()
  if self.stance == 'block' then
    self.defense = self.defense + self.blockBonus
    print('Bonus applied! Defense is now ' .. self.defense)
  end
  self.bonusApplied = true
end;

function DefenseState:keypressed(key)
  if key == self.actionButton and self.stance == 'block' and self.badInputPenalty == 0 and (self.blockWindow[1] <= self.frameCount and self.blockWindow[2] > self.frameCount) and not self.bonusApplied then
    print('Block/Dodge window is between frame ' .. self.blockWindow[1] .. ' and ' .. self.blockWindow[2])
    print('Action Button pressed on frame ' .. self.frameCount)
    self:applyBonus()
  elseif key == self.actionButton and not self.isWindowActive then    -- cannot dodge or block when you flub an input, penalty must expire before action (but you can switch states)
    self:updateBadInputPenalty(true)
  end
end;

function DefenseState:gamepadpressed(joystick, button)
  if button == 'leftshoulder' or button == 'rightshoulder' then
    self.stance = 'block'
  end
  if button == self.actionButton and self.badInputPenalty == 0 and (self.blockWindow[1] <= self.frameCount and self.blockWindow[2] > self.frameCount) and not self.bonusApplied then
    print('Block/Dodge window is between frame ' .. self.blockWindow[1] .. ' and ' .. self.blockWindow[2])
    print('Action Button pressed on frame ' .. self.frameCount)
    self:applyBonus()
  elseif button == self.actionButton and not self.isWindowActive then
    self:updateBadInputPenalty(true)
  end
end;

function DefenseState:gamepadreleased(joystick, button)
  if button == 'rightshoulder' or button == 'leftshoulder' then
    self.stance = 'dodge'
  end
end;

function DefenseState:update(dt)
  self.frameCount = self.frameCount + 1
  self:updateBadInputPenalty(false)
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

  spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.x, self.y, 0, 1)
end;

