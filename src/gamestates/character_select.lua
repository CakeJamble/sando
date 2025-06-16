--! file: gamestates/character_select
require("class.character_team")
require("util.globals")
require("util.stat_sheet")
require("class.character")
require('util.character_select_ui_manager')

local character_select = {}

local TEAM_CAP = 2
local SELECT_START = 100
local GRID_LENGTH = 1

local OFFSET = 64
local CHARACTER_SELECT_PATH = 'asset/sprites/character_select/'
local CURSOR_PATH = CHARACTER_SELECT_PATH .. 'cursor.png'
local BAKE_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'bake_portrait.png'
local MARCO_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'marco_portrait.png'
local MARIA_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'maria_portrait.png'
local KEY_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'key_portrait.png'


function character_select:init()
  -- Set up the UI Layer
  luis.newLayer('CharacterSelectTable')
  luis.enableLayer('CharacterSelectTable')
  luis.setGridSize(love.graphics.getWidth() / 12)
  local buttonSize = characterSelectFlexConfig.buttonSize
  local buttonGridPos = characterSelectFlexConfig.buttonGridPos

  self.container = luis.newFlexContainer(4, 1, 2, 2)
  self.beginContainer = luis.newFlexContainer(1, 1, 6, 2)
  self.bakeIcon = luis.newButton("", buttonSize.width, buttonSize.height, onClickAddBake, onRelease, 1, 1, nil, BAKE_PORTRAIT_PATH)
  self.marcoIcon = luis.newButton("", buttonSize.width, buttonSize.height, onClickAddMarco, onRelease, 2.5, 1, nil, MARCO_PORTRAIT_PATH)
  self.mariaIcon = luis.newButton("", buttonSize.width, buttonSize.height, onClickAddMaria, onRelease, 3.5, 1, nil, MARIA_PORTRAIT_PATH)
  self.keyIcon = luis.newButton("", buttonSize.width, buttonSize.height, onClickAddKey, onRelease, 4.5, 1, nil, KEY_PORTRAIT_PATH)
  self.beginButton = luis.newButton("Begin", buttonSize.width, buttonSize.height, onClickBeginRun, onRelease, 25, 25, nil, nil)
  self.beginContainer:addChild(self.beginButton)
  self.container:addChild(self.bakeIcon)
  self.container:addChild(self.marcoIcon)
  self.container:addChild(self.mariaIcon)
  self.container:addChild(self.keyIcon)
  self.beginContainer:addChild(self.beginButton)
  luis.insertElement('CharacterSelectTable', self.container)
  luis.insertElement('CharacterSelectTable', self.beginContainer)
  self.container:activateInternalFocus()
end;


function character_select:enter()
  self.index = 1
  self.numPlayableCharacters = 4
  teamCount = 0
  members = {}  
  for i=1,TEAM_CAP do
    members[i] = {}
  end

  self.statPreview = character_select:setStatPreview()
end;

function character_select:leave()
  self.beginContainer:deactivateInternalFocus()
  luis.disableLayer('CharacterSelectTable')
end;

function character_select:gamepadpressed(joystick, button)
  luis.gamepadpressed(joystick, button)
  
  -- Updating the Index for Stat Preview
  if button == 'dpleft' or button == 'dpup' then
    if self.index == 1 then
      self.index = self.numPlayableCharacters
    else
      self.index = self.index - 1
    end
  elseif button == 'dpright' or button == 'dpdown' then
    if self.index == self.numPlayableCharacters then
      self.index = 1
    else
      self.index = self.index + 1
    end
  end
  
  -- Move to Begin Button if team is full, and set index to -1
  if(teamCount == TEAM_CAP) then
    local characterTeam = CharacterTeam(members, TEAM_CAP)
    saveCharacterTeam(characterTeam)
    self.index = -1
    self.container:deactivateInternalFocus()
    self.beginContainer:activateInternalFocus()

  end

  -- Update Stat Preview (if the team isn't full)
  if self.index ~= -1 then
    self.statPreview =  self:setStatPreview()
  end
end;

function character_select:validate_selection()
  if teamCount == TEAM_CAP then
    character_select:indicesToCharacters()
    Gamestate.switch(states['combat'])
  end
end;

function character_select:setStatPreview()
  return character_select:statsToString(get_char_stats(self.index))
end;

function character_select:statsToString(stats)
  return 'Name: ' .. stats['entityName'] .. '\n' .. 'HP: ' .. stats['hp'] .. '\n' .. 'FP: ' .. stats['fp'] .. '\n' .. 'Attack: ' .. stats['attack'] .. '\n' .. 'Defense: ' .. stats['defense'] .. '\n' .. 'Speed: ' .. stats['speed'] .. '\n' .. 'Luck: ' .. stats['luck']
end;

function character_select:update(dt)
  luis.updateScale()
end;

function character_select:draw()
  luis.draw()

  if index ~= -1 then
    love.graphics.print(self.statPreview, 1000, 150)
  end
end;

function onClickAddBake()
  if teamCount <= TEAM_CAP then
    members[teamCount + 1] = Character(get_bake_stats(), 'a')
    teamCount = teamCount + 1
    print(teamCount)
  end
end;

function onClickAddMarco()
  if teamCount < TEAM_CAP then
    members[teamCount + 1] = Character(get_marco_stats(), 'x')
    teamCount = teamCount + 1
    print(teamCount)
  end
end;

function onClickAddMaria()
  if teamCount < TEAM_CAP then
    selectedTeamIndices[index] = mariaIndex
    teamCount = teamCount + 1
  end
end;

function onClickAddKey()
  if index < TEAM_CAP then
    selectedTeamIndices[index] = keyIndex
    index = index + 1
  end
end;

function onClickBeginRun()
  if teamCount == TEAM_CAP then
    Gamestate.switch(states['combat'])
  end
end;

return character_select