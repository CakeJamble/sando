--! filename: combat_ui
require('class.solo_button')
require('class.flour_button')
require('class.duo_button')

Class = require 'libs.hump.class'
ActionUI = Class{}

  -- ActionUI constructor
    -- preconditions: name of the character
    -- postconditions: initializes action ui icons for the character
function ActionUI:init(x, y, skillList, currentFP, currentDP) -- needs enemy positions list?
-- The ActionUI position (self.x, self.y) is at the coordinates of the center of the button wheel
  self.x = x + 20 -- replace constant
  self.y = y - 45 -- replace constant
  self.uiState = 'actionSelect'
  self.iconSpacer = 50
  self.soloButton = SoloButton(self.x, self.y, skillList[1])
  self.flourButton = FlourButton(self.x - self.iconSpacer, self.y, currentFP, skillList)
  self.duoButton = DuoButton(self.x + self.iconSpacer, self.y, currentDP, skillList)
  self.buttons = {self.soloButton, self.flourButton, self.duoButton}
  self.activeButton = self.soloButton
  
  -- skill list needs to be printed on another display interface
  self.skillList = skillList
  self.selectedSkill = skillList[1]

  -- self.targets = {}
  -- TODO: to set the position of the cursor, we need a list of enemies that we can ping for their position(s)
    -- enemy class & enemy team class required for this
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
        self.soloButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 1)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 2)     -- result : {left:solo, center:duo, right:flour}
        
      elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
        self.activeButton = self.soloButton
        self.flourButton:setIsActiveButton(false)
        self.soloButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 2)
        self.flourButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 1)     -- result : {left:flour, center:solo, right:duo}
        
      else                                                                    -- {left:duo, center:flour, right:solo}
        self.activeButton = self.flourButton
        self.duoButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 2)
        self.duoButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 1)
        self.flourButton:setTargetPos(self.x, 1)                               -- result : {left: duo, center: flour, right: solo}
      end      
    
      self.uiState = 'rotating'
      
    elseif key == 'left' then                      -- spin the wheel right
      if self.activeButton == self.soloButton then                             -- {left: flour, center:solo , right: duo}
        self.activeButton = self.flourButton
        self.soloButton:setIsActiveButton(false)
        self.flourButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 1)
        self.duoButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 2)
        self.flourButton:setTargetPos(self.x, 1)                              -- result: {left: duo, center: flour, right: solo}
                                                                              
      elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
        self.activeButton = self.duoButton
        self.flourButton:setIsActiveButton(false)
        self.duoButton:setIsActiveButton(true)

        self.soloButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 2)
        self.duoButton:setTargetPos(self.x, 1)
        self.flourButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 1)     -- result: {left: solo, center: duo, right: flour}
        
      else                                                                  -- {left:solo, center:duo, right:flour}
        self.activeButton = self.soloButton
        self.soloButton:setIsActiveButton(true)
        self.duoButton:setIsActiveButton(false)

        self.soloButton:setTargetPos(self.x, 1)
        self.duoButton:setTargetPos(self.x + ActionUI.BUTTON_SPACER, 1)
        self.flourButton:setTargetPos(self.x - ActionUI.BUTTON_SPACER, 2)   -- result: {left: flour, center: solo, right: duo}
      end

      self.uiState = 'rotating'
      
     -- stand ins for confirm/cancel button input 
    elseif key == 'z' then
      self.activeButton:keypressed(key)
      if self.activeButton == 'solo' then
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
    
    self.activeButton:keypressed(key)
  
    if key == 'z' then
      self.selectedSkill = self.activeButton.selectedSkill
      self.uiState = 'targeting'
    elseif key == 'x' then
      if self.activeButton == self.soloButton then
        self.uiState = 'actionSelect'
      else  -- self.uiState == 'submenuing'
        self.uiState = 'actionSelect'
      end
    end

  elseif self.uiState == 'targeting' then -- maybe just else? maybe this is handled in button classes?
    self.targets = self.activeButton:getTargets()
    self.uiState = 'qte'
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
  if self.uiState ~= 'qte' then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
end;