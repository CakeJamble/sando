require('class.ui.button')
Class = require('libs.hump.class')

PassButton = Class{__includes = Button}

function PassButton:init(pos, index)
	Button.init(self, pos, index, 'pass.png')
	self.description = 'End Turn'
end;