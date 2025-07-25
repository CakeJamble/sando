--! filename: hold_sbp_qte
require('class.ui.progress_bar')
require('class.qte.qte')

HoldSBP = Class{__includes = QTE}

function HoldSBP:init()
	-- progress bar
	QTE.init(self)
	self.skill = nil
	self.qteComplete = false
	local pbPos = {x = 100, y = 100}
	self.progressBar = ProgressBar(pbPos, 100, 35, 0, 100, 0.05)
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

function HoldSBP:setUI(activeEntity)
	local targetPos = activeEntity.target.pos
	self.progressBar.pos.x = targetPos.x - 75
	self.progressBar.pos.y = targetPos.y + 100
	self.buttonUIPos.x = self.progressBar.pos.x + 75
	self.buttonUIPos.y = self.progressBar.pos.y - 15
	self.feedbackPos.x = targetPos.x + 25
	self.feedbackPos.y = targetPos.y - 25
end;

function HoldSBP:reset()
	QTE.reset(self)
	self.showGreatText = false
	self.actionButton = nil
	self.progressBar:reset()
	self.waitForPlayer.curr = 0
	self.progressBarComplete = false
	self.doneWaiting = false
	self.progressTween = nil
	self.qteComplete = false
	self.signalEmitted = false
end;

function HoldSBP:update(dt)
	QTE.update(self, dt)
	if self.currFeedbackFrame > self.numFeedbackFrames then
		self.showGreatText = false
	end

	if self.doneWaiting and not self.signalEmitted then
		Signal.emit('Attack')
		self.signalEmitted = true
	end
end;

--[[
1. Wait a x seconds for player to press button
	1a. If they haven't pressed it, they fail the QTE
2. After pressing, cancel the waitTween ]]
function HoldSBP:beginQTE()
	self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
		:oncomplete(function()
				print('Failed to start in time. Attacking now.')
				local qteSuccess = false
				self.doneWaiting = true
				self.qteComplete = true
				self.instructions = nil
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
							local qteSuccess = false
							-- Signal.emit('Attack', qteSuccess)
							self.signalEmitted = true
						end
					end)
			end)
	end
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
		self.isActionButtonPressed = false
		if self.progressTween then
			print('stopping progress tween')
			self.progressTween:stop()
			if not self.progressBarComplete then
				if not self.signalEmitted then
					print('Ended too early. Attacking now')
					local qteSuccess = false
					-- Signal.emit('Attack', qteSuccess)
					-- self.signalEmitted = true
				end
			elseif not self.qteComplete then
				print('Hold SBP QTE Success')
				self.showGreatText = true
				flux.to(self.feedbackPos, 1, {a = 0}):delay(1)
					:oncomplete(function() self.feedbackPos.a = 1 end)
				if not self.signalEmitted then
					local qteSuccess = true
					-- Signal.emit('Attack', qteSuccess)
					Signal.emit('OnQTESuccess')
					self.signalEmitted = true
				end
			end
		end
	end
end;

function HoldSBP:draw()
	if self.showGreatText then
		love.graphics.setColor(1,1,1, self.feedbackPos.a)
		love.graphics.draw(self.greatText, self.feedbackPos.x, self.feedbackPos.y)
		love.graphics.setColor(1,1,1,1)
	end
	if self.instructions ~= nil then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
		love.graphics.setColor(1, 1, 1)
	end
	if not self.qteComplete then
		self.progressBar:draw()
		-- love.graphics.setColor(0, 0, 0)
		love.graphics.circle('fill', self.buttonUIPos.x + 32, self.buttonUIPos.y + 32, 25)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.buttonUI, self.buttonUIPos.x + 16, self.buttonUIPos.y + 16)
	end
end;
