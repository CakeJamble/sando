-- HUMP Globals
Gamestate = require "libs.hump.gamestate"
local Camera = require('libs.hump.camera')
shove = require('libs.shove')

Text = require('libs.sysl-text.slog-text')
Frame = require('libs.sysl-text.slog-frame')

-- Testing
local parseArgs = require('util.parse_args')
local runTests = require('test.main_tests')

local loadAudio = require('util.audio_loader')
local loadItemPools = require('util.item_pool_loader')

states = {
  main_menu         = require 'gamestates.main_menu',
  character_select  = require 'gamestates.character_select',
  bakery            = require 'gamestates.bakery',
  reward            = require 'gamestates.reward',
  combat            = require 'gamestates.combat',
  pause             = require 'gamestates.pause',
  shop = require('gamestates.shop'),
  event = require('gamestates.event'),
  overworld = require("gamestates.overworld")
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
Audio.sfx.ui = love.audio.newSource(audioPath .. "sfx/uke.ogg", "static")
Audio.sfx.ui:setVolume(0.3)
Text.configure.audio_table("Audio")
Text.configure.add_text_sound(Audio.text.default, 0.5)

local JoystickUtils = require 'util.joystick_utils'

---@param args table Arguments to set the game environment (test vs prod, etc.)
function love.load(args)
  -- Screen Scaling
  shove.setResolution(640, 360, {
      fitMethod = "aspect",
      renderMode = "layer",
    })
  local windowWidth, windowHeight = love.window.getDesktopDimensions()
  windowWidth, windowHeight = windowWidth * 0.8, windowHeight* 0.8
  shove.setWindowMode(2560, 1440, {
    resizable = true
  })

  -- Camera
  camera = Camera()

  -- Input
  input = {joystick = nil}
  local joysticks = love.joystick.getJoysticks()
  if joysticks[1] then
    input.joystick = joysticks[1]
    print('added joystick')
  end

  -- Fonts
  Font = love.graphics.newFont('asset/thin_sans.ttf')
  love.graphics.setFont(Font)

  -- Audio
  AllSounds = {sfx = {}, music = {}}
  local sfxDir = 'asset/audio/sfx'
  local musicDir = 'asset/audio/music'
  loadAudio(sfxDir, AllSounds.sfx, "static")
  loadAudio(musicDir, AllSounds.music, "stream")

  -- Item Pools
  ItemPools = loadItemPools()

  -- Test or Run
  local opts = parseArgs(args)
  if opts.test == "true" then
    IsTestMode = true
    local analyticsThread = love.thread.newThread("analytics/analytics_service.lua")
    analyticsThread:start()
    print("Running tests only")
    runTests(opts)
  else
  -- Gamestates
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])
  end
end;

---@param joystick love.Joystick
function love.joystickadded(joystick)
  print("Joystick connected: " .. joystick:getName())

  if not input.joystick then
    input.joystick = joystick
  end
end;

---@param joystick love.Joystick
function love.joystickremoved(joystick)
  print("Joystick disconnected: " .. joystick:getName())

  if input.joystick == joystick then
    input.joystick = nil
  end
end;

---@param dt number
function love.update(dt)
  JoystickUtils.update(dt)

  if input.joystick then
    JoystickUtils.update(dt)
    JoystickUtils.updateAxisRepeater(input.joystick, dt, "left")
    JoystickUtils.updateAxisRepeater(input.joystick, dt, "right")
  end
end;

function love.quit()
  if IsTestMode then
    local channel = love.thread.getChannel('analytics_input')
    channel:push({type = "quit"})
  end
end;

-- for live console output during program execution
io.stdout:setvbuf('no')