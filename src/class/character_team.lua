--! filename: character team
require('class.team')
require('class.inventory')
require('class.character')

Class = require 'libs.hump.class'
CharacterTeam = class('CharacterTeam', Team)

function CharacterTeam:init(characters, numMembers)
    Team:init(characters, numMembers)
    self.inventory = Inventory(Team:getMembers())
end;

function CharacterTeam:addMember(character)
  Entity:addMember(character)
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
  Team:draw()
  love.graphics.print(self.members[1]:getEntityName(), 100, 100)
end;