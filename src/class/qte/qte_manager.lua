--! filename: qte_manager
require('class.qte.qte')
require('class.qte.sbp_qte')
require('class.qte.hold_sbp_qte')
require('class.qte.mbp_qte')
require('class.qte.rand_sbp_qte')
Class = require 'libs.hump.class'
QTEManager = Class{}

function QTEManager:init(characterTeam)
	self.buttons = self:loadButtonImages('asset/sprites/input_icons/xbox-one/full_color/')
	self.qteTable = {
		sbp = sbpQTE(),
		holdSBP = HoldSBP(),
		mbp = mbpQTE(),
		randSBP = randSBP()
	}
	
	self.activeQTE = nil

	Signal.register('QTESuccess',
		function()
			self.activeQTE:setFeedback(true)
		end
	)

	Signal.register('NextTurn', function() self.activeQTE = nil end)
end;

function QTEManager:loadButtonImages(buttonDir)
	local blackButtonsDir = buttonDir .. 'buttons_black/'
	local pressedButtonsDir = buttonDir .. 'buttons_pressed/' 

	local buttonPaths = {
		aRaised = blackButtonsDir 		.. 'btn_a.png',
		bRaised = blackButtonsDir 		.. 'btn_b.png',
		xRaised = blackButtonsDir 		.. 'btn_x.png',
		yRaised = blackButtonsDir 		.. 'btn_y.png',
		aPressed = pressedButtonsDir 	.. 'btn_a.png',
		bPressed = pressedButtonsDir 	.. 'btn_b.png',
		xPressed = pressedButtonsDir 	.. 'btn_x.png',
		yPressed = pressedButtonsDir 	.. 'btn_y.png'

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
	elseif qteType == 'RAND_SBP' then
		local buttons = {'a', 'b', 'x', 'y'}
		local randIndex = buttons[love.math.random(1, #buttons)]
		self.qteTable.randSBP.qteButton = self.buttons[randIndex]
		self.qteTable.randSBP.button = self.buttons[randIndex].raised
		self.activeQTE = self.qteTable.randSBP
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