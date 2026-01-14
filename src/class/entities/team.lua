local Class = require 'libs.hump.class'

---@class Team
local Team = Class{}

---@param entities Entity[]
function Team:init(entities)
  self.members = entities
  self.bench = nil
  self.membersIndex = 1
  self.money = 0
end;

---@param entity Entity
function Team:addMember(entity) --> void
  self.numMembers = self.numMembers + 1
  self.members[self.numMembers] = entity
end;

---@param entities Entity[]
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

function Team:initBench()
  self.bench = {}
  for i=2,#self.members do
    local member = table.remove(self.members, i)
    table.insert(self.bench, member)
  end
end;

---@param index integer
function Team:moveToBench(index)
  local member = table.remove(self.members, index)
  table.insert(self.bench, member)
end;

---@param activeIndex integer Index of active member going to the bench
---@param benchIndex integer Index of bench member entering combat
function Team:swap(activeIndex, benchIndex)
  if #self.members >=1 and #self.bench >= 1 then
    local memberToBench = table.remove(self.members, activeIndex)
    local memberToActive = table.remove(self.bench, benchIndex)
    table.insert(self.bench, benchIndex, memberToBench)
    table.insert(self.members, activeIndex, memberToActive)
  end
end;

---@return Entity[]
function Team:getLivingMembers()
  local result = {}
  for _,member in ipairs(self.members) do
    if member:isAlive() then
      table.insert(result, member)
    end
  end
  return result
end;

---@return boolean
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

---@param dt number
function Team:update(dt)
  for _,member in ipairs(self.members) do
    member:update(dt)
  end
end;

function Team:draw()
  for _,member in pairs(self.members) do
    member:draw()
  end
end;

return Team