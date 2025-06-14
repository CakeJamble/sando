--! file: gamestate/menu
require('util.menu_ui_manager')
local main_menu = {}

-- local index = 1
-- local BUTTONS_START_X = 100
-- local BUTTONS_START_Y = 100
-- local BUTTONS_OFFSET_Y = 45
-- local cursorX = 100
-- local cursorY = 100

-- local NEW_GAME_BUTTON_PATH = "asset/sprites/main_menu/new_button.png"
-- local CONTINUE_BUTTON_PATH = "asset/sprites/main_menu/continue_button.png"
-- local BAKERY_BUTTON_PATH = "asset/sprites/main_menu/bakery_button.png"
-- local SETTINGS_BUTTON_PATH = "asset/sprites/main_menu/settings_button.png"
-- local QUIT_BUTTON_PATH = "asset/sprites/main_menu/quit_button.png"
-- local CURSOR_PATH = "asset/sprites/main_menu/cursor.png"

function main_menu:init()
  -- Set up the UI Layer
  luis.newLayer('MainMenuTable')
  luis.newLayer("Settings")
  luis.enableLayer('MainMenuTable')

  -- Set up grid size to auto scale
  luis.setGridSize(32)

  -- Initialize UI Components
  self.container = luis.newFlexContainer(5, 10, 6, 1)
  self.newGameButton = luis.newButton("New Game", 4, 2, onClickNewGame, onRelease, 1, 1)
  self.continueGameButton = luis.newButton("Continue Game", 4, 2, onClickNewGame, onRelease, 2, 1)
  self.bakeryButton = luis.newButton("Bakery", 4, 2, onClickBakery, nil, 3, 1)
  self.settingsButton = luis.newButton("Settings", 4, 2, onClickSettings, nil, 4, 1)
  self.quitButton = luis.newButton("Quit", 4, 2, onClickQuitGame, onRelease, 5, 1)
  
  -- Add UI Components to Flex Container
  self.container:addChild(self.newGameButton)
  self.container:addChild(self.continueGameButton)
  self.container:addChild(self.bakeryButton)
  self.container:addChild(self.settingsButton)
  self.container:addChild(self.quitButton)

  -- Add Flex Container to Layer
  luis.insertElement('MainMenuTable', self.container)

  -- Set focus to New Game for Gamepad navigation
  self.container:activateInternalFocus()

  self.settingsContainer = createSettingsContainer()
  luis.insertElement("Settings", self.settingsContainer)

end;

function main_menu:leave()
  self.container:deactivateInternalFocus()
end;

function main_menu:update(dt) -- runs every frame
  -- Handle rescaling every frame
  luis.updateScale()
  luis.update(dt)
end;

function main_menu:keypressed(key)
  luis.keypressed(key)
end;

function main_menu:keyreleased(key, code)
  luis.keypressed(key, code)
end;

function main_menu:gamepadpressed(joystick, button)
  luis.gamepadpressed(joystick, button)
end;

function main_menu:gamepadreleased(joystick, button)
  luis.gamepadreleased(joystick, button)
end;

function main_menu:draw()
  luis.draw()
end;


return main_menu