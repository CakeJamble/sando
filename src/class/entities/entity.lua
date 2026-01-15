local Signal = require('libs.hump.signal')
local ProgressBar = require('class.ui.ProgressBar')
local Class = require "libs.hump.class"
local Timer = require('libs.hump.timer')
local flux = require('libs.flux.flux')
local animx = require('libs.animX')
local StatusEffects = require('util.status_effects')
---@class (exact) Stats
---@field hp integer
---@field fp integer
---@field attack integer
---@field defense integer
---@field speed integer
---@field luck integer
---@field growthRate integer Rate at which required EXP raises between levels

---@class (exact) StatusResists
---@field burn number
---@field poison number
---@field sleep number
---@field lactose number
---@field paralyze number
---@field ohko number
---@field late number

---@class Entity
---@field movementTime integer
---@field drawHitboxes boolean
---@field drawHitboxPositions boolean
---@field tweenHP boolean
---@field isATB boolean
---@field hideProgressBar boolean
---@field type string
---@field entityName string
---@field baseStats Stats
---@field battleStats Stats
---@field statStages Stats
---@field statuses Status[]
---@field statusResist StatusResists
---@field debuffImmune boolean
---@field lowerAfterSkillUse table
---@field statMods {[string]: integer}
---@field critMult number
---@field skillPool table[]
---@field skill table
---@field selectedSkill table
---@field projectiles table[]
---@field pos table
---@field hbXOffset integer
---@field hbYOffset integer
---@field hitbox {x: integer, y: integer, w: integer, h: integer}
---@field tPos {x: integer, y: integer}
---@field oPos {x: integer, y: integer}
---@field actor table AnimX Actor class
---@field opacity number [0..1]
---@field shadowDims {x: integer, y: integer, w: integer, h:integer}
---@field tweens {[string]: function}
---@field isFocused boolean
---@field targets {characters: Character[], enemies: Enemy[]}
---@field target Entity
---@field targetableEntities Entity[]
---@field hasUsedAction boolean
---@field turnFinish boolean
---@field state string
---@field moveBackTimerStarted boolean
---@field hazards table Placeholder for future Hazard class
---@field ignoreHazards boolean
---@field progressBar ProgressBar
---@field isResumingTurn boolean
---@field tRate number
local Entity = Class {
  movementTime = 2,
  drawHitboxes = true,
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

  -- Stats & Status
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
    ohko = 0, -- ??
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
  self.statMods = {
    hp = 1,
    fp = 1,
    attack = 1,
    defense = 1,
    speed = 1,
    luck = 1,
  }
  self.critMult = 2
  self.statStageCap = 4

  -- Skills
  self.skillPool = data.skillPool
  self.skill = nil
  self.selectedSkill = nil
  -- self.projectile = nil
  self.projectiles = {}

  -- Position & Collision
  self.pos = {
    x = x,
    y = y,
    r = 0,
    a = 1,
    sx = 0.5,
    sy = 0.5,
    ox = 0,
    oy = 0
  }
  self.hbXOffset, self.hbYOffset = 0, 0
  self.hitbox = {
    x = self.pos.x + self.hbXOffset - self.pos.ox,
    y = self.pos.y + self.hbYOffset - self.pos.oy,
    w = data.hitbox.width * self.pos.sx,
    h = data.hitbox.height * self.pos.sy,
  }
  self.tPos = { x = 0, y = 0 }
  self.oPos = { x = x, y = y }

  -- Animation
  -- local animPath = "asset/sprites/entities/" .. entityType .. "/" .. self.entityName .. "/"
  -- self.actor = self:createActor(data.animations, animPath)
  -- self.actor:switch('idle')
  self.opacity = 0

  self.shadowDims = {
    x = self.hitbox.x + (self.hitbox.w / 2.5) - self.pos.ox,
    y = self.oPos.y - self.pos.oy,
    w = self.hitbox.w / 2,
    h = self.hitbox.h / 8,
  }
  self.tweens = {}

  -- Turn flow during Combat
  self.isFocused = false
  self.targets = {}
  self.target = nil
  self.targetableEntities = {}
  self.hasUsedAction = false
  self.turnFinish = false
  self.state = 'idle'
  self.moveBackTimerStarted = false

  -- Hazards
  self.hazards = nil
  self.ignoreHazards = false


  -- Progress Bar (for ATB)
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
  self.isResumingTurn = false

  local minDur = 0.5
  local maxDur = 5
  local speed = math.max(self.battleStats.speed, 1)
  local maxSpeed = 999

  local normSpeed = math.min(speed / maxSpeed, 1)
  self.tRate = maxDur - (normSpeed ^ 2) * (maxDur - minDur)

  -- Signals
  Signal.register('TargetConfirm',
    function()
      if self.tweens['pbTween'] then
        self.tweens['pbTween']:stop()
      end
    end)
end;

-- Returns a deep copy of the stats table passed into it
---@param stats Stats
---@return Stats
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

--[[Sets relevant variables to valid turn-state status,
ticks statuses, and begins pb tween if we are in an ATB scheduler]]
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

  if self.hazards and not self.ignoreHazards then
    for _, hazard in ipairs(self.hazards) do
      hazard:proc()
    end
  end

  if not self.isResumingTurn then
    self:tickStatuses()
  end

  print('starting turn for ' .. self.entityName)
end;

--[[If alive, the Entity moves back to their `oPos`. Emits an `OnEndTurn` signal]]
---@param duration integer Length of time the tween(s) take
---@param stagingPos? {[string]: number}
---@param tweenType? string
function Entity:endTurn(duration, stagingPos, tweenType)
  if self:isAlive() then
    flux.to(self.pos, 0.75, { x = self.oPos.x, y = self.oPos.y })
        :delay(0.75)
    Signal.emit('OnEndTurn', 1.5)
    -- self:tweenToStagingPosThenStartingPos(duration, stagingPos, tweenType)
  else
    self:reset()
    flux.to(self.pos, 0.5, { x = self.oPos.x, y = self.oPos.y })
    Signal.emit('OnEndTurn', 0)
  end
end;

-- Makes a copy of the targets (which is still a reference to the Entities)
---@param targets {characters: Character[], enemies: Enemy[]}
function Entity:setTargets(targets)
  self.targets = {
    ['characters'] = targets.characters,
    ['enemies'] = targets.enemies
  }

  print('targets set for ' .. self.entityName)
end;

-- Resets variables that maintain state during turn flow
function Entity:reset()
  self.isFocused = false
  self.hasUsedAction = false
  self.turnFinish = false
  -- self.amount = 0
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

-- Stops the attack and immediately ends the Entity's turn
function Entity:attackInterrupt()
  self.tweens['attack']:stop()
  self:endTurn(0)
end;

---@param t integer?
---@param displacement integer
function Entity:goToStagingPosition(t, displacement)
  local stagingPos = { x = 0, y = 0 }
  if self.skill.stagingType == 'near' then
    stagingPos.x = self.target.oPos.x + displacement
    stagingPos.y = self.target.oPos.y
  end
  if t == nil then
    t = self.skill.stagingTime
  end
  flux.to(self.pos, t, { x = stagingPos.x, y = stagingPos.y }):ease('linear')
end;

---@param duration integer
---@param stagingPos? { [string]: number }
---@param tweenType? string
---@deprecated
function Entity:tweenToStagingPosThenStartingPos(duration, stagingPos, tweenType)
  local delay = 0.5
  if stagingPos then
    self.currentAnimTag = 'move'
    local stageBack = flux.to(self.pos, duration, { x = stagingPos.x, y = stagingPos.y }):ease(tweenType)
        :after(self.pos, duration, { x = self.oPos.x, y = self.oPos.y }):delay(delay):ease(tweenType)
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

---@return table
function Entity:getMultdStats()
  local result = {}
  local stats = self.battleStats
  for key, statMod in pairs(self.statMods) do
    result[key] = stats[key] * statMod
  end
  return result
end;

--[[----------------------------------------------------------------------------------------------------
        Battle Stats
----------------------------------------------------------------------------------------------------]]

---@param stats table
function Entity.setStatStages(stats)
  local stages = {}
  for stat, _ in pairs(stats) do
    stages[stat] = 0
  end
  return stages
end;

-- Changes the stat stage of an Entity within the bounds of `[-self.statStageCap .. self.statStageCap]
---@param statName string
---@param stage integer
function Entity:modifyBattleStat(statName, stage) --> void
  if stage < 0 and self.debuffImmune then
    -- Add a flashy animation/effect here
    return
  end
  -- clamping
  local maxStage = self.statStageCap
  local minStage = -self.statStageCap
  local stats = {}

  if statName == 'all' then
    stats = { 'attack', 'defense', 'speed', 'luck' }
  else
    if statName == 'random' then
      local i = love.math.random(#stats)
      statName = stats[i]
    end
    table.insert(stats, statName)
  end

  for _, stat in ipairs(stats) do
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
  for stat, _ in pairs(self.baseStats) do
    if stat ~= 'hp' or stat ~= 'fp' then
      self.battleStats[stat] = self.baseStats[stat]
    end
  end
end;

-- Intended to be called by a skill with a stat-lowering tradeoff
---@param statName string
---@param stage integer
function Entity:lowerAfterSkillResolves(statName, stage)
  self.lowerAfterSkillUse[statName] = math.max(0, self.lowerAfterSkillUse[statName] - stage)
end;

--[[----------------------------------------------------------------------------------------------------
        Status
----------------------------------------------------------------------------------------------------]]

-- Checks for immunities, resistances, and current statuses. Then applies a status if possible
---@param status string
function Entity:applyStatus(status)
  if not self.debuffImmune then
    if not self:isAlreadyAfflicted(status) then
      local chance = love.math.random()

      if chance > self.statusResist[status] then
        table.insert(self.statuses, StatusEffects[status])
        if StatusEffects[status].apply ~= nil then
          local key, mult = StatusEffects[status].apply(self.statMods)
          self.statMods[key] = mult
        end
      else
        print('resisted!')
      end
    end
  end
end;

-- Procs logic for any tickable statuses the Entity has (burn, poison, sleep)
function Entity:tickStatuses()
  for i, status in ipairs(self.statuses) do
    if status.name == 'sleep' then
      local wakeUp, sleepCounter = status.tick(status.sleepCounter)
      if wakeUp then
        self:wakeUp()
      else
        status.sleepCounter = sleepCounter
        self:snooze()
      end
    elseif status.tick then
      local damage = status.tick(self.battleStats.hp, self.baseStats.hp)
      self:tickDOT(status.name, damage)
    end
  end
end;

-- Entity wakes up from sleep status
function Entity:wakeUp()
  local description = self.entityName .. " woke up!"
  -- remove sleep status
end;

-- I don't remember what this was intended for.
function Entity:snooze()
  local description = self.entityName .. " decided to snooze!"
end;

-- Applies a DOT (Damage Over Time) effect
---@param status string
---@param damage integer
function Entity:tickDOT(status, damage)
  local description = self.entityName .. " takes " .. status .. " damage!"

  -- placeholder. need to display this as a text box coroutine
  print(description)

  -- after it happens, take damage, start hurt animation, etc
  self:takeDamagePierce(damage)
end;

-- Checks whether the Entity already has the status
---@param status string
---@return boolean
function Entity:isAlreadyAfflicted(status)
  for _, curr in ipairs(self.statuses) do
    if curr.name == status then
      return true
    end
  end

  return false
end;

-- Raises the Entity's resistance to the statuses passed
---@param statuses string[]
---@param amount integer
function Entity:raiseResist(statuses, amount)
  if statuses == 'all' then
    for status, resistChance in pairs(self.statusResist) do
      self.statusResist[status] = resistChance + amount
    end
  else
    for _, status in ipairs(statuses) do
      self.statusResist[status] = self.statusResist[status] + amount
    end
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Heal & Cleanse
----------------------------------------------------------------------------------------------------]]

-- After healing the Entity, the `OnHPChanged` signal is emitted
---@param amount integer
function Entity:heal(amount) --> void
  local isDamage = false
  if self.tweens['damage'] then
    self.tweens['damage']:stop()
  end
  self.battleStats["hp"] = math.min(self.baseStats["hp"], self.battleStats["hp"] + amount)
  Signal.emit('OnHPChanged', amount, isDamage, Entity.tweenHP)
end;

-- Removes ALL statuses from the Entity
function Entity:cleanse()
  for i, _ in ipairs(self.statuses) do
    local status = table.remove(self.statuses, i)
    -- play effect(s) for heal (use a tween and self-assign using after() to chain visuals)
    print(status) -- temp
  end
end;

-- Removes one status from the Entity
---@param statusToCleanse string
function Entity:cleanseOne(statusToCleanse)
  for i, status in ipairs(self.statuses) do
    if statusToCleanse == status then
      table.remove(self.statuses, i)
      return
    end
  end
end;

-- Revives the Entity, handling the animation transition(s)
---@param pct? number (0,1] Percentage of health to revive with
function Entity:revive(pct)
  local percent = pct or 0.5
  local amount = math.floor(0.5 + self.baseStats.hp)

  self:cleanse()
  self:heal(amount)

  -- play sfx, tween, etc
  self.actor:switch('get_up')
end;

--[[----------------------------------------------------------------------------------------------------
        Damage
----------------------------------------------------------------------------------------------------]]

--[[Deals damage, accounting for defense, critical hit.
Will also transition to a KO'd state if HP falls to 0.]]
---@param amount integer
---@param attackerLuck integer
function Entity:takeDamage(amount, attackerLuck) --> void
  local isCrit = self:isCrit(attackerLuck)
  local damageDuration = 15                      -- generous rn, should be a fcn of the damage taken
  if isCrit then
    amount = amount * self.critMult
    -- Signal.emit('OnCrit')
  end
  self.amount = math.max(0, amount - self.battleStats['defense'])
  self.countFrames = true
  local newHP = math.max(0, self.battleStats["hp"] - self.amount)

  if Entity.tweenHP then
    print('slow tween beginning for HP')
    local damageTween = flux.to(self.battleStats, damageDuration, { hp = newHP })
    -- :oncomplete(function() print('done with hp tween') end)
    self.tweens['damage'] = damageTween
  else
    self.battleStats["hp"] = newHP
  end

  if self:isAlive() then
    self.actor:switch("flinch")
    local anim = self.actor:getCurrentAnimation()
    anim:onAnimOver(function()
      self.actor:switch("idle")
    end)
  end
end;

-- Bypasses checks and deals damage directly.
---@param amount integer
function Entity:takeDamagePierce(amount) --> void
  self.battleStats['hp'] = math.max(0, self.battleStats['hp'] - amount)
  self.actor:switch("flinch")
end;

---@param attackerLuck integer
---@return boolean
function Entity:isCrit(attackerLuck)
  local chance = self:calcCritChance(attackerLuck)
  local rand = love.math.random()

  return rand <= chance
end;

--[[Calculates if hit is a critical hit as a function of the attacker's luck and this Entity's luck.
Critical hit chances range is `[1..100]`.]]
---@param attackerLuck integer
---@return number
function Entity:calcCritChance(attackerLuck)
  local luck = self.battleStats.luck
  local chance = math.min(100, math.max(1, (attackerLuck / 4) - (luck / 8)))
  chance = chance / 100
  return chance
end;

function Entity:startFainting()
  self.actor:switch("ko")
end;

--[[----------------------------------------------------------------------------------------------------
        Animation
----------------------------------------------------------------------------------------------------]]
-- Creates an empty Actor, loops over the paths in `animationData`,
-- creating each animation from its sprite sheet and XML file,
-- then adds it to the Actor
---@param animations string[]
---@param dir string Path to this character's directory
---@return table actor
function Entity:createActor(animations, dir)
  local actor = animx.newActor()
  self:createBaseAnimations(animations, dir, actor)
  self:createSkillAnimations(dir, actor)

  return actor
end;

-- TODO: Need handling for animation state diagram (ex: `get_up` -> `idle`)
---@param animations string[] Array of animation names
---@param dir string The directory where animations are located
---@param actor table Reference to the AnimX actor object housing animations
function Entity:createBaseAnimations(animations, dir, actor)
  for _, name in ipairs(animations) do
    local path = dir .. name .. ".png"
    local animation = animx.newAnimation(path)
    if name == "idle" or name == "run" then
      animation:loop()
    end

    actor:addAnimation(name, animation)
  end
end;

--[[Creates all skill animations up front from the Entity's skill pool.
Animation state changes are handled in the skill's logic file.
NOTE: Character class should not use this to create animations up front!]]
---@param dir string The directory where animations are located
---@param actor table Reference to the AnimX actor object housing animations
function Entity:createSkillAnimations(dir, actor)
  for _, skill in ipairs(self.skillPool) do
    local skillPath = dir .. skill.tag .. "/"
    for _, name in ipairs(skill.animations) do
      local path = skillPath .. name .. ".png"
      local fullName = skill.tag .. "_" .. name -- ex: needle_stab & wind_up -> needle_stab_wind_up
      local animation = animx.newAnimation(path)
      if name == "wobble" or "wobble_fail" then
        animation:loop()
      end
      actor:addAnimation(fullName, animation)
    end
  end
end;

--[[----------------------------------------------------------------------------------------------------
        SFX
----------------------------------------------------------------------------------------------------]]

---@param path string
---@param baseSFXTypes string[]
---@deprecated
function Entity:setSFX(path, baseSFXTypes)
  local sfxList = {}
  for _, sfx in ipairs(baseSFXTypes) do
    local sfxPath = "asset/audio/entities/" .. path .. self.entityName .. "/" .. sfx .. ".wav"
    local src = love.audio.newSource(sfxPath, "static")
    sfxList[sfx] = src
  end
  return sfxList
end;

--[[----------------------------------------------------------------------------------------------------
        Update
----------------------------------------------------------------------------------------------------]]

---@param dt number
function Entity:update(dt) --> void
  self:updateHitbox()
  -- self:updateShadow()

  if Entity.isATB then
    self.progressBar:setPos(self.pos)
  end

  self:updateProjectiles(dt)
  animx.update(dt)
end;

-- Adjusts the hitbox offsets and x,y position based on the current animation state
function Entity:updateHitbox()
  -- local animation = self.animations[self.currentAnimTag]
  local w, h = self.actor:getCurrentAnimation():getDimensions()
  -- local currentQuad = animation.quad[animation.spriteNum]
  -- local sw, sh = currentQuad:getTextureDimensions()
  self.pos.ox = w / 2
  self.pos.oy = h
  self.hitbox.x = self.pos.x - (math.ceil(self.hitbox.w / 2))
  self.hitbox.y = self.pos.y - (math.floor(self.hitbox.h))
  -- self.hbXOffset = (w - self.hitbox.width) / 2
  -- self.hbYOffset = (h - self.hitbox.height) / 2
  -- self.hitbox.x = self.pos.x + self.hbXOffset - self.pos.ox
  -- self.hitbox.y = self.pos.y + self.hbYOffset - self.pos.oy
end;

function Entity:updateShadow()
  self.shadowDims.x = self.hitbox.x + (self.hitbox.w / 2)
  self.shadowDims.y = self.pos.y + (self.pos.oy * 0.95) - self.pos.oy
end;

---@param dt number
function Entity:updateProjectiles(dt)
  for _, projectile in ipairs(self.projectiles) do
    projectile:update(dt)
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Drawing
----------------------------------------------------------------------------------------------------]]
function Entity:draw() --> void
  self:drawShadow()
  self.actor:draw(self.pos.x, self.pos.y, self.pos.r, self.pos.sx, self.pos.sy, self.pos.ox, self.pos.oy)
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

function Entity:drawHitbox()
  if Entity.drawHitboxes then
    love.graphics.setColor(1, 0, 0, 0.4)
    love.graphics.rectangle("fill", self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
    love.graphics.setColor(1, 1, 1)
  end

  if Entity.drawHitboxPositions then
    love.graphics.setColor(0, 0, 0)
    local v = math.floor(self.hitbox.y)
    love.graphics.print(v, self.hitbox.x - 50, v)
    local val = math.floor(self.hitbox.y + self.hitbox.h)
    love.graphics.print(val, self.hitbox.x - 50, val)
    love.graphics.setColor(1, 1, 1)
  end
end;

function Entity:drawProjectiles()
  for _, projectile in ipairs(self.projectiles) do
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
  self.tweens['pbTween'] = flux.to(self.progressBar.meterOptions, remainingDur, { width = goalWidth })
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
