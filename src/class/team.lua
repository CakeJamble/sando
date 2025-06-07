--! filename: team
require("class.entity")

Class = require 'libs.hump.class'
Team = Class{}

  -- Team constructor
function Team:init(entities, numMembers)
  self.members = entities
  self.membersIndex = 1
  self.money = 0
end;

  -- Adds a member to the instance variable self.members list
function Team:addMember(entity) --> void
  self.numMembers = self.numMembers + 1
  self.members[self.numMembers] = entity
end;

function Team:removeMembers(entities) --> void
  local removeIndices = {}
  for i=1, #self.members do
    for j=1, #entities do  
      if self.members[i] == entities[j] then
        table.insert(removeIndices, i)
      end
    end
  end

  for i=1, #removeIndices do
    print('removing ' .. self.members[removeIndices[i]].entityName .. ' from combat')
    table.remove(self.members, removeIndices[i])
  end

  print('done removing')
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
  local result = ''
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

function Team:update(dt)
  for i=1,#self.members do
    self.members[i]:update(dt)
  end
end;

function Team:draw()
  for i=1,#self.members do
    self.members[i]:draw()
  end
end;