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
local numFloors = 50
local TEMP_BG = 'asset/sprites/background/temp-combat-bg.png'

function combat:init()
  -- Combat UI Elements
  luis.newLayer("CombatUI")

  -- Character Team Health Bars, stats, etc, at top of screen
  self.characterTeamUIContainer = luis.newFlexContainer(20, 10, 1, 5)

  -- QTE Input UI Container
  self.qteUIContainer = luis.newFlexContainer(20, 10, 1, 5)
  
  
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
  Signal.register('TargetConfirm',
  function(_, _)
    camera:zoom(1.5)
    self.lockCamera = true
  end
  );
  Signal.register('MoveBack',
    function()
      if camera.scale > 1 then
        camera:zoom(0.6666)
        self.lockCamera = false
      end
    end
  );
end;

function combat:enter(previous)
  self.lockCamera = false
  -- self.commandManager = CommandManager()
  self.characterTeam = loadCharacterTeam()
  self.rewardExp = 0
  self.rewardMoney = 0

  -- Log & Generate the floor's encounter in encounteredPools
  self.enemyTeam = combat:generateEncounter()
  
  -- Add Characters and Enemies to Turn Manager
  self.turnManager = TurnManager(self.characterTeam, self.enemyTeam)
  Signal.emit('NextTurn')
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
  if key == 'p' then
    Gamestate.push(states['pause'], self.characterTeam)
  else
    self.characterTeam:keypressed(key)
  end
end;

function combat:gamepadpressed(joystick, button)
    --[[
  if key == pause key then
    Gamestate.push(states['pause'])
  ]]
  self.characterTeam:gamepadpressed(joystick, button)
end;

function combat:update(dt)
  self.turnManager:update(dt)
  if self.lockCamera then
    local cameraTarget = self.turnManager.activeEntity
    camera:lockWindow(cameraTarget.x, cameraTarget.y, 0, cameraTarget.x + 100, 0, cameraTarget.y + 100)
  end
  
end;

function combat:draw()
  luis.draw()
  camera:attach()
  love.graphics.draw(self.background, 0, 0, 0, 1.75, 2.5)
  self.characterTeam:draw()
  self.enemyTeam:draw()
  camera:detach()

end;
  
return combat