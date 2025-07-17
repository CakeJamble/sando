--! filename: hold_sbp_qte
require('class.ui.progress_bar')
require('class.qte.qte')

TapAnalogLeftQTE = Class{__includes = QTE}

function TapAnalogLeftQTE:init()
	local pbPos = {x=0,y=0}
	self.progressBar = ProgressBar(pbPos, 100, 35, 0, 100, 0.05)
	self.waitTween = nil
	self.doneWaiting = false
	self.progressTween = nil
	self.progressBarComplete = false
	self.qteButton = nil
	self.instructions = 'Tap the Analog Stick left to charge up the meter.'
	self.duration = 2
	self.waitForPlayer {curr = 0, fin = 1}
	self.isAnalogHeldLeft = false
	self.signalEmitted = false

	self.greatText = love.graphics.newImage(QTE.feedbackDir .. 'great.png')
	self.showGreatText = false
	self.buttonUI = nil
	self.buttonUIPos = {
		x = pbPos.x + 100,
		y = pbPos.y
	}
end;

function TapAnalogLeftQTE:setUI(activeEntity)
	local pos = activeEntity.pos
	self.progressBar.pos.x = pos.x + 75
	self.progressBar.pos.y = pos.y - 75
	self.buttonUIPos.x = self.progressBar.pos.x + 75
	self.buttonUIPos.y = self.progressBar.pos.y - 25
	self.feedbackPos.x = pos.x + 25
	self.feedbackPos.y = pos.y - 25
end;

function TapAnalogLeftQTE:reset()
	QTE.reset(self)
	self.showGreatText = false
	self.actionButton = nil
	self.progressBar:reset()
	self.waitForPlayer.curr = 0
	self.progressBarComplete = false
	self.doneWaiting = false
	self.progressTween = nil
	self.feedbackPos.a = 1
	self.qteComplete = false
	self.signalEmitted = false
end;

function TapAnalogLeftQTE:update(dt)
	if self.doneWaiting and not self.signalEmitted then
		Signal.emit('Attack')
		self.signalEmitted = true
	end
end;

function TapAnalogLeftQTE:beginQTE()
	self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
		:oncomplete(function()
			print('failed to start in time. Attacking now')
			local qteSuccess = false
			self.doneWaiting = true
			self.qteComplete = true
		end)
end;

function TapAnalogLeftQTE:gamepadpressed(joystick, button)
	-- get axis, if its left then tween the designated amount
end;