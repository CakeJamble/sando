--! filename: skill_ui.lua

Class = require 'libs.hump.class'
QTE = Class{}

function QTE:init()
	self.type = ''
	self.instructions = nil
	self.instructionsPos = {x = 200, y = 80}
	self.feedbackPos = {x = 250, y = 90}
	self.offset = 0
	self.currQTEFrame = 0
	self.numFeedbackFrames = 30
	self.currFeedbackFrame = 0
	self.showPrompt = false
	self.countQTEFrames = false
	self.countFeedbackFrames = false
end;

function QTE:reset()
	self.currFeedbackFrame = 0
	self.showPrompt = false
	self.countFrames = false
end;

function QTE:update(dt)
	if self.countQTEFrames then
		self.currQTEFrame = self.currQTEFrame + 1
	end
	if self.countFeedbackFrames then
		self.currFeedbackFrame = self.currFeedbackFrame + 1
	end
end;

function QTE:draw()
	love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
end;

--[[
idea: use Flywieght Pattern

create QTE objects that can be reused (like how textures get reused) instead of instantiating a new QTE for every move based on the type of movement.

Attributes of all QTEs:
	1. On input, should display some kind of confirmation and play audio confirmation (success of failure of QTE)

Single Button Press QTE -> only have to change the button prompted
Multi Button Press QTE -> can have the button input sequence randomized when it is selected
Stick holding -> doesn't even need to be modified
]]


--[[ 1. Basic Attack QTEs
- While targeting, draw the instructions at the top
- While moving and attacking, draw the Action Button at the top 
- Show depressed version of action button during the frame window (?)]]

