--! filename: skill_ui.lua

Class = require 'libs.hump.class'
QTE = Class{}

function QTE:init(instructions, skillType)
	self.type = ''
	self.instructions = instructions
	self.instructionsPos = {x = 200, y = 80}
	self.offset = 0
end;

function QTE:draw()
	love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
end;

--[[
idea: use Flywieght Pattern

create QTE objects that can be reused (like how textures get reused) instead of instantiating a new QTE for every move based on the type of movement.

Single Button Press QTE -> only have to change the button prompted
Multi Button Press QTE -> can have the button input sequence randomized when it is selected
Stick holding -> doesn't even need to be modified
]]