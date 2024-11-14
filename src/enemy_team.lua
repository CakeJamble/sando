--! filename: enemy team
require('team')
local class = require 'libs/middleclass'

EnemyTeam = class('EnemyTeam', Team)

function EnemyTeam:initialize()
    Team:initialize()
end;

function EnemyTeam:update(dt)
    Team:update(dt)
end;