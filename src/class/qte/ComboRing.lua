local Class = require('libs.hump.class')
local RingQTE = require('class.qte.Ring')

---@class ComboRing: Ring
local ComboRingQTE = Class{__includes = RingQTE}

---@param data table
function ComboRingQTE:init(data)
	RingQTE.init(self, data)
	self.combo = 0
	self.index = 1
	self.min = data.minCombo
	self.max = data.maxCombo
	self.rings = {}
end;

function ComboRingQTE:reset()
	RingQTE.reset(self)
	self.combo = 0
	self.index = 1
	self.successCount = 0
	self.signalEmitted = false
	self.rings = {}
end;

---@return Ring[]
function ComboRingQTE:makeRings()
	local rings = {}
	self.maxCombo = love.math.random(self.min, self.max)
	for i=1, self.maxCombo do
		rings[i] = self:setUI()
	end
	return rings
end;

---@param callback? fun(qteSuccess: boolean)
function ComboRingQTE:beginQTE(callback)
	if callback then
		self.rings = self:makeRings()
		self.onComplete = callback
	else
		print('there was no callback fcn provided')
	end
	local ring = self.rings[self.index]
	ring:startRevolution()
	ring.flipTween:oncomplete(function()
		ring.revolutionTween:oncomplete(function()
			self.signalEmitted = true
			self.onComplete(false)
		end)
	end)
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function ComboRingQTE:gamepadpressed(joystick, button)
	if button == self.actionButton and not self.signalEmitted then
		local ring = self.rings[self.index]
		if ring.revActive then
			self.sliceIndex = self.sliceIndex + 1
			if ring:isInHitBox() then
				print('good')
				self.successCount = self.successCount + 1
			else
				print('bad')
				-- stop QTE
				self.signalEmitted = true
				self.onComplete(false)
			end

			if self.sliceIndex > ring.numSlices then
				ring.revolutionTween:stop()
				ring.revActive = false

				if self.successCount == ring.numSlices then
					-- good
					self.combo = self.combo + 1
					if self.combo >= self.maxCombo then
						self.signalEmitted = true
						self.onComplete(true)
					else
						self.successCount = 0
						self.index = self.index + 1
						self:beginQTE()
					end
				end
			end
		end
	end
end;

function ComboRingQTE:draw()
	if not self.signalEmitted then
		self.rings[self.index]:draw()
	end
end;

return ComboRingQTE