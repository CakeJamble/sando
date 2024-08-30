--! file: gamestate/menu

local main_menu = {}

local index = 1
local BUTTONS_START_X = 100
local BUTTONS_START_Y = 100
local BUTTONS_OFFSET_Y = 45
local cursorX = 100
local cursorY = 100

local NEW_GAME_BUTTON_PATH = "asset/sprites/main_menu/new_button.png"
local CONTINUE_BUTTON_PATH = "asset/sprites/main_menu/continue_button.png"
local BAKERY_BUTTON_PATH = "asset/sprites/main_menu/bakery_button.png"
local SETTINGS_BUTTON_PATH = "asset/sprites/main_menu/settings_button.png"
local QUIT_BUTTON_PATH = "asset/sprites/main_menu/quit_button.png"
local CURSOR_PATH = "asset/sprites/main_menu/cursor.png"

function main_menu:init()
  -- self.background = love.graphics.newImage('path/to/menu_background')
  newGameButton = love.graphics.newImage(NEW_GAME_BUTTON_PATH)
  continueButton = love.graphics.newImage(CONTINUE_BUTTON_PATH)
  bakeryButton = love.graphics.newImage(BAKERY_BUTTON_PATH)
  settingsButton = love.graphics.newImage(SETTINGS_BUTTON_PATH)
  quitButton = love.graphics.newImage(QUIT_BUTTON_PATH)
  cursor = love.graphics.newImage(CURSOR_PATH)
end;

function main_menu:enter(previous) -- runs every time the state is entered
end;

function main_menu:update(dt) -- runs every frame
end;

function main_menu:keypressed(key)
  if key == 'up' then
    main_menu:set_up()
  elseif key == 'down' then
    main_menu:set_down()
  end
end;
  
function main_menu:set_up()
  if index > 1 then
    cursorY = cursorY - BUTTONS_OFFSET_Y
    index = index - 1
  else
    index = 5
    cursorY = BUTTONS_START_Y + ((index - 1) * BUTTONS_OFFSET_Y)
  end
  
end;

function main_menu:set_down()
  if index < 5 then
    cursorY = cursorY + BUTTONS_OFFSET_Y
    index = index + 1
  else
    cursorY = BUTTONS_START_Y
    index = 0
  end
  
end;



function main_menu:draw()
  -- love.graphics.draw(self.background, 0, 0)
  love.graphics.draw(newGameButton, BUTTONS_START_X, BUTTONS_START_Y)
  love.graphics.draw(continueButton, BUTTONS_START_X, BUTTONS_START_Y + BUTTONS_OFFSET_Y)
  love.graphics.draw(bakeryButton, BUTTONS_START_X, BUTTONS_START_Y + (2 * BUTTONS_OFFSET_Y))
  love.graphics.draw(settingsButton, BUTTONS_START_X, BUTTONS_START_Y + (3 * BUTTONS_OFFSET_Y))
  love.graphics.draw(quitButton, BUTTONS_START_X, BUTTONS_START_Y + (4 * BUTTONS_OFFSET_Y))
  love.graphics.draw(cursor, cursorX, cursorY)
  
end;

function main_menu:keyreleased(key, code)
  if key == 'z' then
    main_menu:validate_selection()
  end
  
end;

function main_menu:validate_selection()
  if index == 1 then
    Gamestate.switch(states['character_select'])
  elseif index == 2 and main_menu:saveExists() == true then
    -- load data
    love.event.quit()
  elseif index == 3 then
    Gamestate.switch(states['bakery'])
  elseif index == 4 then
    Gamestate.switch(states['settings'])
  else
    love.event.quit()
  end
  
    
end;

function main_menu:saveExists()
  return false
end;

return main_menu