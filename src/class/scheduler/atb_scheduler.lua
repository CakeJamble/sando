require('class.scheduler.scheduler')
ATBScheduler = Class{__includes = Scheduler}

-- Active Timer Battle Scheduler

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
	Scheduler.enter(self)
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
		print('OnTurnReady signal emitted')
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
  	self:removeKOs()
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
	self:removeKOs()
  if not self.activeCommand then
    if #self.commandQueue.uninterruptibles > 0 then
      self.activeCommand = table.remove(self.commandQueue.uninterruptibles, 1)
    elseif #self.commandQueue.interruptibles > 0 then
      self.activeCommand = table.remove(self.commandQueue.interruptibles, 1)
    end

    if self.activeCommand then 
      if not self.activeCommand.isInterruptible then
      	print('pausing progress bars 1')
        self:interruptProgressBars()
      end
      -- self:entitiesReactToTurnStart()
      print('starting active command belonging to ' .. self.activeCommand.entity.entityName)
      self.activeCommand:start()

    end

  elseif self.activeCommand.done then
    print('popping active command off from ' .. self.activeCommand.entity.entityName)
    self.activeCommand = nil
    self:checkQueues()
  elseif self.activeCommand.isInterruptible and #self.commandQueue.uninterruptibles > 0 then
    local command = table.remove(self.commandQueue.uninterruptibles, 1)
    self.activeCommand:interrupt()
    table.insert(self.commandQueue.interruptibles, 1, self.activeCommand)
    print('placed active command from ' .. self.activeCommand.entity.entityName .. ' back onto interruptibles list')
    self.activeCommand = command
    print('starting active command belonging to ' .. self.activeCommand.entity.entityName)
  	print('pausing progress bars 2')
    -- self:interruptProgressBars()
    -- self:entitiesReactToTurnStart()
    self.activeCommand:start()
  end
end;

function ATBScheduler:removeKOs()
	Scheduler.removeKOs(self)
	for i,entity in ipairs(self.combatants) do
		if not entity:isAlive() then
			entity.pbTween:stop()
			entity.hideProgressBar = true
		end
	end

	for i,command in ipairs(self.commandQueue.uninterruptibles) do
		if not command.entity:isAlive() then
			table.remove(self.commandQueue.uninterruptibles, i)
		end
	end

	for i,command in ipairs(self.commandQueue.interruptibles) do
		if not command.entity:isAlive() then
			table.remove(self.commandQueue.interruptibles, i)
		end
	end
end;

function ATBScheduler:interruptProgressBars()
  for i,entity in ipairs(self.combatants) do
    entity.pbTween:stop()
    entity.pbTween = nil
    entity.hideProgressBar = true
    print('stopped bar for ' .. entity.entityName)
    if entity.type == 'character' then
      entity.actionUI = nil
    end
  end
end;

function ATBScheduler:resumeProgressBars()
	print('resuming progress bars')
  for i,entity in ipairs(self.combatants) do
  	if entity:isAlive() then
  		entity.hideProgressBar = false
  	end
  	print('resuming progress bar for ' .. entity.entityName)
    entity:tweenProgressBar(
    function()
      print(entity.entityName .. "'s turn is ready to begin")
      Signal.emit('OnTurnReady', entity)
    end)
  end
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