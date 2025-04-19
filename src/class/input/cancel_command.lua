--! filename: Cancel Command

--[[
  Cancel Command Class: inherits from the Base Command Class
  
  This class should go back to the previous menu context
]]
require('class.input.command')
Class = require('libs.hump.class')
CancelCommand = Class{__includes = Command}

function CancelCommand:execute()
  Signal.emit('cancel')
end;
