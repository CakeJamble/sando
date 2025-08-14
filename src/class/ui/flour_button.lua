--! filename: flour button
require('class.ui.button')
require('class.ui.submenu_button')
Class = require 'libs.hump.class'
FlourButton = Class{__includes = SubMenuButton}

function FlourButton:init(pos, index, skillList, actionButton)
  SubMenuButton.init(self, pos, index, 'flour.png', actionButton, skillList)
  self.description = 'Consume FP to use a powerful skill'
end;

function FlourButton:skillListToStr() -- override
  local result = ''
  for i,skill in ipairs(self.actionList) do
    result = result .. skill.name .. '\t' .. self.actionList.cost .. '\n'
  end
  return result
end;

function FlourButton:validateSkillCosts(currentFP)
  for i,skill in ipairs(self.actionList) do
    self.pickableSkillIndices[i] = skill.cost < currentFP
  end
end;

function FlourButton:keypressed(key)
  if key == 'down' or key == 'right' then 
    self.skillIndex = (self.skillIndex % #self.skillListDisplay) + 1
  elseif key == 'up' or key == 'left' then
    if self.skillIndex <= 1 then
      self.skillIndex = #self.skillListDisplay
    else
      self.skillIndex = self.skillIndex - 1
    end
  end
end;

function FlourButton:gamepadpressed(joystick, button)
  SubMenuButton.gamepadpressed(self, joystick, button)

  if button == self.actionButton and self.selectedAction then
    Signal.emit('SkillSelected', self.selectedAction)
  elseif button == 'dpleft' or button == 'dpright' then
    Signal.emit('SkillDeselected')
  end
end;
