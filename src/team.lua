--! filename: team
require("character")

local class = require 'libs/middleclass'
Team = class('Team')

  -- Team constructor
function Team:initialize()
  self.members = {}
  self.numMembers = 0
  self.focusedMember = nil
end;

  -- Adds a member to the instance variable self.members list
function Team:addMember(character) --> void
  table.insert(self.members, character)
  self.numMembers = self.numMembers + 1
end;

  -- Iterates over team members to check if they are all knocked out
    -- preconditions: none
    -- postcondition: returns true if team wiped, false otherwise
function Team:isWipedOut() --> bool
  local i,v = next(self.members, nil)
  while i do
    if v:isAlive() then
      return false
    end
    i,v = next(t,i)
  end
  return true
end;

function Team:getMembers() --> table (list)
  return self.members
end;

function Team:getNumMembers() --> int
  return self.numMembers
end;

  -- Sets the focused member to the character
function Team:setFocusedMember(character) --> void
  self.focusedMember = self.members[character]
end;

function Team:getFocusedMember() --> Character
  return self.focusedMember.data
end;

  -- Distributes exp of equal amount to each living player
function Team:distributeExperience(amount)
  for _,member in pairs(self.members) do
    if member:isAlive() then  member:gainExp(amount) end
  end
end;

function Team:update(dt)
  for _,member in pairs(self.members) do
    member:update(dt)
  end
end;

function Team:draw()
  for _,member in pairs(self.members) do
    member:draw()
  end
end;
