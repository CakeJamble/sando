---@meta

---@class AICommand: Command
---@field targets { characters: Character[], enemies: Enemy[] }
---@field turnManager Scheduler
---@field awaitingInput boolean
---@field waitingForTarget boolean
---@field skill table
---@field isInterruptible boolean
AICommand = {}

---@param entity Entity
---@param turnManager Scheduler
function AICommand:init(entity, turnManager) end

function AICommand:start() end

---@param dt number
function AICommand:update(dt) end