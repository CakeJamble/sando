--! filename: turn manager

Class = require('libs.hump.class')
TurnManager = Class{}

function TurnManager:init()
  self.listeners = {}
  self.listenerCount = 0
  self.turnIndex = 0
  self.activeEntity = nil
end;

function TurnManager:addListener(listener)
  table.insert(self.listeners, listener)
end;

function TurnManager:removeListener(listener)
  table.remove(self.listeners, listener)
end;

function TurnManager:setNext()
  self.turnIndex = self.turnIndex + 1
  self.activeEntity = self.listeners[self.turnIndex]
  -- self.activeCharacter:startTurn()
end;

function TurnManager:notifyListeners()
  local myTurnName = self.listeners[self.turnIndex].entityName
end;