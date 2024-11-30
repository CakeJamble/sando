--! filename: flour button
require('class.button')
Class = require 'libs.hump.class'
FlourButton = Class{__includes = Button}

function FlourButton:init(x, y, currentFP, skillList)
    Button.init(self, x, y, 'flour.png')
    self.skillList = skillList
    self.skillListString = FlourButton.skillListToStr(self)
    self.skillIndex = 1
    self.currentFP = currentFP
    -- self.skillListHolder = love.graphics.newImage(path/to/image)
    -- self.skillListCursor = love.graphics.newImage(path/to/image)
    self.selectedSkill = nil
    self.displaySkillList = false
end;

function FlourButton:skillListToStr()
  local result = ''
  for i=1,#self.skillList do
    result = result .. self.skillList[i].skillName .. '\n'
  end
  return result
end;

function FlourButton:keypressed(key)
  
end;

function FlourButton:update(dt)
    Button.update(self, dt)
end;

function FlourButton:draw()
  Button.draw(self)
  if self.isActiveButton and self.displaySkillList then
    love.graphics.print(self.skillListString, self.x, self.y)
  end
end;