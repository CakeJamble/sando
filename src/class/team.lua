--! filename: team
require("class.entity")
require('class.action_ui')

local class = require 'libs/middleclass'
Team = class('Team')


  -- Team constructor
function Team:initialize(entities, numMembers)
  self.members = entities
  self.numMembers = numMembers
  
  self.membersIndex = 1
  self.focusedMember = nil
  self.actionUI = ActionUI(0, 0)
  self.money = 0
end;

  -- Adds a member to the instance variable self.members list
function Team:addMember(entity) --> void
  self.numMembers = self.numMembers + 1
  self.members[self.numMembers] = entity
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
  for i=1,#self.members do
    local entity = self.members[i]
    result = result .. entity:getEntityName() .. ', '
  end
  return result
end;

function Team:sortBySpeed()
  table.sort(self.members, function(a, b) 
      return a:getSpeed() < b:getSpeed()
    end
    )
end;

function Team:getAt(i)
  return self.members[i]
end;

function Team:getSpeedAt(i)
  return self.members[i]:getSpeed()
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
  if Team:isFull() then
    for i=1,numMembers do
      self.members[i]:update(dt)
    end
  end
end;


function Team:draw()
  if Team:isFull() then
    for i=1,numMembers do
      self.members[i]:draw()
    end
  end
end;