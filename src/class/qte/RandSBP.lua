local QTE = require('class.qte.QTE')
local fireParticles = require 'asset.particle.small_fire'
local Class = require('libs.hump.class')
local Timer = require('libs.hump.timer')
local Signal = require('libs.hump.signal')
local flux = require('libs.flux')

---@class randSBP: QTE
local randSBP = Class{__includes = QTE}

---@param data table
function randSBP:init(data)
	QTE.init(self, data)
	self.type = 'randSBP'
	self.displayButton = false
	self.doneWaiting = false
	self.circleGreenVals = {0,0,0}
	self.smallCircleOptions = data.smallCircleOptions
	self.timeBtwnLights = data.timeBtwnLights
	self.largeCircleScale = data.largeCircleScale
	self.waitDuration = data.waitDuration
	self.actionButton = nil
	self.buttonUI = nil
	self.buttonUIIndex = 'raised'
	self.numSmallCircles = data.numSmallCircles
	self.waitTimer = nil
end;

---@param actionButton string
---@param buttonUI table
function randSBP:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
end;

---@param activeEntity Character
function randSBP:setUI(activeEntity)
	self:readyCamera(false)
	self.entity = activeEntity
	self.targetPos = activeEntity.pos
	self.smallCircleOptions.x = -self.smallCircleOptions.x

	self.smallCircleOptions.x = self.smallCircleOptions.x + self.targetPos.x
	self.smallCircleOptions.y = self.smallCircleOptions.y + self.targetPos.y
	self.feedbackPos.x = self.targetPos.x + self.feedbackOffsets.x
	self.feedbackPos.y = self.targetPos.y - self.feedbackOffsets.y
end;

function randSBP:reset()
	QTE.reset(self)
	self.qteComplete = false
	self.qteSuccess = false
	self.feedbackPos.a = 1
	for i=1,#self.circleGreenVals do
		self.circleGreenVals[i] = 0
	end
	self.doneWaiting = false
	self.displayButton = false

	self.smallCircleOptions.x = self.smallCircleOptions.x - self.targetPos.x
	self.smallCircleOptions.x = -self.smallCircleOptions.x

	self.smallCircleOptions.y = self.smallCircleOptions.y - self.targetPos.y
	self.feedbackPos.x = self.targetPos.x - self.feedbackOffsets.x
	self.feedbackPos.y = self.targetPos.y + self.feedbackOffsets.y
	self.buttonUIIndex = 'raised'
end;

---@param callback fun(qteSuccess: boolean)
function randSBP:beginQTE(callback)
	self.onComplete = callback
	flux.to(self.entity.pos, 0.5, {x = 100, y = 170})
	:oncomplete(function()
		local cameraGoalPos = {
			x = camera.x - self.entity.pos.x * 2,
			y = camera.y + self.entity.pos.y / 4
		}
		self.cameraTween = flux.to(camera, self.duration,
			{x = cameraGoalPos.x, y = cameraGoalPos.y, scale = 1.25}):ease('linear')

		for i=1,self.numSmallCircles do
			Timer.after(i*self.timeBtwnLights, function() self.circleGreenVals[i] = 1 end)
		end

		-- Show random button and give player time to react, then end QTE
		Timer.after(self.duration,
			function()
				self.displayButton = true

				-- Slight delay to give time to see the result
				self.waitTimer = Timer.after(self.waitDuration,
					function()
						-- qte failed
						self.qteComplete = true
						self.doneWaiting = true
						Signal.emit('Attack')
						self.signalEmitted = true
						self.displayButton = false
					end)
			end)
	end)
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function randSBP:gamepadpressed(joystick, button)
	if self.displayButton and not self.qteComplete then
		local qteSuccess = false
		if not self.doneWaiting then
			Timer.cancel(self.waitTimer)
		end
		self.buttonUIIndex = 'pressed'
		if button == self.actionButton then
			qteSuccess = true
			print('qte success')
		end
		self.onComplete(qteSuccess)
		self.signalEmitted = true
	end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function randSBP:gamepadreleased(joystick, button)
end;

---@param dt number
function randSBP:update(dt)
	for _,ps in ipairs(fireParticles) do
		ps.system:update(dt)
	end
end;

function randSBP:draw()
	if not self.qteComplete then
		for i=1,3 do
			love.graphics.setColor(0, self.circleGreenVals[i], 0)
			love.graphics.circle(self.smallCircleOptions.mode,
				self.smallCircleOptions.x + (i-1) * self.smallCircleOptions.xSpace,
				self.smallCircleOptions.y, self.smallCircleOptions.r)
			love.graphics.setColor(1,1,1)

			for _,ps in ipairs(fireParticles) do
				if self.circleGreenVals[i] == 1 then
					love.graphics.draw(ps.system, self.smallCircleOptions.x + (i-1) * self.smallCircleOptions.xSpace,
						self.smallCircleOptions.y )
				end
			end
		end
		love.graphics.setColor(1,0,0)
		love.graphics.circle(self.smallCircleOptions.mode, self.smallCircleOptions.x + self.smallCircleOptions.xSpace * 4,
			self.smallCircleOptions.y, self.smallCircleOptions.r * self.largeCircleScale)
		love.graphics.setColor(1, 1, 1)
	end

	if self.displayButton then
		love.graphics.draw(self.buttonUI[self.buttonUIIndex],
			self.smallCircleOptions.x + self.smallCircleOptions.xSpace * 3.2,
			self.smallCircleOptions.y - self.smallCircleOptions.y / 8.5, 0, self.buttonUIScale, self.buttonUIScale)
	end
end;

return randSBP