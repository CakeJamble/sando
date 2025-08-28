-- -- HUMP Globals
Gamestate = require "libs.hump.gamestate"
Camera = require('libs.hump.camera')
shove = require('libs.shove')

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
  shove.setResolution(640, 360, {
      fitMethod = "aspect",
      renderMode = "layer",
    })
  local windowWidth, windowHeight = love.window.getDesktopDimensions()
  windowWidth, windowHeight = windowWidth * 0.8, windowHeight* 0.8
  shove.setWindowMode(windowWidth, windowHeight, {
    resizable = true
  })

  input = {joystick = nil}
  font = love.graphics.newFont('asset/thin_sans.ttf')
  love.graphics.setFont(font)
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])
  camera = Camera()
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