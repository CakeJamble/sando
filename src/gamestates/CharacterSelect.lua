local CharacterSelect = {}
local initLuis = require('libs.luis.init')
local luis = initLuis("libs/luis/widgets")
local CharacterTeam = require("class.entities.CharacterTeam")
local Character = require("class.entities.Character")
local loadCharacterData = require('util.character_loader')
local json = require('libs.json')
local flux = require('libs.flux')
local Timer = require('libs.hump.timer')
local Signal = require('libs.hump.signal')
local TEAM_CAP = 2
local SELECT_START = 100
local GRID_LENGTH = 1

local OFFSET = 64
local CHARACTER_SELECT_PATH = 'asset/sprites/character_select/'
local CURSOR_PATH = CHARACTER_SELECT_PATH .. 'cursor.png'

function CharacterSelect:init()
  shove.createLayer('background')
  shove.createLayer('ui')
  self.cursor = love.graphics.newImage(CURSOR_PATH)
  self.instructions = 'Select your team members'
  self.selectedContainerOptions = {
    mode = 'line',
    x = 450,
    y = 200,
    width = TEAM_CAP * OFFSET,
    height = OFFSET
  }

  luis.setGridSize(32)
end;

function CharacterSelect:enter(previous, opts)
  self.opts = opts or {}
  self.index = 0
  self.spriteRow = 0
  self.spriteCol = 0
  self.spriteXOffset = 0
  self.spriteYOffset = 0
  self.numPlayableCharacters = 4
  self.teamCount = 0
  self.characters = self.loadCharacters()
  self.currCharacter = self.characters[1]
  self.teamMembers = {}
  self.selectedTeamIndices = {}

  for i=1,TEAM_CAP do
    self.selectedTeamIndices[i] = {}
  end

  self.luisTime = 0
  luis.showGrid = true
  Signal.emit('OnEnterScene')
end;

---@return Character[]
function CharacterSelect.loadCharacters()
  local characters = {}
  local path = "data/entity/unlocked_characters.json"
  local raw = love.filesystem.read(path)
  local data = json.decode(raw)

  for i,name in ipairs(data) do
    local actionButton = "action_p" .. i
    local character = Character(loadCharacterData(name), actionButton)
    table.insert(characters, character)
  end
  return characters
end;

-- Widgets for party select interface
function CharacterSelect:defineWidgets()
  self.icons = self:defineIconWidgets()
  self.buttons = self:defineButtonWidgets()
end;

---@return table
function CharacterSelect:defineIconWidgets()
  local icons = {}

  for _, character in ipairs(self.characters) do
    for _, skill in ipairs(character.currentSkills) do
      local path = "asset/sprites/entities/character/" .. character.entityName .. "/" .. skill.name .. "_icon.png"
      local icon = luis.newIcon(path, 4, 3, 10)
      table.insert(icons, icon)
    end
  end

  return icons
end;

---@return table
function CharacterSelect:defineButtonWidgets()
  local buttons = {}

  for i, character in ipairs(self.characters) do
    local button = luis.newButton(character.entityName, 8, 4, nil,
      function()
      end, 10, 2 + (i-1) * 10)
    table.insert(buttons, button)
  end

  return buttons
end;

---@deprecated Not used in carousel layout
function CharacterSelect:set_right()
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

---@deprecated Not used in carousel layout
function CharacterSelect:set_left()
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

function CharacterSelect:navRight()
  self.index = self.index + 1
  if self.index > #self.characters then
    self.index = 1
  end
  self.currCharacter = self.characters[self.index]
end;

function CharacterSelect:navLeft()
  self.index = self.index - 1
  if self.index < 1 then
    self.index = #self.characters
  end
  self.currCharacter = self.characters[self.index]
end;

function CharacterSelect:navDown()
end;

function CharacterSelect:navUp()
end;

---@deprecated Not used in carousel layout
function CharacterSelect:set_up()
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

---@deprecated Not used in carousel layout
function CharacterSelect:set_down()
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

function CharacterSelect:validate_selection()
  if #self.teamMembers == TEAM_CAP then
    local team = CharacterTeam(self.teamMembers)
    self.opts.team = team
    Gamestate.switch(states['Overworld'], team)
  else
    table.insert(self.teamMembers, self.currCharacter)
  end
end;

-- Format stats table into a string for the stat preview
---@param stats { [string]: string|integer }
---@return string
function CharacterSelect:statsToString(stats)
  return 'Name: ' .. stats['entityName'] .. '\n' .. 'HP: ' .. stats['hp'] .. '\n' .. 'FP: ' .. stats['fp'] .. '\n' .. 'Attack: ' .. stats['attack'] .. '\n' .. 'Defense: ' .. stats['defense'] .. '\n' .. 'Speed: ' .. stats['speed'] .. '\n' .. 'Luck: ' .. stats['luck']
end;

---@param dt number
function CharacterSelect:update(dt)
  self:updateJoystick(dt)
  self.currCharacter:update(dt)
end;

---@param dt number
function CharacterSelect:updateJoystick(dt)
  flux.update(dt)
  Timer.update(dt)
  Player:update()

  if Player:pressed('down') then
    -- self:set_right()
    self.currCharacter = self.characters[2]
    self.readyToValidate = false
  elseif Player:pressed('up') then
    -- self:set_up()
    self.readyToValidate = false
  elseif Player:pressed('left') then
    -- self:set_left()
    self:navLeft()
    self.readyToValidate = false
  elseif Player:pressed('right') then
    self:navRight()
    self.readyToValidate = false
  elseif Player:pressed('confirm') then
    self.readyToValidate = true
  elseif Player:released('confirm') and self.readyToValidate then
    self:validate_selection()
  elseif Player:pressed('cancel') or Player:pressed('menuCancel') then
    Gamestate.switch(states['MainMenu'])
  end
end;

function CharacterSelect:draw()
  shove.beginDraw()

  shove.beginLayer('ui')
  -- love.graphics.print(self.instructions, 240, 20)

  -- if self.teamCount < TEAM_CAP then
    -- love.graphics.print('Choose ' .. TEAM_CAP - self.teamCount .. ' characters', 240, 50)
  -- else
    -- love.graphics.print('Press confirm to begin', 240, 50)
  -- end
  -- love.graphics.rectangle(self.selectedContainerOptions.mode,
    -- self.selectedContainerOptions.x, self.selectedContainerOptions.y,
    -- self.selectedContainerOptions.width, self.selectedContainerOptions.height)
  self.currCharacter:draw()
  shove.endLayer()
  shove.endDraw()
end;

return CharacterSelect