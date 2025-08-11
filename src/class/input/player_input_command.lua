require('class.input.command')
require('class.input.skill_command')
PlayerInputCommand = Class{__includes = Command}

function PlayerInputCommand:init(entity, turnManager)
	Command.init(self, entity)
	self.target = entity.target
	self.turnManager = turnManager
	self.awaitingInput = true
	self.waitingForTarget = false
	self.skill = nil
	self.isInterruptible = true
end;

function PlayerInputCommand:start()
	self.entity:startTurn()
	local skillSelected = function(skill)
		self.entity.skill = skill
		self.skill = skill
		local validTargets = self.turnManager:getValidTargets()
		self.entity:setTargets(validTargets, skill.targetType)
		self.awaitingInput = false
		self.waitingForTarget = true
		self.entity.actionUI.uiState = 'targeting'
	end
	self:registerSignal('SkillSelected', skillSelected)

	local targetConfirm = function(targetType, tIndex)
		self.entity.target = self.entity.targets[tIndex]
		self.entity.skill = self.skill
		self.target = self.entity.targets[tIndex]
		self.waitingForTarget = false
		local skillCommand = SkillCommand(self.entity, self.turnManager.qteManager)
		self.done = true
		self.turnManager:enqueueCommand(skillCommand, skillCommand.isInterruptible)
	end
	self:registerSignal('TargetConfirm', targetConfirm)

	local deselectSkill = function()
		self.turnManager.qteManager:reset()
		self.skill = nil
	end
	self:registerSignal('SkillDeselected', deselectSkill)

	local cancelInput = function()
		self:cleanupSignals()
		self.done = true
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
	-- Signal.emit('InterruptActionUI')
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
