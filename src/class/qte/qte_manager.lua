--! filename: qte_manager
require('class.qte.qte')
require('skills.skill')
-- require('util.skill_sheet')
require('class.qte.sbp_qte')
require('class.qte.hold_sbp_qte')
require('class.qte.mbp_qte')
Class = require 'libs.hump.class'
QTEManager = Class{}

function QTEManager:init(characterTeam)
	self.buttons = self:loadButtonImages('asset/sprites/input_icons/face_buttons/')
	self.qteTable = {
		sbp = sbpQTE(),
		holdSBP = HoldSBP(),
		mbp = mbpQTE(),
	}
	
	self.activeQTE = nil

	Signal.register('QTESuccess',
		function()
			self.activeQTE:setFeedback(true)
		end
	)
end;

function QTEManager:loadButtonImages(buttonDir)
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
			val = 'x'
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
	return buttons
end;

function QTEManager:reset()
	if self.activeQTE then
		self.activeQTE:reset()
		self.activeQTE = nil
	end
end;

function QTEManager:setQTE(qteType, actionButton, skill)
	if qteType == 'SINGLE_BUTTON_PRESS' then
		self.qteTable.sbp.actionButton = self.qteTable.sbp.buttons[actionButton]
		self.qteTable.sbp.actionButtonQTE = self.qteTable.sbp.actionButton.raised
		self.qteTable.sbp.instructions = "Press " .. actionButton .. ' just before landing the attack!'
		self.qteTable.sbp.frameWindow = skill.qte_window
		self.activeQTE = self.qteTable.sbp
	elseif qteType == 'STICK_MOVE' then
	    --do
	elseif qteType == 'MULTI_BUTTON_PRESS' then
		self.qteTable.mbp.buttons = self.buttons
		self.qteTable.mbp:createInputSequence(self.buttons)
		self.activeQTE = self.qteTable.mbp
	elseif qteType == 'HOLD_SBP' then
		self.qteTable.holdSBP.actionButton = actionButton
		self.qteTable.holdSBP.qteButton = self.buttons[actionButton]
		self.qteTable.holdSBP.buttonUI = self.buttons[actionButton].raised
		self.qteTable.holdSBP.instructions = "Hold " .. actionButton .. ' until the meter is filled!'
		self.activeQTE = self.qteTable.holdSBP
	end
end;

function QTEManager:gamepadpressed(joystick, button)
	if self.activeQTE then
		self.activeQTE:gamepadpressed(joystick, button)
	end
end;

function QTEManager:gamepadreleased(joystick, button)
	if self.activeQTE then
		self.activeQTE:gamepadreleased(joystick, button)
	end
end;

function QTEManager:update(dt)
	if self.activeQTE then
		self.activeQTE:update(dt)
	end
end;

function QTEManager:draw()
	if self.activeQTE then
		self.activeQTE:draw()
	end
end;