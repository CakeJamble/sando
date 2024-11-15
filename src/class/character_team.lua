--! filename: character team
require('class.team')

local class = require 'libs/middleclass'

CharacterTeam = class('CharacterTeam', Team)

function CharacterTeam:initialize()
    Team:initialize()
end;

function CharacterTeam:distributeExperience()
end;

function CharacterTeam:keypressed(key)
   Team:getFocusedMember():keypressed(key)
end;

function CharacterTeam:update(dt)
    Team:update(dt)
end;

function CharacterTeam:draw()
    for _,member in pairs(members) do
        member:draw()
        if member == Team:getFocusedMember() then
            member:getActionUI():draw()
        end
    end
end;