require('class.entities.entity')
require('class.scheduler.scheduler')
STBScheduler = Class{__includes = Scheduler}

-- Standard Turn Based Scheduler

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
		-- self.qteManager:reset()
		self:removeKOs()
		if self:winLossConsMet() then
			-- transition to rewards
			print('match done')
		end
		self:sortWaitingCombatants()

		while not self.combatants[self.turnIndex]:isAlive() do
			self.turnIndex = self.turnIndex + 1
		end
		self.activeEntity = self.combatants[self.turnIndex]
		self.activeEntity:startTurn()
		
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

	self:registerSignal('NextTurn', turnStart)
	self:registerSignal('OnStartCombat', function()
		Timer.after(1, turnStart) end)
	

	self:registerSignal('OnEndTurn',
	function(timeBtwnTurns)
		self:resetCamera(timeBtwnTurns)
		self.activeCommand.done = true
		Signal.emit('NextTurn')
	end)

end;

function STBScheduler:exit()
	self:removeSignals()
end;

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
      -- self:entitiesReactToTurnStart()
      print('starting active command belonging to ' .. self.activeCommand.entity.entityName)
      self.activeCommand:start(self)
    end
  elseif self.activeCommand.done then
    print('popping active command off from ' .. self.activeCommand.entity.entityName)
    self.activeCommand = nil
    self:checkQueues()
  end
end;