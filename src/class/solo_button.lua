--! filename: button

require('class.button')
local class = require 'libs/middleclass'
SoloButton = class('SoloButton', Button)

function SoloButton:initialize(x, y)
    Button:initialize(x, y, 'asset/sprites/combat/solo_lame.png')
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