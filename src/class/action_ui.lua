--! filename: combat_ui
--! NOTE: deprecated name? It's not an action UI anymore, it's just for Selecting the Action you want to perform
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
function ActionUI:init()
  self.active = false
  self.x = nil
  self.y = nil
  self.actionButton = nil
  self.numTargets = nil
  self.tX = nil --= targetPositions[1].x
  self.tY = nil --= targetPositions[1].y
  self.uiState  = nil--= 'actionSelect'
  self.iconSpacer = ActionUI.ICON_SPACER
  
  -- skill list and buttons
  self.skillList = nil
  self.selectedSkill = nil
  self.soloButton = nil
  self.flourButton = nil
  self.duoButton = nil
  self.buttons = nil
  self.activeButton = nil
  
  -- self.targetableEnemyPositions = targetPositions
  self.tIndex = 1
  self.targetCursor = love.graphics.newImage(ActionUI.TARGET_CURSOR_PATH)

end;

function ActionUI:set(charRef)
  self.x = charRef.x + ActionUI.X_OFFSET
  self.y = charRef.y + ActionUI.Y_OFFSET
  self.skillList = charRef.skillList
  self.soloButton = SoloButton(self.x, self.y, 1, self.skillList[1])
  self.flourButton = FlourButton(self.x - self.iconSpacer, self.y, 2, self.skillList)
  self.duoButton = DuoButton(self.x + self.iconSpacer, self.y, 3, self.skillList)
  self.buttons = {self.soloButton, self.flourButton, self.duoButton}
  self.activeButton = self.soloButton
  
  -- consider removing if you use observer pattern to refactor keypress
  self.uiState = 'actionSelect'
  
  -- consider removing after refactoring with Command Pattern
  self.actionButton = charRef.actionButton
  self.selectedSkill = self.skillList[1]
  self.active = true
end;
    
  -- Returns a table containing the position of the top left of the center icon in (x,y) coords
function ActionUI:getPos()
  return {self.x, self.y}
end;

-- Great candidate for observer pattern refactor
function ActionUI:keypressed(key) --> void
  if self.active then
  if self.uiState == 'actionSelect' then
    local before = {}
    local x = self.x
    if key == 'right' then                         -- spin the wheel left
      if self.activeButton == self.soloButton then
        before = {'flour', 'solo', 'duo'}
        self.activeButton = self.duoButton
        
      elseif self.activeButton == self.flourButton then
        before = {'duo', 'flour', 'solo'}
        self.activeButton = self.soloButton
        
      else
        before = {'solo', 'duo', 'flour'}
        self.activeButton = self.flourButton
        
      end      
      
      -- Tell all the Buttons where to go
      Signal.emit('SpinUIWheelLeft', before, x)
    
      self.uiState = 'rotating'
      
    elseif key == 'left' then                      -- spin the wheel right
      if self.activeButton == self.soloButton then                             -- {left: flour, center:solo , right: duo}
        before = {'flour', 'solo', 'duo'}
        
      elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
        before = {'duo', 'flour', 'solo'}
        self.activeButton = self.duoButton
        
      else                                                                  -- {left:solo, center:duo, right:flour}
        before = {'solo', 'duo', 'flour'}
        self.activeButton = self.soloButton        
      end
      
      Signal.emit('SpinUIWheelRight', before, x)
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
      self.selectedSkill = self.activeButton.selectedSkill  -- use signal in button class instead?
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
        -- Signal.emit('move')
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
  if self.active then
    if self.uiState == 'rotating' then
      for i=1,#self.buttons do
        self.buttons[i]:update(dt)
      end

      if ActionUI.areDoneRotating(self) then
        self.uiState = 'actionSelect'
      end
    end
  end
end;
  
function ActionUI:draw()
  if(self.active) then
      -- To make the wheel convincing, we have to draw the activeButton last so it appears to rotate in front of the other icons
    if self.uiState == 'targeting' then
      local target = self.targetableEnemyPositions[self.tIndex]
      love.graphics.draw(self.targetCursor, target.x + ActionUI.X_OFFSET, target.y + ActionUI.Y_OFFSET)
    elseif self.uiState ~= 'moving' then
      for i=1,#self.buttons do
        self.buttons[i]:draw()
      end
    end
  end
end;