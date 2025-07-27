require('class.qte.qte')

randSBP = Class{__includes = QTE}

function randSBP:init(data)
	QTE.init(self, data)
	self.type = 'randSBP'
	self.displayButton = false
	self.doneWaiting = false
	self.circleGreenVals = {0,0,0}
	self.smallCircleOptions = data.smallCircleOptions
	self.timeBtwnLights = data.timeBtwnCirclesLightingUp
	self.largeCircleScale = data.largeCircleScale
	self.waitDuration = data.waitDuration
	self.actionButton = nil
	self.buttonUI = nil
	self.buttonUIIndex = 'raised'
	self.numSmallCircles = data.numSmallCircles
end;

function randSBP:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
end;

function randSBP:setUI(activeEntity)
	local isOffensive = activeEntity.skill.isOffensive
	self:readyCamera(isOffensive)

	local targetPos 
	if isOffensive then
		targetPos = activeEntity.target.pos
	else
		targetPos = activeEntity.pos
		self.smallCircleOptions.x = -self.smallCircleOptions.x
	end

	self.smallCircleOptions.x = self.smallCircleOptions.x + targetPos.x
	self.smallCircleOptions.y = self.smallCircleOptions.y + targetPos.y
	self.feedbackPos.x = targetPos.x + self.feedbackOffsets.x
	self.feedbackPos.y = targetPos.y - self.feedbackOffsets.y
end;

function randSBP:reset()
	QTE.reset(self)
	self.feedbackPos.a = 1
	for i=1,#self.circleGreenVals do
		self.circleGreenVals = 0
	end
	self.doneWaiting = false
end;

function randSBP:beginQTE()
	for i=1,self.numSmallCircles do
		Timer.after(i*self.timeBtwnLights, function() self.circleGreenVals[i] = 1 end)
	end

	-- Show random button and give player time to react, then end QTE
	Timer.after((self.numSmallCircles + 1)*self.timeBtwnLights, 
		function() 
			self.displayButton = true 

			-- Slight delay to give time to see the result
			Timer.after(self.waitForPlayer,
				function()
					self.qteComplete = true
					self.doneWaiting = true
					Signal.emit('Attack')
					self.signalEmitted = true
					self.displayButton = false
				end)
		end)
end;

function randSBP:gamepadpressed(joystick, button)
	if self.displayButton and not self.qteComplete then
		self.buttonUIIndex = 'pressed'
		if button ~= self.actionButton then
			print('qte failed, pressed wrong button')
		else
			print('qte success')
			Signal.emit('OnQTESuccess')
		end
		self.qteComplete = true
	end
end;

function randSBP:draw()
	if not self.qteComplete then
		for i=1,3 do
			love.graphics.setColor(0, self.circleGreenVals[i], 0)
			love.graphics.circle(self.smallCircleOptions.mode, self.smallCircleOptions.x + (i-1) * self.smallCircleOptions.xOffset, self.smallCircleOptions.y, self.smallCircleOptions.r)
			love.graphics.setColor(1,1,1)
		end
		love.graphics.setColor(1,0,0)
		love.graphics.circle(self.smallCircleOptions.mode, self.smallCircleOptions.x + self.smallCircleOptions.xOffset * 4, self.smallCircleOptions.y, self.smallCircleOptions.r * self.largeCircleScale)
		love.graphics.setColor(1, 1, 1)
	end

	if self.displayButton then
		love.graphics.draw(self.buttonUI[self.buttonUIIndex], self.smallCircleOptions.x + self.smallCircleOptions.xOffset * 2.75, self.smallCircleOptions.y - self.smallCircleOptions.y / 6.5, 0, 0.5, 0.5)
	end
end;