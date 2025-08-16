--! filename: team
local Class = require 'libs.hump.class'
local Team = Class{}

function Team:init(entities)
  self.members = entities
  self.membersIndex = 1
  self.money = 0
end;

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
    print('removing ' .. self.members[removeIndices[i]].entityName .. ' from team')
    table.remove(self.members, removeIndices[i])
  end
end;

function Team:getLivingMembers()
  local result = {}
  for _,member in ipairs(self.members) do
    if member:isAlive() then
      table.insert(result, member)
    end
  end
  return result
end;


  -- Iterates over team members to check if they are all knocked out
    -- preconditions: none
    -- postcondition: returns true if team wiped, false otherwise
function Team:isWipedOut() --> bool
  for _,c in pairs(self.members) do
    if c:isAlive() then return false end
  end
  return true
end;

function Team:printMembers()
  for i=1,#self.members do
    print(self.members[i].entityName)
    print('pos: ' .. 'x: ' .. self.members[1].pos.x, 'y: ' .. self.members[i].pos.y)
  end
end;

function Team:update(dt)
  for i=1,#self.members do
    self.members[i]:update(dt)
  end
end;

function Team:draw()
  for _,member in pairs(self.members) do
    member:draw()
  end
end;

return Team