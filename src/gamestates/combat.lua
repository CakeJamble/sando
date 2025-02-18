--! file: gamestates/combat
require("class.enemy")
require("class.action_ui")
require("util.encounter_pools")
require('gamestates.character_select')
require("util.globals")
require('class.character_team')
require('class.enemy_team')
require('util.stat_sheet')

local combat = {}
local FIRST_MEMBER_X = 100
local FIRST_MEMBER_Y = 100
local numFloors = 50

local TARGET_SPRITE = 'asset/sprites/combat/target_cursor.png'

function combat:init()
  self.targetCursor = love.graphics.newImage(TARGET_SPRITE)
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
end;

function combat:enter(previous)
  self.characterTeam = loadCharacterTeam()
  
  -- init encounteredPools to keep track of all encounters across a run
  for i=1,numFloors do
    self.encounteredPools[i] = {}
  end;
  
  -- Log & Generate the floor's encounter in encounteredPools
  combat:logEncounter(self.encounteredPools, self.floorNumber)
  self.enemyNameList = self.encounteredPools[self.floorNumber]
  self.enemyList = {}

  for i=1,#self.enemyNameList do
    local enemy = Enemy(self.enemyNameList[i], "Enemy")
    self.enemyList[i] = enemy
  end
  
  -- TODO: needs to determine between types of enemies
  self.enemyTeam = EnemyTeam(self.enemyList, #self.enemyNameList)  
  
  -- sort teams and do a single pass during comba
  -- self.characterTeam:sortBySpeed()
  -- self.enemyTeam:sortBySpeed()
  
  self.rewardExp = 0
  self.rewardMoney = 0
  
  -- Set the focused character to begin combat
  combat:nextTurn()
end;

  -- Increments the enemiesIndex counter by the number of times passed, then sets the position of the cursorX & cursorY variables to the position of the targeted enemy
function combat:setTargetPos(incr) --> void
  self.enemyTeamIndex = (self.enemyTeamIndex + incr) % self.enemyCount
  local targetedEnemy = Enemies[self.enemyTeamIndex]
  self.cursorX = self.targetedEnemy:getX()
  self.cursorY = self.targetedEnemy:getY()
end;


function combat:nextTurn()
  if self.characterTeam:getSpeedAt(self.characterTeamIndex) < self.enemyTeam:getSpeedAt(self.enemyTeamIndex) then
    self.characterTeam:setFocusedMember(nil)
    self.enemyTeam:setFocusedMember(self.enemyTeamIndex)
    self.enemyTeamIndex = self.enemyTeamIndex + 1
    
  else    -- if next Character.speed >= next Enemey.speed then
    self.enemyTeam:setFocusedMember(nil)
    self.characterTeam:setFocusedMember(self.characterTeamIndex)
    self.characterTeamIndex = self.characterTeamIndex + 1

  end
end;

-- Need to port over map generation techniques for weighted random creation of encounters!!!
function combat:logEncounter() --> EnemyTeam
  local encounter = 0
  if self.floorNumber < 10 then
    -- Weighted Randomly grab from Enemy Pool 1
    -- TODO : Make this actually weighted rand
    -- local encounter = math.random(1, #enemyPool1)
    -- encounteredPools[floorNum] = enemyPool1[encounter]
    self.encounteredPools[self.floorNumber] = testPool[1]
  elseif self.floorNumber == 10 then
    -- Randomly grab from Boss Pool 1
    local encounter = math.random(1, #bossPool1)
    self.encounteredPools[self.floorNumber] = bossPool1[encounter]
  elseif self.floorNumber < 20 then
    -- Weighted Randomly grab from Enemy Pool 2
    -- TODO : Make this actually weighted rand
    local encounter = math.random(1, #enemyPool2)
    self.encounteredPools[self.floorNumber] = enemyPool2[encounter]
  elseif self.floorNumber == 20 then
    local encounter = math.random(1, #bossPool2)
    self.encounteredPools[self.floorNumber] = bossPool2[encounter]
  end
end;


function combat:keypressed(key)
  self.characterTeam:keypressed(key)
end;

function combat:update(dt)
  self.characterTeam:update(dt)
  self.enemyTeam:update(dt)
end;

function combat:draw()
  self.characterTeam:draw()
  self.enemyTeam:draw()
  
  -- if team.actionUI:getUIState() == 'targeting' then
  --   love.graphics.draw(targetCursor, cursorX, cursorY)
  -- end
end;
  
return combat