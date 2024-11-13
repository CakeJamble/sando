--! file: gamestates/combat
require("entity")
require("character")
require("enemy")
require("turn_queue")
require("action_ui")
require("encounter_generator")
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
  Enemies = {}
  enemyCount = 0
  enemiesIndex = 1
  floorNumber = 1
end;

function combat:enter(previous, seed)
  -- Create enemy team
  enemyTeam = generateEncounter(floorNumber)
  enemyCount = #enemyTeam  
  -- place the members into the encounter
  for i, v in pairs(team:getMembers()) do
    table.insert(Entities, v)
    print('added ' .. v:getEntityName() .. ' to the combat')
  end
  
  for i, v in ipairs(enemyTeam) do
    table.insert(Entities, v)
    print('added ' .. v:getEntityName() .. ' to the combat')
  end


  if previous ~= pause then
    -- reset rewards, combatants in fight, and turn order
    rewardExp = 0
    rewardMoney = 0
    
    for i,v in pairs(Enemies) do
      table.insert(Entities, v)
      enemyCount = enemyCount + 1
      print('added ' .. v:getEntityName() .. ' to the combat')
    end
    
    sort_entities()
    
  end

  if type(Entities[1]) == 'Character' then
    team:setFocusedMember(Entities[1])
  end

end;

function combat:generateEnemies()
  return Enemy(get_butter_stats(), get_butter_skills())
end;

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
  team:update(dt)
  
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
  team:draw()
  
  if team.actionUI:getUIState() == 'targeting' then
    love.graphics.draw(targetCursor, cursorX, cursorY)
  end
end;
  
return combat