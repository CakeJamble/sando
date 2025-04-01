--! filename: button

require('class.button')

Class = require 'libs.hump.class'
SoloButton = Class{__includes = Button}

function SoloButton:init(x, y, layer, basicAttack)
    Button.init(self, x, y, layer, 'solo_lame.png')
    self.basicAttack = basicAttack
    self.scaleFactor = 1
end;

function SoloButton:keypressed(key)
    -- TODO
end;

function SoloButton:update(dt)
  Button.update(self, dt)
end;
