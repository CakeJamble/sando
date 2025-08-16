--! filename: sbpQTE
local QTE = require('class.qte.qte')
local Class = require 'libs.hump.class'

--[[ sbpQTE : Single Button Press QTE
	- QTE for skills and basic attacks that only require a single buttons press at a given interval. 
]]
local sbpQTE = Class{__includes = QTE}

function sbpQTE:init()
	QTE.init(self)
	self.type = 'sbp'
	self.pos = {x = nil, y = nil}
	self.offset = 10
	self.instructions = nil
	self.frameWindow = nil

	-- face buttons
	self.buttons = self:loadButtonImages(QTE.inputDir .. 'face_buttons/')
	self.actionButton = nil
	self.actionButtonQTE = nil

	-- qte feedback
	self.greatText = love.graphics.newImage(QTE.feedbackDir .. 'great.png')
	self.showGreatText = false
end;

function sbpQTE:loadButtonImages(buttonDir)
	local buttonPaths = {
		aRaised = buttonDir .. 'a_raised.png',
		bRaised = buttonDir .. 'b_raised.png',
		xRaised = buttonDir .. 'x_raised.png',
		yRaised = buttonDir .. 'y_raised.png',
		aPressed = buttonDir .. 'a_depressed.png',
		bPressed = buttonDir .. 'b_depressed.png',
		xPressed = buttonDir .. 'x_depressed.png',
		yPressed = buttonDir .. 'y_depressed.png'

	}
	local buttons = {
		a = {
			raised = love.graphics.newImage(buttonPaths.aRaised),
			pressed = love.graphics.newImage(buttonPaths.aPressed)
		},
		b = {
			raised = love.graphics.newImage(buttonPaths.bRaised),
			pressed = love.graphics.newImage(buttonPaths.bPressed)
		},
		x = {
			raised = love.graphics.newImage(buttonPaths.xRaised),
			pressed = love.graphics.newImage(buttonPaths.xPressed)
		},
		y = {
			raised = love.graphics.newImage(buttonPaths.yRaised),
			pressed = love.graphics.newImage(buttonPaths.yPressed)
		},
		z = { -- temp for testing
			raised = love.graphics.newImage(buttonPaths.aRaised),
			pressed = love.graphics.newImage(buttonPaths.aPressed)
		}
	}

	return buttons
end;

function sbpQTE:setFeedback(isSuccess)
	if isSuccess then
		self.showGreatText = true
		self.countFeedbackFrames = true
	end
end;

function sbpQTE:reset()
	QTE.reset(self)
	self.showGreatText = false
	self.actionButton = nil
end;

function sbpQTE:update(dt)
	QTE.update(self, dt)
	if self.frameWindow then
		if self.currQTEFrame >= self.frameWindow[1] and self.currQTEFrame < self.frameWindow[2] then
			self.actionButtonQTE = self.actionButton.pressed
		else
			self.actionButtonQTE = self.actionButton.raised
		end
	end
	if self.currFeedbackFrame > self.numFeedbackFrames then
		self.showGreatText = false
	end
end;

function sbpQTE:draw()
	if self.showPrompt and self.frameWindow then
		love.graphics.draw(self.actionButtonQTE, self.instructionsPos.x, self.instructionsPos.y, 0, 0.75, 0.75)
	end
	if self.instructions ~= nil then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
		love.graphics.setColor(1, 1, 1)
	end
	if self.showGreatText then
		love.graphics.draw(self.greatText, self.feedbackPos.x, self.feedbackPos.y)
	end
end;

return sbpQTE