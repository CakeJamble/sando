---@meta

---@class Inventory
---@field consumableMult number
---@field gears table
---@field toolManager ToolManager
---@field equipManager EquipManager
---@field accessoryManager AccessoryManager
---@field consumables table
---@field numConsumableSlots integer
---@field money integer
---@field displaySellOption false
---@field textXStart integer
---@field textOffset integer
Inventory = {}

---@param characterTeam CharacterTeam
function Inventory:init(characterTeam) end

---@param amount integer
function Inventory:gainMoney(amount) end

---@param amount integer
function Inventory:loseMoney(amount) end

---@param item table
---@param itemType string
function Inventory:addItem(item, itemType) end

---@param item table
---@param itemType string
---@return table
function Inventory:popItem(item, itemType) end

---@param item table
---@return boolean
function Inventory:addConsumable(item) end

---@param index integer
---@return table
function Inventory:popConsumable(index) end

function Inventory:drawUI() end

-- Draws own menu, and containers for each part of inventory
function Inventory:draw() end