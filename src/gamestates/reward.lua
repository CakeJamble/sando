--! filename: reward
require('class.character_team')
require('class.character')
require('util.tool_pool')
require('util.equipment_pool')
require('util.consumable_pool')

local reward = {}

-- Initialize the reward state once when entered for the first time when the game is started
function reward:init()
  rareToolChance = 0.2
  rareEquipChance = 0.2
  rareConsumableChance = 0.2
  rareChanceDelta = 0.2
  uncommonToolChance = 0.3
  uncommonEquipChance = 0.3
  uncommonConsumableChance = 0.3
  uncommonChanceDelta = 0.3
  numRewardItems = 3
  toolRewardPool = GetToolPool()
  consumableRewardPool = GetConsumablePool()
  equipRewardPool = GetEquipmentPool()
end;

-- Each time the Reward state is entered, given that we are not coming from a combat state,
  -- the reward state expects 2 integers for the amount of EXP rewarded from the fight, and
  -- the amount of money rewarded from the fight.
function reward:enter(previous, team, combatType, rewardExp, rewardMoney)
  if previous == states['combat'] then
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
  end
end;

function reward:generateEliteRewards()  --> table
  rewardChoices = {}
  local chance = love.math.random()
  table.insert(rewardChoices, reward:getToolReward(chance))
  table.insert(rewardChoices, reward:getEquipReward(chance))
  
  -- pseudorandomly select a third reward that can be a tool, equip, or consumable
  if chance < 0.3 then
    table.insert(rewardChoices, reward:getConsumbaleReward(chance))
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
  local toolReward
  if rareToolChance >= chance then
    -- reset the rare chance and add rare tool to reward pool
    rareToolChance = 0.2
    toolReward = reward.SelectRandomReward('tool', 'rare')
  elseif uncommonToolChance >= chance then
    rareToolChance = math.min(rareToolChance + rareChanceDelta, 1.0)
    uncommonToolChance = uncommonChanceDelta
    toolReward = reward.SelectRandomReward('tool', 'uncommon')
  else
    rareToolChance = math.min(rareToolChance + rareChanceDelta, 1.0)
    uncommonToolChance = math.min(uncommonToolChance + uncommonChanceDelta, 1.0)
    toolReward = reward.SelectRandomReward('tool', 'common')
  end

  return toolReward
  
end;

-- Selects an equipment reward of an appropriate rarity and modifies all rarity
-- chances accordingly
function reward:getEquipReward(chance) --> Equipment
  local equipReward
  if rareEquipChance >= chance then
    rareEquipChance = 0.2
    equipReward = reward.SelectRandomReward('equip', 'rare')
  elseif uncommonEquipChance >= chance then
    uncommonEquipChance = 0.3
    rareEquipChance = math.min(rareEquipChance + rareChanceDelta, 1.0)
    equipReward = reward.SelectRandomReward('equip', 'uncommon')
  else
    uncommonEquipChance = math.min(uncommonEquipChance + uncommonChanceDelta, 1.0)
    rareEquipChance = math.min(rareEquipChance + rareChanceDelta, 1.0)
    equipReward = reward.SelectRandomReward('equip', 'common')  
  end

  return equipReward
end;

-- Selects a random consumable to offer in rewards. Not affected by any modifiers
function reward:getConsumableReward(chance) --> Consumable
  local consumableReward
  if rareConsumableChance >= chance then
    rareConsumableChance = 0.2
    consumableReward = reward.SelectRandomReward('consumable', 'rare')
  elseif uncommonConsumableChance >= chance then
    uncommonConsumableChance = 0.3
    rareConsumableChance = math.min(rareConsumableChance + rareChanceDelta, 1.0)
    consumableReward = reward.SelectRandomReward('consumable', 'uncommon')
  else
    uncommonConsumableChance = math.min(uncommonConsumableChance + uncommonChanceDelta, 1.0)
    rareConsumableChance = math.min(rareConsumableChance + rareChanceDelta, 1.0)
    consumableReward = reward.SelectRandomReward('consumable', 'common')
  end
  
  return consumableReward
end;

function reward.SelectRandomReward(rewardType, pool)
  local result
  local i
  if rewardType == 'tool' then
    i = love.math.random(#toolRewardPool[pool])
    result = toolRewardPool[pool][i]
    table.remove(toolRewardPool[pool], i)
  elseif rewardType == 'consumable' then
    i = love.math.random(#consumableRewardPool[pool])
    result = consumableRewardPool[pool][i]
    table.remove(consumableRewardPool[pool], i)
  elseif rewardType == 'equip' then
    local equipRewardType = love.math.random(2)
    
    if equipRewardType == 1 then
      i = love.math.random(#equipRewardPool[pool]['equip'])
      table.remove(equipRewardPool[pool]['equip'], i)
    else
      i = love.math.random(#equipRewardPool[pool]['accessory'])
      table.remove(equipRewardPool[pool]['accessory'], i)
    end
    
    result = equipRewardPool[pool][i]
  end

  return result
end;

return reward