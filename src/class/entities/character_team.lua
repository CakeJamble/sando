--! filename: character team
require('class.entities.team')
require('class.item.inventory')
require('class.entities.character')

Class = require 'libs.hump.class'
CharacterTeam = Class{__includes = Team}

function CharacterTeam:init(characters)
    Team.init(self, characters)
    self.inventory = Inventory(self.members)
end;

function CharacterTeam:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

function CharacterTeam:increaseMoney(amount)
  self.money = self.money + amount
end;

function CharacterTeam:startDefense(incomingSkill)
  for _,character in pairs(self.members) do
    if character:isAlive() then
      character.defenseState:setup(incomingSkill)
    end
  end
end;

function CharacterTeam:keypressed(key)
  for i,member in pairs(self.members) do
    member:keypressed(key)
  end
end;

function CharacterTeam:gamepadpressed(joystick, button)
  for i,member in pairs(self.members) do
    member:gamepadpressed(joystick, button)
  end
end;

function CharacterTeam:gamepadreleased(joystick, button)
  for i,member in pairs(self.members) do
    member:gamepadreleased(joystick, button)
  end
end;
