--! filename: enemy team
require('class.team')
Class = require 'libs.hump.class'
EnemyTeam = Class{__includes = Team}

function EnemyTeam:init(enemies, teamSize)
  Team:init(enemies, teamSize)
end;

function EnemyTeam:update(dt)
  Team:update(dt)
end;

function EnemyTeam:draw()
  Team:draw()
end;