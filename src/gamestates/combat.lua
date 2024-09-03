--! file: gamestates/combat
require("entity")
require("character")
require("turn_queue")
require("action_ui")
local combat = {}
local TARGET_CURSOR_PATH = 'asset/sprites/combat/target_cursor.png'
local FIRST_MEMBER_X = 100
local FIRST_MEMBER_Y = 100

function combat:init()
  -- Set Character Positions
  for i,member in pairs(team:getMembers()) do
    member:setPos(FIRST_MEMBER_X * i, FIRST_MEMBER_Y * i)
  end
  
  self.ui = ActionUI()
  self.targetCursor = love.graphics.newImage(TARGET_CURSOR_PATH)
  self.drawCursor = false
end;

function combat:enter(previous, seed)
  if previous ~= pause then
    sort_entities()
  end
end;

function combat:keypressed(key)
  if key == 'escape' then
    Gamestate.push(states['pause'])
  end
end;

function combat:update(dt)
  team:update(dt)
end;

function combat:draw()
  team:draw()
  
end;
  
return combat