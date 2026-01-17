local SubMenuButton = require('class.ui.SubmenuButton')
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')

---@type ItemButton
local ItemButton = Class{__includes = SubMenuButton}

function ItemButton:init(pos, index, itemList, actionButton)
  SubMenuButton.init(self, pos, index, 'item.png', actionButton, itemList)
  self.description = 'Use an item to gain an advantage'
end;

function ItemButton:update(dt)
  SubMenuButton.updateInput(self)

  if Player:pressed(self.actionButton) and self.selectedAction then
    Signal.emit('ItemSelected', self.selectedAction)
  elseif Player:pressed('left') or Player:pressed('right') then
    Signal.emit('ItemDeselected')
  end
end;

return ItemButton