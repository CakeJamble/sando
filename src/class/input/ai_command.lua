require('class.input.command')
AICommand = Class{__includes = Command}

function AICommand:init(entity, turnManager)
	Command.init(self, entity)
	-- local characterMembers = turnManager.characterTeam.members
	-- local enemyMembers = turnManager.enemyTeam.members
	-- entity:setTargets(characterMembers, enemyMembers)
	self.targets = entity.targets

	self.turnManager = turnManager
	self.awaitingInput = true
	self.waitingForTarget = false
	self.skill = nil
	-- self.signalHandlers = {}
	self.isInterruptible = false
end;

function AICommand:start()
	self.entity:startTurn()

	local targetConfirm = function(targetType, tIndex)
		print(self.entity.entityName .. ' is ready to attack')
		self.waitingForTarget = false
		local skillCommand = SkillCommand(self.entity)
		self.done = true
		self:cleanupSignals()
		self.turnManager:enqueueCommand(skillCommand, skillCommand.isInterruptible)
	end
	self:registerSignal('TargetConfirm', targetConfirm)

	-- skill and target select
	local validTargets = self.turnManager:getValidTargets()
	self.entity:setupOffense(validTargets)
end;

function AICommand:update(dt)
	if self.done then 
		self:cleanupSignals()
		print('cleanup signals for ' .. self.entity.entityName)
		self.done = false
	end
end;