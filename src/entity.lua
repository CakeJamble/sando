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
  current_skills = {}
  pos = { x=0,y=0 }                 -- current x, y position of character
  dX=0
  dY=0                              -- velocity of character
  frameWidth = stats['width']
  frameHeight = stats['height']
  
  -- Set Skills
  local i,v = next(skills, nil)     -- i is an index of t, v = t[i]
  while i do
    skill = Skill(v)
    table.insert(current_skills, skill)
    i,v = next(skills,i)
  end
  
  frames = {}
  idle = Entity:setIdle(stats['name'])
  currentFrame = 1
end;

-- ACCESSORS

function Entity:getPos()  --> table(x, y)
  return current_stats['pos']
end;

  -- Returns the speed from the stats table
  -- made into a fcn because turn_queue needs speed frequently for sorting turn order
function Entity:getSpeed() --> int
  return current_stats['speed']
end;

function Entity:getStats() --> table
  return current_stats
end;

function Entity:getSkills() --> table
  return current_skills
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

function Entity:setIdle(name)
  image = love.graphics.newImage("asset/sprites/entities/character/marco/marco_idle.png")
  local width = image:getWidth()
  local height = image:getHeight()
  local numFrames = 5
  
  for i=0,numFrames do
    table.insert(frames, love.graphics.newQuad(i * frameWidth, 0, frameWidth, frameHeight, width, height))
  end
  
  return image
end;

function Entity:update(dt) --> void
  currentFrame = currentFrame + 10 * dt
  if currentFrame >= 6 then
    currentFrame = 1
  end
end;

function Entity:draw() --> void
  love.graphics.draw(idle, frames[math.floor(currentFrame)], 100, 100)
end;
  