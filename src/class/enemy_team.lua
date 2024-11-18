--! filename: enemy team
require('class.team')
Class = require 'libs.hump.class'
EnemyTeam = Class{__includes = Team}

function EnemyTeam:init(enemies, teamSize)
  Team.init(self, enemies, teamSize)
end;

function EnemyTeam:update(dt)
  Team.update(self, dt)
end;

function EnemyTeam:draw()
  Team.draw(self)
end;