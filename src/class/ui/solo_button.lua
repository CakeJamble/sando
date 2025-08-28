local Button = require('class.ui.button')
local Class = require 'libs.hump.class'

---@class SoloButton: Button
local SoloButton = Class{__includes = Button}

---@param pos { [string]: number }
---@param index integer
---@param basicAttack table
function SoloButton:init(pos, index, basicAttack)
  Button.init(self, pos, index, 'solo_lame.png')
  self.selectedSkill = basicAttack
  self.active = false
  self.description = 'Attack with a basic attack'
end;

return SoloButton