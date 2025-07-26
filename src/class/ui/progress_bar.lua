-- filename: progress_bar
Class = require 'libs.hump.class'

ProgressBar = Class{}

function ProgressBar:init(targetPos, options)
	self.pos = {
		x = targetPos.x + options.xOffset,
		y = targetPos.y + options.yOffset
	} 				-- pos = {x, y}
	self.min = options.min
	self.max = options.max

	self.containerOptions = {
		mode = 'line',
		width = options.w,
		height = options.h
	}


	self.meterStartingWidth = options.w * options.wModifier
	self.meterOptions = {
		color = {0, 1, 0},
		mode = 'fill',
		width = self.meterStartingWidth,
		height = options.h * 0.95
	}
end;

function ProgressBar:reset()
	self.meterOptions.width = self.meterStartingWidth
end;

function ProgressBar:draw()
	love.graphics.rectangle(self.containerOptions.mode, self.pos.x, self.pos.y, self.containerOptions.width, self.containerOptions.height)
	love.graphics.setColor(self.meterOptions.color[1], self.meterOptions.color[2], self.meterOptions.color[3])
	love.graphics.rectangle(self.meterOptions.mode, self.pos.x, self.pos.y, self.meterOptions.width, self.meterOptions.height)
	love.graphics.setColor(1, 1, 1)
end;


