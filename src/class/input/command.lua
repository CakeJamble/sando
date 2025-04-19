--! filename: command

--[[
  Base Clase for Command Design Pattern
]]

Class = require 'libs.hump.class'
Command = Class{}

function Command:init()
  self.listeners = {}
end;

function Command:addListener(listener)
  table.insert(self.listeners, listener)
end;

function Command:notifyListeners(signal)
  for i=1,self.listeners do
    Signal.emit(signal, Command:execute())
  end
end;

function Command:execute()
  -- does nothing by default
end;
