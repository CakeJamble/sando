--! filename: hold_sbp_qte
require('class.ui.progress_bar')
require('class.qte.qte')

HoldSBP = Class{__includes = QTE}

function HoldSBP:init()
	-- progress bar
	QTE.init(self)
	self.qteComplete = false
	local pbPos = {x = 100, y = 300}
	self.progressBar = ProgressBar(pbPos, 100, 35, 0, 100)
	self.waitTween = nil
	self.doneWaiting = false
	self.progressTween = nil
	self.progressBarComplete = false
	self.actionButton = nil
	self.qteButton = nil
	self.instructions = nil
	self.duration = 2
	self.waitForPlayer = {
		start = 0,
		curr = 0,
		fin = 1
	}

	-- qte feedback
	self.greatText = love.graphics.newImage(QTE.feedbackDir .. 'great.png')
	self.showGreatText = false
	self.buttonUI = nil
	self.buttonUIPos = {
		x = pbPos.x + 100,
		y = pbPos.y
	}
	self.isActionButtonPressed = false
	self.signalEmitted = false
end;

function HoldSBP:setFeedback(isSuccess)
	if isSuccess then
		self.showGreatText = true
		self.countFeedbackFrames = true
	end
end;

function HoldSBP:reset()
	QTE.reset(self)
	self.showGreatText = false
	self.actionButton = nil
end;

function HoldSBP:update(dt)
	QTE.update(self, dt)
	if self.currFeedbackFrame > self.numFeedbackFrames then
		self.showGreatText = false
	end
end;

--[[
1. Wait a 2 seconds for player to press button
	1a. If they haven't pressed it, they fail the QTE
2. After pressing, begin tweening progress bar
3. Once progress bar is complete, wait 0.5 seconds for them to release button
	3a. If they haven't released it, they fail the QTE
4. Reward for doing qte?]]
function HoldSBP:beginQTE()
	self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
		:oncomplete(function()
				print('Failed to start in time. Attacking now.')
				Signal.emit('Attack')
		end)
end;

function HoldSBP:handleQTE()
	if self.isActionButtonPressed then
		local goalWidth = self.progressBar.containerOptions.width
		print('starting progress tween')
		self.progressTween = flux.to(self.progressBar.meterOptions, self.duration, {width = goalWidth}):ease('linear')
			:onupdate(function()
				if self.progressBar.meterOptions.width >= goalWidth * 0.9 then
					self.progressBarComplete = true -- close enough
					self.buttonUI = self.qteButton.raised
				end
			end)
			:oncomplete(function()
				self.progressBarComplete = true
				self.waitForPlayer.curr = self.waitForPlayer.start
				flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
					:oncomplete(function()
						self.qteComplete = true
						if not self.signalEmitted then
							print('Failed to end in time. Attacking now')
							Signal.emit('Attack')
							self.signalEmitted = true
						end
					end)
			end)
	end
end;

function HoldSBP:setUI(entityPos)
	-- self.showPrompt = true
	self.buttonUIPos.x = entityPos.x + 100
	self.buttonUIPos.y = entityPos.y + 100
	self.progressBar.pos.x = entityPos.x + 25
	self.progressBar.pos.y = entityPos.y + 115
	self.feedbackPos.x = self.buttonUIPos.x + 25
	self.feedbackPos.y = self.buttonUIPos.y - 25
end;


function HoldSBP:gamepadpressed(joystick, button)
	if button == self.actionButton then
		self.isActionButtonPressed = true
		self.buttonUI = self.qteButton.pressed

		if self.waitForPlayer.curr < self.waitForPlayer.fin then
			self.waitTween:stop()
			print('stopped wait tween')
			self.doneWaiting = true
			self:handleQTE()
		end
	end
end;

function HoldSBP:gamepadreleased(joystick, button)
	if button == self.actionButton then
		print('stopping progress tween')
		self.progressTween:stop()
		if not self.progressBarComplete then
			if not self.signalEmitted then
				print('Ended too early. Attacking now')
				Signal.emit('Attack')
				self.signalEmitted = true
			end
		elseif not self.qteComplete then
			print('Hold SBP QTE Success')
			self.showGreatText = true
			if not self.signalEmitted then
				Signal.emit('Attack')
				self.signalEmitted = true
			end
		end
		self.isActionButtonPressed = false
	end
end;

function HoldSBP:draw()
	if self.showGreatText then
		love.graphics.draw(self.greatText, self.feedbackPos.x, self.feedbackPos.y)
	end
	if self.instructions ~= nil then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
		love.graphics.setColor(1, 1, 1)
	end
	if not self.qteComplete then
		self.progressBar:draw()
	end

	love.graphics.setColor(0, 0, 0)
	love.graphics.circle('fill', self.buttonUIPos.x + 32, self.buttonUIPos.y + 32, 25)
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.buttonUI, self.buttonUIPos.x, self.buttonUIPos.y, 0, 0.5, 0.5)
end;
