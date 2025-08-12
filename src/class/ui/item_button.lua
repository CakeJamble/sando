require('class.ui.button')
Class = require('libs.hump.class')

ItemButton = Class{__includes = Button}

function ItemButton:init(pos, index, itemList, actionButton)
  Button.init(self, pos, index, 'item.png')
  self.actionButton = actionButton
  self.list = itemList
  self.displayList = false
  self.description = 'Use an item to gain an advantage'
  self.numItemsInPreview = 5
  self.itemTableOptions = self:populateItemList()
  self.listMenu = self:populatePreviews()
  self.previewPos = {
      x = self.itemTableOptions.container.x, 
      y = self.itemTableOptions.container.y
  }
  self.previewOffset = self.itemTableOptions.container.height / 2 --centered
  self.itemIndex = 1
  self.selectedItem = nil
end;

function ItemButton:populateItemList()
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
  for i, item in ipairs(self.list) do
    table.insert(result.separator, {
    x1 = x, y1 = y + textSpacing * i,
    x2 = x + width, y2 = y + textSpacing * i
  })
  end
  return result
end;

function ItemButton:populatePreviews()
  local result = {}
  local preview = {}
  for i, item in ipairs(self.list) do
    preview.name = item.name
    preview.description = item.description
    preview.targetType = item.targetType

    result[i] = preview
    preview = {}
  end

  return result
end;

function ItemButton:drawItemMenu()
  love.graphics.rectangle(self.itemTableOptions.container.mode, 
    self.itemTableOptions.container.x, 
    self.itemTableOptions.container.y, 
    self.itemTableOptions.container.width, 
    self.itemTableOptions.container.height)

  love.graphics.setColor(0, 0, 0)
  for _,separator in pairs(self.itemTableOptions.separator) do
    love.graphics.line(separator.x1, separator.y1, separator.x2, separator.y2)
  end
  love.graphics.setColor(1, 1, 1)
end;

function ItemButton:drawItems()
  love.graphics.setColor(0, 0, 0)
  for i,preview in ipairs(self.listMenu) do
    love.graphics.print(preview.name, self.previewPos.x, self.previewPos.y + self.previewOffset * (i - 1))
  end
  love.graphics.setColor(1, 1, 1)
end;

function ItemButton:itemListToStr()
  local result = ''
  for i, item in ipairs(self.list) do
    result = result .. item.name .. '\n'
  end
  return result
end;

function ItemButton:setItemPreview()
    self.itemPreview = self.list[self.index].description
end;

function ItemButton:gamepadpressed(joystick, button)
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
      self.selectedItem = self.list[self.index]
      Signal.emit('ItemSelected', self.selectedItem)
    end
----------------------- Action Cancels -------------------------
  elseif button == 'dpleft' or button == 'dpright' then -- close item select menu
    self.displayList = false
    Signal.emit('ItemDeselected')
    self.index = 1
  end
end;

function ItemButton:draw()
    Button.draw(self)
    if self.displayList then
        self:drawItemMenu()
        self:drawItems()

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle('line', self.previewPos.x, self.previewPos.y + ((self.itemIndex - 1) * self.itemTableOptions.container.height), 100, 25)
    love.graphics.setColor(1, 1, 1)
    end
end;