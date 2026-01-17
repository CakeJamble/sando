---@meta

---@class DuoButton: SubMenuButton
---@field skillList table[]
---@field selectedSkill table
---@field displaySkillList boolean
---@field description string
DuoButton = {}

---@param pos { [string]: number }
---@param index integer
---@param skillList table[]
---@param actionButton string
function DuoButton:init(pos, index, skillList, actionButton) end