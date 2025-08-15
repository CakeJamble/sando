--! filename: hold_sbp_qte
require('class.ui.progress_bar')
require('class.qte.qte')
local JoystickUtils = require('util.joystick_utils')

TapAnalogLeftQTE = Class{__includes = QTE}

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
end;

-- idea: set progress bar fill rate as a function of activeEntity's speed?
function TapAnalogLeftQTE:setUI(activeEntity)
	local isOffensive = activeEntity.skill.isOffensive
	local targetPos = activeEntity.pos
	self:readyCamera(targetPos)
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
end;

function TapAnalogLeftQTE:beginQTE(callback)
	self.onComplete = callback
	self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
		:oncomplete(function()
			print('failed to start in time. Attacking now')
			local qteSuccess = false
			self.doneWaiting = true
			self.qteComplete = true
			self.onComplete(qteSuccess)
		end)
end;

function TapAnalogLeftQTE:gamepadpressed(joystick, button)
	if button == 'dpleft' then
		if not self.doneWaiting then
			self.doneWaiting = true
			self.waitTween:stop()
		end
		self.tapLeftCounter = self.tapLeftCounter + 1
		local widthIncrease = (self.progressBar.containerOptions.width * 0.95) * (self.tapLeftCounter / self.maxTaps)
		local goalWidth = math.min(self.progressBar.containerOptions.width, widthIncrease)
		self.progressTween = flux.to(self.progressBar.meterOptions, 0.25, {width = goalWidth})
			:oncomplete(function()
				if self.progressBar.meterOptions.width >= (self.progressBar.containerOptions.width * 0.95) and not self.signalEmitted then
					local qteSuccess = true
					print('qte success')
					self.onComplete(qteSuccess)
					self.signalEmitted = true
				end
			end)
	end
end;

function TapAnalogLeftQTE:gamepadreleased(joystick, button)
end;

function TapAnalogLeftQTE:update(dt)
	if input.joystick then
		if JoystickUtils.isLatchedDirectionPressed(input.joystick, 'left') then
			self:gamepadpressed(input.joystick, 'dpleft')
		end
	end
end;

function TapAnalogLeftQTE:draw()
	self.progressBar:draw()
end;