--! filename: enemy team
require('class.entities.team')
require('class.entities.enemy')

Class = require 'libs.hump.class'
EnemyTeam = Class{__includes = Team}

function EnemyTeam:init(enemies, teamSize)
  Team.init(self, enemies, teamSize)
end;
