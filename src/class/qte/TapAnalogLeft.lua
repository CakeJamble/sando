--! filename: hold_sbp_qte
local ProgressBar = require('class.ui.ProgressBar')
local QTE = require('class.qte.QTE')
local JoystickUtils = require('util.joystick_utils')
local Class = require('libs.hump.class')
local flux = require('libs.flux')

---@class TapAnalogLeftQTE: QTE
local TapAnalogLeftQTE = Class{__includes = QTE}

---@param data table
function TapAnalogLeftQTE:init(data)
	QTE.init(self, data)
	self.progressBarOptions = data.progressBarOptions
	self.buttonUIOffsets = data.buttonUIOffsets
	self.buttonUI = nil
	self.buttonUIIndex = 'neutral'
	self.waitTween = nil
	self.progressTween = nil
	self.progressBarComplete = false
	self.instructions = 'Tap the Analog Stick left to charge up the meter.'
	self.waitForPlayer = {curr = 0, fin = data.waitDuration}
	self.tapLeftCounter = 0
	self.maxTaps = 10
	self.onComplete = nil
	self.qteSuccess = false

	-- Every tap, the meter increases by 1/self.maxTaps
	self.increaseAmount = data.progressBarOptions.max / self.maxTaps

	-- Every second, the meter decreases by the 6 * increaseAmount
	self.decreaseAmount = data.progressBarOptions.max / (10 * self.maxTaps)
end;

-- idea: set progress bar fill rate as a function of activeEntity's speed?
---@param activeEntity Character
function TapAnalogLeftQTE:setUI(activeEntity)
	local isOffensive = activeEntity.skill.isOffensive
	local targetPos = activeEntity.pos
	self:readyCamera(isOffensive)
	self.progressBar = ProgressBar(targetPos, self.progressBarOptions, isOffensive)
	self.buttonUIPos.x = self.progressBar.pos.x + self.buttonUIOffsets.x
	self.buttonUIPos.y = self.progressBar.pos.y + self.buttonUIOffsets.y

	self.feedbackPos.x = targetPos.x + self.feedbackOffsets.x
	self.feedbackPos.y = targetPos.y + self.feedbackOffsets.y

end;

function TapAnalogLeftQTE:reset()
	QTE.reset(self)
	self.progressBar = nil
	self.waitForPlayer.curr = 0
	self.progressBarComplete = false
	self.doneWaiting = false
	self.progressTween = nil
	self.waitTween = nil
	self.onComplete = nil

	self.buttonUIPos.x = self.buttonUIPos.x - self.buttonUIOffsets.x
	self.buttonUIPos.y = self.buttonUIPos.y - self.buttonUIOffsets.y
	self.feedbackPos.x = self.feedbackPos.x - self.feedbackOffsets.x
	self.feedbackPos.y = self.feedbackPos.y - self.feedbackOffsets.y
end;

---@param callback fun(qteSuccess: boolean)
function TapAnalogLeftQTE:beginQTE(callback)
	self.onComplete = callback
	self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
		:oncomplete(function()
			self.doneWaiting = true
			if self.progressBar.meterOptions.value >= self.progressBar.containerOptions.width * 0.8 then
				self.qteComplete = true
				print('qte success')
			end
			self.signalEmitted = true
			self.onComplete(self.qteSuccess)
		end)
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function TapAnalogLeftQTE:gamepadpressed(joystick, button)
	if button == 'dpleft' and not self.signalEmitted then
		local goalWidth = self.progressBar:increaseMeter(self.increaseAmount)
		self.progressTween = flux.to(self.progressBar.meterOptions, 0.25, {width = goalWidth})
			:oncomplete(function() self.progressTween = nil; end)
	end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function TapAnalogLeftQTE:gamepadreleased(joystick, button)
end;

---@param dt number
function TapAnalogLeftQTE:update(dt)
	if input.joystick then
		if JoystickUtils.isLatchedDirectionPressed(input.joystick, 'left') then
			self:gamepadpressed(input.joystick, 'dpleft')
		end
	end
	if not self.signalEmitted and not self.progressTween then
		self.progressBar:decreaseMeter(self.decreaseAmount)
		flux.to(self.progressBar.meterOptions, 0.1, {width = self.progressBar.meterOptions.value})
	end
end;

function TapAnalogLeftQTE:draw()
	if not self.signalEmitted then
		self.progressBar:draw()
	end
end;

return TapAnalogLeftQTE