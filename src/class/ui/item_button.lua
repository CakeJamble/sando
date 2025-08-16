local SubMenuButton = require('class.ui.submenu_button')
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')

local ItemButton = Class{__includes = SubMenuButton}

function ItemButton:init(pos, index, itemList, actionButton)
  SubMenuButton.init(self, pos, index, 'item.png', actionButton, itemList)
  self.description = 'Use an item to gain an advantage'
end;

function ItemButton:gamepadpressed(joystick, button)
  SubMenuButton.gamepadpressed(self, joystick, button)

  if button == self.actionButton and self.selectedAction then
    Signal.emit('ItemSelected', self.selectedAction)
  elseif button == 'dpleft' or button == 'dpright' then
    Signal.emit('ItemDeselected')
  end
end;

return ItemButton