local SubMenuButton = require('class.ui.SubmenuButton')
local Signal = require('libs.hump.signal')
local Class = require 'libs.hump.class'

---@type FlourButton
local FlourButton = Class{__includes = SubMenuButton}

function FlourButton:init(pos, index, skillList, actionButton)
  SubMenuButton.init(self, pos, index, 'flour.png', actionButton, skillList)
  self.description = 'Consume FP to use a powerful skill'
  self.pickableSkillIndices = {}
end;

function FlourButton:skillListToStr()
  local result = ''
  for _,skill in ipairs(self.actionList) do
    result = result .. skill.name .. '\t' .. self.actionList.cost .. '\n'
  end
  return result
end;

function FlourButton:validateSkillCosts(currentFP)
  for i,skill in ipairs(self.actionList) do
    self.pickableSkillIndices[i] = skill.cost < currentFP
  end
end;

function FlourButton:update(dt)
  SubMenuButton.update(self, dt)

  if Player:pressed(self.actionButton) and self.selectedAction then
    Signal.emit('SkillSelected', self.selectedAction)
  elseif Player:pressed('left') or Player:pressed('right') then
    Signal.emit('SkillDeselected')
  end
end;

return FlourButton