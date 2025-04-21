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

function CharacterTeam:distributeExperience()
end;

function CharacterTeam:getInventory()
  return self.inventory
end;


--[[ Keypress is done for each member because you can press their action button
to perform their action (jump for now) at any time during combat,
even when it isn't optimal (unless the focused member is in offense state)]]
function CharacterTeam:keypressed(key)
  for i=1, self.numMembers do
    local m = self.members[i]
    if m.actionUI.active then
    end
    
    self.members[i]:keypressed(key)
  end
end;

function CharacterTeam:gamepadpressed(joystick, button)
  for i=1, self.numMembers do
    local m = self.members[i]
    if m.actionUI.active then
      self.members[i]:gamepadpressed(joystick, button)
    end
  end
end;
