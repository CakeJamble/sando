-- filename: progress_bar
Class = require 'libs.hump.class'

ProgressBar = Class{}

function ProgressBar:init(pos, width, height, min, max)
	self.pos = {
		x = pos.x,
		y = pos.y
	} 				-- pos = {x, y}
	self.min = min or 0
	self.max = max or 1

	self.containerOptions = {
		mode = 'line',
		width = width,
		height = height
	}

	self.meterOptions = {
		color = {0, 1, 0},
		mode = 'fill',
		width = width * 0.05,
		height = height * 0.95
	}
end;

function ProgressBar:draw()
	love.graphics.rectangle(self.containerOptions.mode, self.pos.x, self.pos.y, self.containerOptions.width, self.containerOptions.height)
	love.graphics.setColor(self.meterOptions.color[1], self.meterOptions.color[2], self.meterOptions.color[3])
	love.graphics.rectangle(self.meterOptions.mode, self.pos.x, self.pos.y, self.meterOptions.width, self.meterOptions.height)
	love.graphics.setColor(1, 1, 1)
end;


