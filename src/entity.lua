--! file: entity.lua
require('skill')
require('animation_frame_counts')
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
  self.entityName = stats['entity_name']
  pos = { x=0,y=0 }                     -- current x, y position of character
  self.dX=0
  self.dY=0                             -- velocity of character
  self.frameWidth = stats['width']      -- width of sprite (or width for a single frame of animation for this character)
  self.frameHeight = stats['height']    -- height of sprite (or height for a single frame of animation for this character)
  
  -- State Animations (set by child constructor since the sprite paths depend on the entity type (character, enemy, boss, etc.))
  self.idleImage = nil
  self.moveXImage = nil
  self.moveYImage = nil
  self.moveXYImage = nil
  self.flinchImage = nil
  self.koImage = nil

  -- Set Skills
  for k,v in ipairs(skills) do
    table.insert(skillList, v)
  end

  idleFrames = {}
  moveXFrames = {}
  moveYFrames = {}
  moveXYFrames = {}
  flinchFrames = {}
  koFrames = {}
  
  self.currentFrame = 1
end;

-- ACCESSORS

function Entity:getEntityName() --> string
  return entityName
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

function Entity:getHealth() --> int
  return current_stats['hp']
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

function Entity:setAnimations(subdir)
  -- Images
  local path = 'asset/sprites/entities/' .. subdir .. self.entityName .. '/'
  self.idleImage = love.graphics.newImage(path .. 'idle.png')
--  self.moveXImage = love.graphics.newImage(path .. 'move_x.png')
--  self.moveYImage = love.graphics.newImage(path .. 'move_y.png')
--  self.moveXYImage = love.graphics.newImage(path .. 'move_xy.png')
--  self.flinchImage = love.graphics.newImage(path .. 'flinch.png')
--  self.koImage = love.graphics.newImage(path .. 'ko.png')

  -- Quads
  local durations = get_state_animations(self.entityName)
  Entity:populateFrames(durations['idle_frames'], self.idleImage, idleFrames)
--  Entity:populateFrames(durations['move_x_frames'], self.moveXImage, moveXFrames)
--  Entity:populateFrames(durations['move_y_frames'], self.moveYImage, moveYFrames)
--  Entity:populateFrames(durations['move_xy_frames'], self.moveXYImage, moveXYFrames)
--  Entity:populateFrames(durations['flinch_frames'], self.flinchImage, flinchFrames)
--  Entity:populateFrames(durations['ko_frames'], self.koImage, koFrames)
end;

function Entity:populateFrames(numFrames, image, frames)
    -- Idle
  for i=0,numFrames do
    table.insert(frames, love.graphics.newQuad(i * self.frameWidth, 0, self.frameWidth, self.frameHeight, image:getWidth(), image:getHeight()))
  end
end;

function Entity:update(dt) --> void
  self.currentFrame = self.currentFrame + 10 * dt
  if self.currentFrame >= 6 then
    self.currentFrame = 1
  end
end;

function Entity:draw() --> void
  if self.state == 'idle' then
    love.graphics.draw(self.idleImage, idleFrames[math.floor(self.currentFrame)], 100, 100)
  elseif self.state == 'attacking' then
    
  end
end;
