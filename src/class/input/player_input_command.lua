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
	self.signalHandlers = {}
	self.isInterruptible = true
end;

function PlayerInputCommand:start()
	self.entity:startTurn(self.turnManager.characterTeam.members, self.turnManager.enemyTeam.members)
	self.signalHandlers.skill = function(skill)
	print(self.entity.entityName .. ' selected a skill')
		self.skill = skill
		self.awaitingInput = false
		self.waitingForTarget = true
		-- self.entity:setTargets(self.turnManager.characterTeam, self.turnManager.enemyTeam)
		self.entity.actionUI.uiState = 'targeting'
	end
	Signal.register('SkillSelected', self.signalHandlers.skill)

	self.signalHandlers.target = function(targetType, tIndex)
		self.entity.target = self.entity.targets[targetType][tIndex]
		self.entity.skill = self.skill
		self.target = self.entity.targets[targetType][tIndex]
		self.waitingForTarget = false
		local skillCommand = SkillCommand(self.entity, self.target, self.skill, self.turnManager.qteManager)
		self.done = true
		self.turnManager:enqueueCommand(skillCommand, skillCommand.isInterruptible)
	end
	Signal.register('TargetConfirm', self.signalHandlers.target)

	self.signalHandlers.deselectSkill = function()
		self.turnManager.qteManager:reset()
		self.skill = nil
	end
	Signal.register('SkillDeselected', self.signalHandlers.deselectSkill)

	self.signalHandlers.cancel = function()
		self:cleanupSignals()
		self.done = true
	end
	Signal.register('CancelInput', self.signalHandlers.cancel)
	Signal.register('OnEndTurn', self.signalHandlers.cancel)
	
	self.signalHandlers.passTurn = function(entity)
		entity.actionUI:unset()
		Signal.emit('OnEndTurn', 0)
	end
	Signal.register('PassTurn', self.signalHandlers.passTurn)
	
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
end;

function PlayerInputCommand:update(dt)
	if self.done then 
		self:cleanupSignals() 
		self.done = false
	end
end;
