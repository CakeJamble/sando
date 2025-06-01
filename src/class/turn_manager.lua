--! filename: turn manager

Class = require('libs.hump.class')
TurnManager = Class{}

function TurnManager:init(characterTeam, enemyTeam)
  self.characterTeam = characterTeam
  self.enemyTeam = enemyTeam
  self.turnQueue = self:populateTurnQueue()
  self:sortQueue()
  self.listenerCount = 0
  self.turnIndex = 1
  self.activeEntity = nil

  Signal.register('NextTurn', 
    function ()
      self.activeEntity = self.turnQueue[self.turnIndex]
      self.activeEntity:startTurn()
      self.activeEntity:setTargets(self.characterTeam.members, self.enemyTeam.members)
      self.turnIndex = (self.turnIndex % #self.turnQueue) + 1
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

function TurnManager:sortQueue()
  table.sort(self.turnQueue,
    function(entity1, entity2)
      return entity1:getSpeed() > entity2:getSpeed()
    end
  );
end;