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
  -- joysticks = love.joystick.getJoysticks()
  -- active_joystick = joysticks[1]
  Gamestate.registerEvents()
  Gamestate.switch(states['main_menu'])

  -- Setup for LUIS
  luis.initJoysticks()
  if luis.activeJoysticks then
    for id,joystick in pairs(luis.activeJoysticks) do
      print(string.format("Gamepad #%d: %s", id, joystick:getName()))
    end
  end
  -- Base resolution
  luis.baseWidth = 1920  
  luis.baseHeight = 1080
  
  -- Window Mode
  love.window.setMode(luis.baseWidth, luis.baseHeight, { resizable=true })
end;

-- Required callbacks for gamepad support
function love.joystickadded(joystick)
    luis.initJoysticks()
end

function love.joystickremoved(joystick)
    luis.removeJoystick(joystick)
end


-- for live console output during program execution
io.stdout:setvbuf('no')