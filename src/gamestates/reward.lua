--! filename: reward
require('class.entities.character_team')
require('class.entities.character')
-- require('util.equipment_pool')
-- require('util.consumable_pool')

local reward = {}

-- Initialize the reward state once when entered for the first time when the game is started
function reward:init()
  self.windowWidth, self.windowHeight = love.window.getDesktopDimensions()
  self.windowWidth, self.windowHeight = self.windowWidth * 0.75, self.windowHeight * 0.75
  self.wOffset, self.hOffset = self.windowWidth * 0.1, self.windowHeight * 0.1
  
  self.toolPools = {}
  self.rareChanceDelta = 0.2
  self.uncommonChanceDelta = 0.3
  self.numFloorsWithoutUncommon = 0
  self.numFloorsWithoutRare = 0
end;

-- Each time the Reward state is entered, given that we are not coming from a combat state,
  -- the reward state expects 2 integers for the amount of EXP rewarded from the fight, and
  -- the amount of money rewarded from the fight.
function reward:enter(previous, rewards)
  if previous == states['combat'] then
    self.combatState = previous
    self.lootRewardOptions = {}
    local reward
    -- for now, just do 1 tool reward per enemy defeated
    for i=1,#rewards do
      reward = self:getToolReward(rewards[i].loot)
      table.insert(self.lootRewardOptions, reward)
    end

    for i=1,#self.lootRewardOptions do
      print(self.lootRewardOptions[i])
    end
  end
end;

-- Selects a random tool reward of an appropriate rarity
-- updates all rarity chances accordingly
function reward:getToolReward(rewardDistribution) --> Tool
  local toolReward
  local trueChance
  local i

  -- Rare chance
  trueChance = rewardDistribution.rare + (self.numFloorsWithoutRare * self.rareChanceDelta)
  if love.math.random() < trueChance then
    i = love.math.random(1, #self.toolPools.rare)
    numFloorsWithoutRare = 0
    numFloorsWithoutUncommon = 0
    return self.toolPools.rare[i]
  end

  -- Uncommon chance
  trueChance = rewardDistribution.uncommon + (self.numFloorsWithoutUncommon * self.uncommonChanceDelta)
  if love.math.random() < trueChance then
    i = love.math.random(1, #self.toolPools.uncommon)
    numFloorsWithoutUncommon = 0
    return self.toolPools.uncommon[i]
  end

  self.numFloorsWithoutUncommon = self.numFloorsWithoutUncommon + 1
  self.numFloorsWithoutRare = self.numFloorsWithoutRare + 1

  i = love.math.random(1, #self.toolPools.common)
  return self.toolPools.common[i]
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

function reward:draw()
  self.combatState:draw()

  love.graphics.setColor(0, 0, 0, 0.6) -- dark transparent background
  love.graphics.rectangle("fill", self.wOffset, self.hOffset, self.windowWidth, self.windowHeight)

  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Victory! You earned:", 100, 100)
  love.graphics.print("Gold: " .. 10, 100, 130)
  love.graphics.print("Press Enter to continue", 100, 180)
end;

return reward