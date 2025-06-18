--! filename: turn manager

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

  Signal.register('NextTurn', 
--[[ After sorting the remaining combatants to account for stat changes during the turn,
  set the next active entity, pass them the valid targets for an operation (attack, heal, etc.),
  and start their turn. After starting it, increment the turnIndex for the next combatant. ]]
    function ()
      local koEntities = {}

      -- loop over combatants, and register those who need to be removed from combat
      for i=1, #self.turnQueue do
        local e = self.turnQueue[i]
        print(e.entityName .. ' HP: ' .. e:getHealth())
        if e:getHealth() == 0 then
          table.insert(koEntities, e)
          -- get rewards from enemies and store them for end of combat
          if e.actionUI == nil then
            local reward = e:knockOut()
            if reward then
              table.insert(self.rewards, reward)
            end
          end
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

      for i=1,#self.turnQueue do
        print(self.turnQueue[i].entityName)
      end

      self.enemyTeam:removeMembers(koEntities)
      self.characterTeam:removeMembers(koEntities)

      -- Check Win/Loss Conditions
      if self.enemyTeam:isWipedOut() then
        print('end combat')
        return
      end
      if self.characterTeam:isWipedOut() then
        print('you lose')
        return
      end
      self:sortWaitingCombatants()
      self.activeEntity = self.turnQueue[self.turnIndex]

      -- Reset frame counters for animations for all entities
      for _,e in pairs(self.turnQueue) do
        e.offenseState:reset()
      end

      self.activeEntity:startTurn()
      self.activeEntity:setTargets(self.characterTeam.members, self.enemyTeam.members)
      if self.activeEntity.actionUI == nil then
        self.activeEntity:setupOffense()
      end
      self.turnIndex = (self.turnIndex % #self.turnQueue) + 1
      
    end
  );

  Signal.register('SkillSelected',
    function(skill)
      self.activeEntity.offenseState:setSkill(skill)
    end
  );

  Signal.register('TargetConfirm',
    -- Set target for active entity, get their position, and begin moving towards it
    function(targetType, tIndex)
      print('confirming target for', self.activeEntity.entityName, 'for target type', targetType, 'at index', tIndex)
      self.activeEntity.target = self.activeEntity.targets[targetType][tIndex]
      print('target name is ' .. self.activeEntity.target.entityName)
      local targetPos = self.activeEntity.target:getPos()
      local isEnemy = targetType == 'enemies'
      self.activeEntity.movementState:moveTowards(targetPos.x, targetPos.y, isEnemy)
      self.activeEntity.state = 'move'
    end
  );

  Signal.register('MoveBack',
    -- Signal that is triggered after finishing an attack, as part of ending turn
    function()
      self.activeEntity.state = 'moveback'
      self.activeEntity.movementState:moveBack()
    end
  );


  Signal.register('Attack',
    -- Sets offense state of entity to a valid state to perform attacks
    function(x, y)
      self.activeEntity.state = 'offense'
      self.activeEntity.offenseState.x = x
      self.activeEntity.offenseState.y = y
      self.activeEntity.offenseState.target = self.activeEntity.target
      self.activeEntity.offenseState.skill.sound:play()
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
