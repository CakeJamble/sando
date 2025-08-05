require('class.scheduler.scheduler')
ATBScheduler = Class{__includes = Scheduler}

function ATBScheduler:init(characterTeam, enemyTeam)
	Scheduler.init(self, characterTeam, enemyTeam)
	self.commandQueue = {
		interruptibles = {},
		uninterruptibles = {}
	}
	self.activeCommand = nil
	self.awaitingPlayerAction = false

	self:enter()
end;

function ATBScheduler:enter()
	self:registerSignal('OnStartCombat', 
	function()
    for i,entity in ipairs(self.combatants) do
	  	entity:tweenProgressBar(
	  	function()
	  		print(entity.entityName .. "'s turn is ready to begin")
	  		Signal.emit('OnTurnReady', entity)
	  	end)
	  end
	end)

	self:registerSignal('OnTurnReady',
	function(entity)
    local command
    local isInterrupt
    if entity.type == 'character' then
      command = PlayerInputCommand(entity, self)
    else
      command = AICommand(entity, self)
    end

    self:enqueueCommand(command, command.isInterruptible)
  end)

  self:registerSignal('OnEndTurn',
  function(timeBtwnTurns)
  	self:resetCamera(timeBtwnTurns)
  	self.activeCommand.done = true
  	self:resumeProgressBars()
  end)
end;

function ATBScheduler:exit()
	self:removeSignals()
end;

function ATBScheduler:enqueueCommand(command, isInterruptible)
  if isInterruptible then
    print('enqueuing command from ' .. command.entity.entityName .. ' in interruptibles queue')
    table.insert(self.commandQueue.interruptibles, command)
  else
    print('enqueuing command from ' .. command.entity.entityName .. ' in uninterruptibles queue')
    table.insert(self.commandQueue.uninterruptibles, command)
  end

  self:checkQueues()
end;

function ATBScheduler:checkQueues()
  if not self.activeCommand then
    if #self.commandQueue.uninterruptibles > 0 then
      self.activeCommand = table.remove(self.commandQueue.uninterruptibles, 1)
    elseif #self.commandQueue.interruptibles > 0 then
      self.activeCommand = table.remove(self.commandQueue.interruptibles, 1)
    end

    if self.activeCommand then 
      if not self.activeCommand.isInterruptible then
        self:interruptProgressBars()
      end
      -- self:entitiesReactToTurnStart()
      print('starting active command belonging to ' .. self.activeCommand.entity.entityName)
      self.activeCommand:start()

    end

  elseif self.activeCommand.done then
    self.activeCommand = nil
    self:checkQueues()
  elseif self.activeCommand.isInterruptible and #self.commandQueue.uninterruptibles > 0 then
    local command = table.remove(self.commandQueue.uninterruptibles, 1)
    self.activeCommand:interrupt()
    table.insert(self.commandQueue.interruptibles, 1, self.activeCommand)
    print('placed active command from ' .. self.activeCommand.entity.entityName .. ' back onto interruptibles list')
    self.activeCommand = command
    print('starting active command belonging to ' .. self.activeCommand.entity.entityName)
    self:interruptProgressBars()
    -- self:entitiesReactToTurnStart()
    self.activeCommand:start()
  end
end;

function ATBScheduler:interruptProgressBars()
  for i,entity in ipairs(self.combatants) do
    entity.pbTween:stop()
    if entity.type == 'character' then
      entity.actionUI = nil
    end
  end
  Entity.hideProgressBar = true
end;

function ATBScheduler:resumeProgressBars()
  for i,entity in ipairs(self.combatants) do
    entity:tweenProgressBar(
    function()
      print(entity.entityName .. "'s turn is ready to begin")
      Signal.emit('OnTurnReady', entity)
    end)
  end
  Entity.hideProgressBar = false
end;

function ATBScheduler:update(dt)
	if self.activeCommand then
		if not self.activeCommand.done then
			self.activeCommand:update(dt)
		end

		if self.activeCommand.done then
			self:checkQueues()
		end
	end

	Scheduler.update(self, dt)
end;