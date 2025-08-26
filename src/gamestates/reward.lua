--! filename: reward
-- local CharacterTeam = require('class.entities.character_team')
-- local Character = require('class.entities.character')
-- require('util.equipment_pool')
-- require('util.consumable_pool')
-- local loadTool = require('util.tool_loader')
local LevelUpManager = require('class.entities.level_up_manager')
local loadItem = require('util.item_loader')
local json = require('libs.json')
local flux = require('libs.flux')

local reward = {}

-- Initialize the reward state once when entered for the first time when the game is started
function reward:init()
  self.windowWidth, self.windowHeight = push:getDimensions()
  self.windowWidth, self.windowHeight = push:toReal(self.windowWidth, self.windowHeight)
  self.windowWidth, self.windowHeight = self.windowWidth * 0.75, self.windowHeight * 0.75
  -- self.windowWidth, self.windowHeight = 640, 360
  self.wOffset, self.hOffset = self.windowWidth * 0.1, self.windowHeight * 0.1
  -- print('wOffset: ' .. self.wOffset, 'hOffset: ' .. self.hOffset)

  self.rewardPools = self.initRewardPools()
  self.rareChanceDelta = 0.2
  self.uncommonChanceDelta = 0.3
  self.numFloorsWithoutUncommon = 0
  self.numFloorsWithoutRare = 0
  self.numRewardOptions = 3
end;

-- Each time the Reward state is entered, given that we are not coming from a combat state,
  -- the reward state expects 2 integers for the amount of EXP rewarded from the fight, and
  -- the amount of money rewarded from the fight.
function reward:enter(previous, rewards, characterTeam)
  if previous == states['combat'] then
    self.expReward = self.sumReward(rewards, 'exp')
    self.moneyReward = self.sumReward(rewards, 'money')
    self.rewards = self:getItemRewards(rewards, characterTeam.rarityMod)
    self.combatState = previous
    self.levelUpManager = LevelUpManager(characterTeam)
    self.levelUpManager:distributeExperience(self.expReward)
    characterTeam:increaseMoney(self.moneyReward)
  end
end;

function reward.initRewardPools()
  local pref = 'data/item/'
  local jsonPaths = {
    accessory = pref .. 'accessory/',
    consumable = pref .. 'consumable/',
    equip = pref .. 'equip/',
    tool = pref .. 'tool/'
  }

  local result = {}
  for itemType,path in pairs(jsonPaths) do
    local rawCommon = love.filesystem.read(path .. 'common_pool.json')
    local rawUncommon = love.filesystem.read(path .. 'uncommon_pool.json')
    local rawRare = love.filesystem.read(path .. 'rare_pool.json')

    local common = json.decode(rawCommon)
    local uncommon = json.decode(rawUncommon)
    local rare = json.decode(rawRare)

    result[itemType] = {
      common = common,
      uncommon = uncommon,
      rare = rare
    }
  end

  return result
end;


function reward.sumReward(rewards, rewardType)
  local result = 0
  for _,rwd in ipairs(rewards) do
    result = result + rwd[rewardType]
  end
  return result
end;

function reward:getItemRewards(rewards, rarityMod)
  local result = {}
  for _,rwd in ipairs(rewards) do
    local rewardOptions = self:getRewardOptions(rwd.rarities, rarityMod)
    table.insert(result, rewardOptions)
  end

  return result
end;

function reward:getRewardOptions(rarities, rarityMod)
  local options = {}
  for i=1, self.numRewardOptions do
    local rewardType = self:getRewardType()
    local rarity = self:getRarityResult(rarities, rarityMod)
    local itemIndex = love.math.random(1, #self.rewardPools[rewardType][rarity])
    local itemName = table.remove(self.rewardPools[rewardType][rarity], itemIndex)
    print(itemName)
    local item = loadItem(itemName, rewardType)
    table.insert(options, item)
  end
  return options
end;

function reward:getRarityResult(rarities, rarityMod)
  local result = 'common'
  local rand = love.math.random()
  local uncommonChance = rarities.uncommon + rarityMod
  local rareChance = rarities.rare + rarityMod

  if rand <= rareChance + (self.numFloorsWithoutRare * self.rareChanceDelta) then
    result = 'rare'
    self.numFloorsWithoutRare = 0
    self.numFloorsWithoutUncommon = 0
  elseif rand <= uncommonChance + (self.numFloorsWithoutUncommon * self.uncommonChanceDelta) then
    result = 'uncommon'
    self.numFloorsWithoutUncommon = 0
  end

  return result
end;

function reward:getRewardType()
  local types = {}
  for k,_ in pairs(self.rewardPools) do
    table.insert(types, k)
  end
  local i = love.math.random(1, #types)
  local result = types[i]

  return result
end;

function reward:update(dt)
  flux.update(dt)
  self.levelUpManager:update(dt)
end;

function reward:draw()
  push:start()
  camera:attach()
  self.combatState:draw()
  love.graphics.push()
  love.graphics.translate(self.wOffset, self.hOffset)

  love.graphics.setColor(0, 0, 0, 0.6) -- dark transparent background
  love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
  love.graphics.setColor(1, 1, 1)

  self.levelUpManager:draw()
  love.graphics.pop()
  camera:detach()
  push:finish()
end;

return reward