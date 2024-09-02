--! file: entity.lua
require("stat_sheet")
require('skill')
-- global table where all entities are stored
Entities = {} 

local class = require 'libs/middleclass'
Entity = class('Entity')

  -- Entity constructor
    -- preconditions: defined stats and skills tables
    -- postconditions: Valid Entity object and added to global table of Entities
function Entity:initialize(stats, skills)
  current_stats = stats
  skillList = {}
  name = stats['name']
  pos = { x=0,y=0 }                 -- current x, y position of character
  dX=0
  dY=0                              -- velocity of character
  frameWidth = stats['width']
  frameHeight = stats['height']
  
  -- Set Skills
  local i,v = next(skills, nil)     -- i is an index of t, v = t[i]
  while i do
    skill = Skill(v)
    table.insert(skillList, skill)
    i,v = next(skills,i)
  end
  
  frames = {}
  currentFrame = 1
end;

-- ACCESSORS

function Entity:getEntityName() --> string
  return name
end;

function Entity:getPos()  --> table(x, y)
  return current_stats['pos']
end;

function Entity:getFWidth()
  return frameWidth
end;
  
function Entity:getFHeight()
  return frameHeight
end;

function Entity:getSpeed() --> int
  return current_stats['speed']
end;

function Entity:getStats() --> table
  return current_stats
end;

function Entity:getSkills() --> table
  return skillList
end;

function Entity:isAlive() --> bool
  return current_stats['hp'] > 0
end;

-- MUTATORS

function Entity:setPos(x, y) --> void
  pos['x'] = x
  pos['y'] = y
end;

function Entity:setDXDY(dx, dy) --> void
  dX = dx
  dY = dy
end;


function Entity:heal(amount) --> void
  current_stats["hp"] = math.min(current_stats["hp"], current_stats["hp"] + amount)
end;

function Entity:takeDamage() --> void
  current_stats["hp"] = math.max(0, current_stats["hp"] - amount)
end;

function Entity:update(dt) --> void
  currentFrame = currentFrame + 10 * dt
  if currentFrame >= 6 then
    currentFrame = 1
  end
end;
  