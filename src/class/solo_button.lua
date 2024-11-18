--! filename: button

require('class.button')

Class = require 'libs.hump.class'
SoloButton = Class{__includes = Button}

function SoloButton:init(x, y)
    Button:init(x, y, Button.BUTTON_PATH .. 'solo_lame.png')
end;

function SoloButton:keypressed(key)
    -- TODO
end;

function SoloButton:update(dt)
    Button:update(dt)
end;

function SoloButton:draw()
    Button:draw()
end;