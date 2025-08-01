require('class.ui.progress_bar')
Class = require "libs.hump.class"
Entity = Class{
  movementTime = 2,
  drawHitboxes = false,
  drawHitboxPositions = false,
  tweenHP = false,
  isATB = true
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
  self.baseAnimationTypes = {'idle', 'move', 'flinch', 'ko'}
  self.animations = {}
  self.currentAnimTag = 'idle'

  self.pos = {x = x, y = y, r = 0, a = 1}
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
  self.hbXOffset = (data.width - data.hbWidth) / 2
  self.hbYOffset = (data.height - data.hbHeight) * 0.75
  self.hitbox = {
    x = self.pos.x + self.hbXOffset,
    y = self.pos.y + self.hbYOffset,
    w = data.hbWidth,
    h = data.hbHeight
  }

  self.shadowDims = {
    x = self.hitbox.x + (self.hitbox.w / 2.5),
    y = self.oPos.y + self.frameHeight,
    w = self.hitbox.w / 2,
    h = self.hitbox.h / 8
  }
  self.tweens = {}

  local pbOptions = {
    xOffset = 0,
    yOffset = 75,
    min = 0,
    max = 100,
    w = 50,
    h = 5,
    wModifier = 0.05
  }
  self.progressBar = ProgressBar(self.pos, pbOptions, false)

  self.hazards = nil
end;

function Entity:startTurn()
  self.isFocused = true
  self.hasUsedAction = false
  self.turnFinish = false
  self.state = 'offense'

  if self.hazards then
    for i,hazard in ipairs(self.hazards) do
      hazard:proc()
    end
  end

  print('starting turn for ' .. self.entityName)
end;

function Entity:endTurn(duration, stagingPos, tweenType)
  if self:isAlive() then
    self:tweenToStagingPosThenStartingPos(duration, stagingPos, tweenType)
  else
    self:reset()
    Signal.emit('OnEndTurn', 0)
  end
end;

function Entity:tweenToStagingPosThenStartingPos(duration, stagingPos, tweenType)
  local delay = 0.5
  if stagingPos then
    self.currentAnimTag = 'move'
    local stageBack = flux.to(self.pos, duration, {x = stagingPos.x, y = stagingPos.y}):ease(tweenType)
      :after(self.pos, duration, {x = self.oPos.x, y = self.oPos.y}):delay(delay):ease(tweenType)
    :oncomplete(
      function() 
        self:reset(); Signal.emit('OnEndTurn', delay); 
      end)
  else
    Timer.after(delay, function() 
      self:reset(); Signal.emit('OnEndTurn', delay) 
    end)
  end
end;

function Entity:attackInterrupt()
  self.tweens['attack']:stop()
  if self:isAlive() then
    self:tweenToStagingPosThenStartingPos(0.5, self.tPos, 'quadout')
  else
    self:reset()
    Signal.emit('NextTurn')
  end
end;

function Entity:reset()
  self.isFocused = false
  self.hasUsedAction = false
  self.turnFinish = false
  self.amount = 0
  self.state = 'idle'
  self.currentAnimTag = 'idle'
  self.moveBackTimerStarted = false
  self.skill = nil

  print('ending turn for ', self.entityName)
end;

function Entity:addTween(tag, tween)
  self.tweens[tag] = tween
end;

function Entity:stopTween(tag)
  if self.tweens[tag] then
    self.tweens[tag]:stop()
    self.tweens[tag] = nil
  end
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
  local isDamage = false
  if self.tweens['damage'] then
    self.tweens['damage']:stop()
  end
  self.battleStats["hp"] = math.min(self.baseStats["hp"], self.battleStats["hp"] + amount)
  Signal.emit('OnHPChanged', amount, isDamage, Entity.tweenHP)
end;

function Entity:takeDamage(amount) --> void
  local isDamage = true
  local damageDuration = 15 -- generous rn, should be a fcn of the damage taken
  self.amount = math.max(0, amount - self.battleStats['defense'])
  self.countFrames = true
  local newHP = math.max(0, self.battleStats["hp"] - self.amount)
  
  if Entity.tweenHP then
    print('slow tween beginning for HP')
    local damageTween = flux.to(self.battleStats, damageDuration,{hp = newHP})
      :oncomplete(function() print('done with hp tween') end)
    self.tweens['damage'] = damageTween
  else
    self.battleStats["hp"] = newHP
  end
  
  if self:isAlive() then
    self.currentAnimTag = 'flinch'
    Timer.after(0.5, function() self.currentAnimTag = 'idle' end)
  else
    self.currentAnimTag = 'ko'
  end

  -- Signal.emit('OnHPChanged', self.amount, isDamage, Entity.tweenHP)
end;

function Entity:takeDamagePierce(amount) --> void
  self.battleStats['hp'] = math.max(0, self.battleStats['hp'] - amount)
  if self:isAlive() then
    self.currentAnimTag = 'flinch'
  else
    self.currentAnimTag = 'ko'
  end
end;

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
function Entity:setAnimations(path)
  local baseAnimationTypes = {'idle', 'move', 'flinch', 'ko'}
  for i,anim in ipairs(baseAnimationTypes) do
    local image = love.graphics.newImage(path .. anim .. '.png')
    self.animations[anim] = self:populateFrames(image)
  end


  -- Images
  -- local path = 'asset/sprites/entities/' .. subdir .. self.entityName .. '/'
  -- local idle = love.graphics.newImage(path .. 'idle.png')
  -- local move = love.graphics.newImage(path .. 'move_x.png')
  -- self.animations['idle'] = self:populateFrames(idle)
  -- self.animations['move'] = self:populateFrames(move)

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
  self.hitbox.x = self.pos.x + self.hbXOffset
  self.hitbox.y = self.pos.y + self.hbYOffset
  self.shadowDims.x = self.hitbox.x + (self.hitbox.w / 2)
  self.shadowDims.y = self.pos.y + (self.frameHeight * 0.95)

  if Entity.isATB then
    self.progressBar:setPos(self.pos)
  end

  local animation = self.animations[self.currentAnimTag]
  -- if self.state == 'idle' then
    -- animation = self.movementAnimations.idle
  -- elseif self.state == 'move' or 'moveback' then
    -- animation = self.movementAnimations.moveX
  -- end
  
  animation.currentTime = animation.currentTime + dt
  if animation.currentTime >= animation.duration then
    if not self:isAlive() and self.currentAnimTag == 'ko' then
      animation.currentTime = animation.duration
    else
      animation.currentTime = animation.currentTime - animation.duration
    end
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
  -- Shadow
  if self:isAlive() then
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.ellipse("fill", self.shadowDims.x, self.shadowDims.y, self.shadowDims.w, self.shadowDims.h)
    love.graphics.setColor(1, 1, 1, 1)
  end
  
  if self.countFrames and self.currDmgFrame <= self.numFramesDmg then
    love.graphics.setColor(0,0,0, 1 - self.opacity)
    love.graphics.print(self.amount, self.pos.x + self.dmgDisplayOffsetX, self.pos.y-self.dmgDisplayOffsetY, 0, self.dmgDisplayScale, self.dmgDisplayScale)
    love.graphics.setColor(1,1,1, 1)
  end

  local animation = self.animations[self.currentAnimTag]
  local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  spriteNum = math.min(spriteNum, #animation.quads)

  love.graphics.setColor(1,1,1,self.pos.a)
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.pos.x, self.pos.y, self.pos.r, 1)
  love.graphics.setColor(1,1,1,1)
  
  if Entity.drawHitboxes then
    love.graphics.setColor(1, 0, 0, 0.4)
    love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
    love.graphics.setColor(1, 1, 1)
  end

  if Entity.drawHitboxPositions then
    love.graphics.setColor(0,0,0)
    local v = math.floor(self.hitbox.y)
    love.graphics.print(v, self.hitbox.x - 50, v)
    local val = math.floor(self.hitbox.y + self.hitbox.h)
    love.graphics.print(val, self.hitbox.x - 50, val)
    love.graphics.setColor(1,1,1)
  end

  if self.projectile then
    love.graphics.setColor(1,0,0)
    love.graphics.circle('fill', self.projectile.pos.x, self.projectile.pos.y, self.projectile.dims.r)
    love.graphics.setColor(1,1,1)
  end

  if Entity.isATB then
    self.progressBar:draw()
  end
end;


-- ATB Functionality
function Entity:tweenProgressBar(onComplete)
  local minDur = 1
  local maxDur = 2
  local speed = math.max(self.battleStats.speed, 1)
  local maxSpeed = 999
  local goalWidth = self.progressBar.containerOptions.width

  local speedRatio = math.min(speed / maxSpeed, 1)
  local t = maxDur - (speedRatio * (maxDur - minDur))
  t = math.max(minDur, math.min(maxDur, t))

  flux.to(self.progressBar.meterOptions, t, {width = goalWidth})
    :ease('linear')
    :oncomplete(onComplete)
end;