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
  -- table.insert(self.members, character)
  self.members = {next = self.members, data = character}
  self.numMembers = self.numMembers + 1
end;

  -- Iterates over team members to check if they are all knocked out
    -- preconditions: none
    -- postcondition: returns true if team wiped, false otherwise
function Team:isWipedOut() --> bool
  local t = self.members
  while t do
    if t.data:isAlive() then
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

  -- Sets the focused member to the front of the members linked list
function Team:setFocusedMember() --> void
  self.focusedMember = self.members
end;

  -- Set the focused member to the next member of the members linked list
function Team:nextFocusedMember() --> void
  self.focusedMember = self.focusedMember.next
end;

function Team:getFocusedMember() --> Character
  return self.focusedMember.data
end;

  -- Creates and returns a table of Character objects
function Team:teamLLToTable() --> table
  local t = self.members
  local teamTable = {}
  while t do
    table.insert(teamTable, t.data)
    t = t.next
  end
  
  return teamTable
end;
