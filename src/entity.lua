--! file: entity.lua
require("stat_sheet")
-- global table where all entities are stored
Entities = {} 

local class = require 'libs/middleclass'
Entity = class('Entity')

  -- Entity constructor
    -- preconditions: defined stats and skills tables
    -- postconditions: Valid Entity object and added to global table of Entities
function Entity:initialize(stats, skills)
  self.stats = stats
  self.current_stats = stats
  self.skills = skills
  self.animations = Entity:addAnimations(self.skills)
end;

  -- Create and return a list of animations
    -- preconditions: a dictionary (table) of skills corresponding to the Entity
    -- postconditions: returns a list (table) of animations
function Entity:addAnimations(skill_dict)
  local animations = {}
  for i, skill in ipairs(skill_dict) do
    sprite_path = skill["sprite_path"]
    animation = newAnimation(sprite_path, sprite_path:getWidth(), sprite_path:getHeight(), duration)
    animations[i] = animation
    i = i + 1
  end
  return animations
end; 

  -- Create and return a new animation
    -- preconditions: A love.graphics.newImage object, the width, height, and duration (number of frames)
    -- postconditions: Returns an animation using a table of quads from a spritesheet
function Entity:newAnimation(image, width, height, duration)
  local animation = {}
  animation.spriteSheet = image
  animation.quads = {}
  
  for y = 0, image:getHeight() - height, height do
    for x = 0, image:getWidth() - width, width do
      table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
  end
  
  animation.duration = duration or 1
  animation.currentTime = 0
    
  return animation 
end;

function Entity:getPos()  --> table(x, y)
  return self.stats['pos']
end;

  -- Returns the speed from the stats table
  -- made into a fcn because turn_queue needs speed frequently for sorting turn order
function Entity:getSpeed() --> int
  return self.stats['speed']
end;

function Entity:getStats() --> table
  return self.stats
end;

function Entity:getSkills() --> table
  return self.skills
end;

function Entity:heal(amount) --> void
  self.current_stats["hp"] = math.min(self.stats["hp"], self.current_stats["hp"] + amount)
end;

function Entity:takeDamage() --> void
  self.current_stats["hp"] = math.max(0, self.current_stats["hp"] - amount)
end;

function Entity:isAlive() --> bool
  return self.current_stats['hp'] > 0
end;

function Entity:draw() --> void
end;
  