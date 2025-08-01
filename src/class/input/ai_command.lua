require('class.input.command')
AICommand = Class{__includes = Command}

function AICommand:init(entity, turnManager)
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
	self.isInterruptible = false
end;

function AICommand:start()
	self.entity:startTurn()

	self.signalHandlers.target = function(targetType, tIndex)
		print(self.entity.entityName .. ' is ready to attack')

		-- pop self-off queue to remove inifinite loop
		table.remove(self.turnManager.commandQueue, 1)

		self.entity.target = self.entity.targets[targetType][tIndex]
		self.skill = self.entity.skill
		self.target = self.entity.targets[targetType][tIndex]
		self.waitingForTarget = false
		local skillCommand = SkillCommand(self.entity, self.target, self.skill, nil)

		local isInterrupt = true
		self.turnManager:enqueueCommand(skillCommand, isInterrupt)
	end
	Signal.register('TargetConfirm', self.signalHandlers.target)

	-- skill and target select
	self.entity:setupOffense()
end;

function AICommand:cleanupSignals()
	Signal.remove('TargetConfirm', self.signalHandlers.target)
end;

function AICommand:update(dt)
	if self.done then self:cleanupSignals() end
end;