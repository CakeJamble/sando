---@meta

---@class AccessoryManager
---@field characterTeam CharacterTeam
---@field list { [string]: table }
---@field indices { [string]: integer }
---@field signalHandlers table
---@field showSwapInterface boolean
---@field ui table
---@field i integer
AccessoryManager = {}

---@param characterTeam CharacterTeam
function AccessoryManager:init(characterTeam) end

---@param item table
function AccessoryManager:addItem(item) end

-- Pops an item off the list and returns it. Raises an error if the list is empty.
---@param item table
---@return table
function AccessoryManager:popItem(item) end

-- TODO
---@param character Character
---@param i integer
---@param itemType string
function AccessoryManager:equip(character, i, itemType) end

---@param character Character
---@param itemType string
---@param pos integer
---@return { [string]: any }
function AccessoryManager:unequip(character, itemType, pos) end

---@param character Character
---@param item table
---@param itemType string
---@return thread
function AccessoryManager:createEquipCoroutine(character, item, itemType) end

--[[ Defines all the different names of signals that an Accessory can emit.
This essentially translates into the different Accessory "types" in the game.]]
---@return { [string]: table}
function AccessoryManager.initItemLists() end

---@param list { [string]: table }
---@return { [string]: integer }
function AccessoryManager.initIndices(list) end

---@param name string
---@param f fun(...)
function AccessoryManager:registerSignal(name, f) end

-- Registers all the different signals this class needs to respond to
function AccessoryManager:registerSignals() end

function AccessoryManager:draw() end

---@param stats { [string]: integer }
---@param gearTable table
---@param item table
function AccessoryManager:displaySwapInterface(stats, gearTable, item) end

function AccessoryManager:drawSwapInterface() end