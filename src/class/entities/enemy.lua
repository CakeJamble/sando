--! filename: Enemy
local Entity = require("class.entities.entity")
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')
local flux = require('libs.flux')
local starParticles = require('asset.particle.ko')
local Timer = require('libs.hump.timer')

---@class Enemy: Entity
---@field xPos integer
---@field yPos integer
---@field yOffset integer
local Enemy = Class{__includes = Entity,
  -- for testing
  xPos = 450, yPos = 150, yOffset = 90}

---@param data table
function Enemy:init(data)
  self.type = 'enemy'
  self.enemyType = data.enemyType
  Entity.init(self, data, Enemy.xPos, Enemy.yPos)
  local animationsPath = 'asset/sprites/entities/enemy/' .. self.enemyType .. '/' .. self.entityName .. '/'
  self:setAnimations(animationsPath)
  self.expReward = data.experienceReward
  self.moneyReward = data.moneyReward
  self.lootReward = self.setRewardsDistribution(data.rewardsDistribution)

  Enemy.yPos = Enemy.yPos + Enemy.yOffset
  self.drawKOStars = false

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
---@param attackerLuck integer
function Enemy:takeDamage(amount, attackerLuck)
  Entity.takeDamage(self, amount, attackerLuck)

  if self.currentAnimTag == 'ko' then
    flux.to(self.pos, 1.5, {a = 0})
    self.drawKOStars = true
    local lifetime = starParticles[1].system:getEmitterLifetime()
    Timer.after(lifetime, function() self.drawKOStars = false; end)

    local reward = self:knockOut()
    Signal.emit('OnEnemyKO', reward)
  end
end;

---@param amount integer
function Enemy:takeDamagePierce(amount)
  Entity.takeDamagePierce(self, amount)
  if self.currentAnimTag == 'ko' then
    flux.to(self.pos, 1.5, {a = 0})
  end
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
  local skillIndex = love.math.random(1, #self.skillPool)
  self.skill = self.skillPool[skillIndex]
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

---@return table
function Enemy:knockOut()
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