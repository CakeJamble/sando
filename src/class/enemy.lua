--! filename: Enemy
require ("util.stat_sheet")
require("util.skill_sheet")
require("class.entity")
require("util.enemy_list")
require("util.enemy_skill_list")

Class = require "libs.hump.class"
Enemy = Class{__includes = Entity, 
  -- for testing
  xPos = 350, yPos = 200}

function Enemy:init(enemyName, enemyType)
  Entity.init(self, getStatsByName(enemyName, enemyType), Enemy.xPos, Enemy.yPos)
  Entity.setAnimations(self, enemyType .. '/')
  self.expReward = self.baseStats['experienceReward']
  self.moneyReward = self.baseStats['moneyReward']
  self.lootReward = self:randPickLoot(self.baseStats['lootPool'])
  self.selectedSkill = nil
  Enemy.yPos = Enemy.yPos + 150
end;

function Enemy:knockOut()
  local reward = {}
  reward.exp = self.expReward
  reward.money = self.moneyReward
  reward.loot = self.lootReward
  return reward
end;

function Enemy:randPickLoot(lootPool)
  if not lootPool then return end
  local lootType = lootPool[math.random(1, #lootPool)]
  local lootIndex = lootType[math.random(1, #lootPool.lootType)]
  local lootDict = lootPool.lootType[lootIndex]
  local loot = {}
  if lootType == 'gear' then
    loot = Gear(lootDict)
  elseif lootType == 'consumable' then
    loot = Consumable(lootDict)
  else -- lootType == 'tool'
    loot = Tool(lootDict)
  end
  return loot
end;

function Enemy:getExpReward()
  return self.expReward
end;

function Enemy:setExpReward(amount)
  self.expReward = amount
end;

function Enemy:getMoneyReward()
  return self.moneyReward
end;

function Enemy:setMoneyReward(moneyReward)
  self.moneyReward = moneyReward
end;

function Enemy:selectAttack() --> Skill (?)
  -- select a random attack and random target(s)
end;

function Enemy:update(dt)
  Entity.update(self, dt)
end;

function Enemy:draw()
  Entity.draw(self)
end;
