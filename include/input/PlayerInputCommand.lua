---@meta

---@class PlayerInputCommand: Command
---@field entity Character
---@field targets { characters: Character[], enemies: Enemy[] }
---@field turnManager Scheduler
---@field awaitingInput boolean
---@field waitingForTarget boolean
---@field action table
---@field isInterruptible boolean
---@field commands { [string]: Command }
---@field commandKey string
PlayerInputCommand = {}

---@param entity Character
---@param turnManager Scheduler
function PlayerInputCommand:init(entity, turnManager) end

---@return { skill_command: SkillCommand, item_command: ItemCommand }
function PlayerInputCommand:defineCommands() end

-- Registers all the different signals this class needs to respond to
function PlayerInputCommand:start() end

-- Cancels this command if it is interruptible
function PlayerInputCommand:interrupt() end

---@param dt number
function PlayerInputCommand:update(dt) end