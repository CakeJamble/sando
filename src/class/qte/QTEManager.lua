local HoldSBP = require('class.qte.HoldSBP')
local mbpQTE = require('class.qte.MBP')
local randSBP = require('class.qte.RandSBP')
local RingQTE = require('class.qte.Ring')
local ComboRingQTE = require('class.qte.ComboRing')
local TapAnalogLeftQTE = require('class.qte.TapAnalogLeft')

local loadQTE = require 'util.qte_loader'

local QTEClasses = {
	hold_sbp = HoldSBP,
	mbp = mbpQTE,
	rand_sbp = randSBP,
	ring_qte = RingQTE,
	combo_ring_qte = ComboRingQTE,
	tap_analog_left_qte = TapAnalogLeftQTE
}

local Signal = require('libs.hump.signal')
local Class = require 'libs.hump.class'

---@class QTEManager
local QTEManager = Class{}

---@param characterTeam CharacterTeam
function QTEManager:init(characterTeam)
	self.qteInits = self:defineQTESetup()
	self.buttons = self.loadButtonImages('asset/sprites/input_icons/xbox-one/full_color/')
	self.qteTable = self.loadQTEData(characterTeam.members)

	self.activeQTE = nil

	Signal.register('QTESuccess',
		function()
			self.activeQTE:setFeedback(true)
		end
	)

	Signal.register('OnEndTurn', function() self.activeQTE = nil end)
end;

---@param buttonDir string
function QTEManager.loadButtonImages(buttonDir)
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

---@return { [string]: fun(...) }
function QTEManager:defineQTESetup()
	local qteInits = {
		hold_sbp = function(actionButton)
			local qte = self.qteTable.hold_sbp
			qte:setActionButton(actionButton, self.buttons[actionButton])
			qte.instructions = 'Hold ' .. string.upper(actionButton) .. ' until the meter fills!'
			return qte
		end,

		mbp = function()
			local qte = self.qteTable.mbp
			qte:createInputSequence(self.buttons)
			return qte
		end,

		rand_sbp = function()
			local buttons = {'a', 'b', 'x', 'y'}
			local randIndex = buttons[love.math.random(1, #buttons)]
			local qte = self.qteTable.rand_sbp
			qte:setActionButton(self.buttons[randIndex].val, self.buttons[randIndex])
			qte.qteButton = self.buttons[randIndex]
			-- qte.button = self.buttons[randIndex].raised
			return qte
		end,

		ring_qte = function(actionButton)
			local qte = self.qteTable.ring_qte
			qte:setActionButton(actionButton)
			return qte
		end,

		combo_ring_qte = function(actionButton)
			local qte = self.qteTable.combo_ring_qte
			qte:setActionButton(actionButton)
			return qte
		end,

		tap_analog_left_qte = function()
			local qte = self.qteTable.tap_analog_left_qte
			-- set joystick UI here
			return qte
		end,
	}

	return qteInits
end;

---@param members Character[]
---@return { [string]: QTE }
function QTEManager.loadQTEData(members)
	local result = {}
	for _,member in ipairs(members) do
		local skillPool = member.skillPool
		for _,skill in ipairs(skillPool) do
			local qteName = skill.qteType
			if not result[qteName] then
				-- result[qteName] = loadQTE(qteName)
				local qteData = loadQTE(qteName)
				local qte = QTEClasses[qteName]
				result[qteName] = qte(qteData)
			end
		end
	end
	return result
end;

function QTEManager:reset()
	if self.activeQTE then
		self.activeQTE:reset()
		self.activeQTE = nil
	end
end;

---@param qteType string
---@param actionButton string
function QTEManager:setQTE(qteType, actionButton)
	local init = self.qteInits[qteType]
	if init then
		self.activeQTE = init(actionButton)
	else
		error("Could not initialize QTE of type: " .. tostring(qteType))
	end
end;

---@param qteType string
---@param actionButton string
function QTEManager.getInstructions(qteType, actionButton)
	local result
	if qteType == 'sbp' then
		result = 'Press ' .. string.upper(actionButton) .. ' just before hitting the enemy!'
	elseif qteType == 'stick_move' then
	    --do
	elseif qteType == 'mbp' then
		result = 'Press the buttons in order!'
	elseif qteType == 'hold_sbp' then
		result = 'Hold ' .. string.upper(actionButton) .. ' until the metter fills!'
	elseif qteType == 'rand_sbp' then
		result = 'Press the button when it appears!'
	end
	return result
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function QTEManager:gamepadpressed(joystick, button)
	if self.activeQTE then
		self.activeQTE:gamepadpressed(joystick, button)
	end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function QTEManager:gamepadreleased(joystick, button)
	if self.activeQTE then
		self.activeQTE:gamepadreleased(joystick, button)
	end
end;

---@param dt number
function QTEManager:update(dt)
	if self.activeQTE then
		self.activeQTE:update(dt)
	end
end;

function QTEManager:draw()
	if self.activeQTE then
		-- draw UI independent of camera movement
		camera:detach()
		self.activeQTE:draw()
		camera:attach()
	end
end;

return QTEManager