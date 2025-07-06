--! filename: qte_manager
require('class.qte.qte')
require('class.qte.skill')
require('util.skill_sheet')
require('class.qte.sbp_qte')
Class = require 'libs.hump.class'
QTEManager = Class{}

function QTEManager:init(characterTeam)
	self.qteTable = {
		sbp = sbpQTE()
	}
	self.activeQTE = nil

	Signal.register('QTESuccess',
		function()
			self.activeQTE:setFeedback(true)
		end
	)
	self.skill = nil
end;

function QTEManager:reset()
	if self.activeQTE then
		self.activeQTE:reset()
		self.activeQTE = nil
	end
end;

function QTEManager:setQTE(skill, character)
	self.skill = skill
	local qteType = skill.qteType
	if qteType == 'SINGLE_BUTTON_PRESS' then
		print(character.actionButton)
		self.qteTable.sbp.actionButton = self.qteTable.sbp.buttons[character.actionButton]
		self.qteTable.sbp.actionButtonQTE = self.qteTable.sbp.actionButton.raised
		self.qteTable.sbp.instructions = "Press " .. character.actionButton .. ' just before landing the attack!'
		self.qteTable.sbp.frameWindow = skill.qte_window
		self.activeQTE = self.qteTable.sbp
	elseif skillType == 'STICK_MOVE' then
	    --do
	elseif skillType == 'MULTI_BUTTON_PRESS' then
		--do
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