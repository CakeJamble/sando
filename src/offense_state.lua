--! filename: attacking state

local class = require 'libs/middleclass'

-- Attacking State of a Character is responsible for maintaining the animation(s), values, and timed inputs for a chosen action

OffenseState = class('OffenseState')


function OffenseState:initialize(skill, target, actionButton)
  self.skill = skill
  self.skill_table = skill:getSkillTable()
  self.damage = self.skill_table['damage']
  self.proc = self.skill_table['proc']
  
  -- Target refers to entity/entities targeted by a skill
  self.targetX = target:getX()
  self.targetY = target:getY()
  
  -- Data used for calculating timed input conditions and bonuses
  self.actionButton = actionButton
  self.frameCount = 0
  self.frameWindow = self.skill_table['qte_window']
  self.isWindowActive = false
  self.actionButtonPressed = false
  self.badInputPenalty = 0
  

  
  self.bonusApplied = false
end;

function getDamage()
  return self.damage
end;

function resolveProc()
  return self.proc >= love.math.random(1, 100)
end;

function OffenseState:setActionButton(newButton)
  self.actionButton = newButton
end;

function OffenseState:startFrameWindow()
  self.isWindowActive = true
  self.frameCounter = 0
  self.actionButtonPressed = false
end;

function OffenseState:updateBadInputPenalty(applyPenalty)
  if applyPenalty then
    self.badInputPenalty = self.badInputPenalty + 20
  elseif badInputPenalty > 0 then
    self.badInputPenalty = self.badInputPenalty - 1
  end
end;

function OffenseState:applyBonus()
  local qte_bonus = self.skill_table['qte_bonus']
  if self.skill_table['qte_bonus_type'] == 'damage' then
    self.damage = self.damage + qte_bonus
    self.bonusApplied = true
  elseif self.skill_table['qte_bonus_type'] == 'proc' then
    self.proc = self.proc + qte_bonus
    self.bonusApplied = true
  end
end;

function OffenseState:keypressed(key)
  if key == self.actionButton and self.badInputPenalty > 0 and self.isWindowActive and not self.bonusApplied then
    OffenseState:applyBonus()
  elseif key == self.actionButton and not self.isWindowActive then
    OffenseState:updateBadInputPenalty(true)
  end
end;

function OffenseState:update(dt)
  if self.isWindowActive then
    self.frameCount = self.frameCount + 1
    
    if self.frameCount > self.frameWindow then
      self.isWindowActive = false
    end
  end
  OffenseState:updateBadInputPenalty(false)
end;

function OffenseState:draw()
  self.skill:draw()
end;

