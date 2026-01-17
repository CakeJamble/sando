---@meta

---@class FlourButton: SubMenuButton
---@field description string
---@field pickableSkillIndices table
FlourButton = {}

---@param pos { [string]: number }
---@param index integer
---@param skillList table[]
---@param actionButton string
function FlourButton:init(pos, index, skillList, actionButton) end

---@return string
function FlourButton:skillListToStr() end

---@param currentFP integer
function FlourButton:validateSkillCosts(currentFP) end

---@param dt number
function FlourButton:update(dt) end