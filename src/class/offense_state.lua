--! filename: attacking state

local class = require 'libs/middleclass'

-- Attacking State of a Character is responsible for maintaining the animation(s), values, and timed inputs for a chosen action

OffenseState = class('OffenseState')


function OffenseState:initialize(actionButton, battleStats) --include luck for lucky miss?
  self.skill = nil
  stats = battleStats    -- may be better to pare down and only include necessary stats
  self.damage = 0
  self.bonus = nil
  
  -- Data used for calculating timed input conditions and bonuses
  self.actionButton = actionButton
  self.frameCount = 0
  self.frameWindow = 0
  self.isWindowActive = false
  self.actionButtonPressed = false
  self.badInputPenalty = 0
  self.bonusApplied = false
end;

function OffenseState:getSkill()
  return self.skill
end;

function OffenseState:setSkill(skillObj)
  self.skill = skillObj
end;

function OffenseState:setTargetXY(x, y)
  self.targetX = x
  self.targetY = y
end;

function OffenseState:resolveProc(proc)
  local skillDict = self.skill:getSkillDict()
  if skillDict['qte_bonus_type'] == 'proc' then
    return proc + self.bonus >= love.math.random(1, 100)
  else
    return proc >= love.math.random(1,100)
  end
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
  elseif self.badInputPenalty > 0 then
    self.badInputPenalty = self.badInputPenalty - 1
  end
end;

function OffenseState:calcDamage()
  local skillDict = self.skill:getSkillDict()
  
  -- NOTE: damage calc design isn't finalized, just adding the two together right now. Need to research and see how other games calc damage
  self.damage = skillDict['damage'] + stats['attack']
end;

function OffenseState:setBattleStats(battleStats)
  self.battleStats = battleStats
end;

function OffenseState:applyBonus()
  local skillDict = self.skill:getSkillDict()
  self.bonus = self.bonus + skillDict['qte_bonus']
  self.bonusApplied = true
end;

function OffenseState:clearSkillModifiers()
  local skillDict = self.skill:getSkillDict()
  self.bonus = nil
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