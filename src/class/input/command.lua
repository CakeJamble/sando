local Signal = require('libs.hump.signal')
local Class = require 'libs.hump.class'

---@type Command
local Command = Class{}

function Command:init(entity)
  self.entity = entity
  self.done = false
  self.signalHandlers = {}
  self.isInterruptible = false
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

function Command:start() end
function Command:interrupt() end
function Command:update(dt) end

return Command