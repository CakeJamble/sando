--! filename: Enemy

local class = require 'middleclass'
Enemy = class('Enemy', Entity)

function Enemy:initialize(stats, skills)
  Entity:initialize(stats, skills)
  self.expReward = stats['experience_reward']
end;


