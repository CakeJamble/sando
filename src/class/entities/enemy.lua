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
  self.procAI = data.ai
  Enemy.yPos = Enemy.yPos + Enemy.yOffset
  self.drawKOStars = false
  self.sfx = SoundManager(AllSounds.sfx.entities.enemy[self.entityName])

  Signal.register('OnStartCombat',
    function()
      self.oPos.x = self.pos.x
      self.oPos.y = self.pos.y
    end)
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

---@param validTargets table{ characters: Character[], enemies: Enemy[] }
function Enemy:setupOffense(validTargets)
  self.targets, self.skill = self.procAI(self, validTargets)
  Signal.emit('TargetConfirm')
end;

---@deprecated
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
        table.insert(singleTargetSkills, s)
      end
    end

    local i = love.math.random(1, #singleTargetSkills)
    skill = singleTargetSkills[i]
  else
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
end;

function Enemy:draw()
  Entity.draw(self)
  if self.drawKOStars then
    for _,ps in ipairs(starParticles) do
      love.graphics.draw(ps.system, self.pos.x + self.frameWidth / 2, self.pos.y + self.frameHeight / 2)
    end
  end
end;

return Enemy