local Team = require('class.entities.Team')
local Class = require 'libs.hump.class'

---@type EnemyTeam
local EnemyTeam = Class{__includes = Team}

function EnemyTeam:init(enemies)
  Team.init(self, enemies)
end;

return EnemyTeam