--! file: gamestates/combat
require("entity")
require("character")
require("enemy")
require("turn_queue")
require("action_ui")
local combat = {}
local FIRST_MEMBER_X = 100
local FIRST_MEMBER_Y = 100

Entities = {}
local TARGET_SPRITE = 'asset/sprites/combat/target_cursor.png'


function combat:init()

  
  targetCursor = love.graphics.newImage(TARGET_SPRITE)
  cursorX = 0
  cursorY = 0
  
end;

function combat:enter(previous, seed)
  for i, v in pairs(team:getMembers()) do
    table.insert(Entities, v)
    print('added ' .. v:getEntityName() .. ' to the combat')
  end

  Enemies = {}
  enemyCount = 0
  enemiesIndex = 1
  
  -- replace me with a fcn that will generate all enemies for an encounter
  butter = Enemy(get_butter_stats(), get_butter_skills())
  
  table.insert(Enemies, butter)
  enemyCount = enemyCount + 1
  --------------------- end replacement area here
  
  
  for i,v in pairs(Enemies) do
    table.insert(Entities, v)
    print('added ' .. v:getEntityName() .. ' to the combat')
  end  
  
  
  if previous ~= pause then
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
end;

function combat:draw()
  team:draw()
  
  if team.actionUI:getUIState() == 'targeting' then
    love.graphics.draw(targetCursor, cursorX, cursorY)
  end
end;
  
return combat