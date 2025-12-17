--! filename: mbp_qte.lua
local QTE = require('class.qte.qte')
local ProgressBar = require('class.ui.progress_bar')
local Class = require 'libs.hump.class'
local Signal = require('libs.hump.signal')
local flux = require('libs.flux')
--[[ mbpQTE: Multi Button Press QTE
	- QTE for skills that require multiple button presses within a given duration
	]]

---@class mbpQTE: QTE
local mbpQTE = Class{__includes = QTE}

---@param data table
function mbpQTE:init(data)
	QTE.init(self, data)
	self.uiInitialized = false
	self.inputSequenceLength = 4
	self.type = 'mbp'
	self.pos = {x = nil, y = nil}
	self.waitTween = nil
	self.progressTween = nil
	-- progress bar
	self.progressBarOptions = data.progressBarOptions
	-- local pbPos = {100, 300}
	-- self.progressBar = ProgressBar(pbPos, 100, 35, 0, 100, 0.95)
	self.progressBarComplete = false

	self.waitForPlayer = {
		curr = 0,
		fin = data.waitDuration
	}

	-- face buttons
	self.buttonsStr = data.buttons
	self.buttons = nil
	self.currentButton = nil
	self.inputSequence = {}
	self.buttonsIndex = 1

	-- rectangle container for input sequence
	self.inputSequenceContainerDims = data.inputContainerOptions
	self.alphas = {}
	self.baseY = data.baseY
	self.baseX = data.baseX
	self.offset = 45
	-- circle holding the current (at the bottom of the rectangle container)
	self.currentInputContainerDims = data.currentInputContainerOptions
end;

--[[Creates input sequence and inserts the face button images into input sequence]]
---@param buttons table[]
function mbpQTE:createInputSequence(buttons)
	for i=1,self.inputSequenceLength do
		local randButton = self.buttonsStr[love.math.random(#self.buttonsStr)]
		table.insert(self.inputSequence, buttons[randButton])
		self.alphas[i] = 1
	end
end;

---@param activeEntity Character
function mbpQTE:setUI(activeEntity)
	local isOffensive = activeEntity.skill.isOffensive
	self.entity = activeEntity
	self:readyCamera(isOffensive)

	local tPos = activeEntity.pos
	self.progressBar = ProgressBar(tPos, self.progressBarOptions, isOffensive)

	self.inputSequenceContainerDims.x = self.inputSequenceContainerDims.x + self.progressBar.pos.x
	self.inputSequenceContainerDims.y = self.inputSequenceContainerDims.y + self.progressBar.pos.y
	self.currentInputContainerDims.x = self.inputSequenceContainerDims.x + (self.inputSequenceContainerDims.w / 2)
	self.currentInputContainerDims.y = self.inputSequenceContainerDims.y + self.inputSequenceContainerDims.h * 0.9
	self.baseY = self.baseY + self.currentInputContainerDims.y

	self.feedbackPos.x = self.currentInputContainerDims.x + 25
	self.feedbackPos.y = self.baseY - 5
end;

---@param callback fun(qteSuccess: boolean)
function mbpQTE:beginQTE(callback)
	self.onComplete = callback
	flux.to(self.entity.pos, 0.5, {x = 100, y = 170})
	:oncomplete(function()
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

function mbpQTE:handleQTE()
	local goalWidth = 0
	print('starting progress tween')

	-- Zoom down and to the left slightly
	local cameraGoalPos = {
		x = camera.x - self.entity.pos.x * 2,
		y = camera.y + self.entity.pos.y / 2
	}
	self.cameraTween = flux.to(camera, self.duration,
		{x = cameraGoalPos.x, y = cameraGoalPos.y, scale = 1.25})

	self.progressTween = flux.to(self.progressBar.meterOptions, self.duration, {width = goalWidth}):ease('linear')
		:oncomplete(function()
			self.progressBarComplete = true
			self.waitForPlayer.curr = self.waitForPlayer.start
		end)
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function mbpQTE:gamepadpressed(joystick, button)
	if not self.qteComplete and button == self.inputSequence[self.buttonsIndex].val then
		self.alphas[self.buttonsIndex] = 0
		self:moveInputSequenceDown() -- adjust for different layout
		if not self.doneWaiting then
			print('stopping wait tween')
			self.waitTween:stop()
			self.doneWaiting = true
			self:handleQTE()
		elseif not self.progressBarComplete then
			print('Hit the correct button')
		end
		self.buttonsIndex = self.buttonsIndex + 1

		if self.buttonsIndex > self.inputSequenceLength then
			self.cameraTween:stop()
			print('MBP QTE Success')
			self.progressTween:stop()
			self:tweenFeedback()
			Signal.emit('OnQTESuccess')
			self.signalEmitted = true
			self.qteComplete = true
			self.onComplete(true)
		end
	end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function mbpQTE:gamepadreleased(joystick, button)
end;

-- For vertically oriented version of QTE
function mbpQTE:moveInputSequenceDown()
	self.baseY = self.baseY + self.offset
end;

-- For horizontally oriented version of QTE
function mbpQTE:moveInputSequenceLeft()
	self.baseX = self.baseX - self.offset
end;

function mbpQTE:reset()
	QTE.reset(self)
	self.inputSequence = {}
	self.alphas = {}
	self.baseY = self.baseY - (self.buttonsIndex * self.offset)
	self.buttonsIndex = 1
	self.progressBar:reset()
	self.doneWaiting = false
	self.progressBarComplete = false
	self.qteComplete = false

	self.inputSequenceContainerDims.x = self.inputSequenceContainerDims.x - self.progressBar.pos.x
	self.inputSequenceContainerDims.y = self.inputSequenceContainerDims.y - self.progressBar.pos.y
	self.currentInputContainerDims.x = self.inputSequenceContainerDims.x - (self.inputSequenceContainerDims.w / 2)
	self.currentInputContainerDims.y = self.inputSequenceContainerDims.y - self.inputSequenceContainerDims.h * 0.9
	self.baseY = self.baseY - self.currentInputContainerDims.y

	self.feedbackPos.x = self.currentInputContainerDims.x - 25
	self.feedbackPos.y = self.baseY + 5

	-- temp fix :(
	self.baseY = -20
end;

---@param dt number
function mbpQTE:update(dt)
end;

function mbpQTE:draw()
	-- if self.showPrompt and self.frameWindow then
	-- 	love.graphics.draw(self.actionButtonQTE, self.instructionsPos.x, self.instructionsPos.y, 0, 0.75, 0.75)
	-- end
	QTE.draw(self)
	if not self.qteComplete then
		love.graphics.push()
		love.graphics.translate(0, 100) -- slight adjustment
		self.progressBar:draw()
		love.graphics.rectangle('fill', self.inputSequenceContainerDims.x, self.inputSequenceContainerDims.y,
			self.inputSequenceContainerDims.w, self.inputSequenceContainerDims.h)
		love.graphics.setColor(0,1,0)
		love.graphics.circle('fill', self.currentInputContainerDims.x, self.currentInputContainerDims.y,
			self.currentInputContainerDims.r)
		love.graphics.setColor(1,1,1)
		self:drawInputButtons()
		love.graphics.pop()
	end
end;

function mbpQTE:drawInputButtons()
	for i,button in ipairs(self.inputSequence) do
		local yOffset = self.offset * (i-1)
		local rotation = 0
		local xOffset = 20
		love.graphics.print(button.val, xOffset, yOffset)
		if i >= self.buttonsIndex then
			love.graphics.draw(button.raised, self.currentInputContainerDims.x - xOffset, self.baseY - yOffset,
				rotation, self.buttonUIScale)
		end
	end
end;

return mbpQTE