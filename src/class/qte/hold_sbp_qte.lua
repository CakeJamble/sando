--! filename: hold_sbp_qte
require('class.ui.progress_bar')
require('class.qte.qte')
HoldSBP = Class{__includes = QTE}

function HoldSBP:init(data)
	-- progress bar
	QTE.init(self, data)
	-- self.progressBar = ProgressBar(pbPos, 100, 35, 0, 100, 0.05)
	self.progressBarOptions = data.progressBarOptions
	self.buttonUIOffsets = data.buttonUIOffsets
	self.buttonUI = nil
	self.buttonUIIndex = 'raised'
	self.buttonUIPos = {x=0,y=0}

	self.waitTween = nil
	self.progressTween = nil
	self.progressBarComplete = false
	
	self.actionButton = nil
	self.isActionButtonPressed = false
	
	self.waitForPlayer = {
		curr = 0,
		fin = data.waitDuration
	}
end;

function HoldSBP:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
	self.instructions = "Hold " .. string.upper(actionButton) .. " until the meter is filled!"
end;

function HoldSBP:setUI(activeEntity)
	local isOffensive = activeEntity.skill.isOffensive
	local targetPos = activeEntity.pos
	self:readyCamera(targetPos)

	self.progressBar = ProgressBar(targetPos, self.progressBarOptions, isOffensive)
	self.buttonUIPos.x = self.progressBar.pos.x + self.buttonUIOffsets.x
	self.buttonUIPos.y = self.progressBar.pos.y + self.buttonUIOffsets.y

	self.feedbackPos.x = targetPos.x + self.feedbackOffsets.x
	self.feedbackPos.y = targetPos.y + self.feedbackOffsets.y
end;

function HoldSBP:reset()
	QTE.reset(self)
	self.actionButton = nil
	self.progressBar = nil
	-- self.progressBar:reset()
	self.waitForPlayer.curr = 0
	self.progressBarComplete = false
	self.doneWaiting = false
	self.progressTween = nil
end;

function HoldSBP:update(dt)
	if self.doneWaiting and not self.signalEmitted then
		Signal.emit('Attack')
		self.signalEmitted = true
	end
end;

--[[
1. Wait a x seconds for player to press button
	1a. If they haven't pressed it, they fail the QTE
2. After pressing, cancel the waitTween ]]
function HoldSBP:beginQTE(callback)
	self.onComplete = callback
	self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
		:oncomplete(function()
				print('Failed to start in time. Attacking now.')
				local qteSuccess = false
				self.doneWaiting = true
				self.qteComplete = true
				self.instructions = nil
				self.onComplete(qteSuccess)
		end)
end;

function HoldSBP:handleQTE()
	if self.isActionButtonPressed then
		local goalWidth = self.progressBar.containerOptions.width
		print('starting progress tween')
		
		-- Start here because QTE happens alongside movement dictated by action's logic
		self.onComplete()

		local goalPosX = self.cameraReturnPos.x
		local goalPosY = self.cameraReturnPos.y

		if self.focusSelf then
			goalPosX = goalPosX - 100
			goalPosY = goalPosY + 30
		else
			goalPosX = goalPosX + 100
			goalPosY = goalPosY - 30
		end
		self.cameraTween = flux.to(camera, self.duration, {x = goalPosX, y = goalPosY,scale = 1.25}):ease('linear')
		self.progressTween = flux.to(self.progressBar.meterOptions, self.duration, {width = goalWidth}):ease('linear')
			:onupdate(function()
				if self.progressBar.meterOptions.width >= goalWidth * 0.9 then
					self.progressBarComplete = true
					self.buttonUIIndex = 'raised'
				end
			end)
			:oncomplete(function()
				self.progressBarComplete = true
				self.waitForPlayer.curr = 0
				self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
					:oncomplete(function()
						self.qteComplete = true
						if not self.signalEmitted then
							print('Failed to end in time. Attacking now')
							Signal.emit('OnQTEResolved', false)
							self.signalEmitted = true
						end
					end)
			end)
	end
end;

function HoldSBP:gamepadpressed(joystick, button)
	if button == self.actionButton then
		self.isActionButtonPressed = true
		self.buttonUIIndex = 'pressed'

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
		self.isActionButtonPressed = true
		if self.progressTween then
			print('stopping progress tween')
			self.progressTween:stop()
			if not self.progressBarComplete then
				if not self.signalEmitted then
					print('Ended too early. Attacking now')
					local qteSuccess = false
					Signal.emit('OnQTEResolved', qteSuccess)
					self.signalEmitted = true
				end
			elseif not self.qteComplete then
				print('Hold SBP QTE Success')
				self.waitTween:stop()
				self.showFeedback = true
				flux.to(self.feedbackPos, 1, {a = 0}):delay(1)
					:oncomplete(function() self.feedbackPos.a = 1 end)
				if not self.signalEmitted then
					local qteSuccess = true
					Signal.emit('OnQTEResolved', qteSuccess)
					self.signalEmitted = true
				end
			end
		end
	end
end;

function HoldSBP:draw()
	QTE.draw(self)
	if not self.qteComplete then
		camera:detach()
		self.progressBar:draw()
		-- love.graphics.setColor(0, 0, 0)
		love.graphics.circle('fill', self.buttonUIPos.x + 32, self.buttonUIPos.y + 32, 25)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.buttonUI[self.buttonUIIndex], self.buttonUIPos.x + 14, self.buttonUIPos.y + 14, 0, self.buttonUIScale, self.buttonUIScale)
		camera:attach()
	end
end;
