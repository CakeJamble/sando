local Command = require('class.input.command')
local Class = require('libs.hump.class')
local SkillCommand = require('class.input.skill_command')

---@class AICommand: Command
local AICommand = Class{__includes = Command}

---@param entity Entity
---@param turnManager Scheduler
function AICommand:init(entity, turnManager)
	Command.init(self, entity)
	self.targets = entity.targets
	self.turnManager = turnManager
	self.awaitingInput = true
	self.waitingForTarget = false
	self.skill = nil
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

---@param dt number
function AICommand:update(dt)
	if self.done then
		self:cleanupSignals()
		print('cleanup signals for ' .. self.entity.entityName)
		self.done = false
	end
end;

return AICommand