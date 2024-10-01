--! filename: team
require("character")
require('action_ui')

local class = require 'libs/middleclass'
Team = class('Team')


  -- Team constructor
function Team:initialize()
  self.members = {}
  self.numMembers = 0
  self.focusedMember = nil
  self.actionUI = ActionUI(0, 0)
  self.money = 0
end;

  -- Called whenever entering the character select gamestate
function Team:clear()
  Team:initialize()
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
  for i,c in pairs(self.members) do
    if c:isAlive() then return false end
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


function Team:keypressed(key)
  self.actionUI:keypressed(key)
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
  
  if self.focusedMember then
    self.actionUI:update(dt)
  end
  
end;


function Team:draw()
  for _,member in pairs(self.members) do
    member:draw()
  end
  
  if self.focusedMember then
    self.actionUI:draw()
  end
  
end;