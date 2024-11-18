--! filename: enemy team
require('class.team')
local class = require 'libs/middleclass'

EnemyTeam = class('EnemyTeam', Team)

function EnemyTeam:initialize(teamSize)
  Team:initialize(teamSize)
end;

function EnemyTeam:update(dt)
  Team:update(dt)
end;

function EnemyTeam:draw()
  for _,member in pairs(Team:getMembers()) do
    member:draw()
    if member == Team:getFocusedMember() then
      member:getActionUI():draw()
    end
  end
end;
  