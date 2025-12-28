-- HUMP Globals
Gamestate = require "libs.hump.gamestate"
local Camera = require('libs.hump.camera')
shove = require('libs.shove')

Text = require('libs.sysl-text.slog-text')
Frame = require('libs.sysl-text.slog-frame')

local Settings = require('class.settings.Settings')
-- Testing
local parseArgs = require('util.parse_args')
local runTests = require('test.main_tests')

local loadAudio = require('util.audio_loader')
local loadItemPools = require('util.item_pool_loader')

-- PostProcessing Effects
local screenCanvas

states = {
  MainMenu         = require 'gamestates.MainMenu',
  CharacterSelect  = require 'gamestates.CharacterSelect',
  Bakery            = require 'gamestates.Bakery',
  Reward            = require 'gamestates.Reward',
  Combat            = require 'gamestates.Combat',
  Pause             = require 'gamestates.Pause',
  Shop = require('gamestates.Shop'),
  Event = require('gamestates.Event'),
  Overworld = require("gamestates.Overworld")
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
  screenCanvas = love.graphics.newCanvas()
  -- postShader = love.graphics.newShader("asset/shader/postprocess.glsl")

  -- Load Audio
  AllSounds = {sfx = {}, music = {}}
  local sfxDir = 'asset/audio/sfx'
  local musicDir = 'asset/audio/music'
  loadAudio(sfxDir, AllSounds.sfx, "static")
  loadAudio(musicDir, AllSounds.music, "stream")

  -- Base Resolution
  shove.setResolution(1920, 1080, {
      fitMethod = "aspect",
      renderMode = "layer",
      scalingFilter = "linear"
    })

  -- Input
  input = {joystick = nil}
  local joysticks = love.joystick.getJoysticks()
  if joysticks[1] then
    input.joystick = joysticks[1]
    print('added joystick')
  end

  -- Screen Resolution, Music/SFX, Input UI
  GameSettings = Settings()

  -- Camera
  camera = Camera()



  -- Fonts
  Font = love.graphics.newFont('asset/Chelsea_Market/ChelseaMarket-Regular.ttf')
  love.graphics.setFont(Font)

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
  Gamestate.switch(states['MainMenu'])
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

function love.draw()
  -- Put the whole game on a canvas
  love.graphics.setCanvas(screenCanvas)
  love.graphics.clear()
  Gamestate.current():draw()
  love.graphics.setCanvas()
  GameSettings:draw()
end;

function love.quit()
  if IsTestMode then
    local channel = love.thread.getChannel('analytics_input')
    channel:push({type = "quit"})
  end
end;

-- for live console output during program execution
io.stdout:setvbuf('no')