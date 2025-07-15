require('class.qte.qte')

randSBP = Class{__includes = QTE}

function randSBP:init()
	QTE.init(self)
	self.type = 'randSBP'
	self.qteButton = nil
	self.displayButton = false
	self.signalEmitted = false
	self.qteComplete = false
	self.doneWaiting = false
	self.circleGreenVals = {0,0,0}
	self.smallCircleDims = {
		mode = 'fill',
		x = 0,
		y = 0,
		r = 10,
		xOffset = 25
	}
	self.timeBtwnCirclesLightingUp = 1
	self.largeCircleScaler = 3
	self.waitForPlayer = 0.75
	self.button = nil
	-- qte feedback
	self.greatText = love.graphics.newImage(QTE.feedbackDir .. 'great.png')
	self.showGreatText = false
end;

function randSBP:setUI(activeEntity)
	local targetPos = activeEntity.target.pos
	self.smallCircleDims.x = targetPos.x - 75
	self.smallCircleDims.y = targetPos.y + 100

	self.feedbackPos.x = targetPos.x + 25
	self.feedbackPos.y = targetPos.y - 25
end;

function randSBP:reset()
	QTE.reset(self)
	self.qteButton = nil
	self.feedbackPos.a = 1
	self.qteComplete = false
	self.signalEmitted = false
	for i=1,#self.circleGreenVals do
		self.circleGreenVals = 0
	end
end;

function randSBP:beginQTE()
	-- time for progression of the QTE
	local t = 0.75
	for i=1,3 do
		Timer.after(i*t, function() self.circleGreenVals[i] = 1 end)
	end

	-- Show random button and give player time to react, then end QTE
	Timer.after(4*t, function() self.displayButton = true end)
	Timer.after(4*t + self.waitForPlayer, 
		function()
			self.qteComplete = true
			self.doneWaiting = true
			Signal.emit('Attack')
			self.signalEmitted = true
			self.displayButton = false
		end
	)
end;

function randSBP:gamepadpressed(joystick, button)
	if self.displayButton and not self.qteComplete then
		self.button = self.qteButton.pressed
		if button ~= self.qteButton.val then
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
			love.graphics.circle(self.smallCircleDims.mode, self.smallCircleDims.x + (i-1) * self.smallCircleDims.xOffset, self.smallCircleDims.y, self.smallCircleDims.r)
			love.graphics.setColor(1,1,1)
		end
		love.graphics.setColor(1,0,0)
		love.graphics.circle(self.smallCircleDims.mode, self.smallCircleDims.x + self.smallCircleDims.xOffset * 4, self.smallCircleDims.y, self.smallCircleDims.r * self.largeCircleScaler)
		love.graphics.setColor(1, 1, 1)
	end

	if self.displayButton then
		love.graphics.draw(self.button, self.smallCircleDims.x + self.smallCircleDims.xOffset * 2.75, self.smallCircleDims.y - self.smallCircleDims.y / 6.5, 0, 0.5, 0.5)
	end
end;