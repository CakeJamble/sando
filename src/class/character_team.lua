--! filename: character team
require('class.team')
require('class.inventory')
require('class.character')

Class = require 'libs.hump.class'
CharacterTeam = Class{__includes = Team}

function CharacterTeam:init(characters, numMembers)
    Team.init(self, characters, numMembers)
    self.inventory = Inventory(Team:getMembers())
end;

function CharacterTeam:addMember(character)
  Team:addMember(character)
end;

function CharacterTeam:at(index)
  local members = Team:getMembers()
  return members[index]
end;

function CharacterTeam:distributeExperience()
end;

function CharacterTeam:getInventory()
    return self.inventory
end;

function CharacterTeam:keypressed(key)
  for i=1, self.numMembers do
    self.members[i]:keypressed(key)
  end
end;