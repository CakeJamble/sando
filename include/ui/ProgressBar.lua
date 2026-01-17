---@meta

---@class ProgressBar
---@field active boolean
---@field pos {x: integer, y: integer}
---@field offsets {x: integer, y: integer}
---@field min integer
---@field max integer
---@field containerOptions {mode: string, width: integer, height: integer}
---@field meterStartingWidth integer
---@field meterOptions {color: integer[], mode: string, width: integer, height: integer, value: integer}
---@field mult number
ProgressBar = {}

---@param targetPos { [string]: integer }
---@param options {[string]: any }
---@param isOffensive boolean
---@param color integer[]
function ProgressBar:init(targetPos, options, isOffensive, color) end

--[[Called when using buffs/heals we want the Progress Bar to display
near the entity using the skill, rather than the target of the skill ]]
function ProgressBar:reversePosOffsets() end

---@param amount integer
---@return integer
function ProgressBar:increaseMeter(amount) end

---@param amount integer
function ProgressBar:decreaseMeter(amount) end

---@param pos { [string]: integer }
function ProgressBar:setPos(pos) end

function ProgressBar:reset() end

function ProgressBar:draw() end