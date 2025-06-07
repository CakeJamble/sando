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
      self:sortWaitingCombatants()
      self.activeEntity = self.turnQueue[self.turnIndex]
      self.activeEntity:startTurn()
      self.activeEntity:setTargets(self.characterTeam.members, self.enemyTeam.members)
      self.turnIndex = (self.turnIndex % #self.turnQueue) + 1

      for i=1, #self.turnQueue do
        local e = self.turnQueue[i]
        print(e.entityName .. ' HP: ' .. e:getHealth())
        if e:getHealth() == 0 then
          local reward = e:knockOut()
          if reward then
            table.insert(self.rewards, reward)
          end
        end
      end

      if self.enemyTeam:isWipedOut() then
        print('end combat')
      end
      if self.characterTeam:isWipedOut() then
        print('you lose')
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
    -- self.commandManager:addListener(self.characterTeam.members[i])
  end
  for i=1,#enemyMembers do
    table.insert(turnQueue, enemyMembers[i])
  end
  return turnQueue
end;

function TurnManager:update(dt)
  for i=1,#self.turnQueue do
    self.turnQueue[i]:update(dt)
  end
end;

function TurnManager:gamepadpressed(joystick, button)
  for i=1,#self.turnQueue do
    self.turnQueue[i]:gamepadpressed(joystick, button)
  end
end;

function TurnManager:removeListener(listener)
  table.remove(self.turnQueue, listener)
end;

function TurnManager:setNext()
  self.turnIndex = (self.turnIndex + 1) % #self.turnQueue
  self.activeEntity = self.turnQueue[self.turnIndex]
  for i=1, #self.turnQueue do
    self.turnQueue[i].isFocused = self.turnQueue[i] == self.activeEntity
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

function TurnManager:sortWaitingCombatants()
  local waitingCombatants = {unpack(self.turnQueue, self.turnIndex, #self.turnQueue)}
  local i=1 
  for j=self.turnIndex, #self.turnQueue do
    self.turnQueue[j] = waitingCombatants[i]
    i = i+1
  end
end;
