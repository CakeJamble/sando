local Class = require('libs.hump.class')

---@class BackButton
local BackButton = Class{}

---@param pos { [string]: number }
function BackButton:init(pos)
	self.pos = {x=pos.x, y=pos.y}
	local path = 'asset/sprites/combat/back_button.png'
	self.button = love.graphics.newImage(path)
	self.playerUsingNonOffensiveSkill = false
end;

function BackButton:draw()
	local offset = {x=0,y=0}
	if self.playerUsingNonOffensiveSkill then
		offset.x = 50; offset.y = 50
	end
	love.graphics.draw(self.button, self.pos.x + offset.x, self.pos.y + offset.y)
end;

return BackButton