require('class.ui.ring')
RingQTE = Class{__includes =  QTE}

function RingQTE:init(data)
	QTE.init(self, data)
	self.options = data.options
	self.flipDuration = data.flipDuration

	local slicesData = {
		numSlices = data.numSlices,
		sliceLenRange = data.sliceLenRange,
	}

	self.ring = Ring(data.options, self.flipDuration, slicesData, data.duration)
	self.successCount = 0
	self.sliceLenRange = {min = data.sliceLenRange.min, max = data.sliceLenRange.max}
	self.sliceIndex = 1
end;

function RingQTE:setUI(activeEntity)
	-- need to rework this
end;

function RingQTE:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
	self.instructions = "Press " .. string.upper(actionButton) .. " in the highlighted positions."
end;

function RingQTE:beginQTE()
	self.ring:startRevolution()
end;

function RingQTE:gamepadpressed(joystick, button)
	if button == self.actionButton then
		if self.ring.line.isActive and self.ring:isInHitBox() then
			print('good')
			self.successCount = self.successCount + 1
		else
			print('bad')
		end
		self.sliceIndex = self.sliceIndex + 1
	end

	if self.sliceIndex > self.ring.numSlices then
		if not self.signalEmitted then
			self.qteComplete = true
			self.ring.revolutionTween:stop()
			
			if self.successCount == self.ring.numSlices then
				print('Ring QTE Success')
				flux.to(self.feedbackPos, 1, {a = 0}):delay(1)
					:oncomplete(function() self.feedbackPos.a = 1 end)
				Signal.emit('OnQTESuccess')
			else
				print('Ring QTE Fail')
			end
			Signal.emit('Attack')
			self.signalEmitted = true
		end
	end
end;

function RingQTE:gamepadreleased(joystick, button)
end;

function RingQTE:update(dt)
end;

function RingQTE:draw()
	self.ring:draw()
end;

