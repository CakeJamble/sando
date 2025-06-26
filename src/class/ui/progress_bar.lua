-- filename: progress_bar
Class = require 'libs.hump.class'

ProgressBar = Class{}

function ProgressBar:init(pos, width, height, min, max, rate)
	self.pos = pos 				-- pos = {x, y}
	self.min = min or 0
	self.max = max or 1
	self.rate = rate or 0.1

	self.containerOptions = {
		mode = 'line',
		width = width,
		height = height
	}
	self.meterOptions = {
		color = {0, 1, 0}
		mode = 'fill',
		width = width * 0.95,
		height = height * 0.95
	}
end;

function ProgressBar:update(dt)
	self.meterOptions.width = math.max(self.min, self.curr - self.rate * dt)
	if self.meterOptions.width < 0.3 * self.max then
		self.meterOptions.color = {1, 0, 0} -- red
	end
end;

function ProgressBar:draw()
	love.graphics.rectangle(containerOptions.mode, pos.x, pos.y, containerOptions.width, containerOptions.height)
	love.graphics.setColor(self.meterOptions.color[0], self.meterOptions.color[1], self.meterOptions.color[2])
	love.graphics.rectangle(meterOptions.mode, self.pos.x, self.pos.y, self.meterOptions.width, self.meterOptions.height)
	love.graphics.setColor(1, 1, 1)
end;


