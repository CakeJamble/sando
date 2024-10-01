--! filename: reward
require('team')
require('character')

local reward = {}



function reward:initialize()
  rareToolChance = 0.2
  rareEquipChance = 0.2
  rareChanceDelta = 0.2
  uncommonToolChance = 0.3
  uncommonEquipChance = 0.3
  uncommonChanceDelta = 0.3
  numRewardItems = 3
  rewardItems = {}
  commonToolPoolSize = 30
  commonEquipPoolSize = 10
  uncommonToolPoolSize = 20
  uncommonEquipPoolSize = 7
  rareToolPoolSize = 15
  rareEquipPoolSize = 5
  consumablePoolSize = 12
end;


-- Each time the Reward state is entered, given that we are not coming from a combat state,
  -- the reward state expects 2 integers for the amount of EXP rewarded from the fight, and
  -- the amount of money rewarded from the fight.
function reward:enter(previous, combatType, rewardExp, rewardMoney)
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
    
    if combatType == 'elite' then
      -- gives a tool as a bonus reward
      rewardItems = reward:generateEliteRewards()
  end
end;

function reward:generateEliteRewards()  --> table
  rewardChoices = {}
  local chance = love.math.random()
  table.insert(rewardChoices, reward:getToolReward(chance))
  table.insert(rewardChoices, reward:getEquipReward(chance))
  
  -- pseudorandomly select a third reward that can be a tool, equip, or consumable
  if chance < 0.3 then
    table.insert(rewardChoices, reward:getConsumbaleReward())
  elseif chance < 0.6 then
    table.insert(rewardChoices, reward:getToolReward(chance))
  else
    table.insert(rewardChoices, reward:getEquipReward(chance))
  end
  
  return rewardChoices
end;
  
  -- Selects a random tool reward of an appropriate rarity
  -- updates all rarity chances accordingly
function reward:getToolReward(chance) --> Tool
  if rareToolChance >= chance then
    -- reset the rare chance and add rare tool to reward pool
    rareToolChance = 0.2
    local toolIndex = love.math.random(rareToolPoolSize)
    toolReward = toolPool['rare'][toolIndex]
    rareToolPoolSize -= 1
    table.remove(toolPool, toolReward)
    return toolReward
  elseif uncommonToolChance >= chance then
    rareToolChance = math.min(rareToolChance + rareChanceDelta, 1.0)
    uncommonToolChance = uncommonChanceDelta
    local toolIndex = love.math.random(uncommonToolPoolSize)
    toolReward = toolPool['uncommon'][toolIndex]
    uncommonToolPoolSize -= 1
    table.remove(toolPool, toolReward)
    return toolReward
  else
    rareToolChance = min(rareToolChance + rareChanceDelta, 1.0)
    uncommonToolChance = math.min(uncommonToolChance + uncommonChanceDelta, 1.0)
    local toolIndex = love.math.random(commonToolPoolSize)
    toolReward = toolPool['common'][toolIndex]
    commonToolPoolSize -= 1
    table.remove(toolPool, toolReward)
    return toolReward
  end
  
end;

-- Selects an equipment reward of an appropriate rarity and modifies all rarity
-- chances accordingly
function reward:getEquipReward(chance) --> Equipment
  if rareEquipChance >= chance then
    rareEquipChance = 0.2
    local equipIndex = love.math.random(rareEquipPoolSize)
    equipReward = equipPool['rare'][equipIndex]
    rareEquipPoolSize = rareEquipPoolSize - 1
    table.remove(equipPool, equipReward)
    return equipReward
  elseif uncommonEquipChance >= chance then
    uncommonEquipChance = 0.3
    rareEquipChance = math.min(rareEquipChance + rareChanceDelta, 1.0)
    local equipIndex = love.math.random(uncommonEquipPoolSize)
    equipReward = equipPool['uncommon'][equipIndex]
    table.remove(equipPool, equipReward)
    return equipReward
  else
    uncommonEquipChance = math.min(uncommonEquipChance + uncommonChanceDelta, 1.0)
    rareEquipChance = math.min(rareEquipChance + rareChanceDelta, 1.0)
    local equipIndex = love.math.random(commonEquipPoolSize)
    equipReward = equipPool['common'][equipIndex]
    table.remove(equipPool, equipReward)
    return equipReward
  end
end;

-- Selects a random consumable to offer in rewards. Not affected by any modifiers
function reward:getConsumableReward() --> Consumable
  local consumableIndex = love.math.random(consumablePoolSize)
  consumableReward = consumablePool[consumableIndex]
  return consumableReward
end;


return reward