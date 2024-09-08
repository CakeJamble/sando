--! filename: combat_ui
local class = require 'libs/middleclass'
ActionUI = class('ActionUI')

ActionUI.static.SOLO_BUTTON_PATH = 'asset/sprites/combat/solo_lame.png'
ActionUI.static.FLOUR_BUTTON_PATH = 'asset/sprites/combat/flour.png'
ActionUI.static.DUO_BUTTON_PATH = 'asset/sprites/combat/duo_lame.png'
ActionUI.static.ICON_SPACER = 50
ActionUI.static.ICON_SCALE = 0.6
ActionUI.static.SCALE_FACTOR = 1
ActionUI.static.ICON_ROTATION = 0
ActionUI.static.ICON_BASE_DX = 150

  -- ActionUI constructor
    -- preconditions: name of the character
    -- postconditions: initializes action ui icons for the character
-- NOTE: Only one set of UI for development rn, customization comes later
function ActionUI:initialize(x, y)
  self.uiState = 'actionSelect'
  self.soloButton = love.graphics.newImage(ActionUI.static.SOLO_BUTTON_PATH)
  self.flourButton = love.graphics.newImage(ActionUI.static.FLOUR_BUTTON_PATH)
  self.duoButton = love.graphics.newImage(ActionUI.static.DUO_BUTTON_PATH)
  self.activeAction = 'solo'
  self.centerX = x
  self.soloX = x
  self.flourX = x - ActionUI.static.ICON_SPACER
  self.duoX = x + ActionUI.static.ICON_SPACER
  self.y = y
  self.soloDest = self.soloX
  self.flourDest = self.flourX
  self.duoDest = self.duoX
  self.soloScale = 1
  self.flourScale = ActionUI.static.ICON_SCALE
  self.duoScale = ActionUI.static.ICON_SCALE
  self.soloDX = 1
  self.flourDX = 1
  self.duoDX = 2
  -- TODO: to set the position of the cursor, we need a list of enemies that we can ping for their position(s)
    -- enemy class & enemy team class required for this
end;

  -- Returns a table containing the position of the top left of the center icon in (x,y) coords
function ActionUI:getPos()
  return {self.centerX, self.y}
end;

  -- Sets the X positions of the three icons and automatically adjusts the other icons based on the const offset spacer
function ActionUI:setPos(x, y)
  self.soloX = x
  self.flourX = x - ActionUI.static.ICON_SPACER
  self.duoX = x + ActionUI.static.ICON_SPACER
  self.y = y
end;

  -- Sets the active action that is used to determine scaling and rotating in the update function for drawing positions
function ActionUI:setActiveAction(action)
  if action == 'solo' then
    self.activeAction = 'solo'
  elseif action == 'flour' then
    self.activeAction = 'flour'
  else
    self.activeAction = 'duo'
  end
end;

function ActionUI:getUIState()
  return self.uiState
end;

  -- Left & Right keys rotate the action ui wheel. Z confirms a selection.
function ActionUI:keypressed(key)
  if self.uiState == 'actionSelect' then  
    if key == 'right' then                         -- spin the wheel left
      if self.activeAction == 'solo' then                          -- {left:solo, center:duo, right:flour}
        self.activeAction = 'duo'
        self.soloDest = self.soloX - ActionUI.static.ICON_SPACER
        self.soloDX = 1
        self.flourDest = self.flourX + 2 * ActionUI.static.ICON_SPACER
        self.flourDX = 2
        self.duoDest = self.duoX - ActionUI.static.ICON_SPACER
        self.duoDX = 1
      elseif self.activeAction == 'flour' then                     -- {left:flour, center:solo, right:duo}
        self.activeAction = 'solo'
        self.soloDest = self.soloX - ActionUI.static.ICON_SPACER
        self.soloDX = 1
        self.flourDest = self.flourX - ActionUI.static.ICON_SPACER
        self.flourDX = 1
        self.duoDest = self.duoX + 2 * ActionUI.static.ICON_SPACER
        self.duoDX = 2
      else                                                                  -- {left:duo, center:flour, right:solo}
        self.activeAction = 'flour'
        self.soloDest = self.soloX + 2 * ActionUI.static.ICON_SPACER
        self.soloDX = 2
        self.flourDest = self.flourX - ActionUI.static.ICON_SPACER
        self.flourDX = 1
        self.duoDest = self.duoX - ActionUI.static.ICON_SPACER
        self.duoDX = 1
      end      
    
      self.uiState = 'rotating'
      
    elseif key == 'left' then                      -- spin the wheel right
      if self.activeAction == 'solo' then                          -- {left:duo, center:flour , right:solo}
        self.activeAction = 'flour'
        self.soloDest = self.soloX + ActionUI.static.ICON_SPACER
        self.soloDX = 1
        self.flourDest = self.flourX + ActionUI.static.ICON_SPACER
        self.flourDX = 1
        self.duoDest = self.duoX - 2 * ActionUI.static.ICON_SPACER
        self.duoDX = 2
      elseif self.activeAction == 'flour' then                     -- {left:solo, center:duo, right:flour}
        self.activeAction = 'duo'
        self.soloDest = self.soloX - 2 * ActionUI.static.ICON_SPACER
        self.soloDX = 2
        self.flourDest = self.flourX + ActionUI.static.ICON_SPACER
        self.flourDX = 1
        self.duoDest = self.duoX + ActionUI.static.ICON_SPACER
        self.duoDX = 1
      else                                                                  -- {left:flour, center:solo, right:duo}
        self.activeAction = 'solo'
        self.soloDest = self.soloX + ActionUI.static.ICON_SPACER
        self.soloDX = 1
        self.flourDest = self.flourX - 2 * ActionUI.static.ICON_SPACER
        self.flourDX = 2
        self.duoDest = self.duoX + ActionUI.static.ICON_SPACER
        self.duoDX = 1
      end

      self.uiState = 'rotating'
      
    elseif key == 'z' then                              -- FIXME: Need to change to check each character!
      if self.activeAction == 'solo' then
        self.uiState = 'targeting'
      elseif self.activeAction == 'flour' then
        ActionUI:displaySkillList()
      else
        ActionUI:displayDuoList()
      end
    else                                                -- FIXME: Need a cancel that will pop the user back to the activeSelection rotating wheel thing
      print("whoops")
    end
  end
  
    
  if self.uiState == 'targetSelect' then
    -- up/down/left/right/confirm/cancel
    print('fixme')
  end
end;

  -- Sets the cursor to be drawn when an Enemy needs to be targeted
function ActionUI:targetEnemy(x, y)
  self.drawCursor = true
end;


function ActionUI:update(dt)
  if self.uiState == 'rotating' then
    
    if self.activeAction == 'flour' and self.flourDest > self.flourX then      -- {left:flour, center:solo, right:duo} -> {left:duo, center:flour, right:solo}
      
      self.soloX = self.soloX + ActionUI.static.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX + ActionUI.static.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX - ActionUI.static.ICON_BASE_DX * dt * self.duoDX
      self.soloScale = self.soloScale - dt
      self.flourScale = self.flourScale + dt
      
      -- In case the updated coordinates overshoot, set them them to correct destination and exit the rotating ui state
      if self.soloX > self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.flourScale = 1
        self.soloScale = ActionUI.static.ICON_SCALE
        self.uiState = 'actionSelect'
      end
      -- if self.soloScale > 1 then self.soloScale = 1 end

    elseif self.activeAction == 'flour' and self.flourDest < self.flourX then  -- {left:solo, center:duo, right:flour} -> {left:duo, center:flour, right:solo}
      
      self.soloX = self.soloX + ActionUI.static.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX - ActionUI.static.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX - ActionUI.static.ICON_BASE_DX * dt * self.duoDX
      self.duoScale = self.duoScale - dt
      self.flourScale = self.flourScale + dt
      if self.soloX > self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.duoScale = ActionUI.static.ICON_SCALE
        self.flourScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'solo' and self.soloDest > self.soloX then -- {left:solo, center:duo, right:flour} -> {left:flour, center:solo, right:duo}
      
      self.soloX = self.soloX + ActionUI.static.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX - ActionUI.static.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX + ActionUI.static.ICON_BASE_DX * dt * self.duoDX
      self.duoScale = self.duoScale - dt
      self.soloScale = self.soloScale + dt
      if self.soloX > self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.duoScale = ActionUI.static.ICON_SCALE
        self.soloScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'solo' and self.soloDest < self.soloX then -- {left:duo, center:flour, right:solo} -> {left:flour, center:solo, right:duo}
      
      self.soloX = self.soloX - ActionUI.static.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX - ActionUI.static.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX + ActionUI.static.ICON_BASE_DX * dt * self.duoDX
      self.flourScale = self.flourScale - dt
      self.soloScale = self.soloScale + dt
      if self.soloX < self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.flourScale = ActionUI.static.ICON_SCALE
        self.soloScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'duo' and self.duoDest > self.duoX then  -- {left:duo, center:flour, right:solo} -> {left:solo, center:duo, right:flour}
      
      self.soloX = self.soloX - ActionUI.static.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX + ActionUI.static.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX + ActionUI.static.ICON_BASE_DX * dt * self.duoDX
      self.flourScale = self.flourScale - dt
      self.duoScale = self.duoScale + dt
      if self.soloX < self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.flourScale = ActionUI.static.ICON_SCALE
        self.duoScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'duo' and self.duoDest < self.duoX then  -- {left:flour, center:solo, right:duo} -> {left:solo, center:duo, right:flour}
      
      self.soloX = self.soloX - ActionUI.static.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX + ActionUI.static.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX - ActionUI.static.ICON_BASE_DX * dt * self.duoDX
      self.soloScale = self.soloScale - dt
      self.duoScale = self.duoScale + dt
      if self.soloX < self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.soloScale = ActionUI.static.ICON_SCALE
        self.duoScale = 1
        self.uiState = 'actionSelect'
      end
    end
  end
  
end;

function ActionUI:draw()
  -- To make the wheel convincing, we have to draw the activeAction last so it appears to rotate in front of the other icons
  -- Currently doesn't do anything because the activeAction is updated first then the positions are moved :(
  if self.activeAction == 'solo' then
      
    love.graphics.draw(self.flourButton, self.flourX, self.y, ActionUI.static.ICON_ROTATION, self.flourScale, self.flourScale)
    love.graphics.draw(self.duoButton, self.duoX, self.y, ActionUI.static.ICON_ROTATION, self.duoScale, self.duoScale)
    love.graphics.draw(self.soloButton, self.soloX, self.y, ActionUI.static.ICON_ROTATION, self.soloScale, self.soloScale)
    
  elseif self.activeAction == 'flour' then
      
    love.graphics.draw(self.duoButton, self.duoX, self.y, ActionUI.static.ICON_ROTATION, self.duoScale, self.duoScale)
    love.graphics.draw(self.soloButton, self.soloX, self.y, ActionUI.static.ICON_ROTATION, self.soloScale, self.soloScale)
    love.graphics.draw(self.flourButton, self.flourX, self.y, ActionUI.static.ICON_ROTATION, self.flourScale, self.flourScale)
  
  else
  
    love.graphics.draw(self.soloButton, self.soloX, self.y, ActionUI.static.ICON_ROTATION, self.soloScale, self.soloScale)
    love.graphics.draw(self.flourButton, self.flourX, self.y, ActionUI.static.ICON_ROTATION, self.flourScale, self.flourScale)
    love.graphics.draw(self.duoButton, self.duoX, self.y, ActionUI.static.ICON_ROTATION, self.duoScale, self.duoScale)
  end
end;
