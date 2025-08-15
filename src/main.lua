-- -- HUMP Globals
Gamestate = require "libs.hump.gamestate"
Camera = require "libs.hump.camera"
Signal = require "libs.hump.signal"
Timer = require 'libs.hump.timer'
flux = require 'libs.flux'

-- Push globals (Screen Size)
push = require "libs.push"
local gameWidth, gameHeight = 640, 360
local windowWidth, windowHeight = love.window.getDesktopDimensions()
windowWidth, windowHeight = windowWidth * 0.5, windowHeight * 0.5 
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

local JoystickUtils = require 'util.joystick_utils'


function love.load()
  input = {joystick = nil}
  font = love.graphics.newFont('asset/thin_sans.ttf')
  love.graphics.setFont(font)
  camera = Camera()
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])
  local joysticks = love.joystick.getJoysticks()
  if joysticks[1] then
    input.joystick = joysticks[1]
    print('added joystick')
  end
end;

function love.joystickadded(joystick)
  print("Joystick connected: " .. joystick:getName())

  if not input.joystick then
    input.joystick = joystick
  end
end;

function love.joystickremoved(joystick)
  print("Joystick disconnected: " .. joystick:getName())

  if input.joystick == joystick then
    input.joystick = nil
  end
end;

function love.update(dt)
  JoystickUtils.update(dt)

  if input.joystick then
    JoystickUtils.updateAxisRepeater(input.joystick, dt)
  end
end;

-- for live console output during program execution
io.stdout:setvbuf('no')