local SubMenuButton = require("class.ui.SubmenuButton")
local Class = require('libs.hump.class')

---@class DuoButton: SubMenuButton
local DuoButton = Class{__includes = SubMenuButton}

---@param pos { [string]: number }
---@param index integer
---@param skillList table[]
---@param actionButton string
function DuoButton:init(pos, index, skillList, actionButton)
    SubMenuButton.init(self, pos, index, 'duo_lame.png', actionButton, skillList)
    self.skillList = skillList
    self.selectedSkill = nil
    self.displaySkillList = false
    self.description = 'Consume BP to use a powerful teamup skill'
end;

return DuoButton