---@meta

---@class SoloButton: Button
---@field selectedSkill table
---@field active boolean
---@field description string
SoloButton = {}

---@param pos { [string]: number }
---@param index integer
---@param basicAttack table
function SoloButton:init(pos, index, basicAttack) end