local flux = require('libs.flux')
local Class = require 'libs.hump.class'

---@class QTE
---@field feedbackDir string
---@field inputDir string
local QTE = Class{
	feedbackDir = 'asset/sprites/combat/qte/feedback/',
	inputDir = 'asset/sprites/input_icons/'
}

---@param data table
function QTE:init(data)
	self.duration = data.duration
	self.qteComplete = false
	self.signalEmitted = false

	self.cameraTween = nil
	self.cameraReturnPos = {x=0,y=0}
	self.cameraReturnPos.x, self.cameraReturnPos.y = camera:position()
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
	self.qteSuccess = false
end;

---@param isOffensive? boolean
function QTE:readyCamera(isOffensive)
	if isOffensive then
		self.focusSelf = false
	else
		self.focusSelf = true
	end
end;

function QTE:reset()
	self.showFeedback = false
	self.qteComplete = false
	self.signalEmitted = false
	self.instructions = nil
end;

---@param duration? number
function QTE:tweenFeedback(duration)
	local t = duration or 1
	self.showFeedback = true
	flux.to(self.feedbackPos, t, {a = 0})
		:oncomplete(function()
			self.showFeedback = false
			self.feedbackPos.a = 1
		end)
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

return QTE
