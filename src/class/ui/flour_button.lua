--! filename: flour button
require('class.ui.button')
require('class.ui.submenu_button')
Class = require 'libs.hump.class'
FlourButton = Class{__includes = SubMenuButton}

function FlourButton:init(pos, index, skillList, actionButton)
  SubMenuButton.init(self, pos, index, 'flour.png', actionButton, skillList)
  -- self.list = skillList
  -- self.skillIndex = 1
  -- self.actionButton = actionButton
  -- self.skillListHolder = love.graphics.newImage(path/to/image)
  -- self.skillListCursor = love.graphics.newImage(path/to/image)
  -- self.selectedSkill = nil
  -- self.displaySkillList = false
  -- self.numSkillsInPreview = 5
  -- self.flourSkillTableOptions = self:populateFlourSkills()
  -- self.skillListDisplay = self:populateSkillPreviews()
  -- self.previewPos = {
    -- x = self.flourSkillTableOptions.container.x, 
    -- y = self.flourSkillTableOptions.container.y}
  -- self.previewOffset = self.flourSkillTableOptions.container.height / self.numSkillsInPreview
  self.description = 'Consume FP to use a powerful skill'
end;

-- --[[ Create UI for the Flour Skills tables
-- Use self.skillList to populate from i=2, #self.skillList
-- because i=1 is the basic attack for all entities]]
-- function FlourButton:populateFlourSkills()
--   local result = {container = {}, separator = {}}
--   -- Specify dimensions (mode, x, y, width, height)
--   result.container = {
--     mode = 'fill',
--     x = self.pos.x + 150,
--     y = self.pos.y,
--     width = 100,
--     height = 125
--   }

--   -- Create separators (lines or images)
--   local textSpacing = result.container.height / self.numSkillsInPreview
--   local x, y = result.container.x, result.container.y
--   local width, height = result.container.width, result.container.height
--   for i=1,#self.list do
--     table.insert(result.separator, {
--     x1 = x, y1 = y + textSpacing * i,
--     x2 = x + width, y2 = y + textSpacing * i
--   })
--   end
--   return result
-- end;

-- function FlourButton:populateSkillPreviews()
--   local result = {}
--   local preview = {}
--   for i=1,#self.list do
--     preview.name = self.list[i].name
--     preview.cost = self.list[i].cost
--     preview.description = self.list[i].description
--     preview.targetType = self.list[i].targetType

--     table.insert(result, preview)
--     preview = {}
--   end

--   return result
-- end;

-- function FlourButton:drawFlourSkillsContainer()
--   love.graphics.rectangle(self.flourSkillTableOptions.container.mode, 
--     self.flourSkillTableOptions.container.x, 
--     self.flourSkillTableOptions.container.y, 
--     self.flourSkillTableOptions.container.width, 
--     self.flourSkillTableOptions.container.height)

--   love.graphics.setColor(0, 0, 0)
--   for _,separator in pairs(self.flourSkillTableOptions.separator) do
--     love.graphics.line(separator.x1, separator.y1, separator.x2, separator.y2)
--   end
--   love.graphics.setColor(1, 1, 1)
-- end;

-- function FlourButton:drawFlourSkills()
--   love.graphics.setColor(0, 0, 0)
--   for i,preview in ipairs(self.skillListDisplay) do
--     love.graphics.print(preview.name, self.previewPos.x, self.previewPos.y + self.previewOffset * (i - 1))
--   end
--   love.graphics.setColor(1, 1, 1)
-- end;

function FlourButton:skillListToStr() -- override
  local result = ''
  for i,skill in ipairs(self.actionList) do
    result = result .. skill.name .. '\t' .. self.actionList.cost .. '\n'
  end
  return result
end;

-- function FlourButton:setSkillPreview()
--   self.skillPreview = self.list[self.skillIndex].description
-- end;

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
-- ----------------------- Action Selection -------------------------
--   if button == 'dpdown' then
--     self.skillIndex = (self.skillIndex % #self.skillListDisplay) + 1
--   elseif button == 'dpup' then
--     if self.skillIndex <= 1 then
--       self.skillIndex = #self.skillListDisplay
--     else
--       self.skillIndex = self.skillIndex - 1
--     end
--   elseif button == self.actionButton then
--     if not self.displaySkillList then
--       self.displaySkillList = true
--     else
--       self.selectedSkill = self.list[self.skillIndex]
--       Signal.emit('SkillSelected', self.selectedSkill)
--     end

-- ----------------------- Action Cancels -------------------------
--   elseif button == 'dpleft' or button == 'dpright' then -- close skill select menu
--     self.displaySkillList = false
--     Signal.emit('SkillDeselected')
--     -- uncomment next line if you want to reset highlighted skill on spin
--     self.skillIndex = 1
--   end
end;

-- function FlourButton:draw()
--   Button.draw(self)
--   if self.displaySkillList then
--     self:drawFlourSkillsContainer()
--     self:drawFlourSkills()

--     -- draw cursor
--     love.graphics.setColor(0, 0, 1)
--     love.graphics.rectangle('line', self.previewPos.x,
--       self.previewPos.y + ((self.skillIndex - 1) * (self.flourSkillTableOptions.container.height / self.numSkillsInPreview)), 100, 25)
--     love.graphics.setColor(1, 1, 1)
--   end
-- end;