local Class = require 'libs.hump.class'

---@type Team
local Team = Class {}

function Team:init(entities)
  self.members = entities
  self.bench = nil
  self.membersIndex = 1
end;

function Team:addMember(entity)
  table.insert(self.members, entity)
end;

function Team:removeMembers(entities)
  local removeIndices = {}
  for i = 1, #self.members do
    for j = 1, #entities do
      if self.members[i] == entities[j] then
        table.insert(removeIndices, i)
      end
    end
  end

  for i = 1, #removeIndices do
    print('removing ' .. self.members[removeIndices[i]].entityName .. ' from team')
    table.remove(self.members, removeIndices[i])
  end
end;

function Team:initBench()
  self.bench = {}
  for i = 2, #self.members do
    local member = table.remove(self.members, i)
    table.insert(self.bench, member)
  end
end;

function Team:moveToBench(index)
  local member = table.remove(self.members, index)
  table.insert(self.bench, member)
end;

function Team:swap(activeIndex, benchIndex)
  if #self.members >= 1 and #self.bench >= 1 then
    local memberToBench = table.remove(self.members, activeIndex)
    local memberToActive = table.remove(self.bench, benchIndex)
    table.insert(self.bench, benchIndex, memberToBench)
    table.insert(self.members, activeIndex, memberToActive)
  end
end;

function Team:getLivingMembers()
  local result = {}
  for _, member in ipairs(self.members) do
    if member:isAlive() then
      table.insert(result, member)
    end
  end
  return result
end;

function Team:isWipedOut()
  for _, c in pairs(self.members) do
    if c:isAlive() then return false end
  end
  return true
end;

function Team:printMembers()
  for i = 1, #self.members do
    print(self.members[i].entityName)
    print('pos: ' .. 'x: ' .. self.members[1].pos.x, 'y: ' .. self.members[i].pos.y)
  end
end;

function Team:update(dt)
  for _, member in ipairs(self.members) do
    member:update(dt)
  end
end;

function Team:draw()
  for _, member in pairs(self.members) do
    member:draw()
  end
end;

return Team
