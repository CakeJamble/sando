--! filename: button

require('class.ui.button')

Class = require 'libs.hump.class'
SoloButton = Class{__includes = Button}

function SoloButton:init(pos, index, basicAttack)
  Button.init(self, pos, index, 'solo_lame.png')
  self.selectedSkill = basicAttack
  self.active = false
  self.description = 'Attack with a basic attack'
end;
