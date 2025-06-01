--! filename: attacking state

Class = require 'libs.hump.class'
OffenseState = Class{
  ACTION_ICON_X = 300,
  ACTION_ICON_Y = 10
  }

-- Attacking State of a Character is responsible for maintaining the animation(s), values, and timed inputs for a chosen action

function OffenseState:init(x, y, actionButton, battleStats, actionIcons) --include luck for lucky miss?
  self.x = x
  self.y = y
  self.skill = nil
  self.animFrameLength = nil
  stats = battleStats    -- may be better to pare down and only include necessary stats
  self.damage = 0
  self.bonus = nil
  self.actionIcons = actionIcons
  
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

function OffenseState:setSkill(skillObj, x, y)
  self.skill = skillObj
  self.frameWindow = skillObj.qte_window
  self.animFrameLength = skillObj.duration
  self.bonus = skillObj.qte_bonus
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

function OffenseState:updateBadInputPenalty(applyPenalty)
  if applyPenalty then
    self.badInputPenalty = self.badInputPenalty + 20
    if self.badInputPenalty > 0 then
      self.badInputPenalty = self.badInputPenalty - 1
    end
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
  self.damage = self.damage + self.bonus
  self.bonusApplied = true
  print('bonus applied!')
end;

function OffenseState:clearSkillModifiers()
  local skillDict = self.skill:getSkillDict()
  self.bonus = nil
end;


function OffenseState:keypressed(key)
  if key == self.actionButton and self.badInputPenalty > 0 and self.isWindowActive and not self.bonusApplied then
    OffenseState.applyBonus(self)
  elseif key == self.actionButton and not self.isWindowActive then
    OffenseState.updateBadInputPenalty(self, true)
  end
end;

function OffenseState:gamepadpressed(joystick, button)
  if key == self.actionButton and self.badInputPenalty > 0 and self.isWindowActive and not self.bonusApplied then
    OffenseState.applyBonus(self)
  elseif key == self.actionButton and not self.isWindowActive then
    OffenseState.updateBadInputPenalty(self, true)
  end
end;

function OffenseState:update(dt)
  self.skill:update(dt)
  if self.isWindowActive then
    if self.frameCount > self.animFrameLength then
      self.isWindowActive = false
    end
  else
    if self.frameCount > self.animFrameLength - self.frameWindow and self.frameCount < self.animFrameLength then
      self.isWindowActive = true
    end
  end
  OffenseState.updateBadInputPenalty(self, false)
  self.frameCount = self.frameCount + 1
end;


function OffenseState:draw()
  if self.isWindowActive then
    love.graphics.draw(self.actionIcons.depressed, OffenseState.ACTION_ICON_X, OffenseState.ACTION_ICON_Y)
  else
    love.graphics.draw(self.actionIcons.raised, OffenseState.ACTION_ICON_X, OffenseState.ACTION_ICON_Y)
  end
  
  self.skill:draw(self.x, self.y)
end;