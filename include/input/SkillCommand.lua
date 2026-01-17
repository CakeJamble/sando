---@meta

---@class SkillCommand: Command
---@field qteManager? QTEManager
---@field qteResult boolean
---@field waitingForQTE boolean
---@field isInterruptible boolean
SkillCommand = {}

--[[Constructor for when a Character uses a skill, because it will always have
an associated QTE.]]
---@param entity Character
---@param qteManager QTEManager
function SkillCommand:init(entity, qteManager) end

-- Constructor for when an Enemy uses a skill
---@param entity Enemy
function SkillCommand:init(entity) end

-- Registers all the different signals this class needs to respond to
function SkillCommand:start() end

-- This is called to get the reward for successfully completing a QTE
---@param qteBonus string
---@return fun(number): number
function SkillCommand.getQTEBonus(qteBonus) end

---@param qteBonus? fun(val: number): number
function SkillCommand:executeSkill(qteBonus) end

---@param dt number
function SkillCommand:update(dt) end