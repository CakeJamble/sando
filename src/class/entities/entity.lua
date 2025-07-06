--! file: entity.lua
require('class.qte.skill')
require('util.stat_sheet')
require('util.enemy_list')
require('util.skill_sheet')
require('util.enemy_skill_list')
require('util.animation_frame_counts')
require('class.entities.movement_state')

Class = require "libs.hump.class"
Entity = Class{
  movementTime = 2
}

  -- Entity constructor
    -- preconditions: defined stats and skills tables
    -- postconditions: Valid Entity object and added to global table of Entities
function Entity:init(stats, x, y)
  self.baseStats = Entity.copyStats(stats)
  self.battleStats = Entity.copyStats(stats)
  self.statUpScaler = 1.25
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

  self.pos = {x = x, y = y}
  self.tPos = {x = 0, y = 0}
  self.oPos = {x = self.pos.x, y = self.pos.y}
  
  -- self.x=x
  -- self.y=y
  self.dX=0
  self.dY=0
  self.frameWidth = self.battleStats['width']      -- width of sprite (or width for a single frame of animation for this character)
  self.frameHeight = self.battleStats['height']    -- height of sprite (or height for a single frame of animation for this character)
  self.currentFrame = 1
  self.isFocused = false
  self.targets = {}
  self.target = nil
  self.hasUsedAction = false
  self.turnFinish = false
  self.state = 'idle'
  self.movementState = MovementState(self.pos.x, self.pos.y)
  self.selectedSkill = nil

  self.numFramesDmg = 60
  self.currDmgFrame = 0
  self.amount = 0
  self.countFrames = false
  self.dmgDisplayOffsetX = 0
  self.dmgDisplayOffsetY = 0
  self.dmgDisplayScale = 1
  self.opacity = 0

  self.ignoreHazards = false
  self.moveBackTimerStarted = false
end;

function Entity:startTurn()
  self.isFocused = true
  self.hasUsedAction = false
  self.turnFinish = false

  print('starting turn for ', self.entityName)
end;

function Entity:setTargets(characterMembers, enemyMembers)
  self.targets = {
    ['characters'] = {},
    ['enemies'] = {}
  }

  for i=1,#characterMembers do
    if characterMembers[i]:isAlive() then
      table.insert(self.targets.characters, characterMembers[i])
    end
  end

  for i=1,#enemyMembers do
    if enemyMembers[i]:isAlive() then
      table.insert(self.targets.enemies, enemyMembers[i])
    end
  end
  
  print('targets set for ', self.entityName)
end;

function Entity:goToTarget(space)
  self.tPos = {x = self.target.pos.x + space, y = self.target.pos.y}
  Timer.tween(Entity.movementTime, self.pos, {x=self.tPos.x, y = self.tPos.y})

  local function onComplete()
    Signal.emit('Attack', self.pos.x, self.pos.y)
  end
  
  Timer.after(Entity.movementTime, onComplete)
end;



function Entity:resetDmgDisplay()
  self.amount = 0
  self.countFrames = false
  self.currDmgFrame = 0
  self.dmgDisplayOffsetX = 0
  self.dmgDisplayOffsetY = 0
  self.dmgDisplayScale = 1
  self.opacity = 0
end;


function Entity:endTurn()
  self.isFocused = false
  self.hasUsedAction = false
  self.turnFinish = false
  self.amount = 0
  self.state = 'idle'
  self.moveBackTimerStarted = false

  print('ending turn for ', self.entityName)
end;

-- COPY
function Entity.copyStats(stats)
  local copy = {}
  for k,v in pairs(stats) do
    copy[k] = v
  end
  return copy
end;

-- ACCESSORS (only write an accessor if it simplifies access to data)

function Entity:getPos() --> {int, int}
  return self.pos
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

function Entity:isAlive() --> bool
  return self.battleStats['hp'] > 0
end;

-- MUTATORS

function Entity:modifyBattleStat(stat_name, amount) --> void
  self.battleStats[stat_name] = math.ceil(self.battleStats[stat_name] * (amount * self.statUpScaler))
end;

function Entity:heal(amount) --> void
  self.battleStats["hp"] = math.min(self.battleStats["hp"], self.battleStats["hp"] + amount)
end;

function Entity:takeDamage(amount) --> void
  self.amount = math.max(0, amount - self.battleStats['defense'])
  self.countFrames = true
  self.battleStats["hp"] = math.max(0, self.battleStats["hp"] - amount)
end;

function Entity:takeDamagePierce(amount) --> void
  self.battleStats['hp'] = math.max(0, self.battleStats['hp'] - amount)
end

-- Called after setting current_stats HP to reflect damage taken during battle
function Entity:resetStatModifiers() --> void
  for stat,_ in pairs(self.baseStats) do
    if stat ~= 'hp' or stat ~= 'fp' then
      self.battleStats[stat] = self.baseStats[stat]
    end
  end
end;

  --[[Sets the animations that all Entities have in common (idle, move_x, flinch, ko)
  Shared animations are called by the child classes since the location of the subdir depends on the type of class]]
function Entity:setAnimations(subdir)
  -- Images
  local path = 'asset/sprites/entities/' .. subdir .. self.entityName .. '/'
  self.spriteSheets.idle = love.graphics.newImage(path .. 'idle.png')
  self.spriteSheets.moveX = love.graphics.newImage(path .. 'move_x.png')
--  self.spriteSheets.flinch = love.graphics.newImage(path .. 'flinch.png')
--  self.spriteSheets.ko = love.graphics.newImage(path .. 'ko.png')

  -- Quads  
  self.movementAnimations.idle = Entity.populateFrames(self, self.spriteSheets.idle)
  self.movementAnimations.moveX = Entity.populateFrames(self, self.spriteSheets.moveX)
--  Entity:populateFrames(self, self.movementAnimations.moveY, self.spriteSheets.moveY, self.durations.moveY)
--  Entity:populateFrames(self, self.movementAnimations.moveXY, self.spriteSheets.moveXY, self.durations.moveXY)
--  Entity:populateFrames(self, self.movementAnimations.flinch, self.spriteSheets.flinch, self.durations.flinch)
--  Entity:populateFrames(self, self.movementAnimations.ko, self.spriteSheets.ko, self.durations.ko)
end;

function Entity:populateFrames(image, duration)
  local animation = {}
  animation.spriteSheet = image
  animation.quads = {}
  
  for y = 0, image:getHeight() - self.frameHeight, self.frameHeight do
    for x = 0, image:getWidth() - self.frameWidth, self.frameWidth do
      table.insert(animation.quads, love.graphics.newQuad(x, y, self.frameWidth, self.frameHeight, image:getDimensions()))
    end
  end
  
  animation.duration = duration or 1
  animation.currentTime = 0
  animation.spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads)
  
  return animation
end;

function Entity:update(dt) --> void
  Timer.update(dt)

  -- print(self.pos.x, self.tPos.x)
  -- if self.pos.x == self.tPos.x and self.pos.y == self.tPos.y then
  --   Signal.emit('Attack', self.pos.x, self.pos.y)
  -- end

  local state = self.movementState.state
  local animation
  if state == 'idle' then
    animation = self.movementAnimations.idle
  elseif state == 'move' or 'moveback' then
    animation = self.movementAnimations.moveX
  end
  
  
  animation.currentTime = animation.currentTime + dt
  if animation.currentTime >= animation.duration then 
    animation.currentTime = animation.currentTime - animation.duration
  end

  if self.countFrames then
    self.currDmgFrame = self.currDmgFrame + 1
    self.dmgDisplayScale = self.dmgDisplayScale - 0.01
    self.dmgDisplayOffsetX = math.cos(self.currDmgFrame * 0.25)
    self.dmgDisplayOffsetY = self.dmgDisplayOffsetY + 0.1
    self.opacity = self.opacity + 0.05
  end
end;

-- Should draw using the animation in the valid state (idle, moving (in what direction), jumping, etc.)
function Entity:draw() --> void    
    -- Placeholder for drawing the state or any visual representation
    -- walk, jump, idle
  -- local state = self.movementState.state
  local spriteNum
  local animation
  if self.state == 'idle' then
    animation = self.movementAnimations.idle
    -- spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
    -- love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.x, self.y, 0, 1 )
  elseif self.state == 'move' or 'moveback' then
    animation = self.movementAnimations.moveX
  elseif self.state == 'moveY' then
    -- love.graphics.draw(self.spriteSheets.moveY, self.movementAnimations.moveY[math.floor(self.currentFrame)], self.x, self.y)
  elseif self.state == 'moveXY' then
    -- love.graphics.draw(self.spriteSheets.moveXY, self.movementAnimations.moveXY[math.floor(self.currentFrame)], self.x, self.y)
  elseif self.state == 'flinch' then
    -- love.graphics.draw(self.spriteSheets.flinch, self.movementAnimations.flinch[math.floor(self.currentFrame)], self.x, self.y) 
  elseif self.state == 'ko' then
    -- love.graphics.draw(self.spriteSheets.ko, self.movementAnimations.ko[math.floor(self.currentFrame)], self.x, self.y)
  else
    print("logical error in determining movement state of entity. state is", state)
  end
  if self.countFrames and self.currDmgFrame <= self.numFramesDmg then
    love.graphics.setColor(0,0,0, 1 - self.opacity)
    love.graphics.print(self.amount, self.pos.x + self.dmgDisplayOffsetX, self.pos.y-self.dmgDisplayOffsetY, 0, self.dmgDisplayScale, self.dmgDisplayScale)
    love.graphics.setColor(1,1,1, 1)
  end
  spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.pos.x, self.pos.y, 0, 1)
end;
