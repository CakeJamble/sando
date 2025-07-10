--! file: gamestates/combat
require("class.entities.enemy")
require("class.ui.action_ui")
require("util.encounter_pools")
require('gamestates.character_select')
require("util.globals")
require('class.entities.character_team')
require('class.entities.enemy_team')
require('util.stat_sheet')
require('class.input.command_manager')
require('class.turn_manager')

local combat = {}
local numFloors = 50
local TEMP_BG = 'asset/sprites/background/temp-combat-bg.png'
local CHARACTER_SELECT_PATH = 'asset/sprites/character_select/'
local BAKE_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'bake_portrait.png'
local MARCO_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'marco_portrait.png'
local MARIA_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'maria_portrait.png'
local KEY_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'key_portrait.png'
local COMBAT_UI_PATH = 'asset/sprites/combat/'
local COMBAT_TEAM_UI_PATH = COMBAT_UI_PATH .. 'combat-team-ui.png'
local HP_HOLDER = COMBAT_UI_PATH .. 'hp-holder.png'

function combat:init()
  self.background = love.graphics.newImage(TEMP_BG)
  self.combatTeamUI = love.graphics.newImage(COMBAT_TEAM_UI_PATH)
  self.hpHolder1 = love.graphics.newImage(HP_HOLDER)
  self.hpHolder2 = love.graphics.newImage(HP_HOLDER)

  self.cursorX = 0
  self.cursorY = 0
  self.rewardExp = 0
  self.rewardMoney = 0
  self.enemyCount = 0
  self.enemyTeamIndex = 1
  self.characterTeamIndex = 1
  self.turnCount = 1
  self.encounteredPools = {}
  self.floorNumber = 1

  for i=1,numFloors do
    self.encounteredPools[i] = {}
  end
  
  Signal.register('NextTurn',
    function()
      local curr = 0
      local total = 0
      for i=1, #self.characterTeam.members do
        curr = self.characterTeam.members[i].battleStats.hp
        total = self.characterTeam.members[i].baseStats.hp
        self.characterTeamHP[i] = self.characterTeam.members[i].entityName .. ": " .. curr .. " / " .. total
      end
    end
  )
end;

function combat:enter(previous)
  self.lockCamera = false
  -- self.commandManager = CommandManager()
  self.characterTeam = loadCharacterTeam()
  self.rewardExp = 0
  self.rewardMoney = 0

  self.characterTeamHP = {}
  local curr = {}
  local total = {}
  for i=1, #self.characterTeam.members do
    curr = self.characterTeam.members[i].battleStats.hp
    total = self.characterTeam.members[i].baseStats.hp
    self.characterTeamHP[i] = self.characterTeam.members[i].entityName .. ': ' .. curr .. ' / ' .. total
  end
  
  self.enemyTeam = combat:generateEncounter()

  Signal.emit('OnStartCombat')

  Timer.after(Character.combatStartEnterDuration, function()
    self.turnManager = TurnManager(self.characterTeam, self.enemyTeam)
    Signal.emit('NextTurn')
  end)
end;

function combat:generateEncounter() --> EnemyTeam
  local enemyTeam = combat:generateEnemyTeam()
  -- combat:logCombat(enemyTeam)
  return enemyTeam
end;

function combat:generateEnemyTeam()
  local enemyList = {}
  local enemyNameList = combat:getEnemyNames()

  for i=1,#enemyNameList do
    local enemy = Enemy(enemyNameList[i], "Enemy")
    enemyList[i] = enemy
  end
  
  return EnemyTeam(enemyList, #enemyNameList)
end;

--[[ Prototype for generating the encounters
Needs to be refactored once I have more enemies and skills developed and tuned
]]
function combat:getEnemyNames() --> void
  local encounterIndex = 0
  if self.floorNumber < 10 then
    -- Weighted Randomly grab from Enemy Pool 1
    encounterIndex = math.random(1, #enemyPool1)
    -- self.encounteredPools[self.floorNum] = enemyPool1[encounter]
    self.encounteredPools[self.floorNumber] = testPool[1]
  elseif self.floorNumber == 10 then
    -- Randomly grab from Boss Pool 1
    encounterIndex = math.random(1, #bossPool1)
    self.encounteredPools[self.floorNumber] = bossPool1[encounterIndex]
  elseif self.floorNumber < 20 then
    -- Weighted Randomly grab from Enemy Pool 2
    encounterIndex = math.random(1, #enemyPool2)
    self.encounteredPools[self.floorNumber] = enemyPool2[encounterIndex]
  elseif self.floorNumber == 20 then
    encounterIndex = math.random(1, #bossPool2)
    self.encounteredPools[self.floorNumber] = bossPool2[encounterIndex]
  end

  return self.encounteredPools[self.floorNumber]
end;

function combat:keypressed(key)
  if key == 'p' then
    Gamestate.push(states['pause'], self.characterTeam.inventory)
  else
    self.characterTeam:keypressed(key)
  end
end;

function combat:gamepadpressed(joystick, button)
  if button == 'start' then
    Gamestate.push(states['pause'])
  end
  self.characterTeam:gamepadpressed(joystick, button)
end;

function combat:update(dt)
  flux.update(dt)
  if self.turnManager then
    self.turnManager:update(dt)
  end
  if self.lockCamera then
    local cameraTarget = self.turnManager.activeEntity
    camera:lockWindow(cameraTarget.x, cameraTarget.y, 0, cameraTarget.x + 100, 0, cameraTarget.y + 100)
  end
  Timer.update(dt)
end;

function combat:draw()
  push:start()
  camera:attach()
  love.graphics.draw(self.background, 0, 0, 0, 1, 1.2)
  love.graphics.draw(self.combatTeamUI, 0, 0, 0, 1, 0.75)
  love.graphics.draw(self.hpHolder1, 10, 10, 0, 1, 0.75)
  love.graphics.draw(self.hpHolder2, 10, 50, 0, 1, 0.75)
  love.graphics.print(self.characterTeamHP[1], 20, 6)
  love.graphics.print(self.characterTeamHP[2], 20, 46)
  self.characterTeam:draw()
  self.enemyTeam:draw()
  if self.turnManager then
    self.turnManager:draw()
  end
  camera:detach()
  push:finish()
end;
  
return combat