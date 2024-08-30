--! file: gamestates/combat
require("entity")
require("character")
local combat = {}

-- CONSTANTS . DO NOT MODIFY AT RUN-TIME!!!
-- solo button
local SOLO_BUTTON_PATH = 'asset/sprites/combat/solo_lame.png'
local SOLO_BUTTON_TEXT = "Solo"
local SOLO_BUTTON_X = 100
local SOLO_BUTTON_Y = 100

-- flour button
local FLOUR_BUTTON_PATH = 'asset/sprites/combat/flour.png'
local FLOUR_BUTTON_TEXT = "Flour"
local FLOUR_BUTTON_X = 100
local FLOUR_BUTTON_Y = 200

-- duo button
local DUO_BUTTON_PATH = 'asset/sprites/combat/duo_lame.png'
local DUO_BUTTON_TEXT = "Duo"
local DUO_BUTTON_X = 100
local DUO_BUTTON_Y = 300

-- list, offsets are relative to parent objects (assoc. button(s))
local LIST_X_OFFSET = 60
local LIST_Y_OFFSET = 10
local LIST_WIDTH = 100
local LIST_HEIGHT = 200
local LIST_ITEM_SPACING = 5
local LIST_ITEM_PADDING = 5
 
-- panel, not really sure what this is for yet 
local PANEL_X = 5
local PANEL_Y = 310
local PANEL_W = 490
local PANEL_H = 115

function combat:init()
  -- self.background = love.graphics.newImage('path/to/combat_background')
  
  -- solo attack button
  local soloButton = combat:createButton(SOLO_BUTTON_PATH, SOLO_BUTTON_TEXT, SOLO_BUTTON_X, SOLO_BUTTON_Y)
  
  -- flour attack button
  local flourButton = combat:createButton(FLOUR_BUTTON_PATH, FLOUR_BUTTON_TEXT, FLOUR_BUTTON_X, FLOUR_BUTTON_Y)
  local flourList = combat:createList(LIST_X_OFFSET + FLOUR_BUTTON_X, LIST_Y_OFFSET + FLOUR_BUTTON_Y)
  flourList:SetVisible(false)
  flourList:SetParent(flourButton)
  
  -- duo attack button
  local duoButton = combat:createButton(DUO_BUTTON_PATH, DUO_BUTTON_TEXT, DUO_BUTTON_X, DUO_BUTTON_Y)
  local duoList = combat:createList(LIST_X_OFFSET + DUO_BUTTON_X, LIST_Y_OFFSET + DUO_BUTTON_Y)
  duoList:SetVisible(false)
  duoList:SetParent(duoButton)
  
  -- fcns to set buttons as visible on click and invisible when a different button is clicked
  soloButton.OnClick = function(object2, x, y)
    flourList:SetVisible(false)
    duoList:SetVisible(false)
  end
  flourButton.OnClick = function(object2, x, y)
    duoList:SetVisible(false)
    flourList:SetVisible(true)
  end
  duoButton.OnClick = function(object2, x, y)
    flourList:SetVisible(false)
    duoList:SetVisible(true)
  end
  
  local panel = loveframes.Create(PANEL_X, PANEL_Y, PANEL_W, PANEL_H) -- not sure if necessary
  
end

function combat:enter(previous, seed)
  if previous ~= pause then
    sort_entities()
  end
end

function combat:update(dt)
  loveframes.update(dt)
  for _, entity in ipairs(Entities) do
    entity.animation.currentTime = entity.animation.currentTime + dt
    if entity.animations[0].currentTime >= entity.animations[0].currrentTime then
      entity.animations[0].currentTime = entity.animations[0].currentTime - entity.animations[0].duration
    end
  end

end

function combat:draw()
  -- love.graphics.draw(self.background)
  loveframes.draw(dt)
  for _, entity in ipairs(Entities) do
    local spriteNum = math.floor(entity.animations[0].currentTime / entity.animations[0].duration * #entity.animations[0].quads) + 1
    if(entity.getState() == 'idle') then
      love.graphics.draw(entity.animations[0].spriteSheet, entity.animations[0].quads[spriteNum], 0, 0, 0, 4)  -- idle
    end
  end
end
function combat:mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function combat:mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function combat:createButton(path, text, x, y)
  local button = loveframes.Create("imagebutton")
  button:SetImage(path)
  button:SizeToImage()
  button:SetPos(x,y)
  button:SetText(text)
  return button
end

function combat:createList(x, y)
  local list = loveframes.Create("list")
  list:SetPos(x,y)
  list:SetSize(LIST_WIDTH, LIST_HEIGHT)
  list:SetPadding(LIST_ITEM_PADDING)
  list:SetSpacing(LIST_ITEM_SPACING)
  return list
end

function combat:createPanel(x, y, width, height)
  local panel = loveframes.Create("panel")
  panel:SetPos(x, y)
  panel:SetSize(width, height)
  return panel
end

function combat:createSlider(x, y, width, min, max, value, text, decimals)
  local slider = loveframes.Create("slider")
  slider:SetPos(x,y)
  slider:SetWidth(width)
  slider:SetMinMax(min, max)
  slider:SetValue(5)
  slider:SetText(text)
  slider:SetDecimals(0)
  return slider
end

function combat:createFirstText(parent, x, y, font, sliderText)
  local text = loveframes.Create("text", parent)
  text:SetPos(x,y)
  text:SetFont(love.graphics.newFont(font))
  text:SetText(sliderText)
  return text
end

function combat:appendNewText(parent, font, slider)
  local text = loveframes.Create("text", parent)
  text:SetFont(font)
  text.Update = function(object, dt)
    object:SetPos(slider:GetWidth() - object:GetWidth(), 5)
    object:SetText(slider:GetValue())
  end
  return text
end

function combat:createText3(parent, x, y, font, sliderText)
  local text = loveframes.Create("text", parent)
  text:SetPos(x,y)
  text:SetFont(font)
  text:SetText(sliderText)
  return text
end
  
return combat