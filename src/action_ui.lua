--! filename: combat_ui
local class = require 'libs/middleclass'
ActionUI = class('ActionUI')

ActionUI.static.SOLO_BUTTON_PATH = 'asset/sprites/combat/solo_lame.png'
ActionUI.static.FLOUR_BUTTON_PATH = 'asset/sprites/combat/flour.png'
ActionUI.static.DUO_BUTTON_PATH = 'asset/sprites/combat/duo_lame.png'

  -- ActionUI constructor
    -- preconditions: name of the character
    -- postconditions: initializes action ui icons for the character
-- NOTE: Only one set of UI for development rn, customization comes later
function ActionUI:initialize(centerPosition)--name)
  self.center = centerPosition
  self.soloButton = love.graphics.newImage(ActionUI.static.SOLO_BUTTON_PATH)
  self.flourButton = love.graphics.newImage(ActionUI.static.FLOUR_BUTTON_PATH)
  self.duoButton = love.graphics.newImage(ActionUI.static.DUO_BUTTON_PATH)
  self.activeAction = 'solo'
  

  
  -- TODO: to set the position of the cursor, we need a list of enemies that we can ping for their position(s)
    -- enemy class & enemy team class required for this
end;

function ActionUI:getPos()
  return self.center
end;

function ActionUI:setPos(newCenter)
  self.center = newCenter
end;

function ActionUI:setActiveAction(action)
  if action == 'solo' then
    self.activeAction = 'solo'
  elseif action == 'flour' then
    self.activeAction = 'flour'
  else
    self.activeAction = 'duo'
  end
end;

function ActionUI:keypressed(key)
  if uiState == 'actionSelect' then  
    if key == 'left' then
      if self.activeAction == 'solo' then
        self.activeAction = 'flour'
      elseif self.activeAction == 'flour' then
        self.activeAction = 'duo'
      else
        self.activeAction = 'solo'
      end
    elseif key == 'right' then
      if self.activeAction == 'solo' then
        self.activeAction = 'duo'
      elseif self.activeAction == 'flour' then
        self.activeAction = 'solo'
      else
        self.activeAction = flour
      end
    end    
    ActionUI:spinIcons()
    if key == 'z' then                              -- FIXME: Need to change to check each character!
      if self.activeAction == 'solo' then
        ActionUI:targetEnemy()
      elseif self.activeAction == 'flour' then
        ActionUI:displaySkillList()
      else
        ActionUI:displayDuoList()
      end
    end
  elseif uiState == 'targetSelect' then
    -- up/down/left/right/confirm/cancel
    print('fixme')
  else  -- uiState is for a skill/menu
    -- up/down/confirm/cancel
  end
  
  
end;

  -- Rotates Action Icons, enabling the activeAction to be selected
function ActionUI:spinIcons()
  -- move each icon's x-position in a for loop
  -- scale the inactive Actions so they appear as though they are behind the active action
end;

  -- Sets the cursor to be drawn when an Enemy needs to be targeted
function ActionUI:targetEnemy()
  self.drawCursor = true
end;

-- Messy Implementation for now: draw based on the current focused action
function ActionUI:draw()
  love.graphics.draw(self.soloButton)
  love.graphics.draw(self.flourButton)
  love.graphics.draw(self.duoButton)
  
  
  if self.drawCursor then
    love.graphics.draw(self.targetCursor, self.cursorX, self.cursorY)
  end
  
end;
