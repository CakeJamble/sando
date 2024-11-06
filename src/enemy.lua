--! filename: Enemy
require ("stat_sheet")
require("skill_sheet")
require("entity")

local class = require 'libs/middleclass'

Enemy = class('Enemy', Entity)

function Enemy:initialize(enemyName, enemyType)
  stats = enemyLookup(enemyName)
  Entity:initialize(stats, stats['skills'])
  self.expReward = stats['experience_reward']
  self.moneyReward = stats['money_reward']
end;

function enemyLookup(enemyName)
  return getStatsByName(enemyName, enemyType)
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

function Enemy:selectAttack()
  -- select a random attack and random target(s)
end;