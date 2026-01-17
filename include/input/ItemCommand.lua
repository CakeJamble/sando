---@meta

---@class ItemCommand: Command
---@field qteManager QTEManager
---@field item table
---@field isInterruptible boolean
---@field waitingForQTE boolean
ItemCommand = {}

-- Constructor for an Enemy using an Item
---@param entity Enemy
---@param item table
function ItemCommand:init(entity, item) end

--[[Constructor for when a Character uses an Item, because it will always have
an associated QTE.]]
---@param entity Character
---@param item table
---@param qteManager QTEManager
function ItemCommand:init(entity, item, qteManager) end

-- Begins Item logic after QTE resolves (if applicable)
---@param turnManager Scheduler
function ItemCommand:start(turnManager) end

function ItemCommand:executeItemAction() end

---@param dt number
function ItemCommand:update(dt) end