--! filename: Enemy
require ("stat_sheet")
require("skill_sheet")
require("entity")

local class = require 'libs/middleclass'

Enemy = class('Enemy', Entity)

function Enemy:initialize(stats, skills)
  Entity:initialize(stats, skills)
  self.expReward = stats['experience_reward']
end;

function Enemy:getExpReward()
  return self.expReward
end;

function Enemy:setExpReward(amount)
  self.expReward = amount
end;

function Enemy:selectAttack()
  -- select a random attack and random target(s)
end;