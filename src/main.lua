-- -- HUMP Globals
Gamestate = require "libs.hump.gamestate"
Camera = require('libs.hump.camera')
shove = require('libs.shove')

Text = require('libs.sysl-text.slog-text')
Frame = require('libs.sysl-text.slog-frame')

states = {
  main_menu         = require 'gamestates.main_menu',
  character_select  = require 'gamestates.character_select',
  bakery            = require 'gamestates.bakery',
  game              = require 'gamestates.game',
  reward            = require 'gamestates.reward',
  combat            = require 'gamestates.combat',
  pause             = require 'gamestates.pause'
}

local framePath = 'asset/sprites/frame/'
images = {}

-- Text box frames
images.frame = {}
images.frame = {}
images.frame.default_8 = love.graphics.newImage(framePath .. "default_8.png")
images.frame.eb_8 = love.graphics.newImage(framePath .. "eb_8.png")
images.frame.m3_8 = love.graphics.newImage(framePath .. "m3_8.png")
images.frame.cart_8 = love.graphics.newImage(framePath .. "cart_8.png")
images.frame.bubble_8 = love.graphics.newImage(framePath .. "bubble_8.png")
images.frame.ff_8 = love.graphics.newImage(framePath .. "ff_8.png")
images.frame.blk_8 = love.graphics.newImage(framePath .. "blk_8.png")
images.frame.bk_32 = love.graphics.newImage(framePath .. "bk_24.png")
images.frame.utp_8 = love.graphics.newImage(framePath .. "utp_8.png")
Text.configure.image_table("images")
Frame.load()

-- Text box audio
local audioPath = 'asset/audio/'
Audio = {}
Audio.text = {}
Audio.text.default = love.audio.newSource(audioPath .. "text/default.ogg", "static")
Audio.sfx = {}
Audio.sfx.ui = love.audio.newSource(audioPath .. "sfx/Selection_Ukelele chord 04_mod.ogg", "static")
Audio.sfx.ui:setVolume(0.3)
Text.configure.audio_table("Audio")
Text.configure.add_text_sound(Audio.text.default, 0.5)

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