local Entity = require('class.entities.entity')
local Scheduler = require('class.scheduler.scheduler')
local Class = require('libs.hump.class')
local PlayerInputCommand = require('class.input.player_input_command')
local AICommand = require('class.input.ai_command')
local Timer = require('libs.hump.timer')

---@class STBScheduler: Scheduler
local STBScheduler = Class{__includes = Scheduler}

-- Standard Turn Based Scheduler
---@param characterTeam CharacterTeam
---@param enemyTeam EnemyTeam
function STBScheduler:init(characterTeam, enemyTeam)
	Scheduler.init(self, characterTeam, enemyTeam)
	self:sortQueue(self.combatants)
	self.turnIndex = 1
	self.activeEntity = nil
	self.activeCommand = nil
	self.commandQueue = {}
	self:enter()
end;

function STBScheduler:enter()
	Scheduler.enter(self)
	Entity.isATB = false

	local turnStart = function()
		local duration = self:removeKOs()

		-- After longest faint animation finishes, check state of combat
		Timer.after(duration,
			function()
						-- self:winLossConsMet()
				if self:winLossConsMet() then
					-- transition to rewards
					print('match done')
				else
					while not self.combatants[self.turnIndex]:isAlive() do
						self.turnIndex = (self.turnIndex % #self.combatants) + 1
					end
					self.activeEntity = self.combatants[self.turnIndex]
					local command

					if self.activeEntity.type == 'character' then
						command = PlayerInputCommand(self.activeEntity, self)
					else
						command = AICommand(self.activeEntity, self)
					end
					self.activeCommand = command
					self.turnIndex = (self.turnIndex % #self.combatants) + 1
					self.activeCommand:start()
				end
			end)
	end

	self:registerSignal('NextTurn', turnStart)
	self:registerSignal('OnStartCombat', function()
		Timer.after(1, turnStart) end)

	self:registerSignal('OnEndTurn',
	function(timeBtwnTurns)
		self:resetCamera(timeBtwnTurns)
		Timer.after(timeBtwnTurns, function()
			self.activeCommand.done = true
			turnStart()
		end)
	end)

end;

function STBScheduler:exit()
	self:removeSignals()
end;

---@param t Entity[]
---@return Entity[]
function STBScheduler:sortQueue(t)
  table.sort(t,
    function(entity1, entity2)
      return entity1:getSpeed() > entity2:getSpeed()
    end
  );
  return t
end;

function STBScheduler:sortWaitingCombatants()
  local waitingCombatants = {unpack(self.combatants, self.turnIndex, #self.combatants)}
  local i=1
  for j=self.turnIndex, #self.combatants do
    self.combatants[j] = waitingCombatants[i]
    i = i+1
  end
end;

---@param command Command
function STBScheduler:enqueueCommand(command)
  print('enqueuing command from ' .. command.entity.entityName .. ' in command queue')
  table.insert(self.commandQueue, command)
  self:checkQueues()
end;

function STBScheduler:checkQueues()
	self:removeKOs()

  if not self.activeCommand then
    if #self.commandQueue > 0 then
      self.activeCommand = table.remove(self.commandQueue, 1)
    end

    if self.activeCommand then
      print('starting active command belonging to ' .. self.activeCommand.entity.entityName)
      self.activeCommand:start(self)
    end
  elseif self.activeCommand.done then
    print('popping active command off from ' .. self.activeCommand.entity.entityName)
    self.activeCommand = nil
    self:checkQueues()
  end
end;

function STBScheduler:removeKOs()
	return Scheduler.removeKOs(self, self.activeEntity)
end;

return STBScheduler