--! filename: Enemy
require("class.entities.entity")
require('class.entities.enemy_offense_state')

Class = require "libs.hump.class"
Enemy = Class{__includes = Entity, 
  -- for testing
  xPos = 450, yPos = 150, yOffset = 40}

function Enemy:init(data)
  self.type = 'enemy'
  self.enemyType = data.enemyType
  Entity.init(self, data, Enemy.xPos, Enemy.yPos)
  local animationsPath = 'asset/sprites/entities/enemy/' .. self.enemyType .. '/' .. self.entityName .. '/'
  self:setAnimations(animationsPath)
  self.expReward = data.experienceReward
  self.moneyReward = data.moneyReward
  self.lootReward = self:setRewardsDistribution(data.rewardsDistribution)
  Enemy.yPos = Enemy.yPos + Enemy.yOffset

  Signal.register('OnStartCombat',
    function()
      self.oPos.x = self.pos.x
      self.oPos.y = self.pos.y
    end)
end;

function Enemy:startTurn(hazards)
  Entity.startTurn(self)

  for i,hazard in pairs(hazards.enemyHazards) do
    hazard:proc(self)
  end
end;

function Enemy:takeDamage(amount)
  Entity.takeDamage(self, amount)

  if self.currentAnimTag == 'ko' then
    flux.to(self.pos, 1.5, {a = 0})
    -- Timer.after(1.5, function() self.drawSelf = false end)
  end
end;

function Enemy:takeDamagePierce(amount)
  Entity.takeDamagePierce(self, amount)
  if self.currentAnimTag == 'ko' then
    flux.to(self.pos, 1.5, {a = 0})
  end
end;

function Enemy:setRewardsDistribution(rewardsDistribution)
  return {
    uncommon = rewardsDistribution[1],
    rare = rewardsDistribution[2]
  }
end;

function Enemy:setupOffense()
  local skillIndex = love.math.random(1, #self.skillPool)
  self.skill = self.skillPool[skillIndex]

  local tIndex = love.math.random(1, #self.targets.characters)
  self.target = self.targets.characters[tIndex]
  Signal.emit('TargetConfirm', 'characters', tIndex)
end;

function Enemy:knockOut()
  local reward = {}
  reward.exp = self.expReward
  reward.money = self.moneyReward
  reward.loot = self.lootReward
  return reward
end;