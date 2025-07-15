--! filename: flour button
require('class.ui.button')
Class = require 'libs.hump.class'
FlourButton = Class{__includes = Button}

function FlourButton:init(x, y, layer, skillList, actionButton)
  Button.init(self, x, y, layer, 'flour.png')
  self.skillList = skillList
  self.skillIndex = 1
  self.actionButton = actionButton
  -- self.skillListHolder = love.graphics.newImage(path/to/image)
  -- self.skillListCursor = love.graphics.newImage(path/to/image)
  self.selectedSkill = nil
  self.displaySkillList = false
  self.flourSkillTableOptions = self:populateFlourSkills()
  self.skillListDisplay = self:populateSkillPreviews()
  self.previewPos = {
    x = self.flourSkillTableOptions.container.x, 
    y = self.flourSkillTableOptions.container.y}
  self.previewOffset = self.flourSkillTableOptions.container.height / 2 --centered
  self.description = 'Consume FP to use a powerful skill'

    
  Signal.register('SpinUIWheelLeft', 
    function(before, x)
      if before == 'fsd' then -- after == {left:solo, center:duo, right:flour}
        self.active = false
        self.layer = 3
        self.tX = x + Button.SPACER
        self.dX = Button.BASE_DX * 2
      elseif before == 'dfs' then -- result: {left:flour, center:solo, right:duo} 
        self.active = false
        self.layer = 3
        self.tX = x - Button.SPACER
        self.dX = Button.BASE_DX
      elseif before == 'sdf' then -- result: {left: duo, center: flour, right: solo}
        self.active = true
        self.layer = 1
        self.tX = x
        self.dX = Button.BASE_DX
      end
    end
  );
  
  Signal.register('SpinUIWheelRight',
    function(before, x)
      if before == 'fsd' then -- result: {left: duo, center: flour, right: solo}
        self.active = true
        self.layer = 1
        self.tX = x
        self.dX = Button.BASE_DX * 1
      elseif before == 'dfs' then -- result: {left: solo, center: duo, right: flour}
        self.active = false
        self.layer = 1
        self.tX = x + Button.SPACER
        self.dX = Button.BASE_DX
      elseif before == 'sdf' then -- result: {left: flour, center: solo, right: duo}
        self.active = false
        self.layer = 3
        self.tX = x - Button.SPACER
        self.dX = Button.BASE_DX * 2
      end
    end
    );
    
end;

--[[ Create UI for the Flour Skills tables
Use self.skillList to populate from i=2, #self.skillList
because i=1 is the basic attack for all entities]]
function FlourButton:populateFlourSkills()
  local result = {container = {}, separator = {}}
  -- Specify dimensions (mode, x, y, width, height)
  result.container = {
    mode = 'fill',
    x = self.x + 150,
    y = self.y,
    width = 100,
    height = 125
  }

  -- Create separators (lines or images)
  local textSpacing = result.container.height / 10
  local x, y = result.container.x, result.container.y
  local width, height = result.container.width, result.container.height
  for i=2,#self.skillList do
    table.insert(result.separator, {
    x1 = x, y1 = y + textSpacing * i,
    x2 = x + width, y2 = y + textSpacing * i
  })
  end
  return result
end;

function FlourButton:populateSkillPreviews()
  local result = {}
  local preview = {}
  for i=1,#self.skillList do
    preview.name = self.skillList[i].name
    preview.cost = self.skillList[i].cost
    preview.description = self.skillList[i].description
    preview.targetType = self.skillList[i].targetType

    table.insert(result, preview)
    preview = {}
  end

  return result
end;

function FlourButton:drawFlourSkillsContainer()
  love.graphics.rectangle(self.flourSkillTableOptions.container.mode, 
    self.flourSkillTableOptions.container.x, 
    self.flourSkillTableOptions.container.y, 
    self.flourSkillTableOptions.container.width, 
    self.flourSkillTableOptions.container.height)

  love.graphics.setColor(0, 0, 0)
  for _,separator in pairs(self.flourSkillTableOptions.separator) do
    love.graphics.line(separator.x1, separator.y1, separator.x2, separator.y2)
  end
  love.graphics.setColor(1, 1, 1)
end;

function FlourButton:drawFlourSkills()
  love.graphics.setColor(0, 0, 0)
  for i,preview in ipairs(self.skillListDisplay) do
    love.graphics.print(preview.name, self.previewPos.x, self.previewPos.y + self.previewOffset * (i - 1))
  end
  love.graphics.setColor(1, 1, 1)
end;

function FlourButton:skillListToStr()
  local result = ''
  for i=1,#self.skillList do
    result = result .. self.skillList[i].skill['skill_name'] .. self.skillList[i].skill['cost'] .. '\n'
  end
  return result
end;

function FlourButton:setSkillPreview()
  self.skillPreview = self.skillList[self.skillIndex].description
end;

function FlourButton:validateSkillCosts(currentFP)
  for i=1,#self.skillList do
    self.pickableSkillIndices[i] = (self.skillList[i].cost < currentFP)
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
  if button == 'dpdown' or button == 'dpright' then
    self.skillIndex = (self.skillIndex % #self.skillListDisplay) + 1
  elseif button == 'dpup' or button == 'dpleft' then
    if self.skillIndex <= 1 then
      self.skillIndex = #self.skillListDisplay
    else
      self.skillIndex = self.skillIndex - 1
    end
  elseif button == self.actionButton then
    if not self.displaySkillList then
      self.displaySkillList = true
    else
      self.selectedSkill = self.skillList[self.skillIndex]
      Signal.emit('SkillSelected', self.selectedSkill)
    end
  end
end;

function FlourButton:draw()
  Button.draw(self)
  if self.displaySkillList then
    self:drawFlourSkillsContainer()
    self:drawFlourSkills()

    -- draw cursor
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle('line', self.previewPos.x,
      self.previewPos.y + ((self.skillIndex - 1) * self.flourSkillTableOptions.container.height), 100, 25)
    love.graphics.setColor(1, 1, 1)
  end
end;