require('class.input.command')
require('class.input.skill_command')
PlayerInputCommand = Class{__includes = Command}

function PlayerInputCommand:init(entity, turnManager)
	Command.init(self, entity)

	local characterMembers = turnManager.characterTeam.members
	local enemyMembers = turnManager.enemyTeam.members
	entity:setTargets(characterMembers, enemyMembers)
	self.target = entity.target
	self.turnManager = turnManager
	self.awaitingInput = true
	self.waitingForTarget = false
	self.skill = nil
	-- self.signalHandlers = {}
	self.isInterruptible = true
end;

function PlayerInputCommand:start()
	self.entity:startTurn(self.turnManager.characterTeam.members, self.turnManager.enemyTeam.members)
	-- self.signalHandlers.skill = function(skill)
	local skillSelected = function(skill)
		self.skill = skill
		self.awaitingInput = false
		self.waitingForTarget = true
		-- self.entity:setTargets(self.turnManager.characterTeam, self.turnManager.enemyTeam)
		self.entity.actionUI.uiState = 'targeting'
	end
	-- Signal.register('SkillSelected', self.signalHandlers.skill)
	self:registerSignal('SkillSelected', skillSelected)

	-- self.signalHandlers.target = function(targetType, tIndex)
	local targetConfirm = function(targetType, tIndex)
		self.entity.target = self.entity.targets[targetType][tIndex]
		self.entity.skill = self.skill
		self.target = self.entity.targets[targetType][tIndex]
		self.waitingForTarget = false
		local skillCommand = SkillCommand(self.entity, self.target, self.skill, self.turnManager.qteManager)
		self.done = true
		self.turnManager:enqueueCommand(skillCommand, skillCommand.isInterruptible)
	end
	-- Signal.register('TargetConfirm', self.signalHandlers.target)
	self:registerSignal('TargetConfirm', targetConfirm)

	-- self.signalHandlers.deselectSkill = function()
	local deselectSkill = function()
		self.turnManager.qteManager:reset()
		self.skill = nil
	end
	-- Signal.register('SkillDeselected', self.signalHandlers.deselectSkill)
	self:registerSignal('SkillDeselected', deselectSkill)

	-- self.signalHandlers.cancel = function()
	local cancelInput = function()
		self:cleanupSignals()
		self.done = true
	end
	-- Signal.register('CancelInput', self.signalHandlers.cancel)
	-- Signal.register('OnEndTurn', self.signalHandlers.cancel)
	self:registerSignal('CancelInput', cancelInput)
	self:registerSignal('OnEndTurn', cancelInput)
	
	-- self.signalHandlers.passTurn = function()
	local passTurn = function()
		self.entity.actionUI:unset()
		self.entity:endTurn()
	end
	-- Signal.register('PassTurn', self.signalHandlers.passTurn)
	self:registerSignal('PassTurn', passTurn)
	
	-- basic cleanup
	self.awaitingInput = true
	self.skill = nil
	self.waitingForTarget = false
end;

function PlayerInputCommand:cleanupSignals()
	Signal.remove('SkillSelected', self.signalHandlers.skill)
	Signal.remove('SkillDeselected', self.signalHandlers.deselectSkill)
	Signal.remove('TargetConfirm', self.signalHandlers.target)
	Signal.remove('PassTurn', self.signalHandlers.passTurn)
	Signal.remove('CancelInput', self.signalHandlers.cancel)
	Signal.remove('OnEndTurn', self.signalHandlers.cancel)
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
