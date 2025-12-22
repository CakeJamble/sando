local Button = require('class.ui.button')
local Class = require('libs.hump.class')

---@class SubMenuButton: Button
local SubMenuButton = Class{__includes = Button}

---@param pos { [string]: number }
---@param index integer
---@param path string
---@param actionButton string
---@param actionList table[]
function SubMenuButton:init(pos, index, path, actionButton, actionList)
	Button.init(self, pos, index, path)
	self.actionButton = actionButton
	self.actionList = actionList
	self.displayList = false
	self.numItemsInPreview = 5
	self.listOptions = self:populateList()
	self.listUI = self:populatePreviews()
	self.previewPos = {
		x = self.listOptions.container.x,
		y = self.listOptions.container.y
	}
	self.previewOffset = self.listOptions.container.height / self.numItemsInPreview
	self.listIndex = 1
	self.selectedAction = nil
end;

---@return { [string]: table }
function SubMenuButton:populateList()
  local result = {container = {}, separator = {}}

  result.container = {
    mode = 'fill',
    x = self.pos.x + 150,
    y = self.pos.y,
    width = 100,
    height = 125
  }

  -- Create separators (lines or images)
  local textSpacing = result.container.height / self.numItemsInPreview
  local x, y = result.container.x, result.container.y
  local width, height = result.container.width, result.container.height
  for i,_ in ipairs(self.actionList) do
    table.insert(result.separator, {
    x1 = x, y1 = y + textSpacing * i,
    x2 = x + width, y2 = y + textSpacing * i
  })
  end
  return result
end;

---@return { [string]: string }[]
function SubMenuButton:populatePreviews()
  local result = {}
  local preview = {}
  for i, item in ipairs(self.actionList) do
    preview.name = item.name
    preview.description = item.description
    preview.targetType = item.targetType

    result[i] = preview
    preview = {}
  end

  return result
end;

function SubMenuButton:drawListUI()
  love.graphics.rectangle(self.listOptions.container.mode,
    self.listOptions.container.x,
    self.listOptions.container.y,
    self.listOptions.container.width,
    self.listOptions.container.height)

  love.graphics.setColor(0, 0, 0)
  for _,separator in pairs(self.listOptions.separator) do
    love.graphics.line(separator.x1, separator.y1, separator.x2, separator.y2)
  end
  love.graphics.setColor(1, 1, 1)
end;

function SubMenuButton:drawElems()
  love.graphics.setColor(0, 0, 0)
  for i,preview in ipairs(self.listUI) do
    love.graphics.print(preview.name, self.previewPos.x, self.previewPos.y + self.previewOffset * (i - 1))
  end
  love.graphics.setColor(1, 1, 1)
end;

-- Should be refactored to return a list of strings instead of 1 big string
---@return string
function SubMenuButton:actionListToStr()
  local result = ''
  for _, elem in ipairs(self.actionList) do
    result = result .. elem.name .. '\n'
  end
  return result
end;

function SubMenuButton:setDescription()
	self.preview = self.actionList[self.index].description
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function SubMenuButton:gamepadpressed(joystick, button)
----------------------- Action Selection -------------------------
  if button == 'dpdown' then
    self.listIndex = (self.listIndex % #self.listUI) + 1
  elseif button == 'dpup' then
    if self.listIndex <= 1 then
      self.listIndex = #self.listUI
    else
      self.listIndex = self.listIndex - 1
    end
  elseif button == self.actionButton then
    if not self.displayList then
      self.displayList = true
    else
      self.selectedAction = self.actionList[self.listIndex]
    end
----------------------- Action Cancels -------------------------
  elseif button == 'dpleft' or button == 'dpright' then -- close item select menu
    self.displayList = false
    self.selectedAction = nil
    self.listIndex = 1
  end
end;

function SubMenuButton:draw()
	Button.draw(self)
	if self.displayList then
		self:drawListUI()
		self:drawElems()

    love.graphics.setColor(0,0,1)

    local y = self.previewPos.y + ((self.listIndex - 1) * (self.listOptions.container.height / self.numItemsInPreview))
    love.graphics.rectangle('line', self.previewPos.x, y, 100, 25)
    love.graphics.setColor(1, 1, 1)
  end
end;

return SubMenuButton