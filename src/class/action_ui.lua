--! filename: combat_ui
require('class.solo_button')
require('class.flour_button')
require('class.duo_button')
require('util.globals')

Class = require 'libs.hump.class'
ActionUI = Class{
  ICON_SPACER = 50,
  X_OFFSET = 20,
  Y_OFFSET = -45,
  TARGET_CURSOR_PATH = 'asset/sprites/combat/target_cursor.png'}
local CHARACTER_SELECT_PATH = 'asset/sprites/character_select/'
local CURSOR_PATH = CHARACTER_SELECT_PATH .. 'cursor.png'
  -- ActionUI constructor
    -- preconditions: name of the character
    -- postconditions: initializes action ui icons for the character
-- function ActionUI:init(x, y, skillList, currentFP, currentDP) -- needs enemy positions list?
-- The ActionUI position (self.x, self.y) is at the coordinates of the center of the button wheel
function ActionUI:init(activeCharacter, targetPositions)
  self.x = activeCharacter.x + ActionUI.X_OFFSET
  self.y = activeCharacter.y + ActionUI.Y_OFFSET
  self.actionButton = activeCharacter.actionButton
  self.currentFP = activeCharacter.currentFP
  self.currentDP = activeCharacter.currentDP
  self.numTargets = #targetPositions
  self.tX = targetPositions[1].x
  self.tY = targetPositions[1].y
  self.uiState = 'actionSelect'
  self.iconSpacer = ActionUI.ICON_SPACER
  
  -- skill list and buttons
  self.skillList = activeCharacter.skillList
  self.selectedSkill = self.skillList[1]    -- basic attack
  self.soloButton = SoloButton(self.x, self.y, 1, self.skillList[1])
  self.flourButton = FlourButton(self.x - self.iconSpacer, self.y, 2, self.skillList)
  self.duoButton = DuoButton(self.x + self.iconSpacer, self.y, 3, self.skillList)
  self.buttons = {self.soloButton, self.flourButton, self.duoButton}
  self.activeButton = self.soloButton
  
  self.targetableEnemyPositions = targetPositions
  self.tIndex = 1
  self.targetCursor = love.graphics.newImage(ActionUI.TARGET_CURSOR_PATH)
end;

  -- Returns a table containing the position of the top left of the center icon in (x,y) coords
function ActionUI:getPos()
  return {self.x, self.y}
end;

function ActionUI:keypressed(key) --> void
  if self.uiState == 'actionSelect' then
    if key == 'right' then                         -- spin the wheel left
      if self.activeButton == self.soloButton then                            -- {left:flour, center:solo, right:duo}
        self.activeButton = self.duoButton
        self.duoButton:setIsActiveButton(true)
        self.soloButton:setIsActiveButton(false)
        self.soloButton:setTargetPos(self.x - self.iconSpacer, 1)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + self.iconSpacer, 2)     -- result : {left:solo, center:duo, right:flour}
        
        -- set layers
        self.activeButton.layer = 1
        self.soloButton.layer = 2
        self.flourButton.layer = 3
        
      elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
        self.activeButton = self.soloButton
        self.flourButton:setIsActiveButton(false)
        self.soloButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + self.iconSpacer, 2)
        self.flourButton:setTargetPos(self.x - self.iconSpacer, 1)     -- result : {left:flour, center:solo, right:duo}
        
        -- set layers
        self.activeButton.layer = 1
        self.duoButton.layer = 3
        self.flourButton.layer = 2
        
      else                                                                    -- {left:solo, center:duo, right:flour}
        self.activeButton = self.flourButton
        self.duoButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + self.iconSpacer, 2)
        self.duoButton:setTargetPos(self.x - self.iconSpacer, 1)
        self.flourButton:setTargetPos(self.x, 1)                               -- result : {left: duo, center: flour, right: solo}
        
        -- set layers
        self.activeButton.layer = 1
        self.duoButton.layer = 2
        self.soloButton.layer = 3
        
      end      
    
      self.uiState = 'rotating'
      
    elseif key == 'left' then                      -- spin the wheel right
      if self.activeButton == self.soloButton then                             -- {left: flour, center:solo , right: duo}
        self.activeButton = self.flourButton
        self.soloButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + self.iconSpacer, 1)
        self.duoButton:setTargetPos(self.x - self.iconSpacer, 2)
        self.flourButton:setTargetPos(self.x, 1)                              -- result: {left: duo, center: flour, right: solo}
                                                                              
        -- set layers
        self.activeButton.layer = 1
        self.soloButton.layer = 2
        self.duoButton.layer = 3
        
      elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
        self.activeButton = self.duoButton
        self.flourButton:setIsActiveButton(false)
        self.duoButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x - self.iconSpacer, 2)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + self.iconSpacer, 1)     -- result: {left: solo, center: duo, right: flour}
        
        -- set layers
        self.activeButton.layer = 1
        self.soloButton.layer = 2
        self.flourButton.layer = 3
        
      else                                                                  -- {left:solo, center:duo, right:flour}
        self.activeButton = self.soloButton
        self.soloButton:setIsActiveButton(true)
        self.duoButton:setIsActiveButton(false)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + self.iconSpacer, 1)
        self.flourButton:setTargetPos(self.x - self.iconSpacer, 2)   -- result: {left: flour, center: solo, right: duo}
        
        -- set layers
        self.activeButton.layer = 1
        self.duoButton.layer = 2
        self.flourButton.layer = 3
      end

      self.uiState = 'rotating'
      
     -- stand ins for confirm/cancel button input 
    elseif key == 'z' then
      if self.activeButton == self.soloButton then
        self.uiState = 'targeting'
      else
        self.uiState = 'submenuing'
      end
    end
  elseif self.uiState == 'submenuing' then    -- the activeButton is either flourButton or duoButton
    if self.activeButton ~= self.soloButton then
      self.activeButton.displaySkillList = true
    else
      self.flourButton.displaySkillList = false
      self.duoButton.displaySkillList = false
    end

    if key == 'z' then
      self.selectedSkill = self.activeButton.selectedSkill
      self.uiState = 'targeting'
    elseif key == 'x' then
      if self.activeButton == self.soloButton then
        self.uiState = 'actionSelect'
      else  -- self.uiState == 'submenuing'
        self.uiState = 'actionSelect'
        self.activeButton.displaySkillList = false
      end
    end

  elseif self.uiState == 'targeting' then
    if self.selectedSkill.targetType == 'single' then
      -- TODO : need to account for self targeting or team targets for heals/buffs in the future
      if key == 'left' or key == 'up' then
        self.tIndex = math.max(1, self.tIndex - 1)
      elseif key == 'right' or key == 'down' then
        self.tIndex = math.min(#self.targetableEnemyPositions, self.tIndex + 1)
      elseif key == 'z' then 
        Signal.emit('move')
        self.uiState = 'moving'
      elseif key == 'x' then
        self.tIndex = 1
        if self.activeButton == self.soloButton then
          self.uiState = 'actionSelect'
        else
          self.uiState = 'submenuing'
        end
      end
    end
  end

end;

function ActionUI:gamepadpressed(joystick, button) --> void
  if self.uiState == 'actionSelect' then
    if button == 'dpright' then                         -- spin the wheel left
      if self.activeButton == self.soloButton then                            -- {left:flour, center:solo, right:duo}
        self.activeButton = self.duoButton
        self.duoButton:setIsActiveButton(true)
        self.soloButton:setIsActiveButton(false)
        self.soloButton:setTargetPos(self.x - self.iconSpacer, 1)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + self.iconSpacer, 2)     -- result : {left:solo, center:duo, right:flour}
        
        -- set layers
        self.activeButton.layer = 1
        self.soloButton.layer = 2
        self.flourButton.layer = 3
        
      elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
        self.activeButton = self.soloButton
        self.flourButton:setIsActiveButton(false)
        self.soloButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + self.iconSpacer, 2)
        self.flourButton:setTargetPos(self.x - self.iconSpacer, 1)     -- result : {left:flour, center:solo, right:duo}
        
        -- set layers
        self.activeButton.layer = 1
        self.duoButton.layer = 3
        self.flourButton.layer = 2
        
      else                                                                    -- {left:solo, center:duo, right:flour}
        self.activeButton = self.flourButton
        self.duoButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + self.iconSpacer, 2)
        self.duoButton:setTargetPos(self.x - self.iconSpacer, 1)
        self.flourButton:setTargetPos(self.x, 1)                               -- result : {left: duo, center: flour, right: solo}
        
        -- set layers
        self.activeButton.layer = 1
        self.duoButton.layer = 2
        self.soloButton.layer = 3
        
      end      
    
      self.uiState = 'rotating'
      
    elseif button == 'dpleft' then                      -- spin the wheel right
      if self.activeButton == self.soloButton then                             -- {left: flour, center:solo , right: duo}
        self.activeButton = self.flourButton
        self.soloButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + self.iconSpacer, 1)
        self.duoButton:setTargetPos(self.x - self.iconSpacer, 2)
        self.flourButton:setTargetPos(self.x, 1)                              -- result: {left: duo, center: flour, right: solo}
                                                                              
        -- set layers
        self.activeButton.layer = 1
        self.soloButton.layer = 2
        self.duoButton.layer = 3
        
      elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
        self.activeButton = self.duoButton
        self.flourButton:setIsActiveButton(false)
        self.duoButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x - self.iconSpacer, 2)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + self.iconSpacer, 1)     -- result: {left: solo, center: duo, right: flour}
        
        -- set layers
        self.activeButton.layer = 1
        self.soloButton.layer = 2
        self.flourButton.layer = 3
        
      else                                                                  -- {left:solo, center:duo, right:flour}
        self.activeButton = self.soloButton
        self.soloButton:setIsActiveButton(true)
        self.duoButton:setIsActiveButton(false)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + self.iconSpacer, 1)
        self.flourButton:setTargetPos(self.x - self.iconSpacer, 2)   -- result: {left: flour, center: solo, right: duo}
        
        -- set layers
        self.activeButton.layer = 1
        self.duoButton.layer = 2
        self.flourButton.layer = 3
      end

      self.uiState = 'rotating'
      
     -- stand ins for confirm/cancel button input 
    elseif button == self.actionButton then
      if self.activeButton == self.soloButton then
        self.uiState = 'targeting'
      else
        self.uiState = 'submenuing'
      end
    end
  elseif self.uiState == 'submenuing' then    -- the activeButton is either flourButton or duoButton
    if self.activeButton ~= self.soloButton then
      self.activeButton.displaySkillList = true
    else
      self.flourButton.displaySkillList = false
      self.duoButton.displaySkillList = false
    end

    if button == self.actionButton then
      self.selectedSkill = self.activeButton.selectedSkill
      self.uiState = 'targeting'
    elseif key == 'leftshoulder' then
      if self.activeButton == self.soloButton then
        self.uiState = 'actionSelect'
      else  -- self.uiState == 'submenuing'
        self.uiState = 'actionSelect'
        self.activeButton.displaySkillList = false
      end
    end

  elseif self.uiState == 'targeting' then
    if self.selectedSkill.targetType == 'single' then
      -- TODO : need to account for self targeting or team targets for heals/buffs in the future
      if button == 'dpleft' or button == 'dpup' then
        self.tIndex = math.max(1, self.tIndex - 1)
      elseif button == 'dpright' or button == 'dpdown' then
        self.tIndex = math.min(#self.targetableEnemyPositions, self.tIndex + 1)
      elseif button == self.actionButton then 
        self.uiState = 'moving'
      elseif button == 'leftshoulder' then
        self.tIndex = 1
        if self.activeButton == self.soloButton then
          self.uiState = 'actionSelect'
        else
          self.uiState = 'submenuing'
        end
      end
    end
  end

end;

  -- Sets the cursor to be drawn when an Enemy needs to be targeted
function ActionUI:targetEnemy(x, y)
  self.drawCursor = true
end;

function ActionUI:areDoneRotating()
  for i=1,#self.buttons do
    if not self.buttons[i]:isFinishedRotating() then
      return false
    end
  end
  return true
end;


function ActionUI:update(dt)
  if self.uiState == 'rotating' then
    for i=1,#self.buttons do
      self.buttons[i]:update(dt)
    end

    if ActionUI.areDoneRotating(self) then
      self.uiState = 'actionSelect'
    end
  end
end;
  
function ActionUI:draw()
  -- To make the wheel convincing, we have to draw the activeButton last so it appears to rotate in front of the other icons
  if self.uiState == 'targeting' then
    local target = self.targetableEnemyPositions[self.tIndex]
    love.graphics.draw(self.targetCursor, target.x + ActionUI.X_OFFSET, target.y + ActionUI.Y_OFFSET)
  elseif self.uiState ~= 'moving' then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
  
  -- if self.uiState == 'qte' then draw the qte buttons when the character is in place
end;