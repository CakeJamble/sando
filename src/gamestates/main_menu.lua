local main_menu = {}
local index = 1
local BUTTONS_START_X = 75
local BUTTONS_START_Y = 300
local BUTTONS_OFFSET = 100

local NEW_GAME_BUTTON_PATH = "asset/sprites/main_menu/new_button.png"
local CONTINUE_BUTTON_PATH = "asset/sprites/main_menu/continue_button.png"
local BAKERY_BUTTON_PATH = "asset/sprites/main_menu/bakery_button.png"
local SETTINGS_BUTTON_PATH = "asset/sprites/main_menu/settings_button.png"
local QUIT_BUTTON_PATH = "asset/sprites/main_menu/quit_button.png"
local buttonPaths = {
  NEW_GAME_BUTTON_PATH,
  CONTINUE_BUTTON_PATH,
  BAKERY_BUTTON_PATH,
  SETTINGS_BUTTON_PATH,
  QUIT_BUTTON_PATH
}
local CURSOR_PATH = "asset/sprites/main_menu/cursor.png"
local TEMP_BG = 'asset/sprites/background/temp_mm_bg.png'
-- local Vector = require('libs.hump.vector')
local Timer = require('libs.hump.timer')
local JoystickUtils = require('util.joystick_utils')
local flux = require('libs.flux')

function main_menu:init()
  shove.createLayer('background')
  shove.createLayer('ui', {zIndex = 100})
  self.background = love.graphics.newImage(TEMP_BG)
  self.cursor = love.graphics.newImage(CURSOR_PATH)
  self.cursorPos = {x = BUTTONS_START_X, y = BUTTONS_START_Y}
  self.bounceFinished = false
  self.mmButtons = {}
  for i=1,#buttonPaths do
    table.insert(self.mmButtons, love.graphics.newImage(buttonPaths[i]))
  end
  self.pos = {x = BUTTONS_START_X, y = 0}
  local duration = 2
  flux.to(self.pos, duration, {x = BUTTONS_START_X, y = BUTTONS_START_Y}):ease('bouncein')
    :oncomplete(function() self.bounceFinished = true end)
end;

---@param key string
function main_menu:keypressed(key)
  if self.bounceFinished then
    if key == 'up' or key == 'left' then
      main_menu:set_up()
    elseif key == 'down' or key == 'right' then
      main_menu:set_down()
    end
  end
end;

---@param key string
---@param scancode love.Scancode
function main_menu:keyreleased(key, scancode)
  if self.bounceFinished then
    if key == 'z' then
      main_menu:validate_selection()
    end
  end
end;

---@param joystick string
---@param button string
function main_menu:gamepadpressed(joystick, button)
  if self.bounceFinished then
    if button == 'dpup' or button == 'dpleft' then
      main_menu:set_up()
    elseif button == 'dpdown' or button == 'dpright' then
      main_menu:set_down()
    end
  end
end;

---@param joystick string
---@param button string
function main_menu:gamepadreleased(joystick, button)
  if self.bounceFinished then
    if button == 'a' then
      main_menu:validate_selection()
    end
  end
end;

function main_menu:set_up()
  if index > 1 then
    self.cursorPos.x = self.cursorPos.x - BUTTONS_OFFSET
    index = index - 1
  else
    index = 5
    self.cursorPos.x = BUTTONS_START_X + ((index - 1) * BUTTONS_OFFSET)
  end
end;

function main_menu:set_down()
  if index < 5 then
    self.cursorPos.x = self.cursorPos.x + BUTTONS_OFFSET
    index = index + 1
  else
    self.cursorPos.x = BUTTONS_START_X
    index = 1
  end
end;

---@param dt number
function main_menu:update(dt)
  flux.update(dt)
  Timer.update(dt)

  if input.joystick and self.bounceFinished then
    if JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'right') or JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'down') then
      self:set_down()
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'left') or JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'up') then
      self:set_up()
    end
  end
end;

function main_menu:draw()
  shove.beginDraw()
    shove.beginLayer("ui")
      for i=1,#self.mmButtons do
        love.graphics.draw(self.mmButtons[i], BUTTONS_START_X + ((i-1) * BUTTONS_OFFSET), self.pos.y)
      end
      love.graphics.draw(self.cursor, self.cursorPos.x, self.pos.y)
    shove.endLayer()

    shove.beginLayer('background')
      love.graphics.draw(self.background, 0, 0)
    shove.endLayer()
  shove.endDraw()
end;

function main_menu:validate_selection()
  if index == 1 then
    Gamestate.switch(states['character_select'])
  elseif index == 2 and main_menu:saveExists() == true then
    -- load data
    love.event.quit() -- remove later
  elseif index == 3 then
    Gamestate.switch(states['bakery'])
  elseif index == 4 then
    Gamestate.switch(states['settings'])
  else
    love.event.quit()
  end
end;

---@deprecated
---@return boolean
function main_menu:saveExists()
  return false
end;

return main_menu
