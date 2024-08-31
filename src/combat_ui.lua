--! filename: combat_ui
local class = require 'libs/middleclass'
CombatUI = class('CombatUI')

CombatUI.static.SOLO_BUTTON_PATH = 'asset/sprites/combat/solo_lame.png'
CombatUI.static.FLOUR_BUTTON_PATH = 'asset/sprites/combat/flour.png'
CombatUI.static.DUO_BUTTON_PATH = 'asset/sprites/combat/duo_lame.png'

function CombatUI:initialize()
  -- Team Stats UI
  
  -- Actions UI
  self.soloButton = love.graphics.newImage(CombatUI.static.SOLO_BUTTON_PATH)
  self.flourButton = love.graphics.newImage(CombatUI.static.FLOUR_BUTTON_PATH)
  self.duoButton = love.graphics.newImage(CombatUI.static.DUO_BUTTON_PATH)
end;

function CombatUI:draw()
  love.graphics.draw(self.soloButton)
  love.graphics.draw(self.flourButton)
  love.graphics.draw(self.duoButton)
end;
