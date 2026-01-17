local Class = require 'libs.hump.class'

---@type ProgressBar
local ProgressBar = Class{}

function ProgressBar:init(targetPos, options, isOffensive, color)
	self.active = true
	self.pos = {
		x = targetPos.x + options.xOffset,
		y = targetPos.y + options.yOffset
	}
	self.offsets = {x=options.xOffset, y=options.yOffset}
	self.min = options.min
	self.max = options.max

	self.containerOptions = {
		mode = 'line',
		width = options.w,
		height = options.h
	}

	self.meterStartingWidth = options.w * options.wModifier
	self.meterOptions = {
		color = color or {0, 1, 0},
		mode = 'fill',
		width = self.meterStartingWidth,
		height = options.h * 0.95,
		value = 0
	}

	if not isOffensive then
		self:reversePosOffsets()
	end
	self.mult = options.w / options.max
end;

function ProgressBar:reversePosOffsets()
	self.pos.x = self.pos.x - 2 * self.offsets.x
	self.pos.y = self.pos.y - self.offsets.y
end;

function ProgressBar:increaseMeter(amount)
	self.meterOptions.value = math.min(self.max, self.meterOptions.value + amount)
	return self.meterOptions.value
end;

function ProgressBar:decreaseMeter(amount)
	self.meterOptions.value = math.max(self.min, self.meterOptions.value - amount)
end;

function ProgressBar:setPos(pos)
	self.pos.x = pos.x + self.offsets.x
	self.pos.y = pos.y + self.offsets.y
end;

function ProgressBar:reset()
	self.meterOptions.width = self.meterStartingWidth
	self.meterOptions.value = 0
end;

function ProgressBar:draw()
	love.graphics.rectangle(self.containerOptions.mode, self.pos.x, self.pos.y,
		self.containerOptions.width, self.containerOptions.height)
	love.graphics.setColor(self.meterOptions.color[1], self.meterOptions.color[2], self.meterOptions.color[3])
	love.graphics.rectangle(self.meterOptions.mode, self.pos.x, self.pos.y,
		self.meterOptions.width, self.meterOptions.height)
	love.graphics.setColor(1, 1, 1)
end;

return ProgressBar