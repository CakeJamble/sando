require('class.input.player_input_command')
require('class.input.skill_command')
require('class.input.cancel_command')
require('class.input.ai_command')
require('class.qte.qte_manager')
require('util.globals')
Class = require('libs.hump.class')
TurnManager = Class{isATB = true}

function TurnManager:init(characterTeam, enemyTeam)
  self.characterTeam = characterTeam
  self.enemyTeam = enemyTeam
  self.turnQueue = {}
  self.combatants = self:populateTurnQueue()

  -- ATB system will insert entities into queue when they are ready
  if not TurnManager.isATB then
    self.turnQueue = self:populateTurnQueue()
    self.turnQueue = self:sortQueue(self.turnQueue)
  end

  self.listenerCount = 0
  self.turnIndex = 1
  self.activeEntity = nil
  self.turnSpentQueue = {}
  self.rewards = {}
  self.qteManager = QTEManager(characterTeam)
  self.combatHazards = {
    characterHazards = {},
    enemyHazards = {}
  }
  self.setupDelay = 0.75
  self.instructions = nil
  self.instructionsPos = {x=200,y=300}
  self.cameraPosX, self.cameraPosY = camera:position()

  -- ATB Variables
  self.commandQueue = {
    interruptibles = {},
    uninterruptibles = {}
  }
  self.activeCommand = nil
  self.awaitingPlayerAction = false

  Signal.register('NextTurn', 
--[[ After sorting the remaining combatants to account for stat changes during the turn,
  set the next active entity, pass them the valid targets for an operation (attack, heal, etc.),
  and start their turn. After starting it, increment the turnIndex for the next combatant. ]]
    function ()
      if self.turnIndex == 1 then
        turnCounter = turnCounter + 1
      end

      self.qteManager:reset()
      self:removeKOs()

      if TurnManager.isATB then
        if #self.commandQueue > 0 then
          local command = table.remove(self.commandQueue, 1)
          command:start()
        end
      elseif not self:winLossConsMet() then
        self:sortWaitingCombatants()

        -- skip over KO'd Characters (they don't get removed from queue bc they can be revived)
        while(not self.turnQueue[self.turnIndex]:isAlive()) do
          self.turnIndex = self.turnIndex + 1
        end

        self.activeEntity = self.turnQueue[self.turnIndex]
        self.activeEntity:startTurn(self.combatHazards)
        self.activeEntity:setTargets(self.characterTeam.members, self.enemyTeam.members)
        self:entitiesReactToTurnStart()

        self.turnIndex = (self.turnIndex % #self.turnQueue) + 1
      end
    end
  );

  -- Signal.register('PassTurn',
  --   function()
  --     self.activeEntity.actionUI:unset()
  --     Signal.emit('OnEndTurn', 0)
  --   end
  -- );

  -- Signal.register('SkillSelected',
  --   function(skill)
  --     print('Setting up QTE Manager for selected skill: ' .. skill.name)
  --     -- self.qteManager:setQTE(skill.qteType, self.activeEntity.actionButton)
  --     if not skill.isOffensive then
  --       self.activeEntity.actionUI.targetType = 'characters'
  --       self.activeEntity.actionUI.backButton.playerUsingNonOffensiveSkill = true
  --     else
  --       self.activeEntity.actionUI.targetType = 'enemies'
  --       self.activeEntity.actionUI.backButton.playerUsingNonOffensiveSkill = false
  --     end
  --     self.activeEntity.skill = skill
  --     self.activeEntity.actionUI.uiState = 'targeting'

  --     if self.activeEntity.type == 'character' then
  --       self.instructions = self.qteManager:getInstructions(skill.qteType, self.activeEntity.actionButton)
  --     end

  --   end
  -- );

  -- Signal.register('SkillDeselected',
  --   function ()
  --     self.qteManager:reset()
  --     self.instructions = nil
  --     self.activeEntity.skill = nil
  --   end
  -- );

  -- Signal.register('TargetConfirm',
  --   function(targetType, tIndex)
  --     self.instructions = nil
  --     print('confirming target for', self.activeEntity.entityName, 'for target type', targetType, 'at index', tIndex)
  --     self.activeEntity.target = self.activeEntity.targets[targetType][tIndex]
  --     print('target name is ' .. self.activeEntity.target.entityName)
  --     -- Skill should control qte because some skills deal damage during QTE
  --     if self.activeEntity.type == 'character' then
  --       self.qteManager:setQTE(self.activeEntity.skill.qteType, self.activeEntity.actionButton, self.activeEntity.skill)
  --       self.qteManager.activeQTE:setUI(self.activeEntity)
  --       self.qteManager.activeQTE:beginQTE()
  --     else
  --       Signal.emit('Attack')
  --     end
  --   end
  -- );

  -- Signal.register('OnQTESuccess',
  --   function()
  --     self.activeEntity.qteSuccess = true
  --   end)

  -- Signal.register('Attack',
  --   function()
  --     print('attacking')
  --     self.activeEntity.skill.proc(self.activeEntity, self.qteManager)
  --   end
  -- );

  Signal.register('OnEndTurn', 
    function(timeBtwnTurns)
      local withTimeToBreathe = timeBtwnTurns + 0.25
      self:resetCamera(timeBtwnTurns)
      Timer.after(withTimeToBreathe , function() Signal.emit('NextTurn') end)
    end
  );

  Signal.register('PlacedHazards',
    function(entityType, hazard)
      if entityType == 'character' then
        table.insert(self.combatHazards.enemyHazards, hazard)
      else
        table.insert(self.combatHazards.characterHazards, hazard)
      end
    end
  );

  Signal.register('ProjectileMade', 
    function(projectile)
      self.activeEntity.projectile = projectile
    end
  );

  Signal.register('DespawnProjectile',
    function() 
      self.activeEntity.projectile = nil 
      print('Projectile destroyed')
    end
  );

----------------- ATB Signals ------------------------
  Signal.register('OnStartCombat',
    function()
      if TurnManager.isATB then
        for i,entity in ipairs(self.combatants) do
          entity:tweenProgressBar(function()
            print(entity.entityName .. "'s turn is ready to begin")
            Signal.emit('TurnReady', entity)
          end
          )
        end
      end
    end
  );

  Signal.register('TurnReady',
    function(entity)
      -- enqueue the command to get their desired action
      local command
      local isInterrupt
      if entity.type == 'character' then
        command = PlayerInputCommand(entity, self)
        isInterrupt = false
      else
        command = AICommand(entity, self)
        isInterrupt = true
      end

      self:enqueueCommand(command, isInterrupt)
    end
  );
end;

function TurnManager:resetCamera(duration)
  flux.to(camera, duration, {x = self.cameraPosX, y = self.cameraPosY, scale = 1})
end;

function TurnManager:populateTurnQueue()
  local turnQueue = {}
  local characterMembers = self.characterTeam.members
  local enemyMembers = self.enemyTeam.members
  
  for i=1,#characterMembers do
    table.insert(turnQueue, characterMembers[i])
  end
  for i=1,#enemyMembers do
    table.insert(turnQueue, enemyMembers[i])
  end

  return turnQueue
end;

-- loop over combatants, and register enemies who need to be removed from combat
function TurnManager:removeKOs()
  local koEntities = {}
  for i=1, #self.turnQueue do
    local e = self.turnQueue[i]
    print(e.entityName .. ' HP: ' .. e:getHealth())
    if e:getHealth() == 0 and e.type == 'enemy' then
      table.insert(koEntities, e)
      local reward = e:knockOut()
      table.insert(self.rewards, reward)
    else  -- setup survivors for next turn
      self.turnQueue[i]:resetDmgDisplay()
      self.turnQueue[i].state = 'idle'
    end
  end

  local removeIndices = {}
  for i=1, #self.turnQueue do
    for j=1, #koEntities do
      if self.turnQueue[i] == koEntities[j] then
        table.insert(removeIndices, i)
      end
    end
  end

  for i=1, #removeIndices do
    print('removing ' .. self.turnQueue[removeIndices[i]].entityName .. ' from combat')
    table.remove(self.turnQueue, removeIndices[i])
  end

  self.enemyTeam:removeMembers(koEntities)
end;

function TurnManager:winLossConsMet()
  local result = false
  print('checking win loss cons')
  if self.enemyTeam:isWipedOut() then
    print('end combat')
    Gamestate.switch(states['reward'], self.rewards)
    result = true
  end
  if self.characterTeam:isWipedOut() then
    print('you lose')
    result = true
  end

  return result
end;

function TurnManager:draw()
  self.qteManager:draw()
  if self.instructions then
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.instructions, self.instructionsPos.x, self.instructionsPos.y)
    love.graphics.setColor(1, 1, 1)
  end
end;

----------------- Standard Turn-Based Combat -----------------

function TurnManager:entitiesReactToTurnStart()
  if self.activeEntity.type == 'enemy' then
    self.activeEntity:setupOffense()
    for _,e in pairs(self.turnQueue) do
      if e.type == 'character' then
        e.state = 'defense'
      end
    end
  end
end;

function TurnManager:update(dt)
  if TurnManager.isATB then
    if self.activeCommand and not self.activeCommand.done then
      self.activeCommand:update(dt)
    elseif #self.commandQueue > 0 then
      self.activeCommand = table.remove(self.commandQueue, 1)
      self.activeCommand:start(self)
    end
  end

  for _,entity in pairs(self.combatants) do
    entity:update(dt)
  end
  self.qteManager:update(dt)
end;

function TurnManager:sortQueue(t)
  table.sort(t,
    function(entity1, entity2)
      return entity1:getSpeed() > entity2:getSpeed()
    end
  );
  return t
end;

--[[ Sorting algorithm for start of a turn
During a turn, buffs/debuffs can alter a combatants speed.
We want the turn queue to reflect these changes immediately,
but it shouldn't allow characters whose turns have already been completed to go twice.
This only sorts characters who haven't take their turn yet this round.]]
function TurnManager:sortWaitingCombatants()
  local waitingCombatants = {unpack(self.turnQueue, self.turnIndex, #self.turnQueue)}
  local i=1 
  for j=self.turnIndex, #self.turnQueue do
    self.turnQueue[j] = waitingCombatants[i]
    i = i+1
  end
end;

----------------- Active Timer Battle Combat -----------------

function TurnManager:enqueueCommand(command, isInterrupt)
  if not self.activeCommand then
    self.activeCommand = command
    command:start(self)
  else
    if isInterrupt then
      table.insert(self.commandQueue.uninterruptibles, command)
    else
      table.insert(self.commandQueue.interruptibles, command)
    end
  end
end;