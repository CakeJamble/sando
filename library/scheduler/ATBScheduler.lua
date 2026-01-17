---@meta

-- Active Timer Battle Scheduler
---@class ATBScheduler: Scheduler
---@field commandQueue {interruptibles: Command[], uninterruptibles: Command[]}
---@field activeCommand Command
---@field awaitingPlayerAction boolean
ATBScheduler = {}

---@param characterTeam CharacterTeam
---@param enemyTeam EnemyTeam
---@param config table
function ATBScheduler:init(characterTeam, enemyTeam, config) end

function ATBScheduler:enter() end

function ATBScheduler:exit() end

---@param command Command
---@param isInterruptible boolean
function ATBScheduler:enqueueCommand(command, isInterruptible) end

function ATBScheduler:checkQueues() end

function ATBScheduler:removeKOs() end

---@param dt number
function ATBScheduler:update(dt) end

