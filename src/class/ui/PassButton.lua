local Button = require('class.ui.Button')
local Class = require('libs.hump.class')

---@type PassButton
local PassButton = Class{__includes = Button}

function PassButton:init(pos, index)
	Button.init(self, pos, index, 'pass.png')
	self.description = 'End Turn'
end;

return PassButton