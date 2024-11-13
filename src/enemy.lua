--! filename: Enemy
require ("stat_sheet")
require("skill_sheet")
require("entity")
require("enemy_list")
require("enemy_skill_list")

local class = require 'libs/middleclass'

Enemy = class('Enemy', Entity)

-- why are these static? for testing :D
Enemy.static.yPos = 100
Enemy.static.xPos = 100

function Enemy:initialize(enemyName, enemyType)
  stats = getStatsByName(enemyName, enemyType)
  Entity:initialize(stats, Enemy.static.xPos, Enemy.static.yPos)
  self.expReward = stats['experienceReward']
  self.moneyReward = stats['moneyReward']
  self.selectedSkill = nil
end;

function Enemy:enemyLookup(enemyName, enemyType)
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

function Enemy:draw()
  if not Enemy:attacking() then
    Entity:draw()
  else
    if not(self.selectedSkill == nil) then
      self.selectedSkill:draw()
    end
  end
  
end;
