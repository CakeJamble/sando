--! filename: stick_move_qte

require('class.qte.qte')
Class = require 'libs.hump.class'

--[[stick_move_qte
	- QTE for skills that require the stick to be held in a given direction for a given duration,
	then released back to the neutral position
	]]

StickMoveQTE = Class{__includes = QTE}

function StickMoveQTE:init()
	QTE.init(self)
	self.type = 'sm'
	self.pos = {x = nil, y = nil}
	self.offset = 50
	self.instructions = nil
	self.frameWindow = nil

	-- analog stick
	self.analog = self:loadAnalogStickImages(QTE.inputDir .. 'analog_stick/')

	-- qte feedback
	local feedback = love.graphics.newImage(QTE.feedbackDir .. 'gread.png')
	self.showGreatText = false
end;

function StickMoveQTE:loadAnalogStickImages(dir)
	local result = {
		leftStick = {
			lsAll = love.graphics.newImage(dir .. 'left_stick_all' .. '.png'),
			lsClick = love.graphics.newImage(dir .. 'left_stick_click' .. '.png'),
			lsDown = love.graphics.newImage(dir .. 'left_stick_down' .. '.png'),
			lsLeft = love.graphics.newImage(dir .. 'left_stick_left' .. '.png'),
			lsLeftRight = love.graphics.newImage(dir .. 'left_stick_left_right' .. '.png'),
			lsRight = love.graphics.newImage(dir .. 'left_stick_right' .. '.png'),
			lsUp = love.graphics.newImage(dir .. 'left_stick_up' .. '.png'),
			lsUpDown = love.graphics.newImage(dir .. 'left_stick_up_down' .. '.png'),
			ls = love.graphics.newImage(dir .. 'left_stick' .. '.png'),
		},
		rightStick = {
			rsAll = love.graphics.newImage(dir .. 'right_stick_all' .. '.png'),
			rsClick = love.graphics.newImage(dir .. 'right_stick_click' .. '.png'),
			rsDown = love.graphics.newImage(dir .. 'right_stick_down' .. '.png'),
			rsLeft = love.graphics.newImage(dir .. 'right_stick_left' .. '.png'),
			rsLeftRight = love.graphics.newImage(dir .. 'right_stick_left_right' .. '.png'),
			rsRight = love.graphics.newImage(dir .. 'right_stick_right' .. '.png'),
			rsUp = love.graphics.newImage(dir .. 'right_stick_up' .. '.png'),
			rsUpDown = love.graphics.newImage(dir .. 'right_stick_up_down' .. '.png'),
			rs = love.graphics.newImage(dir .. 'right_stick' .. '.png'),
		}
	}
	return result
end;
