--! filename: defending_state

local class = require 'libs/middleclass'

-- Defending State of a Character is responsible for maintaining their blocking animation, dodging animation, and timed inputs for defense

DefenseState = class('DefenseState')

function DefenseState:initialize(baseDefense, blockBonus, blockWindow, dodgeWindow)
  self.defense = baseDefense
  self.blockBonus = blockBonus
  self.stance = 'block'
  
  -- Data used for calculating timed input conditions and bonuses
  self.actionButton = actionButton
  self.frameCount = 0
  self.frameWindow = self.skill_table['qte_window']
  self.isWindowActive = false
  self.actionButtonPressed = false
  self.badInputPenalty = 0

end;

function DefenseState:setActionButton(newButton)
  self.actionButton = newButton
end;

function DefenseState:startFrameWindow()
  self.isWindowActive = true
  self.frameCounter = 0
  self.actionButtonPressed = false
end;

function DefenseState:updateBadInputPenalty(applyPenalty)
  if applyPenalty then
    self.badInputPenalty = self.badInputPenalty + 20
  elseif badInputPenalty > 0 then
    self.badInputPenalty = self.badInputPenalty - 1
  end
end;

function DefenseState:applyBonus()
  if self.state == 'block' then
    self.defense = self.defense + blockBonus
  end
end;

function DefenseState:keypressed(key)
  if key == self.actionButton and self.badInputPenalty > 0 and self.isWindowActive and not self.bonusApplied then
    DefenseState:applyBonus()
  end
  elseif key == self.actionButton and not self.isWindowActive then
    DefenseState:updateBadInputPenalty(true)
  end
end;


function DefenseState:update(dt)
  if self.isWindowActive then
    self.frameCount = self.frameCount + 1
    
    if self.frameCount > self.frameWindow then
      self.isWindowActive = false
    end
  end
  OffenseState:updateBadInputPenalty(false)
end;