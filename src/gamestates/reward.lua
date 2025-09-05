local LevelUpManager = require('class.entities.level_up_manager')
local LootManager = require('class.entities.loot_manager')
local loadItem = require('util.item_loader')
local json = require('libs.json')
local flux = require('libs.flux')
local Signal = require('libs.hump.signal')

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
    local lootOptions = self:getItemRewards(rewards, characterTeam.rarityMod)
    self.lootManager = LootManager(lootOptions)
    self.combatState = previous
    self.levelUpManager = LevelUpManager(characterTeam)
    self.levelUpManager:distributeExperience(self.expReward)
    self.moneyValues = {
      rewardVal = self.moneyReward,
      totalVal = characterTeam.inventory.money
    }
    self:increaseMoney(characterTeam)
  end

  -- temp
  Signal.register('OnExpDistributionComplete',
    function()
      print('finished distributing exp! Returning control back to the reward state')
      self.lootManager:distributeLoot()
    end)

  Signal.register('OnLootChosen',
    function(loot)
      self:addToInventory(characterTeam, loot)
    end)
  Signal.register('OnLootDistributionComplete',
    function(selectedReward)
      print(selectedReward.name)
      self:increaseMoney(characterTeam)
  end)
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

-- gets a set of reward options for every enemy in combat
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

-- gets n random items of any type (consumable, equip, accessory, tool) and returns that table
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
    print(rewardType, rarity, itemName, itemIndex)
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

-- adds item to inventory. Does not force it to be equipped at this time
---@param characterTeam CharacterTeam
---@param item table
function reward:addToInventory(characterTeam, item)
  local itemType = item.itemType
  local itemManager

  if itemType == 'accessory' then
    itemManager = characterTeam.inventory.accessoryManager
  elseif itemType == 'equip' then
    itemManager = characterTeam.inventory.equipManager
  elseif itemType == 'tool' then
    itemManager = characterTeam.inventory.toolManager
  else
    characterTeam.inventory:addConsumable(item)
  end

  if itemManager then
    itemManager:addItem(item)
  end
end;

---@param characterTeam CharacterTeam
function reward:increaseMoney(characterTeam)
  local amount = self.moneyReward + characterTeam.inventory.money
  flux.to(self.moneyValues, 1.5, {rewardVal = 0, totalVal = amount})
    :oncomplete(function()
      characterTeam:increaseMoney(self.moneyReward)
    end)
end;

---@param joystick string
---@param button string
function reward:gamepadpressed(joystick, button)
  self.levelUpManager:gamepadpressed(joystick, button)
  self.lootManager:gamepadpressed(joystick, button)
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
  self.lootManager:draw()

  love.graphics.push()
  local rewardVal = math.floor(self.moneyValues.rewardVal)
  local currVal = math.floor(0.5 + self.moneyValues.totalVal)
  love.graphics.translate(250, 0)
  love.graphics.print(rewardVal .. ' -> ' .. currVal, 0, 0)
  love.graphics.pop()

  shove.endLayer()
  camera:detach()
  shove.endDraw()
end;

return reward