--! filename: combat_ui
require('class.solo_button')
require('class.flour_button')
require('class.duo_button')
Class = require 'libs.hump.class'
ActionUI = Class{BUTTON_SPACER = 50, BUTTON_SCALE = 0.6, ICON_ROTATION = 0}

  -- ActionUI constructor
    -- preconditions: name of the character
    -- postconditions: initializes action ui icons for the character
-- NOTE: Only one set of UI for development rn, customization comes later
-- character only has own x and y, not sure if they need offset
function ActionUI:init(x, y, skillList, currentFP, currentDP) -- needs enemy positions list?
-- The ActionUI position (self.x, self.y) is at the coordinates of the center of the button wheel
  self.x = x
  self.y = y
  self.uiState = 'actionSelect'
  self.iconSpacer = 50
  self.soloButton = SoloButton(self.x, self.y)
  self.flourButton = FlourButton(self.x - self.iconSpacer, self.y, currentFP, skillList)
  self.duoButton = DuoButton(x + self.iconSpacer, self.y, currentDP, skillList)
  self.activeButton = self.soloButton

  
  -- skill list needs to be printed on another display interface
  self.skillList = skillList or nil
  self.selectedSkill = nil

  self.targets = {}
  -- TODO: to set the position of the cursor, we need a list of enemies that we can ping for their position(s)
    -- enemy class & enemy team class required for this
end;

  -- Returns a table containing the position of the top left of the center icon in (x,y) coords
function ActionUI:getPos()
  return {self.x, self.y}
end;

  -- Sets the X positions of the three icons and automatically adjusts the other icons based on the const offset spacer
function ActionUI:setPos(x, y)
  self.x = x
  self.y = y
end;

  -- Sets the active action that is used to determine scaling and rotating in the update function for drawing positions
function ActionUI:setActiveAction(action)
  if action == 'solo' then
    self.activeAction = self.soloButton
  elseif action == 'flour' then
    self.activeAction = self.flourButton
  else
    self.activeAction = self.duoButton
  end
end;

function ActionUI:getUIState()
  return self.uiState
end;

  -- Left & Right keys rotate the action ui wheel. Z confirms a selection.
function ActionUI:keypressed(key)
  if self.uiState == 'actionSelect' then  
    if key == 'right' then                         -- spin the wheel left
      if self.activeButton == self.soloButton then                          -- {left:solo, center:duo, right:flour}
        self.activeAction = self.duoButton
        self.duoButton:setIsActiveButton(true)
        self.soloButton:setIsActiveButton(false)
        self.soloButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 1)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 2)
      elseif self.activeAction == self.flourButton then                     -- {left:flour, center:solo, right:duo}
        self.activeAction = self.soloButton
        self.flourButton:setIsActiveButton(false)
        self.soloButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 2)
        self.flourButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 1)
      else                                                                  -- {left:duo, center:flour, right:solo}
        self.activeAction = self.flourButton
        self.duoButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 2)
        self.duoButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 1)
        self.flourButton:setTargetPos(self.x, 1)
      end      
    
      self.uiState = 'rotating'
      
    elseif key == 'left' then                      -- spin the wheel right
      if self.activeAction == self.soloButton then                          -- {left:duo, center:flour , right:solo}
        self.activeAction = self.flourButton
        self.soloButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 1)
        self.duoButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 2)
        self.flourButton:setTargetPos(self.x, 1)
      elseif self.activeAction == self.flourButton then                     -- {left:solo, center:duo, right:flour}
        self.activeAction = self.duoButton
        self.flourButton:setIsActiveButton(false)
        self.duoButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 2)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 1)
      else                                                                  -- {left:flour, center:solo, right:duo}
        self.activeAction = self.soloButton
        self.soloButton:setIsActiveButton(true)
        self.duoButton:setIsActiveButton(false)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 1)
        self.flourButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 2)
      end

      self.uiState = 'rotating'
      
     -- stand ins for confirm/cancel button input 
    elseif key == 'z' then
      self.activeAction:keypressed(key)
      if self.activeAction == 'solo' then
        self.uiState = 'targeting'
      else
        self.uiState = 'submenuing'
      end
  end
  
    
  elseif self.uiState == 'submenuing' then    -- the activeAction is either flourButton or duoButton
    self.activeAction:keypressed(key)
  
    if key == 'z' then
      self.selectedSkill = self.activeAction.selectedSkill
      self.uiState = 'targeting'
    elseif key == 'x' then
      if self.activeAction == self.soloButton then
        self.uiState = 'actionSelect'
      else  -- self.uiState == 'submenuing'
        self.uiState = 'actionSelect'
      end
    end

  elseif self.uiState == 'targeting' then -- maybe just else?
    self.targets = self.activeAction:getTargets()
    self.uiState = 'qte'
  end

end;

  -- Sets the cursor to be drawn when an Enemy needs to be targeted
function ActionUI:targetEnemy(x, y)
  self.drawCursor = true
end;

function ActionUI:update(dt)
  if self.uiState == 'rotating' then
    
    if self.activeAction == 'flour' and self.flourDest > self.flourX then      -- {left:flour, center:solo, right:duo} -> {left:duo, center:flour, right:solo}
      
      self.soloX = self.soloX + ActionUI.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX + ActionUI.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX - ActionUI.ICON_BASE_DX * dt * self.duoDX
      self.soloScale = self.soloScale - dt
      self.flourScale = self.flourScale + dt
      
      -- In case the updated coordinates overshoot, set them them to correct destination and exit the rotating ui state
      if self.soloX > self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.flourScale = 1
        self.soloScale = ActionUI.ICON_SCALE
        self.uiState = 'actionSelect'
      end
      -- if self.soloScale > 1 then self.soloScale = 1 end

    elseif self.activeAction == 'flour' and self.flourDest < self.flourX then  -- {left:solo, center:duo, right:flour} -> {left:duo, center:flour, right:solo}
      
      self.soloX = self.soloX + ActionUI.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX - ActionUI.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX - ActionUI.ICON_BASE_DX * dt * self.duoDX
      self.duoScale = self.duoScale - dt
      self.flourScale = self.flourScale + dt
      if self.soloX > self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.duoScale = ActionUI.ICON_SCALE
        self.flourScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'solo' and self.soloDest > self.soloX then -- {left:solo, center:duo, right:flour} -> {left:flour, center:solo, right:duo}
      
      self.soloX = self.soloX + ActionUI.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX - ActionUI.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX + ActionUI.ICON_BASE_DX * dt * self.duoDX
      self.duoScale = self.duoScale - dt
      self.soloScale = self.soloScale + dt
      if self.soloX > self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.duoScale = ActionUI.ICON_SCALE
        self.soloScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'solo' and self.soloDest < self.soloX then -- {left:duo, center:flour, right:solo} -> {left:flour, center:solo, right:duo}
      
      self.soloX = self.soloX - ActionUI.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX - ActionUI.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX + ActionUI.ICON_BASE_DX * dt * self.duoDX
      self.flourScale = self.flourScale - dt
      self.soloScale = self.soloScale + dt
      if self.soloX < self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.flourScale = ActionUI.ICON_SCALE
        self.soloScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'duo' and self.duoDest > self.duoX then  -- {left:duo, center:flour, right:solo} -> {left:solo, center:duo, right:flour}
      
      self.soloX = self.soloX - ActionUI.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX + ActionUI.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX + ActionUI.ICON_BASE_DX * dt * self.duoDX
      self.flourScale = self.flourScale - dt
      self.duoScale = self.duoScale + dt
      if self.soloX < self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.flourScale = ActionUI.ICON_SCALE
        self.duoScale = 1
        self.uiState = 'actionSelect'
      end
      
    elseif self.activeAction == 'duo' and self.duoDest < self.duoX then  -- {left:flour, center:solo, right:duo} -> {left:solo, center:duo, right:flour}
      
      self.soloX = self.soloX - ActionUI.ICON_BASE_DX * dt * self.soloDX
      self.flourX = self.flourX + ActionUI.ICON_BASE_DX * dt * self.flourDX
      self.duoX = self.duoX - ActionUI.ICON_BASE_DX * dt * self.duoDX
      self.soloScale = self.soloScale - dt
      self.duoScale = self.duoScale + dt
      if self.soloX < self.soloDest then
        self.soloX = self.soloDest
        self.flourX = self.flourDest
        self.duoX = self.duoDest
        self.soloScale = ActionUI.ICON_SCALE
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
      
    love.graphics.draw(self.flourButton, self.flourX, self.y, ActionUI.ICON_ROTATION, self.flourScale, self.flourScale)
    love.graphics.draw(self.duoButton, self.duoX, self.y, ActionUI.ICON_ROTATION, self.duoScale, self.duoScale)
    love.graphics.draw(self.soloButton, self.soloX, self.y, ActionUI.ICON_ROTATION, self.soloScale, self.soloScale)
    
  elseif self.activeAction == 'flour' then
      
    love.graphics.draw(self.duoButton, self.duoX, self.y, ActionUI.ICON_ROTATION, self.duoScale, self.duoScale)
    love.graphics.draw(self.soloButton, self.soloX, self.y, ActionUI.ICON_ROTATION, self.soloScale, self.soloScale)
    love.graphics.draw(self.flourButton, self.flourX, self.y, ActionUI.ICON_ROTATION, self.flourScale, self.flourScale)
  
  else
  
    love.graphics.draw(self.soloButton, self.soloX, self.y, ActionUI.ICON_ROTATION, self.soloScale, self.soloScale)
    love.graphics.draw(self.flourButton, self.flourX, self.y, ActionUI.ICON_ROTATION, self.flourScale, self.flourScale)
    love.graphics.draw(self.duoButton, self.duoX, self.y, ActionUI.ICON_ROTATION, self.duoScale, self.duoScale)
  end
end;