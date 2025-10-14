--! filename: Enemy
local Entity = require("class.entities.entity")
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')
local flux = require('libs.flux')
local starParticles = require('asset.particle.ko')
local Timer = require('libs.hump.timer')
local SoundManager = require('class.ui.sound_manager')

---@class Enemy: Entity
---@field xPos integer
---@field yPos integer
---@field yOffset integer
local Enemy = Class{__includes = Entity,
  -- for testing
  xPos = 450, yPos = 150, yOffset = 90}

---@param data table
function Enemy:init(data)
  self.enemyType = data.enemyType
  Entity.init(self, data, Enemy.xPos, Enemy.yPos, "enemy")
  local animationsPath = 'asset/sprites/entities/enemy/' .. self.enemyType .. '/' .. self.entityName .. '/'
  self:setAnimations(animationsPath)
  self.expReward = data.experienceReward
  self.moneyReward = data.moneyReward
  self.lootReward = self.setRewardsDistribution(data.rewardsDistribution)

  Enemy.yPos = Enemy.yPos + Enemy.yOffset
  self.drawKOStars = false
  self.sfx = SoundManager(AllSounds.sfx.entities.enemy[self.entityName])

  self:defineShaders()
  self.patternOffset = {x=0,y=0}
  self.prevPos = {x = self.pos.x, y = self.pos.y}
  Signal.register('OnStartCombat',
    function()
      self.oPos.x = self.pos.x
      self.oPos.y = self.pos.y
    end)
end;

function Enemy:defineShaders()
  self.pattern = love.graphics.newImage("asset/shader/pattern/dust.png")
  self.pattern:setWrap("repeat", "repeat")
  self.bodyShader = love.graphics.newShader("asset/shader/scrollfill_color_replace.glsl")
  self.scrollSpeed = {0.2, 0.2}
  self.patternScale = {3.0, 3.0}
  self.time = 0

  self.bodyShader:send("pattern", self.pattern)
  self.bodyShader:send("patternScale", self.patternScale)

  local r,g,b = 0xa1, 0xae, 0xae
  r,g,b = r/255, g/255, b/255
  self.bodyShader:send("targetColor", {r, g, b})
  self.bodyShader:send("tolerance", 0.2)
end;

---@param targets { [string]: Entity[] }
---@param targetType string
function Enemy:setTargets(targets, targetType)
  if targetType == 'any' then
    Entity.setTargets(self, targets)
  else
    self.targetableEntities = targets[targetType]
  end
end;

---@param amount integer
function Enemy:takeDamagePierce(amount)
  Entity.takeDamagePierce(self, amount)
  if self.currentAnimTag == 'ko' then
    flux.to(self.pos, 1.5, {a = 0})
  end
end;

function Enemy:startFainting()
  Entity.startFainting(self)
  flux.to(self.pos, 1.5, {a = 0})
  self.drawKOStars = true
  local lifetime = starParticles[1].system:getEmitterLifetime()
  Timer.after(lifetime, function() self.drawKOStars = false; end)
  self.sfx:play("ko")
end;

---@param rewardsDistribution integer[]
---@return { [string]: integer}
function Enemy.setRewardsDistribution(rewardsDistribution)
  return {
    uncommon = rewardsDistribution[1],
    rare = rewardsDistribution[2]
  }
end;

---@param validTargets { [string]: Entity[]}
function Enemy:setupOffense(validTargets)
  self.skill = self.getRandomSkill(self.skillPool, #validTargets)
  local targetType = self.skill.targetType
  local isSingleTarget = self.skill.isSingleTarget
  self:setTargets(validTargets, targetType)
  self.targets = self:targetSelect(targetType, isSingleTarget)
  Signal.emit('TargetConfirm')
end;

---@param targetType string
---@param  isSingleTarget boolean
function Enemy:targetSelect(targetType, isSingleTarget)
  local targets = {}

  if isSingleTarget then
    local tIndex = love.math.random(1, #self.targetableEntities)
    table.insert(targets, self.targetableEntities[tIndex])
  else
    for _,entity in ipairs(self.targetableEntities) do
      table.insert(targets, entity)
    end
  end

  return targets
end;

---@param skillPool table
---@param numValidTargets integer
function Enemy.getRandomSkill(skillPool, numValidTargets)
  local skill

  if numValidTargets == 1 then
    local singleTargetSkills = {}
    for _,s in ipairs(skillPool) do
      if s.isSingleTarget then
        table.insert(singleTargetSkills)
      end
    end

    local i = love.math.random(1, #singleTargetSkills)
    skill = singleTargetSkills[i]
  else
    print('selecting from all skills')
    local i = love.math.random(1, #skillPool)
    skill = skillPool[i]
  end

  return skill
end;

---@return table
function Enemy:getRewards()
  local reward = {
    exp = self.expReward,
    money = self.moneyReward,
    rarities = self.lootReward  -- table(uncommon: number, rare: number)
  }
  return reward
end;

---@param dt number
function Enemy:update(dt)
  Entity.update(self, dt)
  if self.drawKOStars then
    for _,ps in ipairs(starParticles) do
      ps.system:update(dt)
    end
  end
  self:updateShader()
end;

function Enemy:updateShader()
  local dx,dy = self.pos.x - self.prevPos.x, self.pos.y - self.prevPos.y
  self.patternOffset.x = self.patternOffset.x + dx * self.scrollSpeed[1]
  self.patternOffset.y = self.patternOffset.y + dy * self.scrollSpeed[2]
  self.bodyShader:send("patternOffset", {self.patternOffset.x, self.patternOffset.y})
  self.prevPos.x, self.prevPos.y = self.pos.x, self.pos.y
end;

function Enemy:draw()
  love.graphics.setShader(self.bodyShader)
  Entity.draw(self)
  if self.drawKOStars then
    for _,ps in ipairs(starParticles) do
      love.graphics.draw(ps.system, self.pos.x + self.frameWidth / 2, self.pos.y + self.frameHeight / 2)
    end
  end
  love.graphics.setShader()
end;

return Enemy