--! filename: equip

local class = require 'libs/middleclass'
local Equip = class('Equip')

function Equip:initialize(equipDict, x, y)
    self.equip = equipDict
    self.sprite = love.graphics.newImage(equipDict['spritePath'])
    self.x = x
    self.y = y
end;

function Equip:getStatModifiers()
    return self.equip['statModifiers']
end;

function Equip:setPosition(x, y) --> void
    self.x = x
    self.y = y
end;

function Equip:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end;