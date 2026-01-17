---@meta

-- CTB is similar to STB except that enemies act once every n character actions
---@class CTBScheduler: Scheduler
---@field combatants Character[]
---@field enemyTimers table[]
---@field turnIndex integer
---@field activeEntity Entity
---@field activeCommand Command
---@field characterCommandQueue Command[]
---@field enemyCommandQueue Command[]
---@field isEnemyTurn boolean
CTBScheduler = {}

---@param characterTeam CharacterTeam
---@param enemyTeam EnemyTeam
---@param config table
function CTBScheduler:init(characterTeam, enemyTeam, config) end

function CTBScheduler:enter() end

-- Sorts based on speed stat
---@param t Character[]
---@return table
function CTBScheduler:sortQueue(t) end

-- Sorts other combatants in queue, in case their speeds were modified this turn.
function CTBScheduler:sortWaitingCombatants() end

-- for now, all enemies go every 3 turns
---@param enemy Enemy
---@return {enemy: Enemy, tick: integer, gauge: integer}
function CTBScheduler.initCTimer(enemy) end

--[[Increments the tick value of every `tick` value in `self.enemyTimers`.
If the timer goes off, their action is inserted into `self.enemyCommandQueue`.]]
function CTBScheduler:tick() end

---@param command Command
function CTBScheduler:enqueueCommand(command) end

function CTBScheduler:checkQueues() end

-- Roundabout way of removing enemy KOs without putting them in the combatants list
function CTBScheduler:removeKOs() end

-- Update enemies without needing them in the combatants list
---@param dt number
function CTBScheduler:update(dt) end

function CTBScheduler:draw() end