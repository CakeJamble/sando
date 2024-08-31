--! filename: team
require("character")

local class = require 'libs/middleclass'
Team = class('Team')

  -- Team constructor
function Team:initialize()
  self.members = {}
  self.numMembers = 0
end;

  -- Adds a member to the instance variable self.members table
function Team:addMember(character) --> void
  table.insert(self.members, character)
  self.numMembers = self.numMembers + 1
end;

function Team:isWipedOut() --> bool
  for _,member in ipairs(self.members) do
    if member:isAlive() then
      return false
    end
  end
  return true
end;

function Team:getMembers() --> table (list)
  return self.members
end;

function Team:getNumMembers() --> int
  return self.numMembers
end;