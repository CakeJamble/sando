--! filename: reward

local Reward = {}

function Reward:init()
  
end;

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
end;

return Reward