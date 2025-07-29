require('class.qte.qte')

randSBP = Class{__includes = QTE}

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
	-- self.duration = self.timeBtwnLights * 3
	self.buttonUIIndex = 'raised'
	self.numSmallCircles = data.numSmallCircles
	self.waitTimer = nil
end;

function randSBP:setActionButton(actionButton, buttonUI)
	self.actionButton = actionButton
	self.buttonUI = buttonUI
end;

function randSBP:setUI(activeEntity)
	self:readyCamera(false)

	self.targetPos = activeEntity.pos
	self.smallCircleOptions.x = -self.smallCircleOptions.x

	self.smallCircleOptions.x = self.smallCircleOptions.x + self.targetPos.x
	self.smallCircleOptions.y = self.smallCircleOptions.y + self.targetPos.y
	self.feedbackPos.x = self.targetPos.x + self.feedbackOffsets.x
	self.feedbackPos.y = self.targetPos.y - self.feedbackOffsets.y
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
	-- Hardcoded values that need to be determined dynamically!
	local goalPosX = self.cameraReturnPos.x 
	local goalPosY = self.cameraReturnPos.y

	goalPosX = goalPosX - self.targetPos.x
	goalPosY = goalPosY - self.targetPos.y / 4

	self.cameraTween = flux.to(camera, self.duration, {x = goalPosX, y = goalPosY, scale = 1.25}):ease('linear')
	
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
end;

function randSBP:gamepadpressed(joystick, button)
	if self.displayButton and not self.qteComplete then
		if not self.doneWaiting then
			Timer.cancel(self.waitTimer)
		end
		self.buttonUIIndex = 'pressed'
		if button ~= self.actionButton then
			print('qte failed, pressed wrong button')
		else
			print('qte success')
			Signal.emit('OnQTESuccess')
			self.signalEmitted = true
		end
		self.doneWaiting = true
		self.displayButton = false
		self.qteComplete = true
		Signal.emit('Attack')
	end
end;

function randSBP:gamepadreleased(joystick, button)
end;

function randSBP:update()
end;

function randSBP:draw()
	if not self.qteComplete then
		for i=1,3 do
			love.graphics.setColor(0, self.circleGreenVals[i], 0)
			love.graphics.circle(self.smallCircleOptions.mode, self.smallCircleOptions.x + (i-1) * self.smallCircleOptions.xSpace, self.smallCircleOptions.y, self.smallCircleOptions.r)
			love.graphics.setColor(1,1,1)
		end
		love.graphics.setColor(1,0,0)
		love.graphics.circle(self.smallCircleOptions.mode, self.smallCircleOptions.x + self.smallCircleOptions.xSpace * 4, self.smallCircleOptions.y, self.smallCircleOptions.r * self.largeCircleScale)
		love.graphics.setColor(1, 1, 1)
	end

	if self.displayButton then
		love.graphics.draw(self.buttonUI[self.buttonUIIndex], self.smallCircleOptions.x + self.smallCircleOptions.xSpace * 3.2, self.smallCircleOptions.y - self.smallCircleOptions.y / 8.5, 0, self.buttonUIScale, self.buttonUIScale)
	end
end;