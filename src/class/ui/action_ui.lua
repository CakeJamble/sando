--! filename: combat_ui
require('class.ui.solo_button')
require('class.ui.flour_button')
require('class.ui.duo_button')
require('class.ui.item_button')
require('class.ui.back_button')
require('class.ui.pass_button')
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
  self.pos = {x=self.x,y=self.y}
  self.actionButton = nil
  self.numTargets = nil
  self.uiState  = nil
  self.iconSpacer = ActionUI.ICON_SPACER

  self.skillList = nil
  self.selectedSkill = nil
  self.soloButton = nil
  self.flourButton = nil
  self.duoButton = nil
  self.buttons = nil
  self.activeButton = nil
  self.targets = {}
  self.targetType = 'enemies'
  self.tIndex = 1
  self.targetCursor = love.graphics.newImage(ActionUI.TARGET_CURSOR_PATH)
  self.buttonTweenDuration = 0.1 -- for delay after buttons set into place
  self.buttonDims = {w=32,h=32}
  self.landingPositions = nil
end;

function ActionUI:setTargets(characterMembers, enemyMembers)
  self.targets = {
    ['characters'] = characterMembers,
    ['enemies'] = enemyMembers,
  }
end;

function ActionUI:set(charRef)
  self.x = charRef.pos.x + ActionUI.X_OFFSET
  self.y = charRef.pos.y + ActionUI.Y_OFFSET
  self.pos.x = self.x
  self.pos.y = self.y
  self.skillList = charRef.currentSkills
  self.actionButton = charRef.actionButton
  self.landingPositions = self:setButtonLandingPositions()

  self.soloButton = SoloButton(self.landingPositions[1], 1, charRef.basic)
  self.flourButton = FlourButton(self.landingPositions[2], 2, charRef.currentSkills, self.actionButton)
  self.duoButton = DuoButton(self.landingPositions[3], 3, self.skillList)
  self.itemButton = ItemButton(self.landingPositions[4], 4, {})

  self.passButton = PassButton(self.landingPositions[5], 5, charRef.basic)
  self.buttons = {self.soloButton, self.flourButton, self.duoButton, self.itemButton, self.passButton}
  self.activeButton = self.soloButton
  sortLayers(self.buttons)
  
  self.backButton = BackButton(self.landingPositions[1])

  -- consider removing if you use observer pattern to refactor keypress
  self.uiState = 'actionSelect'
  
  -- consider removing after refactoring with Command Pattern

  self.selectedSkill = self.skillList[1]
  self.active = true
  self.easeType = 'linear'
end;

function ActionUI:setButtonLandingPositions()
  local sideOffsets = {x = 1.5 * self.buttonDims.w, y = self.buttonDims.h / 1.5}
  local backOffsets = {x = self.buttonDims.w, y = self.buttonDims.h}
  local landingPositions = {
    { -- 1
      x     = self.x, 
      y     = self.y,
      scale = 1
    },
    { -- 2
      x     = self.x - sideOffsets.x, 
      y     = self.y - sideOffsets.y,
      scale = Button.SIDE_BUTTON_SCALE
    },
    { -- 3
      x     = self.x - backOffsets.x,
      y     = self.y - backOffsets.y,
      scale = Button.BACK_BUTTON_SCALE,
    },
    { -- 4
      x     = self.x + backOffsets.x,
      y     = self.y - backOffsets.y,
      scale = Button.BACK_BUTTON_SCALE,
    },
    { -- 5
      x     = self.x + sideOffsets.x,
      y     = self.y - sideOffsets.y,
      scale = Button.SIDE_BUTTON_SCALE,
    },
  }
  return landingPositions
end;

-- button indexes and layers get changed before this tween goes off, so we know where they will land
function ActionUI:tweenButtons()
  self.uiState = 'rotating'

  for i,button in ipairs(self.buttons) do
    local landingPos = self.landingPositions[button.index]
    button:tween(landingPos, self.buttonTweenDuration, self.easeType)
    if button.index == 1 then self.activeButton = button end
  end

  Timer.after(self.buttonTweenDuration + 0.1, 
    function() 
      self.uiState = 'actionSelect'
    end)
end;

function ActionUI:unset()
  self.x = nil; self.y = nil; self.skillList = nil;
  self.soloButton = nil; self.flourButton = nil; self.duoButton = nil;
  self.itemButton = nil; self.passButton = nil;
  self.buttons = nil; self.activeButton = nil;
  self.landingPositions = nil
  self.isFocused = false
  self.active = false
end;

function ActionUI:keypressed(key) --> void
  if self.active then
    if self.uiState == 'actionSelect' then
      local before = ''
      local x = self.x
      if key == 'right' then                         -- spin the wheel left
        if self.activeButton == self.soloButton then
          before = 'fsd'
          self.activeButton = self.duoButton
          
        elseif self.activeButton == self.flourButton then
          before = 'dfs'
          self.activeButton = self.soloButton
          
        else
          before = 'sdf'
          self.activeButton = self.flourButton
          
        end      
        
        -- Tell all the Buttons where to go
        Signal.emit('SpinUIWheelLeft', before, x)
        self.uiState = 'rotating'
        
      elseif key == 'left' then                      -- spin the wheel right
        if self.activeButton == self.soloButton then                             -- {left: flour, center:solo , right: duo}
          before = 'fsd'
          self.activeButton = self.flourButton
          
        elseif self.activeButton == self.flourButton then                       -- {left:duo, center:flour, right:solo}
          before = 'dfs'
          self.activeButton = self.duoButton
          
        else                                                                  -- {left:solo, center:duo, right:flour}
          before = 'sdf'
          self.activeButton = self.soloButton        
        end
      
        Signal.emit('SpinUIWheelRight', before, x)
        self.uiState = 'rotating'
        
       -- stand ins for confirm/cancel button input 
      elseif key == 'z' then
        if self.activeButton == self.soloButton then
          self.selectedSkill = self.activeButton.selectedSkill
          self.uiState = 'targeting'
          Signal.emit('SkillSelected', self.selectedSkill)
        else -- the activeButton is either flourButton or duoButton
          self.uiState = 'submenuing'
          self.activeButton.displaySkillList = true
          self.activeButton:keypressed(key)
        end
      end
    elseif self.uiState == 'submenuing' then
      self.activeButton:keypressed(key)

    elseif self.uiState == 'targeting' then
      if self.selectedSkill.targetType == 'single' then
        -- TODO : need to account for self targeting or team targets for heals/buffs in the future
        if key == 'left' then
          self.highlightBack = true
        elseif key == 'up' then
          self.tIndex = math.max(1, self.tIndex - 1)
        elseif key == 'right' then
          if self.highlightBack then
            self.highlightBack = false
          end
        elseif key == 'down' then
          self.tIndex = math.min(#self.targets[self.targetType], self.tIndex + 1)
        elseif key == 'z' then
          print(self.targetType, self.tIndex)
          Signal.emit('TargetConfirm', self.targetType, self.tIndex)
          self.uiState = 'moving'
        elseif key == 'x' then
          self.tIndex = 1
          if self.activeButton == self.soloButton then
            self.uiState = 'actionSelect'
            Signal.emit('SkillDeselected')
          else
            self.uiState = 'submenuing'
          end
        end
      end
    end
  end
end;

function ActionUI:gamepadpressed(joystick, button) --> void
  if self.active then

----------------------- Button Tweening ---------------------------
    if self.uiState == 'actionSelect' then
      if button == 'dpright' then                         -- spin the wheel left
        for i,button in ipairs(self.buttons) do
          button.index = (button.index % #self.buttons) + 1
          button.layer = button:idxToLayer()
        end
        sortLayers(self.buttons)
        self:tweenButtons()
      elseif button == 'dpleft' then                      -- spin the wheel right
        for i,button in ipairs(self.buttons) do
          button.index = button.index - 1
          if button.index == 0 then button.index = #self.buttons end
          button.layer = button:idxToLayer()
        end
        sortLayers(self.buttons)
        self:tweenButtons()

----------------------- Skill Selection -------------------------
      elseif button == self.actionButton then
        if self.activeButton == self.passButton then
          Signal.emit('PassTurn')
        elseif self.activeButton == self.soloButton then
          self.selectedSkill = self.activeButton.selectedSkill
          self.uiState = 'targeting'
          self.backButton.isHidden = false
          Signal.emit('SkillSelected', self.selectedSkill)
        else
          self.uiState = 'submenuing'
          self.activeButton:gamepadpressed(joystick, button)
        end
      end
    elseif self.uiState == 'submenuing' then    -- the activeButton is either flourButton or duoButton
      self.activeButton:gamepadpressed(joystick, button)
    elseif self.uiState == 'targeting' then
      if self.selectedSkill.targetType == 'single' then
        -- TODO : need to account for self targeting or team targets for heals/buffs in the future
        if button == 'dpleft' then
          if self.tIndex == 1 then
            self.highlightBack = true
          else
            self.tIndex = math.max(1, self.tIndex - 1)
          end
        elseif button == 'dpup' then
          self.tIndex = math.max(1, self.tIndex - 1)
        elseif button == 'dpright' then
          if self.highlightBack then
            self.highlightBack = false
          else
            self.tIndex = math.min(#self.targets[self.targetType], self.tIndex + 1)
          end
        elseif button == 'dpdown' then
          self.tIndex = math.min(#self.targets[self.targetType], self.tIndex + 1)
        elseif button == self.actionButton then 
          if self.highlightBack then
            Signal.emit('SkillDeselected')

            if self.activeButton == self.soloButton then
              self.uiState = 'actionSelect'
            else
              self.uiState = 'submenuing'
            end

          else
            Signal.emit('TargetConfirm', self.targetType, self.tIndex)
            self.uiState = 'moving'
          end
        end
      end
    end
  end
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
--   if self.active then
--     if self.uiState == 'rotating' then
--       for i=1,#self.buttons do
--         local button = self.buttons[i]
--         button:update(dt)
--       end

--       if ActionUI.areDoneRotating(self) then
--         self.uiState = 'actionSelect'
--       end
--     end
--   end
end;

function ActionUI:draw()
  if(self.active) then
      -- To make the wheel convincing, we have to draw the activeButton last so it appears to rotate in front of the other icons
    if self.uiState == 'targeting' then
      self.backButton:draw()
      local target
      if self.highlightBack then
        target = self.backButton
      else
        target = self.targets[self.targetType][self.tIndex]
      end

      love.graphics.draw(self.targetCursor, target.pos.x + ActionUI.X_OFFSET, target.pos.y + ActionUI.Y_OFFSET)
    elseif self.uiState ~= 'moving' then
      for i=1,#self.buttons do
        self.buttons[i]:draw()
      end
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(self.activeButton.description, self.activeButton.descriptionPos.x, self.activeButton.descriptionPos.y)
      love.graphics.setColor(1, 1, 1)
    end
  end
end;