-- HUMP Globals
Gamestate = require "libs.hump.gamestate"
Camera = require "libs.hump.camera"
Signal = require "libs.hump.signal"
Timer = require 'libs.hump.timer'
flux = require 'libs.flux'
bump = require 'libs.bump'
world = bump.newWorld(50)

-- Push globals (Screen Size)
push = require "libs.push"
local gameWidth, gameHeight = 640, 360
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth * 0.9, windowHeight * 0.9 
push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false})

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
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])
end;

-- for live console output during program execution
io.stdout:setvbuf('no')