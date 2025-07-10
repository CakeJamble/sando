--! filename: equip

Class = require 'libs.hump.class'
Equip = Class{}

function Equip:init(equipDict, x, y)
    self.equip = equipDict
    self.sprite = love.graphics.newImage(equipDict['spritePath'])
    self.x = x
    self.y = y
end;

function Equip:getStatModifiers()
    return self.equip['statModifiers']
end;

function Equip:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end;