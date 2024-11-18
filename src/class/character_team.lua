--! filename: character team
require('class.team')
require('class.inventory')
require('class.character')

local class = require 'libs/middleclass'

CharacterTeam = class('CharacterTeam', Team)

function CharacterTeam:initialize(characters, numMembers)
    Team:initialize(characters, numMembers)
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
end;