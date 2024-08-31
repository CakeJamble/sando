--! file: gamestates/combat
require("entity")
require("character")
require("combat_ui")
local combat = {}

function combat:init()
  ui = CombatUI()
end;

function combat:enter(previous, seed)
  if previous ~= pause then
    sort_entities()
  end
end;

function combat:update(dt)
end;

function combat:draw()
  ui:draw()
end;
  
return combat

--  for _, entity in ipairs(Entities) do
--    local spriteNum = math.floor(entity.animations[0].currentTime / entity.animations[0].duration * #entity.animations[0].quads) + 1
--    if(entity.getState() == 'idle') then
--      love.graphics.draw(entity.animations[0].spriteSheet, entity.animations[0].quads[spriteNum], 0, 0, 0, 4)  -- idle
--    end
--  end