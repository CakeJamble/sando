--! filename: qte

Class = require 'libs.hump.class'
QTE = Class{
	feedbackDir = 'asset/sprites/combat/qte/feedback/',
	inputDir = 'asset/sprites/input_icons/'
}

function QTE:init(data)
	self.duration = data.duration
	self.qteComplete = false
	self.signalEmitted = false

	self.cameraTween = nil
	self.cameraReturnPos = {x=0,y=0}
	self.focusSelf = false

	self.instructions = data.instructions
	self.instructionsPos = {x = 200, y = 80}
	
	self.buttonUI = nil
	self.buttonUIPos = {x=0,y=0}
	self.buttonUIScale = 2.5

	self.feedbackUI = data.feedbackList
	self.feedbackIndex = 1
	self.showFeedback = false
	self.feedbackPos = {x = 250, y = 90, a = 1}
	self.feedbackOffsets = {x=25, y=-25}
end;

function QTE:readyCamera(isOffensive)
	self.cameraReturnPos.x, self.cameraReturnPos.y = camera:position()
	self.focuseSelf = not isOffensive
end;

function QTE:reset()
	self.showFeedback = false
	self.qteComplete = false
	self.signalEmitted = false
	self.instructions = nil
end;

function QTE:draw()
	if self.instructions then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
		love.graphics.setColor(1, 1, 1)
	end

	if self.showFeedback then
		love.graphics.setColor(1,1,1, self.feedbackPos.a)
		love.graphics.draw(self.feedbackUI[self.feedbackIndex], self.feedbackPos.x, self.feedbackPos.y)
		love.graphics.setColor(1,1,1,1)
	end
end;
