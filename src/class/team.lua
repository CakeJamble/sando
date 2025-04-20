--! filename: team
require("class.entity")

Class = require 'libs.hump.class'
Team = Class{}


  -- Team constructor
function Team:init(entities, numMembers)
  self.members = entities
  self.oppositionTeamPositions = {}
    
  self.numMembers = numMembers  
  self.membersIndex = 1
  self.money = 0
  

end;

function Team:setOppositionTeamPositions(positions)
  self.oppositionTeamPositions = positions
end;

function Team:getPositions() --> Table({x:int, y:int})
  local result = {}
  for i=1,self.numMembers do
    table.insert(result, self.members[i]:getPos())
  end
  return result
end;

  -- Adds a member to the instance variable self.members list
function Team:addMember(entity) --> void
  self.numMembers = self.numMembers + 1
  self.members[self.numMembers] = entity
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
      return a.battleStats.speed < b.battleStats.speed
    end
    )
end;

function Team:at(i)
  if i ~= nil then
    return self.members[i]
  end
  
end;

function Team:getSpeedAt(i)
  local member = self.members[i]
  return member:getSpeed()
end;


function Team:getMembers() --> table
  return self.members
end;


function Team:getNumMembers() --> int
  return self.numMembers
end;


  -- Verifies that each character is in valid focus state
function Team:setFocusedMember(index) --> void
  if index ~= nil then
    for i=1,self.numMembers do
      self.members[i]:setFocused(index == i)
    end
  else
    for i=1,self.numMembers do
      self.members[i]:setFocused(index == i)
    end
  end
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
  for i=1,self.numMembers do
    self.members[i]:update(dt)
  end
end;


function Team:draw()
  for i=1,self.numMembers do
    self.members[i]:draw()
  end
end;