--! filename: character team
require('class.team')
require('class.inventory')

local class = require 'libs/middleclass'

CharacterTeam = class('CharacterTeam', Team)

function CharacterTeam:initialize()
    Team:initialize()
    self.inventory = Inventory(Team:getMembers())
end;

function CharacterTeam:distributeExperience()
end;

function CharacterTeam:getInventory()
    return self.inventory
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