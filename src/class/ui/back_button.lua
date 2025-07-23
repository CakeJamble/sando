--! filename: dup button
require('class.ui.button')
Class = require('libs.hump.class')

BackButton = Class{}

function BackButton:init(pos)
	self.pos = {x=pos.x, y=pos.y}
	local path = 'asset/sprites/combat/back_button.png'
	self.button = love.graphics.newImage(path)
	self.isHidden = true
end;

function BackButton:draw()
	if not self.isHidden then
		love.graphics.draw(self.button, self.pos.x, self.pos.y)
	end
end;