SubMenuButton = Class{__includes = Button}

function SubMenuButton:init(pos, index, path, actionButton, actionList)
	Button.init(self, pos, index, path)
	self.actionButton = actionButton
	self.actionList = actionList
	self.displayList = false
	self.numItemsInPreview = 5
	self.listOptions = self:populateList()
	self.listUI = self:populatePreviews
	self.previewPos = {
		x = self.listOptions.container.x,
		y = self.listOptions.container.y
	}
	self.previewOffset = self.listOptions.container.height / 2
	self.listIndex = 1
	self.selectedAction = nil
end;

function SubMenuButton:populateList()
  local result = {container = {}, separator = {}}
  -- Specify dimensions (mode, x, y, width, height)
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
  for i, item in ipairs(self.actionList) do
    table.insert(result.separator, {
    x1 = x, y1 = y + textSpacing * i,
    x2 = x + width, y2 = y + textSpacing * i
  })
  end
  return result
end;

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

function SubMenuButton:actionListToStr()
  local result = ''
  for i, elem in ipairs(self.actionList) do
    result = result .. elem.name .. '\n'
  end
  return result
end;

function SubMenuButton:setDescription()
	self.preview = self.actionList[self.index].description
end;

function SubMenuButton:gamepadpressed(joystick, button)
----------------------- Action Selection -------------------------
  if button == 'dpdown' then
    self.index = (self.index % #self.listMenu) + 1
  elseif button == 'dpup' then
    if self.index <= 1 then
      self.index = #self.listMenu
    else
      self.index = self.index - 1
    end
  elseif button == self.actionButton then
    if not self.displayList then
      self.displayList = true
    else
      self.selectedAction = self.actionList[self.listIndex]
      Signal.emit('ItemSelected', self.selectedItem)
    end
----------------------- Action Cancels -------------------------
  elseif button == 'dpleft' or button == 'dpright' then -- close item select menu
    self.displayList = false
    self.index = 1
  end
end;

function SubMenuButton:draw()
	Button.draw(self)
	if self.displayList then
		self:drawListUI()
		self:drawElems()

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle('line', self.previewPos.x, self.previewPos.y + ((self.itemIndex - 1) * self.itemTableOptions.container.height), 100, 25)
    love.graphics.setColor(1, 1, 1)
  end
end;