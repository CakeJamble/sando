--! file: gamestates/combat
require("class.enemy")
require("class.action_ui")
require("util.encounter_pools")
require('gamestates.character_select')
require("util.globals")
require('class.character_team')
require('class.enemy_team')
require('util.stat_sheet')
require('class.input.command_manager')
require('class.turn_manager')


local combat = {}
local FIRST_MEMBER_X = 100
local FIRST_MEMBER_Y = 100
local numFloors = 50
local TEMP_BG = 'asset/sprites/background/temp-combat-bg.png'

function combat:init()
  self.background = love.graphics.newImage(TEMP_BG)
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

  -- init encounteredPools to keep track of all encounters across a run
  for i=1,numFloors do
    self.encounteredPools[i] = {}
  end
  
  -- Register Signals
  Signal.register('move',
  function(x, y)
    camera:zoom(1.5)
    self.lockCamera = true
  end
  );
  Signal.register('endTurn',
    function()
      camera:zoom(0.6666)
      self.lockCamera = false
    end
  );

end;

function combat:enter(previous)
  self.lockCamera = false
  self.commandManager = CommandManager()
  self.turnManager = TurnManager()  
  self.characterTeam = loadCharacterTeam()
  self.rewardExp = 0
  self.rewardMoney = 0

  -- Log & Generate the floor's encounter in encounteredPools
  self.enemyTeam = combat:generateEncounter()
  
  -- Add Characters and Enemies to Turn Manager
  for i=1,#self.characterTeam.members do
    self.turnManager:addListener(self.characterTeam.members[i])
    self.commandManager:addListener(self.characterTeam.members[i])
  end
  for i=1,#self.enemyTeam.members do
    self.turnManager:addListener(self.enemyTeam.members[i])
  end
  
  -- sort teams and do a single pass during comba
  -- self.turnManager:sortBySpeed()
  self.turnManager:setNext()
  Signal.emit('NextTurn', self.turnManager.activeEntity)
end;

--[[ Increments the enemiesIndex counter by the number of times passed, 
then sets the position of the cursorX & cursorY variables to the position of the targeted enemy ]]
function combat:setTargetPos(incr) --> void
  self.enemyTeamIndex = (self.enemyTeamIndex + incr) % self.enemyCount
  local targetedEnemy = self.enemyTeam[self.enemyTeamIndex]
  self.cursorX = self.targetedEnemy:getX()
  self.cursorY = self.targetedEnemy:getY()
end;

--[[ Sets the focused member, and adjusts ActionUI accordingly ]]
function combat:nextTurn()
  self.turnManager:setNext()
  self.turnManager:notifyListeners()
end;

function combat:generateEncounter() --> EnemyTeam
  local enemyTeam = combat:generateEnemyTeam()
  -- combat:logCombat(enemyTeam)
  return enemyTeam
end;

function combat:generateEnemyTeam()
  local enemyList = {}
  local enemyNameList = combat:getEnemyNames()

  -- Populate list for EnemyTeam ctor
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
  --[[
  if key == pause key then
    Gamestate.push(states['pause'])
  else]]
  self.characterTeam:keypressed(key)
  
  if self.turnManager.activeEntity.actionUI.uiState == 'targeting' then
    local targetPositions = self.enemyTeam:getPositions()
    Signal.emit('TargetSelect', targetPositions)
  elseif self.turnManager.activeEntity.actionUI.uiState == 'moving' then
    local e = self.turnManager.activeEntity
    Signal.emit('MoveToEnemy')
  end
end;

function combat:gamepadpressed(joystick, button)
    --[[
  if key == pause key then
    Gamestate.push(states['pause'])
  ]]
  self.characterTeam:gamepadpressed(joystick, button)
  if button == 'a' and self.turnManager.activeEntity.actionUI.uiState == 'targeting' then
    local targetPositions = self.enemyTeam:getPositions()
    Signal.emit('TargetSelect', targetPositions)
  end
end;

function combat:update(dt)
  self.turnManager:update(dt)
  if self.lockCamera then
    camera:lockWindow(character.x, character.y, 0, character.x + 100, 0, character.y + 100)
  end
  
end;

function combat:draw()
  camera:attach()
  love.graphics.draw(self.background, 0, 0, 0, 1.75, 2.5)
  self.characterTeam:draw()
  self.enemyTeam:draw()
  camera:detach()
end;
  
return combat