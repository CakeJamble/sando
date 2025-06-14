--! file: gamestates/character_select
require("class.character_team")
require("util.globals")
require("util.stat_sheet")
require("class.character")

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
  luis.setGridSize(32)
  self.container = luis.newFlexContainer(20, 25, 6, 2)
  self.beginContainer = luis.newFlexContainer(4, 4, 25, 25)
  self.bakeIcon = luis.newButton("", 4, 4, onClickAddBake, onRelease, 1, 1, nil, BAKE_PORTRAIT_PATH)
  self.marcoIcon = luis.newButton("", 4, 4, onClickAddMarco, onRelease, 2, 1, nil, MARCO_PORTRAIT_PATH)
  self.mariaIcon = luis.newButton("", 4, 4, onClickAddMaria, onRelease, 3, 1, nil, MARIA_PORTRAIT_PATH)
  self.keyIcon = luis.newButton("", 4, 4, onClickAddKey, onRelease, 4, 2, nil, KEY_PORTRAIT_PATH)
  self.beginButton = luis.newButton("Begin", 4, 4, onClickBeginRun, onRelease, 25, 25, nil, nil)
  self.beginContainer:addChild(self.beginButton)
  self.container:addChild(self.bakeIcon)
  self.container:addChild(self.marcoIcon)
  self.container:addChild(self.mariaIcon)
  self.container:addChild(self.keyIcon)
  -- self.container:addChild(self.beginButton)
  luis.insertElement('CharacterSelectTable', self.container)
  luis.insertElement('CharacterSelectTable', self.beginContainer)
  self.container:activateInternalFocus()
end;


function character_select:enter()
  index = 1
  -- spriteRow = 0
  -- spriteCol = 0
  -- spriteXOffset = 0
  -- spriteYOffset = 0
  numPlayableCharacters = 4
  teamCount = 0
  members = {}  
  for i=1,TEAM_CAP do
    members[i] = {}
  end

  -- self.statPreview = character_select:setStatPreview()
  
end;

function character_select:leave()
  self.beginContainer:deactivateInternalFocus()
end;

function character_select:gamepadpressed(joystick, button)
  luis.gamepadpressed(joystick, button)

  if(teamCount == TEAM_CAP) then
    local characterTeam = CharacterTeam(members, TEAM_CAP)
    saveCharacterTeam(characterTeam)
    self.container:deactivateInternalFocus()
    self.beginContainer:activateInternalFocus()
  end
end;

function character_select:validate_selection()
  if teamCount == TEAM_CAP then
    character_select:indicesToCharacters()
    Gamestate.switch(states['combat'])
  end
end;

  -- Takes table of selected character indices and converts
  -- each index to a valid Character object, adding to the global team table
function character_select:indicesToCharacters()
  local characterList = {}
  for i=1,TEAM_CAP do
    if selectedTeamIndices[i] == 0 then
      bake = Character(get_bake_stats(), 'a')
      characterList[i] = bake
    elseif selectedTeamIndices[i] == 1 then
      marco = Character(get_marco_stats(), 'z')
      characterList[i] = marco
    elseif selectedTeamIndices[i] == 2 then
      maria = Character(get_maria_stats(), 'x')
      characterList[i] = maria
    elseif selectedTeamIndices[i] == 3 then
      key = Character(get_key_stats(), 'y')
      characterList[i] = key
    end
  end
  
  characterTeam = CharacterTeam(characterList, TEAM_CAP)
  saveCharacterTeam(characterTeam)
end;

function character_select:setStatPreview()
  local statPreview = ''
  if spriteRow == 0 and spriteCol == 0 then
    statPreview = character_select:statsToString(get_bake_stats())
  elseif spriteRow == 0 and spriteCol == 1 then
    statPreview = character_select:statsToString(get_marco_stats())
  elseif spriteRow == 1 and spriteCol == 0 then
    statPreview = character_select:statsToString(get_maria_stats())
  else
    statPreview = character_select:statsToString(get_key_stats())
  end
  return statPreview
end;

function character_select:statsToString(stats)
  return 'Name: ' .. stats['entityName'] .. '\n' .. 'HP: ' .. stats['hp'] .. '\n' .. 'FP: ' .. stats['fp'] .. '\n' .. 'Attack: ' .. stats['attack'] .. '\n' .. 'Defense: ' .. stats['defense'] .. '\n' .. 'Speed: ' .. stats['speed'] .. '\n' .. 'Luck: ' .. stats['luck']
end;

function character_select:update(dt)
  luis.updateScale()
end;

function character_select:draw()
  luis.draw()
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