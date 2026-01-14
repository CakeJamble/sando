local SubMenuButton = require('class.ui.SubmenuButton')
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')

---@class ItemButton: SubMenuButton
local ItemButton = Class{__includes = SubMenuButton}

---@param pos { [string]: number }
---@param index integer
---@param itemList table[]
---@param actionButton string
function ItemButton:init(pos, index, itemList, actionButton)
  SubMenuButton.init(self, pos, index, 'item.png', actionButton, itemList)
  self.description = 'Use an item to gain an advantage'
end;

-- ---@deprecated Use update with baton to handle inputs
-- ---@param joystick love.Joystick
-- ---@param button love.GamepadButton
-- function ItemButton:gamepadpressed(joystick, button)
--   SubMenuButton.gamepadpressed(self, joystick, button)

--   if button == self.actionButton and self.selectedAction then
--     Signal.emit('ItemSelected', self.selectedAction)
--   elseif button == 'dpleft' or button == 'dpright' then
--     Signal.emit('ItemDeselected')
--   end
-- end;

function ItemButton:updateInput()
  SubMenuButton.updateInput(self)

  if Player:pressed(self.actionButton) and self.selectedAction then
    Signal.emit('ItemSelected', self.selectedAction)
  elseif Player:pressed('left') or Player:pressed('right') then
    Signal.emit('ItemDeselected')
  end
end;

return ItemButton