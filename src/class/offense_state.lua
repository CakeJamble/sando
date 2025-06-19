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
  self.damage = battleStats.attack
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
  self.target = nil
  self.isComplete = false
end;

function OffenseState:reset()
  self.isComplete = false
  self.frameCount = 0
  self.bonusApplied = false
  self.target = nil
end;

function OffenseState:setSkill(skillObj)
  self.skill = skillObj
  self.frameWindow = skillObj.qte_window
  self.animFrameLength = skillObj.duration
  self.bonus = skillObj.qte_bonus
  self.damage = self.damage + self.skill.skill.damage
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
    print('applied penalty for missed input timing')
  elseif self.badInputPenalty > 0 then
      self.badInputPenalty = self.badInputPenalty - 1
  end
end;

function OffenseState:calcDamage()
  local skillDict = self.skill:getSkillDict()
  
  -- NOTE: damage calc design isn't finalized, just adding the two together right now. Need to research and see how other games calc damage
  self.damage = skillDict['damage'] + stats['attack']
end;

function OffenseState:dealDamage()
  if self.target then
    print("dealing damage to " .. self.target.entityName)
    self.target:takeDamage(self.damage)
  end
end;

function OffenseState:applyBonus()
  self.damage = self.damage + self.bonus
  self.bonusApplied = true
  print('bonus applied! Damage is now ' .. self.damage)
end;

function OffenseState:clearSkillModifiers()
  local skillDict = self.skill:getSkillDict()
  self.bonus = nil
end;


function OffenseState:keypressed(key)
  if key == self.actionButton and self.badInputPenalty == 0 and (self.frameWindow[1] <= self.frameCount and self.frameWindow[2] > self.frameCount) and not self.bonusApplied then
    print('QTE Window is between frame ' .. self.frameWindow[1] .. ' and ' .. self.frameWindow[2])
    print('Action Button pressed on frame ' .. self.frameCount)
    self:applyBonus()
  elseif key == self.actionButton and not self.isWindowActive then
    self:updateBadInputPenalty(true)
  end
end;

function OffenseState:gamepadpressed(joystick, button)
  if button == self.actionButton and self.badInputPenalty == 0 and (self.frameWindow[1] <= self.frameCount and self.frameWindow[2] > self.frameCount) and not self.bonusApplied then
    print('QTE Window is between frame ' .. self.frameWindow[1] .. ' and ' .. self.frameWindow[2])
    print('Action Button pressed on frame ' .. self.frameCount)  
    self:applyBonus()
  elseif button == self.actionButton and not self.isWindowActive then
    self:updateBadInputPenalty(true)
  end
end;

function OffenseState:update(dt)
  if self.isComplete then 
    print('Turn is finished')
    return 
  end
  if not self.skill then return end

  self.frameCount = self.frameCount + 1
  self.skill:update(dt)
  
  if self.frameCount > self.animFrameLength then
    self:dealDamage()
    self.isComplete = true
    self.isWindowActive = false
  end 

  self:updateBadInputPenalty(false)
end;


function OffenseState:draw()
  self.skill:draw(self.x, self.y)
end;