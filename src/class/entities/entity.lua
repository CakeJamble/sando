local Signal = require('libs.hump.signal')
local ProgressBar = require('class.ui.progress_bar')
local Class = require "libs.hump.class"
local Timer = require('libs.hump.timer')
local flux = require('libs.flux')
require('util.globals')

---@class Entity
---@field movementTime integer
---@field drawHitboxes boolean
---@field drawHitboxPositions boolean
---@field tweenHP boolean
---@field isATB boolean
---@field hideProgressBar boolean
local Entity = Class{
  movementTime = 2,
  drawHitboxes = false,
  drawHitboxPositions = false,
  tweenHP = false,
  isATB = true,
  hideProgressBar = false
}

---@param data table
---@param x integer
---@param y integer
---@param entityType string
function Entity:init(data, x, y, entityType)
  self.type = entityType
  self.entityName = data.entityName
  self.baseStats = self.copyStats(data)
  self.battleStats = self.copyStats(data)
  self.statStages = self.setStatStages(self.baseStats)
  self.statuses = {}
  self.statusResist = {
    burn = 0,
    poison = 0,
    sleep = 0,
    lactose = 0,
    paralyze = 0,
    ohko = 0,
    late = 0
  }
  self.debuffImmune = false
  self.lowerAfterSkillUse = {
    hp = 0,
    fp = 0,
    attack = 0,
    defense = 0,
    speed = 0,
    luck = 0,
    growthRate = 0
  }
  self.critMult = 2
  self.basic = data.basic
  self.skillPool = data.skillPool
  self.skill = nil
  -- self.projectile = nil
  self.projectiles = {}
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
  self.koAnimDuration = data.koAnimDuration or 1.5

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
  self.targetableEntities = {}
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
  self.hideProgressBar = Entity.hideProgressBar

  self.hazards = nil

  local minDur = 0.5
  local maxDur = 5
  local speed = math.max(self.battleStats.speed, 1)
  local maxSpeed = 999

  local normSpeed = math.min(speed/maxSpeed, 1)
  self.tRate = maxDur - (normSpeed ^ 2) * (maxDur - minDur)

  
  Signal.register('TargetConfirm',
  function()
    if self.tweens['pbTween'] then
      self.tweens['pbTween']:stop()
    end
  end)
end;

---@param stats table
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

--[[----------------------------------------------------------------------------------------------------
        Turn Set-up & Take-down
----------------------------------------------------------------------------------------------------]]

function Entity:startTurn()
  self.isFocused = true
  self.hasUsedAction = false
  self.turnFinish = false
  self.state = 'offense'
  self.progressBar:reset()

  if self.tweens['pbTween'] then
    self.tweens['pbTween']:stop()
    self.tweens['pbTween'] = nil
  end

  if self.hazards then
    for _,hazard in ipairs(self.hazards) do
      hazard:proc()
    end
  end

  print('starting turn for ' .. self.entityName)
end;

---@param duration integer Length of time the tween(s) take
---@param stagingPos? {[string]: number}
---@param tweenType? string
function Entity:endTurn(duration, stagingPos, tweenType)
  if self:isAlive() then
    flux.to(self.pos, 0.75, {x = self.oPos.x, y = self.oPos.y})
      :delay(0.75)
    Signal.emit('OnEndTurn', 1.5)
    -- self:tweenToStagingPosThenStartingPos(duration, stagingPos, tweenType)
  else
    self:reset()
    flux.to(self.pos, 0.5, {x = self.oPos.x, y = self.oPos.y})
    Signal.emit('OnEndTurn', 0)
  end
end;

---@param targets { [string]: Entity }
function Entity:setTargets(targets)
  self.targets = {
    ['characters'] = targets.characters,
    ['enemies'] = targets.enemies
  }

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

--[[----------------------------------------------------------------------------------------------------
        Tweening
----------------------------------------------------------------------------------------------------]]

---@param tag string
---@param tween fun()
function Entity:addTween(tag, tween)
  self.tweens[tag] = tween
end;

---@param tag string
function Entity:stopTween(tag)
  if self.tweens[tag] then
    self.tweens[tag]:stop()
    self.tweens[tag] = nil
  end
end;

function Entity:attackInterrupt()
  self.tweens['attack']:stop()
  self:endTurn(0)
  -- if self:isAlive() then
    -- self:tweenToStagingPosThenStartingPos(0.5, self.tPos, 'quadout')

  -- else
    -- self:reset()
    -- Signal.emit('NextTurn')
  -- end
end;

---@param t integer?
---@param displacement integer
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

---@param duration integer
---@param stagingPos? { [string]: number }
---@param tweenType? string
---@deprecated
function Entity:tweenToStagingPosThenStartingPos(duration, stagingPos, tweenType)
  local delay = 0.5
  if stagingPos then
    self.currentAnimTag = 'move'
    local stageBack = flux.to(self.pos, duration, {x = stagingPos.x, y = stagingPos.y}):ease(tweenType)
      :after(self.pos, duration, {x = self.oPos.x, y = self.oPos.y}):delay(delay):ease(tweenType)
    :oncomplete(
      function()
        self:reset(); Signal.emit('OnEndTurn', 0.5);
      end)
    self.tweens['stageBack'] = stageBack
  else
    Timer.after(delay, function()
      self:reset(); Signal.emit('OnEndTurn', 0.5)
    end)
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Getters
----------------------------------------------------------------------------------------------------]]

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

--[[----------------------------------------------------------------------------------------------------
        Battle Stats
----------------------------------------------------------------------------------------------------]]

---@param stats table
function Entity.setStatStages(stats)
  local stages = {}
  for stat,_ in pairs(stats) do
    stages[stat] = 0
  end
  return stages
end;

---@param statName string
---@param stage integer
function Entity:modifyBattleStat(statName, stage) --> void
  if stage < 0 and self.debuffImmune then 
    -- Add a flashy animation/effect here
    return 
  end
  -- clamping
  local maxStage = statStageCap
  local minStage = -statStageCap
  local stats = {}

  if statName == 'all' then
    stats = {'attack', 'defense', 'speed', 'luck'}
  else
    if statName == 'random' then
      local i = love.math.random(#stats)
      statName = stats[i]
    end
    table.insert(stats, statName)
  end

  for _,stat in ipairs(stats) do
    stage = self.statStages[stat] + stage
    self.statStages[stat] = math.min(maxStage, math.max(minStage, stage))

    local mult
    if self.statStages[stat] >= 0 then
      mult = (2 + self.statStages[stat]) / 2
    else
      mult = 2 / (2 - self.statStages[stat])
    end

    -- local prev = self.battleStats[stat]
    self.battleStats[stat] = math.floor((self.battleStats[stat] * mult) + 0.5)
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

---@param statName string
---@param stage integer
function Entity:lowerAfterSkillResolves(statName, stage)
  self.lowerAfterSkillUse[statName] = math.max(0, self.lowerAfterSkillUse[statName] - stage)
end;


--[[----------------------------------------------------------------------------------------------------
        Status
----------------------------------------------------------------------------------------------------]]

---@param status string
function Entity:applyStatus(status)
  if not self.debuffImmune then
    if not self:isAlreadyAfflicted(status) then
      local chance = love.math.random()

      if chance > self.statusResist[status] then
        table.insert(self.statuses, status)
      else
        print('resisted!')
      end
    end
  end
end;

---@param status string
---@return boolean
function Entity:isAlreadyAfflicted(status)
  for _,curr in ipairs(self.statuses) do
    if curr == status then
      return true
    end
  end

  return false
end;

---@param statuses string[]
---@param amount integer
function Entity:raiseResist(statuses, amount)
  if statuses == 'all' then
    for status,resistChance in pairs(self.statusResist) do
      self.statusResist[status] = resistChance + amount
    end
  else
    for _,status in ipairs(statuses) do
      self.statusResist[status] = self.statusResist[status] + amount
    end
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Heal & Cleanse
----------------------------------------------------------------------------------------------------]]

---@param amount integer
function Entity:heal(amount) --> void
  local isDamage = false
  if self.tweens['damage'] then
    self.tweens['damage']:stop()
  end
  self.battleStats["hp"] = math.min(self.baseStats["hp"], self.battleStats["hp"] + amount)
  Signal.emit('OnHPChanged', amount, isDamage, Entity.tweenHP)
end;

function Entity:cleanse()
  for i,_ in ipairs(self.statuses) do
    local status = table.remove(self.statuses, i)
    -- play effect(s) for heal (use a tween and self-assign using after() to chain visuals)
    print(status) -- temp
  end
end;

---@param statusToCleanse string
function Entity:cleanseOne(statusToCleanse)
  for i, status in ipairs(self.statuses) do
    if statusToCleanse == status then
      table.remove(self.statuses, i)
      return
    end
  end
end;

---@param pct? number (0,1] Percentage of health to revive with
function Entity:revive(pct)
  local percent = pct or 0.5
  local amount = math.floor(0.5 + self.baseStats.hp)

  self:cleanse()
  self:heal(amount)

  -- play sfx, tween, etc
end;


--[[----------------------------------------------------------------------------------------------------
        Damage
----------------------------------------------------------------------------------------------------]]

---@param amount integer
---@param attackerLuck integer
function Entity:takeDamage(amount, attackerLuck) --> void
  local isCrit = self:isCrit(attackerLuck)
  local damageDuration = 15 -- generous rn, should be a fcn of the damage taken
  if isCrit then
    amount = amount * self.critMult
    -- Signal.emit('OnCrit')
  end
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
  end
end;

---@param amount integer
function Entity:takeDamagePierce(amount) --> void
  self.battleStats['hp'] = math.max(0, self.battleStats['hp'] - amount)
  self.currentAnimTag = 'flinch'
end;

---@param attackerLuck integer
---@return boolean
function Entity:isCrit(attackerLuck)
  local chance = self:calcCritChance(attackerLuck)
  local rand = love.math.random()

  return rand <= chance
end;

---@param attackerLuck integer
---@return number
function Entity:calcCritChance(attackerLuck)
  local luck = self.battleStats.luck
  local chance = math.min(100, math.max(1, (attackerLuck / 4) - (luck / 8)))
  chance = chance / 100
  return chance
end;

function Entity:startFainting()
  self.currentAnimTag = "ko"
  return self.koAnimDuration
end;

--[[----------------------------------------------------------------------------------------------------
        Sprites & SFX
----------------------------------------------------------------------------------------------------]]

--[[Sets the animations that all Entities have in common (idle, move_x, flinch, ko)
  Shared animations are called by the child classes since the location of the subdir depends on the type of class]]
---@param path string
function Entity:setAnimations(path)
  local baseAnimationTypes = {'idle', 'move', 'flinch', 'ko'}
  for _,anim in ipairs(baseAnimationTypes) do
    local image = love.graphics.newImage(path .. anim .. '.png')
    self.animations[anim] = self:populateFrames(image)
  end

  for _,skill in ipairs(self.skillPool) do
    local skillPath = path .. skill.tag .. '.png'
    local image = love.graphics.newImage(skillPath)
    self.animations[skill.tag] = self:populateFrames(image)
  end
end;

---@param path string
---@param baseSFXTypes string[]
---@deprecated
function Entity:setSFX(path, baseSFXTypes)
  local sfxList = {}
  for _,sfx in ipairs(baseSFXTypes) do
    local sfxPath = "asset/audio/entities/" .. path .. self.entityName .. "/" .. sfx .. ".wav"
    local src = love.audio.newSource(sfxPath, "static")
    sfxList[sfx] = src
  end
  return sfxList
end;

---@param image table
---@param duration? integer
---@return table
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

--[[----------------------------------------------------------------------------------------------------
        Update
----------------------------------------------------------------------------------------------------]]

---@param dt number
function Entity:update(dt) --> void
  self:updateHitbox()
  self:updateShadow()

  if Entity.isATB then
    self.progressBar:setPos(self.pos)
  end

  self:updateProjectiles(dt)
  self:updateAnimation(dt)

  if self.countFrames then
    self.currDmgFrame = self.currDmgFrame + 1
    self.dmgDisplayScale = self.dmgDisplayScale - 0.01
    self.dmgDisplayOffsetX = math.cos(self.currDmgFrame * 0.25)
    self.dmgDisplayOffsetY = self.dmgDisplayOffsetY + 0.1
    self.opacity = self.opacity + 0.05
  end
end;

---@param dt number
function Entity:updateAnimation(dt)
  local animation = self.animations[self.currentAnimTag]
  animation.currentTime = animation.currentTime + dt
  if animation.currentTime >= animation.duration then
    if not self:isAlive() and self.currentAnimTag == 'ko' then
      animation.currentTime = animation.duration
    else
      animation.currentTime = animation.currentTime - animation.duration
    end
  end
end;

function Entity:updateHitbox()
  self.hitbox.x = self.pos.x + self.hbXOffset
  self.hitbox.y = self.pos.y + self.hbYOffset
end;

function Entity:updateShadow()
  self.shadowDims.x = self.hitbox.x + (self.hitbox.w / 2)
  self.shadowDims.y = self.pos.y + (self.frameHeight * 0.95)
end;

---@param dt number
function Entity:updateProjectiles(dt)
  for _,projectile in ipairs(self.projectiles) do
    projectile:update(dt)
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Drawing
----------------------------------------------------------------------------------------------------]]

-- Should draw using the animation in the valid state (idle, moving (in what direction), jumping, etc.)
function Entity:draw() --> void
  self:drawShadow()
  self:drawFeedback()
  self:drawSprite()
  self:drawHitbox()
  self:drawProjectiles()
  self:drawProgressBar()
end;

function Entity:drawShadow()
  if self:isAlive() then
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.ellipse("fill", self.shadowDims.x, self.shadowDims.y, self.shadowDims.w, self.shadowDims.h)
    love.graphics.setColor(1, 1, 1, 1)
  end
end;

function Entity:drawFeedback()
  if self.countFrames and self.currDmgFrame <= self.numFramesDmg then
    love.graphics.setColor(0,0,0, 1 - self.opacity)
    love.graphics.print(self.amount, self.pos.x + self.dmgDisplayOffsetX, self.pos.y-self.dmgDisplayOffsetY, 0,
      self.dmgDisplayScale, self.dmgDisplayScale)
    love.graphics.setColor(1,1,1, 1)
  end
end;

function Entity:drawSprite()
  local animation = self.animations[self.currentAnimTag]
  local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
  spriteNum = math.min(spriteNum, #animation.quads)
  love.graphics.setColor(1,1,1,self.pos.a)
  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.pos.x, self.pos.y, self.pos.r, 1)
  love.graphics.setColor(1,1,1,1)
end;

function Entity:drawHitbox()
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
end;

function Entity:drawProjectiles()
  for _,projectile in ipairs(self.projectiles) do
    projectile:draw()
  end
end;

function Entity:drawProgressBar()
  if Entity.isATB and not self.hideProgressBar then
    self.progressBar:draw()
  end
end;


-- ATB Functionality
---@param onComplete fun() Emits OnTurnReady(entity) signal
function Entity:tweenProgressBar(onComplete)
  local goalWidth = self.progressBar.containerOptions.width
  local currWidth = self.progressBar.meterOptions.width
  local progress = currWidth / goalWidth
  local remainingDur = self.tRate * (1 - progress)
  self.tweens['pbTween'] = flux.to(self.progressBar.meterOptions, remainingDur, {width = goalWidth})
    :ease('linear')
    :oncomplete(onComplete)
end;

function Entity:stopProgressBar()
  self.tweens['pbTween']:stop()
end;

function Entity:setProgressBarPos()
  self.progressBar:setPos(self.pos)
end;

return Entity