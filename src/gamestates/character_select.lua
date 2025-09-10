local character_select = {}
local CharacterTeam = require("class.entities.character_team")
require("util.globals")
local Character = require("class.entities.character")
local loadCharacterData = require('util.character_loader')
local JoystickUtils = require('util.joystick_utils')

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
  shove.createLayer('background')
  shove.createLayer('ui')
  self.cursor = love.graphics.newImage(CURSOR_PATH)
  self.bakePortrait = love.graphics.newImage(BAKE_PORTRAIT_PATH)
  self.marcoPortrait = love.graphics.newImage(MARCO_PORTRAIT_PATH)
  self.mariaPortrait = love.graphics.newImage(MARIA_PORTRAIT_PATH)
  self.keyPortrait = love.graphics.newImage(KEY_PORTRAIT_PATH)

  self.instructions = 'Select your team members'
  self.selectedContainerOptions = {
    mode = 'line',
    x = 450,
    y = 200,
    width = TEAM_CAP * OFFSET,
    height = OFFSET
  }
end;

function character_select:enter()
  self.index = 0
  self.spriteRow = 0
  self.spriteCol = 0
  self.spriteXOffset = 0
  self.spriteYOffset = 0
  self.numPlayableCharacters = 4
  self.teamCount = 0

  self.selectedTeamIndices = {}

  for i=1,TEAM_CAP do
    self.selectedTeamIndices[i] = {}
  end

  -- statPreview = character_select:setStatPreview()

end;

---@deprecated
---@param key string
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
  -- statPreview = character_select:setStatPreview()
end;

---@param joystick string
---@param button string
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
  -- statPreview = character_select:setStatPreview()
end;

function character_select:set_right()
  if self.spriteCol < GRID_LENGTH then
    self.spriteCol = self.spriteCol + 1
    self.spriteXOffset = OFFSET * self.spriteCol
    self.index = self.index + 1
  else
    self.spriteCol = 0
    self.spriteXOffset = 0
    if self.spriteRow < GRID_LENGTH then
      self.spriteRow = self.spriteRow + 1
      self.spriteYOffset = self.spriteYOffset + OFFSET
      self.index = self.index + 1
    else
      self.spriteRow = 0
      self.spriteYOffset = 0
      self.index = 0
    end
  end
end;

function character_select:set_left()
  if self.spriteCol > 0 then
    self.spriteCol = self.spriteCol - 1
    self.index = self.index - 1
  elseif self.spriteRow > 0 then
    self.spriteRow = self.spriteRow - 1
    self.spriteCol = GRID_LENGTH
    self.spriteYOffset = OFFSET * self.spriteRow
    self.index = self.index - 1
  else
    self.spriteCol = GRID_LENGTH
    self.spriteRow = GRID_LENGTH
    self.spriteYOffset = OFFSET * self.spriteRow
    self.index = self.numPlayableCharacters - 1
  end
  self.spriteXOffset = OFFSET * self.spriteCol
end;

function character_select:set_up()
  if self.spriteRow > 0 then
    self.spriteRow = self.spriteRow - 1
    self.spriteYOffset = self.spriteRow * OFFSET
    self.index = self.index - GRID_LENGTH
  else
    self.spriteRow = GRID_LENGTH
    self.spriteYOffset = GRID_LENGTH * OFFSET
    self.index = self.spriteCol + (self.spriteRow * GRID_LENGTH)
  end
end;

function character_select:set_down()
  if self.spriteRow < GRID_LENGTH then
    self.spriteRow = self.spriteRow + 1
    self.spriteYOffset = self.spriteRow * OFFSET
    self.index = self.index + GRID_LENGTH
  else
    self.spriteRow = 0
    self.spriteYOffset = 0
    self.index = self.spriteCol
  end
end;

function character_select:validate_selection()
  if self.teamCount == TEAM_CAP then
    character_select:indicesToCharacters()
    Gamestate.switch(states['combat'])
  else
    self.selectedTeamIndices[self.teamCount + 1] = self.index
    self.teamCount = self.teamCount + 1
  end
end;

  -- Takes table of selected character indices and converts
  -- each index to a valid Character object, adding to the global team table
function character_select:indicesToCharacters()
  local characterList = {}
  for i=1,TEAM_CAP do
    if self.selectedTeamIndices[i] == 0 then
      -- bake = Character(get_bake_stats(), 'a')
      local bake = Character(loadCharacterData('bake'), 'a')
      characterList[i] = bake
    elseif self.selectedTeamIndices[i] == 1 then
      -- marco = Character(get_marco_stats(), 'x')
      local marco = Character(loadCharacterData('marco'), 'x')
      characterList[i] = marco
    elseif self.selectedTeamIndices[i] == 2 then
      local maria = Character(get_maria_stats(), 'b')
      characterList[i] = maria
    elseif self.selectedTeamIndices[i] == 3 then
      local key = Character(get_key_stats(), 'y')
      characterList[i] = key
    end
  end

  local characterTeam = CharacterTeam(characterList)
  saveCharacterTeam(characterTeam)
end;

---@return string
function character_select:setStatPreview()
  local statPreview
  if self.spriteRow == 0 and self.spriteCol == 0 then
    statPreview = character_select:statsToString(get_bake_stats())
  elseif self.spriteRow == 0 and self.spriteCol == 1 then
    statPreview = character_select:statsToString(get_marco_stats())
  elseif self.spriteRow == 1 and self.spriteCol == 0 then
    statPreview = character_select:statsToString(get_maria_stats())
  else
    statPreview = character_select:statsToString(get_key_stats())
  end
  return statPreview
end;

---@param stats { [string]: string|integer }
---@return string
function character_select:statsToString(stats)
  return 'Name: ' .. stats['entityName'] .. '\n' .. 'HP: ' .. stats['hp'] .. '\n' .. 'FP: ' .. stats['fp'] .. '\n' .. 'Attack: ' .. stats['attack'] .. '\n' .. 'Defense: ' .. stats['defense'] .. '\n' .. 'Speed: ' .. stats['speed'] .. '\n' .. 'Luck: ' .. stats['luck']
end;

---@param dt number
function character_select:update(dt)
  if input.joystick then
    if JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'right') then
      self:gamepadpressed(input.joystick, 'dpright')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'left') then
      self:gamepadpressed(input.joystick, 'dpleft')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'up') then
      self:gamepadpressed(input.joystick, 'dpup')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'down') then
      self:gamepadpressed(input.joystick, 'dpdown')
    end
  end
end;

function character_select:draw()
  shove.beginDraw()

  shove.beginLayer('ui')
  -- Character Select Grid and Stats
  love.graphics.rectangle('line', SELECT_START - 5, SELECT_START - 5, OFFSET * (GRID_LENGTH + 1) + 10,
    OFFSET * (GRID_LENGTH + 1) + 10)
  love.graphics.draw(self.bakePortrait, SELECT_START, SELECT_START)
  love.graphics.draw(self.marcoPortrait, SELECT_START + OFFSET, SELECT_START)
  love.graphics.draw(self.mariaPortrait, SELECT_START, SELECT_START + OFFSET)
  love.graphics.draw(self.keyPortrait, SELECT_START + OFFSET, SELECT_START + OFFSET)
  love.graphics.draw(self.cursor, SELECT_START + (self.spriteCol * OFFSET), SELECT_START+ (self.spriteRow * OFFSET))
  -- love.graphics.print(statPreview, 300, 100)

  -- Instructions
  love.graphics.print(self.instructions, 240, 20)

  if self.teamCount < TEAM_CAP then
    love.graphics.print('Choose ' .. TEAM_CAP - self.teamCount .. ' characters', 240, 50)
  else
    love.graphics.print('Press confirm to begin', 240, 50)
  end
  love.graphics.rectangle(self.selectedContainerOptions.mode,
    self.selectedContainerOptions.x, self.selectedContainerOptions.y,
    self.selectedContainerOptions.width, self.selectedContainerOptions.height)
  shove.endLayer()
  shove.endDraw()
end;

return character_select