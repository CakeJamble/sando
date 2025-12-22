--! filename: enemy team
local Team = require('class.entities.team')
local Class = require 'libs.hump.class'

---@class EnemyTeam: Team
local EnemyTeam = Class{__includes = Team}

---@param enemies Enemy[]
function EnemyTeam:init(enemies)
  Team.init(self, enemies)
end;

return EnemyTeam