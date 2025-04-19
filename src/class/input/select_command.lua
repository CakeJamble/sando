--! filename: SelectCommand

--[[
  Select Command Class: inherits from the Base Command Class
  
  This class selects highlighted menu items
]]
require('class.input.command')
Class = require('libs.hump.class')
SelectCommand = Class{__includes = Command}

function SelectCommand:execute()
  Signal.emit('select')
end;
