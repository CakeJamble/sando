-- local InputCommand = require('class.input.command')
local Command = require('class.input.command')
local SkillCommand = require('class.input.skill_command')
local ItemCommand = require('class.input.item_command')
local Class = require('libs.hump.class')

local PlayerInputCommand = Class{__includes = Command}

local CommandClasses = {
	skill_command = SkillCommand,
	item_command = ItemCommand
}

function PlayerInputCommand:init(entity, turnManager)
	Command.init(self, entity)
	self.targets = entity.targets
	self.turnManager = turnManager
	self.awaitingInput = true
	self.waitingForTarget = false
	self.action = nil
	self.isInterruptible = true
	self.commands = self:defineCommands()
	self.commandKey = ''
end;

function PlayerInputCommand:defineCommands()
	local commandInits = {
		skill_command = function(self)
			return CommandClasses.skill_command(self.entity, self.turnManager.qteManager)
		end,

		item_command = function(self)
			return CommandClasses.item_command(self.entity, self.action, self.turnManager.qteManager)
		end
	}
	return commandInits
end;

function PlayerInputCommand:start()
	self.entity:startTurn()
	local skillSelected = function(skill)
		if self.entity:validateSkillCost(skill.cost) then
			self.entity.skill = skill
			self.action = skill
			local validTargets = self.turnManager:getValidTargets()
			self.commandKey = 'skill_command'
			self.entity:setTargets(validTargets, self.action.targetType)
			self.awaitingInput = false
			self.waitingForTarget = true
			self.entity.actionUI.uiState = 'targeting'
		end
	end
	self:registerSignal('SkillSelected', skillSelected)

	local itemSelected = function(item)
		self.action = item
		local validTargets = self.turnManager:getValidTargets()

		local targetType
		if item.itemType == 'support' then
			targetType = 'characters'
		else
			targetType = 'enemies'
		end
		self.commandKey = 'item_command'
		self.entity:setTargets(validTargets, targetType)
		self.awaitingInput = false
		self.waitingForTarget = true
		self.entity.actionUI.uiState = 'targeting'
	end
	self:registerSignal('ItemSelected', itemSelected)

	local itemDeselected = function()
		self.turnManager.qteManager:reset()
		self.commandKey = ''
		self.action = nil
	end
	self:registerSignal('ItemDeselected', itemDeselected)

	local targetConfirm = function(targetType, tIndex)
		if self.commandKey == 'skill_command' then
			self.entity:deductFP(self.action.cost)
		elseif self.commandKey == 'item_command' then
			self.turnManager.characterTeam.inventory:popItem(self.action)
		end
		if self.action.isSingleTarget then
			table.insert(self.entity.targets, self.entity.targetableEntities[tIndex])
			table.insert(self.targets, self.entity.targetableEntities[tIndex])
		else
			for _,entity in ipairs(self.entity.targetableEntities) do
				table.insert(self.entity.targets, entity)
			end
			self.targets = self.entity.targets
		end

		self.waitingForTarget = false
		local command = self.commands[self.commandKey](self)
		self.done = true
		self.turnManager:enqueueCommand(command, command.isInterruptible)
		self.commandKey = ''
	end
	self:registerSignal('TargetConfirm', targetConfirm)

	local deselectSkill = function()
		self.turnManager.qteManager:reset()
		self.commandKey = ''
		self.action = nil
	end
	self:registerSignal('SkillDeselected', deselectSkill)

	local cancelInput = function()
		self:cleanupSignals()
		self.done = true
		self.commandKey = ''
		-- self.entity:endTurn()
	end
	self:registerSignal('CancelInput', cancelInput)
	self:registerSignal('OnEndTurn', cancelInput)
	self:registerSignal('PassTurn', function()
		cancelInput()
		self.entity:endTurn()
	end)
end;

function PlayerInputCommand:interrupt()
	self:cleanupSignals()
	print('interrupting ' .. self.entity.entityName .. '\'s command')
	self.entity.actionUI.active = false
end;

function PlayerInputCommand:update(dt)
	if self.done then
		self:cleanupSignals()
		self.done = false
	end
end;

return PlayerInputCommand