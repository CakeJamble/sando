---@meta

-- Distributes loot rewards (Accessory, Equip, Tool, Consumables)
---@class LootManager
---@field lootOptions table
---@field pick3UI table
---@field coroutines table
---@field i integer
---@field isDisplayingNotification boolean
---@field textBox table
---@field isActive boolean
---@field highlightSelected boolean
---@field lootIndex integer
---@field selectedReward table
---@field isRewardSelected boolean
---@field tweens table
LootManager = {}

---@return table
function LootManager.initUI(loot) end

-- Begins a dialog selection sequence for the player to select loot(s)
function LootManager:distributeLoot() end

---@param loot table
---@return thread
function LootManager:createLootSelectCoroutine(loot) end

--[[Controller for `self.coroutines`. When a loot is selected, the `OnLootChosen`
signal will be emitted. Once all coroutines are finished,
it emits the `OnLootDistributionComplete` signal, which will cause the
LevelUpManager to relinquish control of the program to the calling object.
There are two separate signals defined here to provide flexibility for designing
interactions where 1 or more loot selections take place in succession.]]
function LootManager:resumeCurrent() end

-- Raises the highlighted item and lowers the other items
function LootManager:raiseItemTween() end

---@param dt number
function LootManager:update(dt) end

function LootManager:draw() end