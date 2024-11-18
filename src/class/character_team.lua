--! filename: character team
require('class.team')
require('class.inventory')
require('class.character')

local class = require 'libs/middleclass'

CharacterTeam = class('CharacterTeam', Team)

function CharacterTeam:initialize(teamSize)
    Team:initialize(teamSize)
    self.inventory = Inventory(Team:getMembers())
end;

function CharacterTeam:addMember(index)
  if index == 0 then
    bake = Character(get_bake_stats(), 'b')
    Team:addMember(bake)
    print(bake:getEntityName() .. ' added to team')
  elseif index == 1 then
    marco = Character(get_marco_stats(), 'm')
    Team:addMember(marco)
    print(marco:getEntityName() .. ' added to team')
  elseif index == 2 then
    maria = Character(get_maria_stats(), 'a')
    Team:addMember(maria)
  elseif index == 3 then
    key = Character(get_key_stats(), 'k')
    Team:addMember(key)
  end
end;

function CharacterTeam:copy(otherObj)
  Team:copy(otherObj)
  self.inventory = otherObj.inventory
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
  local members = Team:getMembers()
  for _,member in ipairs(members) do
    member:draw()
    if member == Team:getFocusedMember() then
      member:getActionUI():draw()
    end
  end
end;