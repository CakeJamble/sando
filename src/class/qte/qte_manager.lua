--! filename: qte_manager
require('class.qte.qte')
require('class.qte.sbp_qte')
require('class.qte.hold_sbp_qte')
require('class.qte.mbp_qte')
require('class.qte.rand_sbp_qte')
local loadQTE = require 'util.qte_loader'

Class = require 'libs.hump.class'
QTEManager = Class{}

function QTEManager:init(characterTeam)
	self.buttons = self:loadButtonImages('asset/sprites/input_icons/xbox-one/full_color/')
	self.qteData = self:loadQTEData(characterTeam.members) 
	self.qteTable = self:initQTETable()
	
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
	}
	return buttons
end;

function QTEManager:loadQTEData(members)
	local result = {}
	for i,member in ipairs(members) do
		local skillPool = member.skillPool
		for i,skill in ipairs(skillPool) do
			local qteName = skill.qteType
			if not result[qteName] then
				result[qteName] = loadQTE(qteName)
			end
		end
	end
	return result
end;

function QTEManager:initQTETable()
	local result = {
		-- sbp 			= sbpQTE(self.qteData['sbp']),
		holdSBP		= HoldSBP(self.qteData['hold_sbp']),
		mbp 			= mbpQTE(self.qteData['mbp']),
		-- randSBP 	= randSBP(self.qteData['rand_sbp'])
	}
	return result
end;

function QTEManager:reset()
	if self.activeQTE then
		self.activeQTE:reset()
		self.activeQTE = nil
	end
end;

function QTEManager:setQTE(qteType, actionButton, skill)
	if qteType == 'sbp' then
		-- local actionButton 
		-- self.qteTable['sbp'] = sbpQTE()
		-- self.qteTable.sbp.actionButton = self.buttons[actionButton]
		-- self.qteTable.sbp.actionButtonQTE = self.qteTable.sbp.actionButton.raised
		-- self.qteTable.sbp.instructions = "Press " .. actionButton .. ' just before landing the attack!'
		-- self.qteTable.sbp.frameWindow = skill.qte_window
		-- self.activeQTE = self.qteTable.sbp
	elseif qteType == 'stick_move' then
	    --do
	elseif qteType == 'mbp' then
		self.qteTable.mbp:createInputSequence(self.buttons)
		self.activeQTE = self.qteTable.mbp
	elseif qteType == 'hold_sbp' then
		self.qteTable.holdSBP:setActionButton(actionButton, self.buttons[actionButton])
		self.activeQTE = self.qteTable.holdSBP
	elseif qteType == 'rand_sbp' then
		local buttons = {'a', 'b', 'x', 'y'}
		local randIndex = buttons[love.math.random(1, #buttons)]
		self.qteTable.randSBP:setActionButton(actionButton, self.buttons[randIndex])
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