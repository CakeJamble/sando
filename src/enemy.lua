--! filename: Enemy
require ("enemy_state_sprite_sheet")

local class = require 'middleclass'
Enemy = class('Enemy', Entity)

function Enemy:initialize(stats, skills)
  Entity:initialize(stats, skills)
  self.expReward = stats['experience_reward']
end;

function Enemey:getExpReward()
  return self.expReward
end;

function Enemy:setExpReward(amount)
  self.expReward = amount
end;

function Enemy:selectAttack()
  -- select a random attack and random target(s)
end;