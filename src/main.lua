Gamestate = require "libs.hump.gamestate"
loveframes = require "libs.loveframes"
require("entity")
require("character")
require("turn_queue")

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
  loveframes.update(dt)
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])
end
