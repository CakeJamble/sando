--! filename: Enemy
require ("util.stat_sheet")
require("util.skill_sheet")
require("class.entities.entity")
require("util.enemy_list")
require("util.enemy_skill_list")
require('class.entities.enemy_offense_state')

Class = require "libs.hump.class"
Enemy = Class{__includes = Entity, 
  -- for testing
  xPos = 450, yPos = 110}

function Enemy:init(enemyName, enemyType)
  self.type = 'enemy'
  Entity.init(self, getStatsByName(enemyName, enemyType), Enemy.xPos, Enemy.yPos)
  Entity.setAnimations(self, enemyType .. '/')
  self.expReward = self.baseStats['experienceReward']
  self.moneyReward = self.baseStats['moneyReward']
  self.lootReward = self.baseStats.rewardsDistribution
  self.offenseState = EnemyOffenseState(self.pos.x, self.pos.y, self.battleStats)
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
