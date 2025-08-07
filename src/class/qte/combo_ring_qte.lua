require('class.qte.ring_qte')
ComboRingQTE = Class{__includes = RingQTE}

function ComboRingQTE:init(data)
	RingQTE.init(self, data)
	self.combo = 0
	self.index = 1
	self.maxCombo = data.maxCombo
	self.rings = {}
end;

function ComboRingQTE:makeRings()
	local rings = {}
	for i=1, self.maxCombo do
		rings[i] = self:setUI()
	end
	return rings
end;

function ComboRingQTE:beginQTE(callback)
	if callback then
		self.rings = self:makeRings()
		self.onComplete = callback
	end
	local ring = self.rings[self.index]
	ring:startRevolution()
	ring.flipTween:oncomplete(function()
		ring.revolutionTween:oncomplete(function()
			self.signalEmitted = true
			callback(false)
		end)
	end)

end;

function ComboRingQTE:gamepadpressed(joystick, button)
	if button == self.actionButton then
		local ring = self.rings[self.index]
		if ring.revActive then
			self.sliceIndex = self.sliceIndex + 1
			if ring:isInHitBox() then
				print('good')
				self.successCount = self.successCount + 1
			else
				print('bad')
				-- stop QTE
				self.onComplete(false)
				self.signalEmitted = true
			end

			if self.sliceIndex > ring.numSlices then
				ring.revolutionTween:stop()
				ring.revActive = false

				if self.successCount == ring.numSlices then
					-- good
					self.combo = self.combo + 1
					if self.combo >= self.maxCombo then
						self.onComplete(true)
						self.signalEmitted = true
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