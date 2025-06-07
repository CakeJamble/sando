--! filename: character team
require('class.team')
require('class.inventory')
require('class.character')

Class = require 'libs.hump.class'
CharacterTeam = Class{__includes = Team}

function CharacterTeam:init(characters, numMembers)
    Team.init(self, characters, numMembers)
    self.inventory = Inventory(self.members)
end;

-- Distributes exp of equal amount to each living player
function Team:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

function Team:getMoney()
  return self.money
end;

function Team:increaseMoney(amount)
  self.money = self.money + amount
end;

function CharacterTeam:getInventory()
  return self.inventory
end;

function CharacterTeam:keypressed(key)
  for i=1, #self.members do
    self.members[i]:keypressed(key)
  end
end;

function CharacterTeam:gamepadpressed(joystick, button)
  for i=1, #self.members do
      self.members[i]:gamepadpressed(joystick, button)
  end
end;
