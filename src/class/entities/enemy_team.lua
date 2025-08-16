--! filename: enemy team
local Team = require('class.entities.team')
local Class = require 'libs.hump.class'
local EnemyTeam = Class{__includes = Team}

function EnemyTeam:init(enemies)
  Team.init(self, enemies)
end;

return EnemyTeam