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
  cursor = love.graphics.newImage(CURSOR_PATH)  
  bakePortrait = love.graphics.newImage(BAKE_PORTRAIT_PATH)
  marcoPortrait = love.graphics.newImage(MARCO_PORTRAIT_PATH)
  mariaPortrait = love.graphics.newImage(MARIA_PORTRAIT_PATH)
  keyPortrait = love.graphics.newImage(KEY_PORTRAIT_PATH)
end;

function character_select:enter()
  index = 0
  spriteRow = 0
  spriteCol = 0
  spriteXOffset = 0
  spriteYOffset = 0
  numPlayableCharacters = 4
  teamCount = 0
  
  selectedTeamIndices = {}
  
  for i=1,TEAM_CAP do
    selectedTeamIndices[i] = {}
  end

  statPreview = character_select:setStatPreview()
  
end;

function character_select:keypressed(key)
  if key == 'right' then
    character_select:set_right()
  elseif key == 'left' then
    character_select:set_left()
  elseif key == 'up' then
    character_select:set_up()
  elseif key == 'down' then
    character_select:set_down()
  elseif key == 'z' then
    character_select:validate_selection()
  end
  statPreview = character_select:setStatPreview()
end;
  
function character_select:gamepadpressed(joystick, button)
  if button == 'dpright' then
    character_select:set_right()
  elseif button == 'dpleft' then
    character_select:set_left()
  elseif button == 'dpup' then
    character_select:set_up()
  elseif button == 'dpdown' then
    character_select:set_down()
  elseif button == 'a' then
    character_select:validate_selection()
  end
  statPreview = character_select:setStatPreview()
end;

function character_select:set_right()
  if spriteCol < GRID_LENGTH then
    spriteCol = spriteCol + 1
    spriteXOffset = OFFSET * spriteCol
    index = index + 1
  else 
    spriteCol = 0
    spriteXOffset = 0
    if spriteRow < GRID_LENGTH then
      spriteRow = spriteRow + 1
      spriteYOffset = spriteYOffset + OFFSET
      index = index + 1
    else
      spriteRow = 0
      spriteYOffset = 0
      index = 0
    end
  end
end;

function character_select:set_left()
  if spriteCol > 0 then
    spriteCol = spriteCol - 1
    index = index - 1
  elseif spriteRow > 0 then
    spriteRow = spriteRow - 1
    spriteCol = GRID_LENGTH
    spriteYOffset = OFFSET * spriteRow
    index = index - 1
  else
    spriteCol = GRID_LENGTH
    spriteRow = GRID_LENGTH
    spriteYOffset = OFFSET * spriteRow
    index = numPlayableCharacters - 1
  end
  spriteXOffset = OFFSET * spriteCol
end;

function character_select:set_up()
  if spriteRow > 0 then
    spriteRow = spriteRow - 1
    spriteYOffset = spriteRow * OFFSET
    index = index - GRID_LENGTH
  else
    spriteRow = GRID_LENGTH
    spriteYOffset = GRID_LENGTH * OFFSET
    index = spriteCol + (spriteRow * GRID_LENGTH)
  end
end;

function character_select:set_down()
  if spriteRow < GRID_LENGTH then
    spriteRow = spriteRow + 1
    spriteYOffset = spriteRow * OFFSET
    index = index + GRID_LENGTH
  else
    spriteRow = 0
    spriteYOffset = 0
    index = spriteCol
  end
end;

function character_select:validate_selection()
  if teamCount == TEAM_CAP then
    character_select:indicesToCharacters()
    Gamestate.switch(states['combat'])
  else
    selectedTeamIndices[teamCount + 1] = index
    teamCount = teamCount + 1
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
      marco = Character(get_marco_stats(), 'b')
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

function character_select:draw()
  push:start()
  love.graphics.rectangle('line', SELECT_START - 5, SELECT_START - 5, OFFSET * (GRID_LENGTH + 1) + 10, OFFSET * (GRID_LENGTH + 1) + 10)
  love.graphics.draw(bakePortrait, SELECT_START, SELECT_START)
  love.graphics.draw(marcoPortrait, SELECT_START + OFFSET, SELECT_START)
  love.graphics.draw(mariaPortrait, SELECT_START, SELECT_START + OFFSET)
  love.graphics.draw(keyPortrait, SELECT_START + OFFSET, SELECT_START + OFFSET)
  love.graphics.draw(cursor, SELECT_START + (spriteCol * OFFSET), SELECT_START+ (spriteRow * OFFSET))
  love.graphics.print(statPreview, 300, 100)
  push:finish()
end;

return character_select