--! file: gamestate/menu
require('util.menu_ui_manager')
-- require('util.lui')
local main_menu = {}

local TEMP_BG = 'asset/sprites/background/temp_mm_bg.png'

function main_menu:init()
  self.background = love.graphics.newImage(TEMP_BG)
  -- Set up the UI Layer
  luis.newLayer('MainMenuTable')
  luis.newLayer("Settings")
  luis.enableLayer('MainMenuTable')

  -- Set a 12x9 grid for a 16:9 aspect ratio
  luis.setGridSize(love.graphics.getWidth() / 12)

  -- Initialize UI Components
  -- self.container = luis.newFlexContainer(20, 2, 30, 18)
  local buttonSize = mainMenuConfig.buttonSize
  local buttonGridPos = mainMenuConfig.buttonGridPos
  local newGameButton = luis.newButton("New Game", buttonSize.width, buttonSize.height, onClickNewGame, nil, buttonGridPos.row, buttonGridPos.col)
  buttonGridPos.col = buttonGridPos.col + buttonGridPos.offset

  local continueGameButton = luis.newButton("Continue Game", buttonSize.width, buttonSize.height, onClickNewGame, nil, buttonGridPos.row, buttonGridPos.col)
  buttonGridPos.col = buttonGridPos.col + buttonGridPos.offset

  local bakeryButton = luis.newButton("Bakery", buttonSize.width, buttonSize.height, onClickBakery, nil, buttonGridPos.row, buttonGridPos.col)
  buttonGridPos.col = buttonGridPos.col + buttonGridPos.offset

  local settingsButton = luis.newButton("Settings", buttonSize.width, buttonSize.height, onClickSettings, nil, buttonGridPos.row, buttonGridPos.col)
  buttonGridPos.col = buttonGridPos.col + buttonGridPos.offset

  local quitButton = luis.newButton("Quit", buttonSize.width, buttonSize.height, onClickQuitGame, nil, buttonGridPos.row, buttonGridPos.col)
  buttonGridPos.col = buttonGridPos.col + buttonGridPos.offset

  luis.insertElement('MainMenuTable', newGameButton)
  luis.insertElement('MainMenuTable', continueGameButton)
  luis.insertElement('MainMenuTable', bakeryButton)
  luis.insertElement('MainMenuTable', settingsButton)
  luis.insertElement('MainMenuTable', quitButton)

  self.settingsContainer = createSettingsContainer()
  luis.insertElement("Settings", self.settingsContainer)

end;

function main_menu:leave()
  -- self.container:deactivateInternalFocus()
  luis.disableLayer('MainMenuTable')
end;

function main_menu:update(dt) -- runs every frame
  -- Handle rescaling every frame
  luis.updateScale()
  luis.update(dt)
        -- Example: D-pad navigation between elements
    if luis.joystickJustPressed(1, 'dpdown') or luis.joystickJustPressed(1, 'dpright') then
        luis.moveFocus("next")
    elseif luis.joystickJustPressed(1, 'dpup') or luis.joystickJustPressed(1, 'dpleft') then
        luis.moveFocus("previous")
    end
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

function main_menu:joystickadded(joystick)
  luis.initJoysticks()
end;

function main_menu:joystickremoved(joystick)
  luis.removeJoystick(joystick)
end;

function main_menu:draw()
  love.graphics.draw(self.background, 0, 0)
  love.graphics.printf('Sando :)', love.graphics.getWidth() / 2.5, love.graphics.getHeight() / 2.5, 400, 'right', 0, 2, 2)

  luis.draw()
end;


return main_menu