--! filename: Enemy
-- require ("util.stat_sheet")
-- require("util.skill_sheet")
require("class.entities.entity")
-- require("util.enemy_list")
-- require("util.enemy_skill_list")
require('class.entities.enemy_offense_state')

Class = require "libs.hump.class"
Enemy = Class{__includes = Entity, 
  -- for testing
  xPos = 450, yPos = 110}

function Enemy:init(data)
  self.type = 'enemy'
  self.enemyType = data.enemyType
  Entity.init(self, data, Enemy.xPos, Enemy.yPos)
  local subdir = self.type .. '/' .. data.enemyType .. '/'
  self:setAnimations(subdir)
  self.expReward = data.experienceReward
  self.moneyReward = data.moneyReward
  self.lootReward = self:setRewardsDistribution(data.rewardsDistribution)
  Enemy.yPos = Enemy.yPos + 150

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

function Enemy:setRewardsDistribution(rewardsDistribution)
  return {
    uncommon = rewardsDistribution[1],
    rare = rewardsDistribution[2]
  }
end;

function Enemy:setupOffense()
  local skillIndex = love.math.random(1, #self.skillList)
  self.skill = self.skillList[skillIndex]

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
