local Signal = require('libs.hump.signal')
local Class = require 'libs.hump.class'

---@class Command
local Command = Class{}

---@param entity Entity
function Command:init(entity)
  self.entity = entity
  self.done = false
  self.signalHandlers = {}
end;

---@param name string
---@param f fun(...)
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

return Command