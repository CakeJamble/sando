local Button = require('class.ui.button')
local Class = require('libs.hump.class')

---@class PassButton: Button
local PassButton = Class{__includes = Button}

---@param pos { [string]: number }
---@param index integer
function PassButton:init(pos, index)
	Button.init(self, pos, index, 'pass.png')
	self.description = 'End Turn'
end;

return PassButton