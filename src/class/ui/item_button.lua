require('class.ui.button')
Class = require('libs.hump.class')

ItemButton = Class{__includes = Button}

function ItemButton:init(pos, index, itemList)
    Button.init(self, pos, index, 'item.png')
    self.itemList = itemList
    self.displayList = false
    self.description = 'Use an item to gain an advantage'
    self.itemTableOptions = self:populateItemList()
    self.listMenu = self:populatePreviews()
    self.previewPos = {
        x = self.itemTableOptions.container.x, 
        y = self.itemTableOptions.container.y
    }
    self.previewOffset = self.itemTableOptions.container.height / 2 --centered
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
  local textSpacing = result.container.height / 10
  local x, y = result.container.x, result.container.y
  local width, height = result.container.width, result.container.height
  for i, item in ipairs(self.itemList) do
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
  for i, item in ipairs(self.itemList) do
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
  for i, item in ipairs(self.itemList) do
    result = result .. item.name .. '\n'
  end
  return result
end;

function ItemButton:setItemPreview()
    self.itemPreview = self.itemList[self.itemIndex].description
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