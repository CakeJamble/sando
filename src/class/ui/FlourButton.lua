local SubMenuButton = require('class.ui.SubmenuButton')
local Signal = require('libs.hump.signal')
local Class = require 'libs.hump.class'

---@class FlourButton: SubMenuButton
local FlourButton = Class{__includes = SubMenuButton}

---@param pos { [string]: number }
---@param index integer
---@param skillList table[]
---@param actionButton string
function FlourButton:init(pos, index, skillList, actionButton)
  SubMenuButton.init(self, pos, index, 'flour.png', actionButton, skillList)
  self.description = 'Consume FP to use a powerful skill'
  self.pickableSkillIndices = {}
end;

---@return string
function FlourButton:skillListToStr() -- override
  local result = ''
  for _,skill in ipairs(self.actionList) do
    result = result .. skill.name .. '\t' .. self.actionList.cost .. '\n'
  end
  return result
end;

---@param currentFP integer
function FlourButton:validateSkillCosts(currentFP)
  for i,skill in ipairs(self.actionList) do
    self.pickableSkillIndices[i] = skill.cost < currentFP
  end
end;

---@param key string
---@deprecated
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

---@param joystick love.Joystick
---@param button love.GamepadButton
function FlourButton:gamepadpressed(joystick, button)
  SubMenuButton.gamepadpressed(self, joystick, button)

  if button == self.actionButton and self.selectedAction then
    Signal.emit('SkillSelected', self.selectedAction)
  elseif button == 'dpleft' or button == 'dpright' then
    Signal.emit('SkillDeselected')
  end
end;

return FlourButton