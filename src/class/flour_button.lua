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
    self.skillPreview = skillList[1].description
end;

function FlourButton:skillListToStr()
  local result = ''
  for i=1,#self.skillList do
    result = result .. self.skillList[i].skill['skill_name'] .. self.skillList[i].skill['cost'] .. '\n'
  end
  return result
end;

function FlourButton:setSkillPreview()
  self.skillPreview = skillList[self.skillIndex].description
end;

function FlourButton:keypressed(key)
  if key == 'down' then
    self.skillIndex = math.max(1, (self.skillIndex + 1) % #self.skillList)
  elseif key == 'up' then
    self.skillIndex = if self.skillIndex > 1 then self.skillIndex - 1 else #self.skillList end
  elseif key == 'z' then
    -- TODO: Switch to active state with Character:offenseState
  end
end;

function FlourButton:update(dt)
    Button.update(self, dt)
end;

function FlourButton:draw()
  Button.draw(self)
  if self.isActiveButton and self.displaySkillList then
    for i=1,#self.skillList do
      
    love.graphics.print(self.skillListString, self.x, self.y)
    -- draw cursor @ offset based on position & self.skillIndex
  end
end;