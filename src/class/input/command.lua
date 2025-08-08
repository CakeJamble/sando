--! filename: command

--[[
  Base Clase for Command Design Pattern
]]

Class = require 'libs.hump.class'
Command = Class{}

function Command:init(entity)
  self.entity = entity
  self.done = false
  self.signalHandlers = {}
end;

function Command:registerSignal(name, f)
  self.signalHandlers[name] = f
  Signal.register(name, f)
end;

function Command:cleanupSignals()
  for name,f in pairs(self.signalHandlers) do
    Signal.remove(name, f)
  end
  self.signalHandlers = {}
end;

function Command:start(battle) -- = 0;
end;

function Command:update(dt, battle) -- = 0;
end;