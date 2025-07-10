--! filename: mbp_qte.lua
require('class.qte.qte')
require('class.ui.progress_bar')
Class = require 'libs.hump.class'

--[[ mbpQTE: Multi Button Press QTE
	- QTE for skills that require multiple button presses within a given duration
	]]

	mbpQTE = Class{__includes = QTE}

function mbpQTE:init()
	QTE.init(self)
	self.inputSequenceLength = 6
	self.type = 'mbp'
	self.pos = {x = nil, y = nil}
	self.offset = 50
	self.instructions = nil
	self.frameWindow = nil

	-- progress bar
	local pbPos = {100, 300}
	self.progressBar = ProgressBar(pbPos, 100, 35, 0, 100, 1)

	-- face buttons (how can I reuse?)
	self.buttons = self:loadButtonImages(QTE.inputDir .. 'face_buttons/')
	self.currButton = nil

	-- qte feedback (add more?)
	self.greatText = love.graphics.newImage(QTE.feedbackDir .. 'great.png')
	self.showGreatText = false
end;

function mbpQTE:loadButtonImages(buttonDir)
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
			pressed = love.graphics.newImage(buttonPaths.aPressed),
			val = 'a'
		},
		b = {
			raised = love.graphics.newImage(buttonPaths.bRaised),
			pressed = love.graphics.newImage(buttonPaths.bPressed),
			val = 'b'
		},
		x = {
			raised = love.graphics.newImage(buttonPaths.xRaised),
			pressed = love.graphics.newImage(buttonPaths.xPressed),
		},
		y = {
			raised = love.graphics.newImage(buttonPaths.yRaised),
			pressed = love.graphics.newImage(buttonPaths.yPressed),
			val = 'y'
		},
		z = { -- temp for testing
			raised = love.graphics.newImage(buttonPaths.aRaised),
			pressed = love.graphics.newImage(buttonPaths.aPressed),
			val = 'z'
		}
	}

	return self:createInputSequence(buttons)
end;

function mbpQTE:createInputSequence(buttons)
	local result = {}

	-- generate set of inputs for QTE
	for i=1,self.inputSequenceLength do
		local randIndex = love.math.random(#buttons)
		table.insert(result, buttons[randIndex])
	end
	return result
end;

function mbpQTE:setFeedback(isSuccess)
	if isSuccess then
		self.showGreatText = true
		self.countFeedbackFrames = true
	end
end;

function mbpQTE:reset()
	QTE.reset(self)
	self.showGreatText = false
	-- self.actionButton = nil
end;

function mbpQTE:update(dt)
	QTE.update(self, dt)
	-- if self.frameWindow then
	-- 	if self.currQTEFrame >= self.frameWindow[1] and self.currQTEFrame < self.frameWindow[2] then
	-- 		self.actionButtonQTE = self.actionButton.pressed
	-- 	else
	-- 		self.actionButtonQTE = self.actionButton.raised
	-- 	end
	-- end
	-- if self.currFeedbackFrame > self.numFeedbackFrames then
	-- 	self.showGreatText = false
	-- end
end;

function mbpQTE:draw()
	-- if self.showPrompt and self.frameWindow then
	-- 	love.graphics.draw(self.actionButtonQTE, self.instructionsPos.x, self.instructionsPos.y, 0, 0.75, 0.75)
	-- end
	if self.instructions ~= nil then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
		love.graphics.setColor(1, 1, 1)
	end
	if self.showGreatText then
		love.graphics.draw(self.greatText, self.feedbackPos.x, self.feedbackPos.y)
	end
end;