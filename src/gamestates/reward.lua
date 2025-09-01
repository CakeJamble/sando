local LevelUpManager = require('class.entities.level_up_manager')
local loadItem = require('util.item_loader')
local json = require('libs.json')
local flux = require('libs.flux')

local reward = {}

-- Initialize the reward state once when entered for the first time when the game is started
function reward:init()
  shove.createLayer('background')
  shove.createLayer('entity', {zIndex = 10})
  shove.createLayer('ui', {zIndex = 100})
  self.rewardPools = self.initRewardPools()
  self.rareChanceDelta = 0.2
  self.uncommonChanceDelta = 0.3
  self.numFloorsWithoutUncommon = 0
  self.numFloorsWithoutRare = 0
  self.numRewardOptions = 3
end;

--- Each time the Reward state is entered, given that we are not coming from a combat state,
-- the reward state expects 2 integers for the amount of EXP rewarded from the fight, and
-- the amount of money rewarded from the fight.
---@param previous table Previous gamestate
---@param rewards table[] Array of rewards from combat, 1 for each enemy
---@param characterTeam CharacterTeam
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

---@return { [string]: table }
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

---@param rewards table[]
---@param rewardType string
function reward.sumReward(rewards, rewardType)
  local result = 0
  for _,rwd in ipairs(rewards) do
    result = result + rwd[rewardType]
  end
  return result
end;

---@param rewards table[]
---@param rarityMod number
function reward:getItemRewards(rewards, rarityMod)
  local result = {}
  for _,rwd in ipairs(rewards) do
    local rewardOptions = self:getRewardOptions(rwd.rarities, rarityMod)
    table.insert(result, rewardOptions)
  end

  return result
end;

---@param rarities { [string]: number}
---@param rarityMod number
---@return table
function reward:getRewardOptions(rarities, rarityMod)
  local options = {}
  for i=1, self.numRewardOptions do
    local rewardType = self:getRewardType()
    local rarity = self:getRarityResult(rarities, rarityMod)
    local itemIndex = love.math.random(1, #self.rewardPools[rewardType][rarity])
    local itemName = table.remove(self.rewardPools[rewardType][rarity], itemIndex)
    -- print(rewardType, rarity, itemName, itemIndex)
    local item = loadItem(itemName, rewardType)
    table.insert(options, item)
  end
  return options
end;

---@param rarities { [string]: number}
---@param rarityMod number
---@return string
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

---@return string
function reward:getRewardType()
  ---@type string[]
  local types = {}
  for k,_ in pairs(self.rewardPools) do
    table.insert(types, k)
  end
  local i = love.math.random(1, #types)
  local result = types[i]

  return result
end;

function reward:gamepadpressed(joystick, button)
  self.levelUpManager:gamepadpressed(joystick, button)
end;

---@param dt number
function reward:update(dt)
  flux.update(dt)
  self.levelUpManager:update(dt)
end;

function reward:draw()
  self.combatState:draw()
  shove.beginDraw()
  camera:attach()
  shove.beginLayer('ui')
  self.levelUpManager:draw()
  shove.endLayer()
  camera:detach()
  shove.endDraw()
end;

return reward