--! file: gamestates/combat
require("entity")
require("character")
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
  team:update(dt)
end;

function combat:draw()
  --ui:draw()
  team:draw()
end;
  
return combat