--! filename: Jump Command

--[[
  Jump Command Class: inherits from the Base Command Class
  
  Makes the character jump
]]

require('class.input.command')
Class = require('libs.hump.class')
JumpCommand = Class{__includes = Command}

function JumpCommand:notifyListeners(signal)
  for i=1,self.listeners do
    Signal.emit(signal, JumpCommand:execute())
  end
end;

function JumpCommand:execute(actor)
  
end;
