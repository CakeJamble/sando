--! filename: qte

Class = require 'libs.hump.class'
QTE = Class{
	feedbackDir = 'asset/sprites/combat/qte/feedback/',
	inputDir = 'asset/sprites/input_icons/'
}

function QTE:init()
	self.type = ''
	self.instructions = nil
	self.instructionsPos = {x = 200, y = 80}
	self.feedbackPos = {x = 250, y = 90, a = 1}
	self.offset = 0

	self.currQTEFrame = 0
	self.currFeedbackFrame = 0
	self.numFeedbackFrames = 45
	self.showPrompt = false
	self.countQTEFrames = falsef
	self.countFeedbackFrames = false
end;

function QTE:reset()
	self.currQTEFrame = 0
	self.currFeedbackFrame = 0
	self.countQTEFrames = false
	self.countFeedbackFrames = false
	self.showPrompt = false
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
