Gamestate = require "libs.hump.gamestate"
require("class.entity")
require("class.character")
luis = require("libs.luis.init")("libs/luis/widgets")
Camera = require "libs.hump.camera"
Signal = require "libs.hump.signal"
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
  font = love.graphics.newFont('asset/zai-seagull-felt-tip-pen.regular.otf', 20)
  love.graphics.setFont(font)
  camera = Camera()
  joysticks = love.joystick.getJoysticks()
  active_joystick = joysticks[1]
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])
end;

-- for live console output during program execution
io.stdout:setvbuf('no')