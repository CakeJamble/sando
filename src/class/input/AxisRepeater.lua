local Class = require('libs.hump.class')

---@class AxisRepeater
local AxisRepeater = Class{}

---@param opts table?
function AxisRepeater:init(opts)
	opts = opts or {}

	self.threshold = opts.threshold or 0.5
	self.initialDelay = opts.initialDelay or 0.4
	self.repeatDelay = opts.repeatDelay or 0.1
	self.timer = 0
	self.direction = 0
	self.fired = false
end;

---@param axisValue number
---@param dt number
function AxisRepeater:update(axisValue, dt)
	local absVal = math.abs(axisValue)

	if absVal < self.threshold then
		self.timer = 0
		self.fired = false
		self.direction = 0
		return 0
	end

	local dir = axisValue > 0 and 1 or -1

	if not self.fired or dir ~= self.direction then
		self.direction = dir
		self.fired = true
		self.timer = self.initialDelay
		return dir
	end

	self.timer = self.timer - dt

	if self.timer <= 0 then
		self.timer = self.repeatDelay
		return dir
	end

	return 0
end;

return AxisRepeater