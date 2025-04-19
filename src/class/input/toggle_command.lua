--! filename: Toggle Command

--[[
  Toggle Command Class: inherits from the Base Command Class
  
  Toggles the input command between the guard and the jump command
]]

require('class.input.command')
Class = require('libs.hump.class')
ToggleCommand = Class{__includes = Command}

function ToggleCommand:notifyListeners()
  for i=1,self.listeners do
    ToggleCommand:execute()
  end
end;

function ToggleCommand:execute()
  Signal.emit('toggle')
end;
