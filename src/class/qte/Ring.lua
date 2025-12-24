local Ring = require('class.ui.Ring')
local Class = require('libs.hump.class')
local QTE = require('class.qte.QTE')
local flux = require('libs.flux')

---@class RingQTE: QTE
local RingQTE = Class{__includes =  QTE}

---@param data table
function RingQTE:init(data)
	QTE.init(self, data)
	self.data = data
	self.options = data.options
	self.flipDuration = data.flipDuration

	self.slicesData = {
		numSlices = data.numSlices,
		sliceLenRange = data.sliceLenRange,
	}
	self.revDur = data.duration

	self.successCount = 0
	self.sliceLenRange = {min = data.sliceLenRange.min, max = data.sliceLenRange.max}
	self.sliceIndex = 1
	self.onComplete = nil
end;

function RingQTE:reset()
	QTE.reset(self)
	self.sliceIndex = 1
	self.successCount = 0
	self.signalEmitted = false
end;

---@return Ring
function RingQTE:setUI()
	return Ring(self.options, self.flipDuration, self.slicesData, self.revDur)
end;

---@param actionButton string
---@param buttonUI table
function RingQTE:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
	self.instructions = "Press " .. string.upper(actionButton) .. " in the highlighted positions."
end;

---@param callback fun(qteSuccess: boolean)
function RingQTE:beginQTE(callback)
	self.ring = self:setUI()
	self.ring:startRevolution()
	self.onComplete = callback

	self.ring.flipTween:oncomplete(function()
		self.ring.revolutionTween:oncomplete(function()
			self.signalEmitted = true
			callback(false)
		end)
	end)
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function RingQTE:gamepadpressed(joystick, button)
	if button == self.actionButton and not self.signalEmitted then
		if self.ring.revActive then
			self.sliceIndex = self.sliceIndex + 1
			if self.ring:isInHitBox() then
				print('good')
				self.successCount = self.successCount + 1
			else
			print('bad')
			self.signalEmitted = true
			self.onComplete(false)
			end

			if self.sliceIndex > self.ring.numSlices then
				if not self.signalEmitted then
					self.qteComplete = true
					self.ring.revolutionTween:stop()
					self.ring.revActive = false
					local isSuccess = false
					if self.successCount == self.ring.numSlices then
						print('Ring QTE Success')
						isSuccess = true
						self:tweenFeedback()
					else
						print('Ring QTE Fail')
					end
					self.signalEmitted = true
					self.onComplete(isSuccess)
				end
			end

		end
	end


end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function RingQTE:gamepadreleased(joystick, button)
end;

---@param dt number
function RingQTE:update(dt)
end;

function RingQTE:draw()
	self.ring:draw()
end;

return RingQTE