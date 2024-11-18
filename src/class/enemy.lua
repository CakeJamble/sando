--! filename: Enemy
require ("util.stat_sheet")
require("util.skill_sheet")
require("class.entity")
require("util.enemy_list")
require("util.enemy_skill_list")

local class = require 'libs/middleclass'

Enemy = class('Enemy', Entity)

-- why are these static? for testing :D
Enemy.static.yPos = 100
Enemy.static.xPos = 300

function Enemy:initialize(enemyName, enemyType)
  stats = getStatsByName(enemyName, enemyType)
  Entity:initialize(stats, Enemy.static.xPos, Enemy.static.yPos)
  Entity:setAnimations(enemyType .. '/')
  self.expReward = stats['experienceReward']
  self.moneyReward = stats['moneyReward']
  self.selectedSkill = nil
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

function Enemy:draw()
  Entity:draw()
end;
