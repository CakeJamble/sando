--! filename: command

--[[
  Base Clase for Command Design Pattern
]]

Class = require 'libs.hump.class'
Command = Class{}

function Command:init(entity)
  self.entity = entity
  self.done = false
end;

function Command:start(battle) -- = 0;
end;

function Command:update(dt, battle) -- = 0;
end;