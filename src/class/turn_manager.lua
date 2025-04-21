--! filename: turn manager

Class = require('libs.hump.class')
TurnManager = Class{}

function TurnManager:init()
  self.listeners = {}
  self.listenerCount = 0
  self.turnIndex = 0
  self.activeEntity = nil
end;

function TurnManager:update(dt)
  for i=1,#self.listeners do
    self.listeners[i]:update(dt)
  end
end;

function TurnManager:gamepadpressed(joystick, button)
  for i=1,#self.listeners do
    self.listeners[i]:gamepadpressed(joystick, button)
  end
end;

function TurnManager:addListener(listener)
  table.insert(self.listeners, listener)
end;

function TurnManager:removeListener(listener)
  table.remove(self.listeners, listener)
end;

function TurnManager:setNext()
  self.turnIndex = (self.turnIndex + 1) % #self.listeners
  self.activeEntity = self.listeners[self.turnIndex]
  for i=1, #self.listeners do
    self.listeners[i].isFocused = self.listeners[i] == self.activeEntity
  end

  print('Starting turn for:', self.activeEntity.entityName)
end;

function TurnManager:sortQueue()
  table.sort(self.listeners,
    function(entity1, entity2)
      return entity1:getSpeed() < entity2:getSpeed()
    end
  );
end;