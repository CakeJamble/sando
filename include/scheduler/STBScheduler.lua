---@meta

-- Standard Turn Based Scheduler
---@class STBScheduler: Scheduler
---@field turnIndex integer
---@field activeEntity Entity
---@field activeCommand Command
---@field commandQueue Command[]
STBScheduler = {}

---@param characterTeam CharacterTeam
---@param enemyTeam EnemyTeam
---@param config table
function STBScheduler:init(characterTeam, enemyTeam, config) end

function STBScheduler:enter() end

function STBScheduler:exit() end

-- Sorts based on speed
---@param t Entity[]
---@return Entity[]
function STBScheduler:sortQueue(t) end

-- Sorts other combatants in queue, in case their speeds were modified this turn.
function STBScheduler:sortWaitingCombatants() end

---@param command Command
function STBScheduler:enqueueCommand(command) end

function STBScheduler:checkQueues() end

function STBScheduler:removeKOs() end