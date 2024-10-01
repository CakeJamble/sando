--! filename: reward
require('team')
require('character')

local Reward = {}

-- Each time the Reward state is entered, given that we are not coming from a combat state,
  -- the reward state expects 2 integers for the amount of EXP rewarded from the fight, and
  -- the amount of money rewarded from the fight.
function Reward:enter(previous, rewardExp, rewardMoney)
  if previous == combat then
    -- Check number of survivors
    livingTeamMembers = 0
    for member in team do
      if member:isAlive() then
        livingTeamMembers = livingTeamMembers + 1
      end
    end
    
    -- divvy up exp between the survivors
    expPerCharacter = rewardExp / livingTeamMembers
    
    for _,member in pairs(team) do
      member:gainExp(expPerCharacter)
    end
    
    team:setMoney(rewardMoney)
  end
end;



return Reward