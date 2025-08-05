require('class.scheduler.scheduler')
STBScheduler = Class{__includes = Scheduler}

-- Standard Turn Based Scheduler

function STBScheduler:init(characterTeam, enemyTeam)
	Scheduler.init(self, characterTeam, enemyTeam)
	self.turnIndex = 1
	self.activeEntity = nil
	self.activeCommand = nil

	self:enter()
end;

function STBScheduler:enter()
	Scheduler.enter(self)
	self:registerSignal('NextTurn',
	function()
		-- self.qteManager:reset()
		self.removeKOs()
		self:sortWaitingCombatants()

		while not self.turnQueue[self.turnIndex]:isAlive() do
			self.turnIndex = self.turnIndex + 1
		end
		self.activeEntity = self.combatants[self.turnIndex]
		self.activeEntity:startTurn()
		
		local command

		if self.activeEntity.type == 'character' then
			command = PlayerInputCommand(self.activeEntity, self)
		else
			command = AICommand(entity, self)
		end
		self.activeCommand = command
		self.turnIndex = (self.turnIndex % #self.combatants) + 1
		self.activeCommand:start()
	end
	)

	self:registerSignal('OnEndTurn',
	function(timeBtwnTurns)
		self:resetCamera(timeBtwnTurns)
		self.activeCommand.done = true
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