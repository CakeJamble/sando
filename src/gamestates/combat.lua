--! file: gamestates/combat
require("class.entity")
require("class.character")
require("class.enemy")
require("class.action_ui")
require("util.encounter_pools")
require('gamestates/character_select')

local combat = {}
local FIRST_MEMBER_X = 100
local FIRST_MEMBER_Y = 100
local numFloors = 50

local TARGET_SPRITE = 'asset/sprites/combat/target_cursor.png'
entities = {}
enemyTeam = {}
characterTeam = {}

function combat:init()
  targetCursor = love.graphics.newImage(TARGET_SPRITE)
  cursorX = 0
  cursorY = 0
  rewardExp = 0
  rewardMoney = 0
  enemyCount = 0
  enemiesIndex = 1
  floorNumber = 1
end;

function combat:enter(previous, team)
  characterTeam = CharacterTeam(team:getNumMembers())
  characterTeam:copy(team)
  encounteredPools = {}
  
  -- init encounteredPools to keep track of all encounters across a run
  for i=1,numFloors do
    encounteredPools[i] = {}
  end;
  
  -- Log the floor's encounter in encounteredPools, then generate the encounter
  combat:logEncounter(floorNumber)
  enemyNameList = encounteredPools[floorNumber]
  
  -- TODO: needs to determine between types of enemies
  enemyTeam = EnemyTeam(#enemyNameList)
  for i=1,#enemyNameList do
    local enemy = Enemy(enemyNameList[i], "Enemy")
    enemyTeam:addMember(enemy)
  end
  
  combat:addToEncounter(characterTeam)  -- adds whatever team is created most recently :(
  -- combat:addToEncounter(enemyTeam)


  rewardExp = 0
  rewardMoney = 0

-- TODO needs to be fixed
--  combat:sortEntities(Entities)

  if type(entities[1]) == 'Character' then
    team:setFocusedMember(entities[1])
  end

end;

function combat:addToEncounter(team)
  local members = team:getMembers()
  for _,v in pairs(members) do
    table.insert(entities, v)
    print('added ' .. v:getEntityName() .. ' to combat')
  end
end;

-- function combat:orderFcn(a, b)
--   return a:getSpeed() < b:getSpeed()
-- end

-- function combat:sortEntities()
--   table.sort(Entities, orderFcn)
-- end

  -- Increments the enemiesIndex counter by the number of times passed, then sets the position of the cursorX & cursorY variables to the position of the targeted enemy
function combat:setTargetPos(incr) --> void
  enemiesIndex = (enemiesIndex + incr) % enemyCount
  local targetedEnemy = Enemies[enemiesIndex]
  cursorX = targetedEnemy:getX()
  cursorY = targetedEnemy:getY()
end;




-- Need to port over map generation techniques for weighted random creation of encounters!!!
function combat:logEncounter(floorNum) --> EnemyTeam
  local encounter = 0
  if floorNum < 10 then
    -- Weighted Randomly grab from Enemy Pool 1
    -- TODO : Make this actually weighted rand
    -- local encounter = math.random(1, #enemyPool1)
    -- encounteredPools[floorNum] = enemyPool1[encounter]
    encounteredPools[floorNum] = testPool[1]
  elseif floorNum == 10 then
    -- Randomly grab from Boss Pool 1
    local encounter = math.random(1, #bossPool1)
    encounteredPools[floorNum] = bossPool1[encounter]
  elseif floorNum < 20 then
    -- Weighted Randomly grab from Enemy Pool 2
    -- TODO : Make this actually weighted rand
    local encounter = math.random(1, #enemyPool2)
    encounteredPools[floorNum] = enemyPool2[encounter]
  elseif floorNum == 20 then
    local encounter = math.random(1, #bossPool2)
    encounteredPools[floorNum] = bossPool2[encounter]
  end
end;


function combat:keypressed(key)
  if team.actionUI:getUIState() == 'targeting' then
    if key == 'down' then
      combat:setTargetPos(1)
    elseif key == 'up' then
      combat:setTargetPos(-1)
    end
  elseif key == 'escape' then
    Gamestate.push(states['pause'])
  end
  
  team:keypressed(key)
    
  -- come back to me when you have a team of enemies ready to load in :) 
  -- if team.actionUI:getUIState() == 'targeting' then
    
end;

function combat:update(dt)
  characterTeam:update(dt)
  -- enemyTeam:update(dt)

  -- Remove an enemy from the Entities table upon defeat
  for _,entity in pairs(Entities) do
    if not entity:isAlive() then
      if type(entity) == Enemy then -- add their rewards to the combat rewards
        rewardExp = rewardExp + entity:getExpReward()
        rewardMoney = rewardMoney + entity:getMoneyReward()
        Entities:pop(entity)
      end
    end
  end

end;

function combat:draw()
  characterTeam:draw()
  -- enemyTeam:draw()
  
  -- if team.actionUI:getUIState() == 'targeting' then
  --   love.graphics.draw(targetCursor, cursorX, cursorY)
  -- end
end;
  
return combat