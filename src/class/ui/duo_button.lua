--! filename: dup button
local SubMenuButton = require("class.ui.submenu_button")
local Class = require('libs.hump.class')
local DuoButton = Class{__includes = SubMenuButton}

function DuoButton:init(pos, index, skillList, actionButton)
    SubMenuButton.init(self, pos, index, 'duo_lame.png', actionButton, skillList)
    self.skillList = skillList
    self.selectedSkill = nil
    self.displaySkillList = false
    self.description = 'Consume BP to use a powerful teamup skill'
end;

return DuoButton