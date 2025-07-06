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

  Signal.register('NextTurn', 
--[[ After sorting the remaining combatants to account for stat changes during the turn,
  set the next active entity, pass them the valid targets for an operation (attack, heal, etc.),
  and start their turn. After starting it, increment the turnIndex for the next combatant. ]]
    function ()
      if self.turnIndex == 1 then
        turnCounter = turnCounter + 1
      end

      self.qteManager:reset()
      local koEntities = {}

      -- loop over combatants, and register enemies who need to be removed from combat
      for i=1, #self.turnQueue do
        local e = self.turnQueue[i]
        print(e.entityName .. ' HP: ' .. e:getHealth())
        if e:getHealth() == 0 and e.type == 'enemy' then
          table.insert(koEntities, e)
          -- get rewards from enemies and store them for end of combat
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
      print('Setting up QTE Manager for selected skill')
      self.qteManager:setQTE(skill, self.activeEntity)
      self.activeEntity.offenseState:setSkill(skill)
    end
  );

  Signal.register('SkillDeselected',
    function ()
      self.qteManager:reset()
    end
  );

  Signal.register('TargetConfirm',
    -- Set target for active entity, get their position, and begin moving towards it
    function(targetType, tIndex)
      print('confirming target for', self.activeEntity.entityName, 'for target type', targetType, 'at index', tIndex)
      self.activeEntity.target = self.activeEntity.targets[targetType][tIndex]
      print('target name is ' .. self.activeEntity.target.entityName)
      local space
      local isEnemy = targetType == 'enemies'
      if self.activeEntity.type == 'enemy' then
        self.characterTeam:startDefense(self.activeEntity.offenseState.skill)
        space = 96
      else
        self.qteManager.activeQTE.showPrompt = true
        space = -96
      end
      self.activeEntity:goToTarget(space)
    end
  );

  Signal.register('MoveBack',
    -- Signal that is triggered after finishing an attack, as part of ending turn
    function()
      Timer.tween(2, self.activeEntity.pos, {x = self.activeEntity.oPos.x, y = self.activeEntity.oPos.y})
      self.activeEntity.state = 'moveback'
    end
  );


  Signal.register('Attack',
    -- Sets offense state of entity to a valid state to perform attacks
    function(x, y)
      self.activeEntity.state = 'offense'
      self.activeEntity.offenseState.x = x
      self.activeEntity.offenseState.y = y
      if self.activeEntity.type == 'character' then
        self.qteManager.activeQTE.feedbackPos.x = x - 25
        self.qteManager.activeQTE.feedbackPos.y = y - 25
        self.qteManager.activeQTE.countQTEFrames = true
      end
      self.activeEntity.offenseState.target = self.activeEntity.target
      if self.activeEntity.type == 'enemy' then
        self.activeEntity.offenseState.target.defenseState.isEnemyAttacking = true
      end
      self.activeEntity.offenseState.skill.sound:play()
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

-- Uses character and enemy teams to make a single turn queue
function TurnManager:populateTurnQueue()
  local turnQueue = {}
  local characterMembers = self.characterTeam.members
  local enemyMembers = self.enemyTeam.members
  
  -- Add characters to turn queue
  for i=1,#characterMembers do
    table.insert(turnQueue, characterMembers[i])
    -- self.commandManager:addListener(self.characterTeam.members[i])
  end

  -- Add enemies to turn queue
  for i=1,#enemyMembers do
    table.insert(turnQueue, enemyMembers[i])
  end

  return turnQueue
end;

function TurnManager:update(dt)
  for _,entity in pairs(self.turnQueue) do
    entity:update(dt)
  end
  self.qteManager:update(dt)

  if self.activeEntity.pos == self.activeEntity.tPos then
    Signal.emit('Attack', self.activeEntity.pos.x, self.activeEntity.pos.y)
  end
end;

function TurnManager:gamepadpressed(joystick, button)
  for i=1,#self.turnQueue do
    self.turnQueue[i]:gamepadpressed(joystick, button)
  end
end;

-- Sorting algorithm for start of combat
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