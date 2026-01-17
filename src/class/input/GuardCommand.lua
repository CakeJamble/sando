--[[
  Guard Command Class: inherits from the Base Command Class
  
  Makes the character guard
]]

require('class.input.command')
Class = require('libs.hump.class')
GuardCommand = Class{__includes = Command}

function GuardCommand:notifyListeners()
  for i=1,self.listeners do
    GuardCommand:execute()
  end
end;

function GuardCommand:execute()
  Signal.emit('guard')
end;
