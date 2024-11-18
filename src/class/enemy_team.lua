--! filename: enemy team
require('class.team')
local class = require 'libs/middleclass'

EnemyTeam = class('EnemyTeam', Team)

function EnemyTeam:initialize(enemies, teamSize)
  Team:initialize(enemies, teamSize)
end;

function EnemyTeam:update(dt)
  Team:update(dt)
end;

function EnemyTeam:draw()
  Team:draw()
end;