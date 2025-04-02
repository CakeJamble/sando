Gamestate = require "libs.hump.gamestate"
loveframes = require "libs.loveframes"
require("class.entity")
require("class.character")

states = {
  main_menu         = require 'gamestates.main_menu',
  character_select  = require 'gamestates.character_select',
  bakery            = require 'gamestates.bakery',
  game              = require 'gamestates.game',
  reward            = require 'gamestates.reward',
  combat            = require 'gamestates.combat',
  pause             = require 'gamestates.pause'
}

function love.load()
  font = love.graphics.newFont('asset/Cafe Francoise_D.otf')
  love.graphics.setFont(font)
  loveframes.update(dt)
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])
end;