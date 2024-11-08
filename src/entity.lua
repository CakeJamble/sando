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
function Entity:initialize(stats, skills, x, y)
  current_stats = stats
  battle_stats = stats
  skillList = {}
  self.entityName = stats['entityName']
  self.x=x
  self.y=y
  self.dX=0
  self.dY=0
  self.frameWidth = stats['width']      -- width of sprite (or width for a single frame of animation for this character)
  self.frameHeight = stats['height']    -- height of sprite (or height for a single frame of animation for this character)

  -- Set Skills
  for k,v in ipairs(skills) do
    table.insert(skillList, v)
  end
  
  self.currentFrame = 1
  self.movement_state = MovementState(self.x, self.y, self.frameHeight)
end;


-- ACCESSORS

function Entity:getEntityName() --> string
  return self.entityName
end;

function Entity:getX()  --> int
  return self.x
end;

function Entity:getY()  --> int
  return self.y
end;

function Entity:getFWidth()
  return self.frameWidth
end;
  
function Entity:getFHeight()
  return self.frameHeight
end;

function Entity:getSpeed() --> int
  return battle_stats['speed']
end;

function Entity:getHealth() --> int
  return battle_stats['hp']
end;

function Entity:getMaxHealth() --> int
  return current_stats['hp']
end;

function Entity:getStats() --> table
  return current_stats
end;

function Entity:getSkills() --> table
  return skillList
end;

function Entity:isAlive() --> bool
  return battle_stats['hp'] > 0
end;

-- MUTATORS

function Entity:raiseBattleStat(stat_name) --> void
  battle_stats[stat_name] = math.ceil(battle_stats[stat_name] * 1.25)
end;

function Entity:setPos(x, y) --> void
  self.x = x
  self.y = y
end;

function Entity:setDXDY(dx, dy) --> void
  dX = dx
  dY = dy
end;

function Entity:setMovementState(state) --> void
  self.movement_state = state
end;

function Entity:heal(amount) --> void
  battle_stats["hp"] = math.min(battle_stats["hp"], battle_stats["hp"] + amount)
end;

function Entity:takeDamage() --> void
  battle_stats["hp"] = math.max(0, battle_stats["hp"] - amount)
end;

-- ONLY run this after setting current_stats HP to reflect damage taken during battle
function Entity:resetStatModifiers() --> void
  for stat,val in pairs(current_stats) do
    if stat ~= 'hp' or stat ~= 'fp' then
      battle_stats[stat] = current_stats[stat]
    end
  end
end;

  -- Sets the animations that all Entities have in common (idle, move_x, flinch, ko)
  -- Shared animations are called by the child classes since the location of the subdir depends on the type of class
function Entity:setAnimations(subdir)
  -- Images
  local path = 'asset/sprites/entities/' .. subdir .. self.entityName .. '/'
  self.idleImage = love.graphics.newImage(path .. 'idle.png')
--  self.moveXImage = love.graphics.newImage(path .. 'move_x.png')
--  self.flinchImage = love.graphics.newImage(path .. 'flinch.png')
--  self.koImage = love.graphics.newImage(path .. 'ko.png')

  -- Quads
  local durations = get_state_animations(self.entityName)
  Entity:populateFrames(durations['idle_frames'], self.idleImage, idleFrames)
--  Entity:populateFrames(durations['move_x_frames'], self.moveXImage, moveXFrames)
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
  if self.currentFrame >= 6 then -- hardcoded for testing initial animation :(
    self.currentFrame = 1
  end
end;

-- Should draw using the animation in the valid state (idle, moving (in what direction), jumping, etc.)
function Entity:draw() --> void
  if self.movement_state == 'idle' then
    love.graphics.draw(self.idleImage, idleFrames[math.floor(self.currentFrame)], self.x, self.y)
  elseif self.movement_state == 'moveX' then
    print("Moving left and right")
  elseif self.movement_state == 'moveY' then
    print("Moving up and down")
  elseif self.movement_state == 'moveXY' then
    print("Moving diagonally")
  elseif self.movement_state == 'flinch' then
    print("Flinching... ouch!") 
  elseif self.movement_state == 'ko' then
    print("Fainting... eughhh")
  else
    print("There's some undefined state we've entered here, Captain. Red Alert!")
  end
end;
