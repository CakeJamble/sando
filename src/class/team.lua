--! filename: team
require("class.entity")
require('class.action_ui')

local class = require 'libs/middleclass'
Team = class('Team')


  -- Team constructor
function Team:initialize(teamSize)
  self.members = {}
  for i=1,teamSize do
    self.members[i] = {}
  end
  self.membersIndex = 1
  self.numMembers = teamSize
  self.focusedMember = nil
  self.actionUI = ActionUI(0, 0)
  self.money = 0
end;

function Team:copy(otherObj)
  local otherMembers = otherObj:getMembers()
  for i=1,#otherMembers do
    self.members[i] = otherMembers[i]
  end
  self.membersIndex = otherObj.membersIndex
  self.focusedMember = otherObj.focusedMember
  self.actionUI = otherObj.actionUI
  self.money = otherObj.money
end;

  -- Called whenever entering the character select gamestate
function Team:clear()
  Team:initialize()
end;

  -- Adds a member to the instance variable self.members list
function Team:addMember(entity) --> void
  self.members[self.membersIndex] = entity
  self.membersIndex = self.membersIndex + 1
end;

function Team:isFull()
  return self.membersIndex == self.numMembers
end;

  -- Iterates over team members to check if they are all knocked out
    -- preconditions: none
    -- postcondition: returns true if team wiped, false otherwise
function Team:isWipedOut() --> bool
  for i,c in pairs(self.members) do
    if c:isAlive() then return false end
  end
  return true
end;

function Team:printMembers()
  result = ''
  for i,char in ipairs(self.members) do
    result = result .. char:getEntityName() .. ', '
  end
  return result
end;



function Team:getMembers() --> table
  return self.members
end;


function Team:getNumMembers() --> int
  return self.numMembers
end;


  -- Sets the focused member to the character
function Team:setFocusedMember(character) --> void
  self.focusedMember = character
  self.actionUI:setPos(self.focusedMember:getX() + 25, self.focusedMember:getY() - 50)
end;


function Team:getFocusedMember() --> Character
  return self.focusedMember
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