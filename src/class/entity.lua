--! file: entity.lua
require('class.skill')
require('util.stat_sheet')
require('util.enemy_list')
require('util.skill_sheet')
require('util.enemy_skill_list')
require('util.animation_frame_counts')
require('class.movement_state')
-- global table where all entities are stored
Entities = {} 

Class = require "libs.hump.class"
Entity = Class{}

  -- Entity constructor
    -- preconditions: defined stats and skills tables
    -- postconditions: Valid Entity object and added to global table of Entities
function Entity:init(stats, x, y)
  self.baseStats = Entity.copyStats(stats)
  self.battleStats = Entity.copyStats(stats)
  self.skillList = stats['skillList']
  self.spriteSheets = {
    idle = {},
    moveX = {},
    moveY = {},
    moveXY = {},
    flinch = {},
    ko = {}
  }
  self.movementAnimations = {
    idle = {},
    moveX = {},
    moveY = {},
    moveXY = {},
    flinch = {},
    ko = {}
  }    
  self.subdir = ''
  self.entityName = self.baseStats['entityName']
  self.x=x
  self.y=y
  self.dX=0
  self.dY=0
  self.frameWidth = self.battleStats['width']      -- width of sprite (or width for a single frame of animation for this character)
  self.frameHeight = self.battleStats['height']    -- height of sprite (or height for a single frame of animation for this character)
  self.movementState = MovementState(self.x, self.y, self.frameHeight)
  self.currentFrame = 1
end;

-- COPY
function Entity.copyStats(stats)
  local copy = {}
  for k,v in pairs(stats) do
    copy[k] = v
  end
  return copy
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
  return self.battleStats['speed']
end;

function Entity:getHealth() --> int
  return self.battleStats['hp']
end;

function Entity:getMaxHealth() --> int
  return self.baseStats['hp']
end;

function Entity:getStats() --> table
  return self.baseStats
end;

function Entity:getBattleStats() --> table
  return self.battleStats
end;

function Entity:getSkills() --> table
  return self.skillList
end;

function Entity:isAlive() --> bool
  return self.battleStats['hp'] > 0
end;

-- MUTATORS

function Entity:modifyBattleStat(stat_name, amount) --> void
  self.battleStats[stat_name] = math.ceil(self.battleStats[stat_name] * (amount * 1.25))
end;

function Entity:setPos(x, y) --> void
  self.x = x
  self.y = y
end;

function Entity:setDXDY(dx, dy) --> void
  self.dX = dx
  self.dY = dy
end;

function Entity:setSubdir(subdir)
  self.subdir = subdir
end;

function Entity:setMovementState(state) --> void
  self.movementState = state
end;

function Entity:heal(amount) --> void
  self.battleStats["hp"] = math.min(self.battleStats["hp"], self.battleStats["hp"] + amount)
end;

function Entity:takeDamage(amount) --> void
  self.battleStats["hp"] = math.max(0, self.battleStats["hp"] - amount)
end;

-- ONLY run this after setting current_stats HP to reflect damage taken during battle
function Entity:resetStatModifiers() --> void
  for stat,val in pairs(self.baseStats) do
    if stat ~= 'hp' or stat ~= 'fp' then
      self.battleStats[stat] = self.baseStats[stat]
    end
  end
end;

  -- Sets the animations that all Entities have in common (idle, move_x, flinch, ko)
  -- Shared animations are called by the child classes since the location of the subdir depends on the type of class
function Entity:setAnimations(subdir)
  -- Images
  local path = 'asset/sprites/entities/' .. subdir .. self.entityName .. '/'
  self.spriteSheets.idle = love.graphics.newImage(path .. 'idle.png')
--  self.moveXImage = love.graphics.newImage(path .. 'move_x.png')
--  self.flinchImage = love.graphics.newImage(path .. 'flinch.png')
--  self.koImage = love.graphics.newImage(path .. 'ko.png')

  -- Quads
  local durations = get_state_animations(self.entityName)
  
  Entity.populateFrames(self, durations.idleFrames)
--  Entity:populateFrames(xMoveFrames, durations['move_x_frames'], self.moveXImage, moveXFrames)
--  Entity:populateFrames(flinchFrames, durations['flinch_frames'], self.flinchImage, flinchFrames)
--  Entity:populateFrames(koFrames, durations['ko_frames'], self.koImage, koFrames)
end;

function Entity:populateFrames(numFrames)
  for i=1,numFrames do
    self.movementAnimations.idle[i] = love.graphics.newQuad(i * self.frameWidth, 0, self.frameWidth, self.frameHeight, self.spriteSheets.idle:getWidth(), self.spriteSheets.idle:getHeight())
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
    -- Placeholder for drawing the state or any visual representation
    -- walk, jump, idle
  local state = self.movementState.state
  if state == 'idle' then
    love.graphics.draw(self.spriteSheets.idle, self.movementAnimations.idle[math.floor(self.currentFrame)], self.x, self.y)
  elseif state == 'moveX' then
    print("Moving left and right")
  elseif state == 'moveY' then
    print("Moving up and down")
  elseif state == 'moveXY' then
    print("Moving diagonally")
  elseif state == 'flinch' then
    print("Flinching... ouch!") 
  elseif state == 'ko' then
    print("Fainting... eughhh")
  else
    print("There's some undefined state we've entered here, Captain. Red Alert!")
  end
end;
