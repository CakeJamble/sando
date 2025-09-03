--! filename: hold_sbp_qte
local ProgressBar = require('class.ui.progress_bar')
local QTE = require('class.qte.qte')
local Class = require('libs.hump.class')
local Signal = require('libs.hump.signal')
local flux = require('libs.flux')
require('util.globals')

---@class HoldSBP: QTE
local HoldSBP = Class{__includes = QTE}

---@param data table
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
	self.setupComplete = false

	self.actionButton = nil
	self.isActionButtonPressed = false

	self.waitForPlayer = {
		curr = 0,
		fin = data.waitDuration
	}
end;

---@param actionButton string
---@param buttonUI table
function HoldSBP:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
	self.instructions = "Hold " .. string.upper(actionButton) .. " until the meter is filled!"
end;

---@param activeEntity Character
function HoldSBP:setUI(activeEntity)
	self.entity = activeEntity
	local isOffensive = activeEntity.skill.isOffensive
	local targetPos = activeEntity.pos
	self:readyCamera(isOffensive)

	self.progressBar = ProgressBar(targetPos, self.progressBarOptions, isOffensive)
	self.buttonUIPos.x = self.progressBar.pos.x + self.buttonUIOffsets.x
	self.buttonUIPos.y = self.progressBar.pos.y + self.buttonUIOffsets.y

	self.feedbackPos.x = targetPos.x + self.feedbackOffsets.x
	self.feedbackPos.y = targetPos.y + self.feedbackOffsets.y
end;

function HoldSBP:reset()
	QTE.reset(self)
	self.onComplete = nil
	self.actionButton = nil
	self.isActionButtonPressed = false
	self.progressBar:reset()
	self.progressBar = nil
	self.waitForPlayer.curr = 0
	self.progressBarComplete = false
	self.doneWaiting = false
	self.progressTween = nil
	self.signalEmitted = false
	self.qteComplete = false
	self.setupComplete = false
end;

--[[
1. Wait a x seconds for player to press button
	1a. If they haven't pressed it, they fail the QTE
2. After pressing, cancel the waitTween ]]
---@param callback fun(qteSuccess: boolean)
function HoldSBP:beginQTE(callback)
	self.onComplete = callback
	self.setupComplete = false
	-- print('setup complete was reset')
	flux.to(self.entity.pos, 0.5, {x = 100, y = 170})
	:oncomplete(function()
		self.setupComplete = true
		self.signalEmitted = false
		self.isActionButtonPressed = false
		self.waitTween = flux.to(self.waitForPlayer, self.waitForPlayer.fin, {curr = self.waitForPlayer.fin})
			:oncomplete(function()
					print('Failed to start in time. Attacking now.')
					local qteSuccess = false
					self.doneWaiting = true
					self.qteComplete = true
					self.instructions = nil
					self.onComplete(qteSuccess)
			end)
		end)
end;

function HoldSBP:handleQTE()
	if self.isActionButtonPressed then
		local goalWidth = self.progressBar.containerOptions.width

		local target = self.entity.targets[1]
		local yOffset = self.entity.hitbox.h - target.hitbox.h
		local tPos = target.hitbox
		local spaceFromTarget = calcSpacingFromTarget('near', 'character')

		local stagingPos = {
			x = tPos.x + spaceFromTarget.x,
			y = tPos.y - yOffset + spaceFromTarget.y
		}

		-- Zoom towards staging position
		local cameraGoalPos = {
			x = camera.x + (stagingPos.x - self.entity.oPos.x) / 10,
			y = camera.y + (stagingPos.y - self.entity.pos.y) / 2
		}
		self.cameraTween = flux.to(camera, self.duration, {x = cameraGoalPos.x, y = cameraGoalPos.y, scale = 1.25}):ease('linear')

		self.stagingTween = flux.to(self.entity.pos, self.duration, {x = stagingPos.x, y = stagingPos.y})
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
							self.onComplete(false)
						end
					end)
			end)
	end
end;

---@param joystick string
---@param button string
function HoldSBP:gamepadpressed(joystick, button)
	if button == self.actionButton and self.setupComplete and not self.signalEmitted and not self.isActionButtonPressed then
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

---@param joystick string
---@param button string
function HoldSBP:gamepadreleased(joystick, button)
	if button == self.actionButton and self.setupComplete and self.isActionButtonPressed then
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
					self.onComplete(false)
				end
			else
				print('Hold SBP QTE Success')
				self.waitTween:stop()
				self:tweenFeedback()
				local qteSuccess = true
				Signal.emit('OnQTEResolved', qteSuccess)
				self.signalEmitted = true
				self.onComplete(qteSuccess)
			end
		end
	end
end;

---@param dt number
function HoldSBP:update(dt)
end;

function HoldSBP:draw()
	QTE.draw(self)
	if not self.qteComplete then
		self.progressBar:draw()
		-- love.graphics.setColor(0, 0, 0)
		love.graphics.circle('fill', self.buttonUIPos.x + 32, self.buttonUIPos.y + 32, 25)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.buttonUI[self.buttonUIIndex], self.buttonUIPos.x + 14, self.buttonUIPos.y + 14, 0,
			self.buttonUIScale, self.buttonUIScale)
	end
end;

return HoldSBP