--! filename: turn manager
require('class.qte.qte_manager')
require('util.globals')
Class = require('libs.hump.class')
TurnManager = Class{}

function TurnManager:init(characterTeam, enemyTeam)
  self.characterTeam = characterTeam
  self.enemyTeam = enemyTeam
  self.turnQueue = self:populateTurnQueue()
  self.turnQueue = self:sortQueue(self.turnQueue)
  self.listenerCount = 0
  self.turnIndex = 1
  self.activeEntity = nil
  self.turnSpentQueue = {}
  self.rewards = {}
  self.qteManager = QTEManager()
  self.combatHazards = {
    characterHazards = {},
    enemyHazards = {}
  }
  self.setupDelay = 0.75

  Signal.register('NextTurn', 
--[[ After sorting the remaining combatants to account for stat changes during the turn,
  set the next active entity, pass them the valid targets for an operation (attack, heal, etc.),
  and start their turn. After starting it, increment the turnIndex for the next combatant. ]]
    function ()
      if self.turnIndex == 1 then
        turnCounter = turnCounter + 1
      else
        self.activeEntity:endTurn()
      end

      self.qteManager:reset()
      local koEntities = {}

      -- loop over combatants, and register enemies who need to be removed from combat
      for i=1, #self.turnQueue do
        local e = self.turnQueue[i]
        print(e.entityName .. ' HP: ' .. e:getHealth())
        if e:getHealth() == 0 and e.type == 'enemy' then
          table.insert(koEntities, e)
          local reward = e:knockOut()
          table.insert(self.rewards, reward)
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

      -- Check Win/Loss Conditions
      if self.enemyTeam:isWipedOut() then
        print('end combat')
        Gamestate.switch(states['reward'], self.rewards)
        return
      end
      if self.characterTeam:isWipedOut() then
        print('you lose')
        return
      end

      self:sortWaitingCombatants()

      while(not self.turnQueue[self.turnIndex]:isAlive()) do
        self.turnIndex = self.turnIndex + 1
      end
      self.activeEntity = self.turnQueue[self.turnIndex]

      -- Reset frame counters for animations for all entities
      for _,e in pairs(self.turnQueue) do
        e.offenseState:reset()
        e:resetDmgDisplay()
        e.state = 'idle'
        if e.type == 'character' then
          e.defenseState:reset()
        end
      end

      self.activeEntity:startTurn(self.combatHazards)
      self.activeEntity:setTargets(self.characterTeam.members, self.enemyTeam.members)
      if self.activeEntity.type == 'enemy' then
        self.activeEntity:setupOffense()
        for _,e in pairs(self.turnQueue) do
          if e.type == 'character' then
            e.state = 'defense'
          end
        end
      end

      self.turnIndex = (self.turnIndex % #self.turnQueue) + 1      
    end
  );

  Signal.register('SkillSelected',
    function(skill)
      print('Setting up QTE Manager for selected skill: ' .. skill.dict.skill_name)
      self.qteManager:setQTE(skill, self.activeEntity)
      self.activeEntity.skill = skill
    end
  );

  Signal.register('SkillDeselected',
    function ()
      self.qteManager:reset()
      self.activeEntity.skill = nil
    end
  );

  Signal.register('TargetConfirm',
    function(targetType, tIndex)
      print('confirming target for', self.activeEntity.entityName, 'for target type', targetType, 'at index', tIndex)
      self.activeEntity.target = self.activeEntity.targets[targetType][tIndex]
      print('target name is ' .. self.activeEntity.target.entityName)
      
      self.activeEntity:goToStagingPosition()
      local t = self.activeEntity:getSkillStagingTime()

      -- Once in position, initialize QTE UI Components
      if self.activeEntity.type == 'character' then
        Timer.after(t, function()
            self.qteManager.activeQTE.showPrompt = true
            self.qteManager.activeQTE.feedbackPos.x = x - 25
            self.qteManager.activeQTE.feedbackPos.y = y - 25
            self.qteManager.countQTEFrames = true

            self.qteManager.activeQTE:proc()
        end)
      else -- go straight into attack
        Timer.after(t, function() Signal.emit('Attack') end)
      end
    end
  );

  Signal.register('MoveBack',
    function(delay)
      Timer.after(delay, function()
        local travelTime = 0.5
        local additionalBufferTime = 0.25
        self.activeEntity:goToStagingPosition(travelTime)    
        Timer.tween(travelTime, self.activeEntity.pos, {x = self.activeEntity.oPos.x, y = self.activeEntity.oPos.y})
        Timer.after(travelTime + additionalBufferTime, function() Signal.emit('NextTurn') end)
      end)
    end
  );


  Signal.register('Attack',
    function()
      Timer.after(self.setupDelay, function()
        self.activeEntity.skill.proc(
          self.activeEntity.target.pos, self.activeEntity.skill.duration,
          self.activeEntity.pos, self.activeEntity.oPos
        )
      end)
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

function TurnManager:update(dt)
  for _,entity in pairs(self.turnQueue) do
    entity:update(dt)
    world:update(entity, entity.pos.x, entity.pos.y)
  end
  self.qteManager:update(dt)

  if self.activeEntity.pos == self.activeEntity.tPos then
    Signal.emit('Attack', self.activeEntity.pos.x, self.activeEntity.pos.y)
  end
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

function TurnManager:draw()
  self.qteManager:draw()
end;