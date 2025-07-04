--! filename: defending_state

Class = require 'libs.hump.class'
-- Defending State of a Character is responsible for maintaining their blocking animation, dodging animation, and timed inputs for defense

DefenseState = Class{}

function DefenseState:init(actionButton, baseDefense)
  self.defense = baseDefense
  self.blockBonus = nil
  self.blockWindow = nil
  self.incomingSkill = nil
  self.stance = 'block'

  -- Data used for calculating timed input conditions and bonuses
  self.actionButton = actionButton
  self.frameCount = 0
  self.frameWindow = nil
  self.isWindowActive = false
  self.actionButtonPressed = false
  self.badInputPenalty = 0
end;

-- function DefenseState:setActionButton(newButton)
--   self.actionButton = newButton
-- end;

-- function DefenseState:setDefense(defense)
--   self.defense = defense
-- end

-- function DefenseState:setIncomingSkill(skill)
--   self.incomingSkill = skill
-- end;

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
  if self.stance == 'block' then
    self.defense = self.defense + self.blockBonus
  end
end;

function DefenseState:keypressed(key)
  if key == self.actionButton and self.stance == 'block' and self.badInputPenalty > 0 and self.isWindowActive and not self.bonusApplied then
    DefenseState:applyBonus()
  elseif key == self.actionButton and not self.isWindowActive then    -- cannot dodge or block when you flub an input, penalty must expire before action (but you can switch states)
    DefenseState:updateBadInputPenalty(true)
  end
end;


function DefenseState:update(dt)
  if love.keyboard.isDown('l') or love.keyboard.isDown('r') then
    self.stance = 'block'
  end
  
  if self.isWindowActive then
    self.frameCount = self.frameCount + 1
    
    if self.frameCount > self.frameWindow then
      self.isWindowActive = false
    end
  end
  OffenseState:updateBadInputPenalty(false)
end;