Class = require "libs.hump.class"
Entity = Class{
  movementTime = 2,
  drawHitboxes = false
}

  -- Entity constructor
    -- preconditions: defined stats and skills tables
    -- postconditions: Valid Entity object and added to global table of Entities
function Entity:init(data, x, y)
  self.entityName = data.entityName
  self.baseStats = Entity.copyStats(data)
  self.battleStats = Entity.copyStats(data)
  self.basic = data.basic
  self.skillPool = data.skillPool
  self.skill = nil
  self.projectile = nil
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
  self.animations = {}
  self.currentAnimTag = 'idle'

  self.pos = {x = x, y = y, r = 0}
  self.tPos = {x = 0, y = 0}
  self.oPos = {x = x, y = x}
  
  -- self.dX=0
  -- self.dY=0
  self.frameWidth = data.width      -- width of sprite (or width for a single frame of animation for this character)
  self.frameHeight = data.height    -- height of sprite (or height for a single frame of animation for this character)
  self.currentFrame = 1
  self.isFocused = false
  self.targets = {}
  self.target = nil
  self.hasUsedAction = false
  self.turnFinish = false
  self.state = 'idle'
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
  self.hitbox = {
    x = self.pos.x,
    y = self.pos.y,
    w = data.hbWidth,
    h = data.hbHeight
  }
end;

function Entity:startTurn()
  self.isFocused = true
  self.hasUsedAction = false
  self.turnFinish = false
  self.state = 'offense'

  print('starting turn for ' .. self.entityName)
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
  
  print('targets set for ' .. self.entityName)
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
  self.skill = nil

  print('ending turn for ', self.entityName)
end;

-- COPY
function Entity.copyStats(stats)
  return {
    hp = stats.hp,
    fp = stats.fp,
    attack = stats.attack,
    defense = stats.defense,
    speed = stats.speed,
    luck = stats.luck,
    growthRate = stats.growthRate
  }
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

function Entity:getSkillStagingTime()
  return self.skill.stagingTime
end;

-- MUTATORS

function Entity:goToStagingPosition(t, displacement)
  local stagingPos = {x=0,y=0}
  if self.skill.stagingType == 'near' then
    stagingPos.x = self.target.oPos.x + displacement
    stagingPos.y = self.target.oPos.y
  end
  print('Tweening for active entity to use ' .. self.skill.name)
  if t == nil then
    t = self.skill.stagingTime
  end
  flux.to(self.pos, t, {x = stagingPos.x, y = stagingPos.y}):ease('linear')
end;

function Entity:modifyBattleStat(stat_name, amount) --> void
  self.battleStats[stat_name] = math.ceil(self.battleStats[stat_name] * (amount * self.statUpScaler))
end;

function Entity:heal(amount) --> void
  self.battleStats["hp"] = math.min(self.battleStats["hp"], self.battleStats["hp"] + amount)
end;

function Entity:takeDamage(amount) --> void
  self.amount = math.max(0, amount - self.battleStats['defense'])
  self.countFrames = true
  self.battleStats["hp"] = math.max(0, self.battleStats["hp"] - self.amount)
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
  local idle = love.graphics.newImage(path .. 'idle.png')
  local move = love.graphics.newImage(path .. 'move_x.png')
  self.animations['idle'] = self:populateFrames(idle)
  self.animations['move'] = self:populateFrames(move)

  -- all characters have a basic attack
  if subdir == 'character/' then
    local basicSprite = love.graphics.newImage(path .. 'basic.png')
    self.animations['basic'] = self:populateFrames(basicSprite)
  end

  for i,skill in ipairs(self.skillPool) do
    local skillPath = path .. skill.tag .. '.png'
    local image = love.graphics.newImage(skillPath)
    self.animations[skill.tag] = self:populateFrames(image)
  end
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
  self.hitbox.x = self.pos.x
  self.hitbox.y = self.pos.y
  local animation = self.animations[self.currentAnimTag]
  -- if self.state == 'idle' then
    -- animation = self.movementAnimations.idle
  -- elseif self.state == 'move' or 'moveback' then
    -- animation = self.movementAnimations.moveX
  -- end
  
  
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
  love.graphics.setColor(0, 0, 0, 0.4)
  love.graphics.ellipse("fill", self.pos.x + (self.frameWidth / 2.5), self.pos.y + (self.frameHeight * 0.95), self.frameWidth / 4, self.frameHeight / 8)
  love.graphics.setColor(1, 1, 1, 1)
  
  -- local spriteNum
  -- local animation
  -- if self.state == 'idle' then
  --   animation = self.movementAnimations.idle
  --   -- spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  --   -- love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.x, self.y, 0, 1 )
  -- elseif self.state == 'move' or 'moveback' then
  --   animation = self.movementAnimations.moveX
  -- elseif self.state == 'moveY' then
  --   -- love.graphics.draw(self.spriteSheets.moveY, self.movementAnimations.moveY[math.floor(self.currentFrame)], self.x, self.y)
  -- elseif self.state == 'moveXY' then
  --   -- love.graphics.draw(self.spriteSheets.moveXY, self.movementAnimations.moveXY[math.floor(self.currentFrame)], self.x, self.y)
  -- elseif self.state == 'flinch' then
  --   -- love.graphics.draw(self.spriteSheets.flinch, self.movementAnimations.flinch[math.floor(self.currentFrame)], self.x, self.y) 
  -- elseif self.state == 'ko' then
  --   -- love.graphics.draw(self.spriteSheets.ko, self.movementAnimations.ko[math.floor(self.currentFrame)], self.x, self.y)
  -- else
  --   print("logical error in determining movement state of entity. state is", state)
  -- end
  if self.countFrames and self.currDmgFrame <= self.numFramesDmg then
    love.graphics.setColor(0,0,0, 1 - self.opacity)
    love.graphics.print(self.amount, self.pos.x + self.dmgDisplayOffsetX, self.pos.y-self.dmgDisplayOffsetY, 0, self.dmgDisplayScale, self.dmgDisplayScale)
    love.graphics.setColor(1,1,1, 1)
  end
  local animation = self.animations[self.currentAnimTag]
  local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.pos.x, self.pos.y, self.pos.r, 1)

  if Entity.drawHitboxes then
    love.graphics.setColor(1, 0, 0, 0.4)
    love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
    love.graphics.setColor(1, 1, 1)
  end

  if self.projectile then
    love.graphics.setColor(1,0,0)
    love.graphics.circle('fill', self.projectile.pos.x, self.projectile.pos.y, self.projectile.dims.r)
    love.graphics.setColor(1,1,1)
  end
end;
