---@meta

---@class Command
---@field entity Entity
---@field done boolean
---@field signalHandlers table
---@field isInterruptible boolean
Command = {}

---@param entity Entity
function Command:init(entity) end

---@param name string
---@param f fun(...)
function Command:registerSignal(name, f) end

function Command:cleanupSignals() end
function Command:start() end
function Command:interrupt() end

---@param dt number
function Command:update(dt) end