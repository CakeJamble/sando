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
    entity.hideProgressBar = true
    local command
    local isInterrupt
    if entity.type == 'character' then
      command = PlayerInputCommand(entity, self)
    else
      command = AICommand(entity, self)
    end

    self:enqueueCommand(command, command.isInterruptible)
  end)

  self:registerSignal('TargetConfirm',
  function()
    print('target confirmed')

    for i,entity in ipairs(self.combatants) do
      if entity.tweens['pbTween'] then
        print('stopping ' .. entity.entityName .. "'s progress bar")
        entity.tweens['pbTween']:stop()
        entity.tweens['pbTween'] = nil
      else
        print(entity.entityName .. ' had no progress bar to stop')
      end
      entity.hideProgressBar = true
    end
  end)

  self:registerSignal('OnEndTurn',
  function(timeBtwnTurns)
  	self:resetCamera(timeBtwnTurns)
  	self.activeCommand.done = true
  	self:removeKOs()

    for i,entity in ipairs(self.combatants) do
      print('starting ' .. entity.entityName .. "'s progress bar")
      entity:tweenProgressBar(function() Signal.emit('OnTurnReady', entity) end)
      entity.hideProgressBar = false
    end
  end)
end;

function ATBScheduler:exit()
	self:removeSignals()
end;

function ATBScheduler:enqueueCommand(command, isInterruptible)
	print(command.entity.entityName, 'pb width / 50 =', command.entity.progressBar.meterOptions.width )
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
      -- self:entitiesReactToTurnStart()
      print('starting active command belonging to ' .. self.activeCommand.entity.entityName)
      self.activeCommand:start(self)
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
    self.activeCommand:start(self)
  end
end;

function ATBScheduler:removeKOs()
	Scheduler.removeKOs(self)
	for i,entity in ipairs(self.combatants) do
		if not entity:isAlive() then
			entity:stopProgressBar()
			entity.hideProgressBar = true
      entity.tweens['pbTween'] = nil
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