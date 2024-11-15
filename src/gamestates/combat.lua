--! file: gamestates/combat
require("class.entity")
require("class.character")
require("class.enemy")
require("class.action_ui")
require("util.encounter_generator")
require('gamestates/character_select')

local combat = {}
local FIRST_MEMBER_X = 100
local FIRST_MEMBER_Y = 100

Entities = {}
local TARGET_SPRITE = 'asset/sprites/combat/target_cursor.png'


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
  -- Create enemy team
  enemyTeam = generateEncounter(floorNumber)
  characterTeam = team
  combat:addToEncounter(characterTeam)
  combat:addToEncounter(enemyTeam)

  rewardExp = 0
  rewardMoney = 0

-- TODO needs to be fixed
--  combat:sortEntities(Entities)

  if type(Entities[1]) == 'Character' then
    team:setFocusedMember(Entities[1])
  end

end;

function combat:addToEncounter(team)
  for i, v in ipairs(enemyTeam) do
    table.insert(Entities, v)
    print('added ' .. v:getEntityName() .. ' to the combat')
  end
end;

function combat:orderFcn(a, b)
  return a:getSpeed() < b:getSpeed()
end

function combat:sortEntities()
  table.sort(Entities, orderFcn)
end

  -- Increments the enemiesIndex counter by the number of times passed, then sets the position of the cursorX & cursorY variables to the position of the targeted enemy
function combat:setTargetPos(incr) --> void
  enemiesIndex = (enemiesIndex + incr) % enemyCount
  local targetedEnemy = Enemies[enemiesIndex]
  cursorX = targetedEnemy:getX()
  cursorY = targetedEnemy:getY()
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
  for _,enemy in ipairs(enemyTeam) do
    enemy:draw()
  end
  
  if team.actionUI:getUIState() == 'targeting' then
    love.graphics.draw(targetCursor, cursorX, cursorY)
  end
end;
  
return combat