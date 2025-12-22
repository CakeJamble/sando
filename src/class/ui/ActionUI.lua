local Button = require('class.ui.Button')
local SoloButton = require('class.ui.SoloButton')
local FlourButton = require('class.ui.FlourButton')
local DuoButton = require('class.ui.DuoButton')
local ItemButton = require('class.ui.ItemButton')
local BackButton = require('class.ui.BackButton')
local PassButton = require('class.ui.PassButton')
local JoystickUtils = require('util.joystick_utils')
local Signal = require('libs.hump.signal')
local Timer = require('libs.hump.timer')
local sortLayers = require('util.table_utils').sortLayers

local Class = require 'libs.hump.class'

---@class ActionUI
---@field ICON_SPACER integer
---@field X_OFFSET integer
---@field Y_OFFSET integer
---@field TARGET_CURSOR_PATH string
local ActionUI = Class{
  ICON_SPACER = 50,
  X_OFFSET = 20,
  Y_OFFSET = -45,
  TARGET_CURSOR_PATH = 'asset/sprites/combat/target_cursor.png'}

-- The ActionUI position (self.x, self.y) is at the coordinates of the center of the button wheel
---@param charRef Character
---@param characterMembers Character[]
---@param enemyMembers Enemy[]
function ActionUI:init(charRef, characterMembers, enemyMembers)
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
  self.selectedItem = nil
  self.soloButton = nil
  self.flourButton = nil
  self.duoButton = nil
  self.buttons = nil
  self.activeButton = nil
  self.targets = {
    ['characters'] = characterMembers,
    ['enemies'] = enemyMembers
  }
  self.targetType = 'any'
  self.tIndex = 1
  self.targetCursor = love.graphics.newImage(ActionUI.TARGET_CURSOR_PATH)
  self.buttonTweenDuration = 0.1 -- for delay after buttons set into place
  self.buttonDims = {w=32,h=32}
  self.landingPositions = nil
  self:set(charRef)
end;

---@param characterMembers Character[]
---@param enemyMembers Enemy[]
function ActionUI:setTargets(characterMembers, enemyMembers)
  self.targets = {
    ['characters'] = characterMembers,
    ['enemies'] = enemyMembers,
  }
end;

---@param charRef Character
function ActionUI:set(charRef)
  self.x = charRef.pos.x + ActionUI.X_OFFSET - charRef.pos.ox
  self.y = charRef.pos.y + ActionUI.Y_OFFSET - charRef.pos.oy
  self.pos.x = self.x - charRef.pos.ox
  self.pos.y = self.y - charRef.pos.oy
  self.skillList = charRef.currentSkills
  self.actionButton = charRef.actionButton
  self.landingPositions = self:setButtonLandingPositions()

  self.soloButton = SoloButton(self.landingPositions[1], 1, charRef.basic)
  self.flourButton = FlourButton(self.landingPositions[2], 2, charRef.currentSkills, self.actionButton)
  self.duoButton = DuoButton(self.landingPositions[3], 3, charRef.currentSkills, self.actionButton)
  self.itemButton = ItemButton(self.landingPositions[4], 4, ActionUI.consumables, self.actionButton)

  self.passButton = PassButton(self.landingPositions[5], 5, charRef.basic)
  self.buttons = {self.soloButton, self.flourButton, self.duoButton, self.itemButton, self.passButton}
  self.activeButton = self.soloButton
  sortLayers(self.buttons)

  self.backButton = BackButton(self.landingPositions[1])

  -- consider removing if you use observer pattern to refactor keypress
  self.uiState = 'actionSelect'

  -- consider removing after refactoring with Command Pattern

  -- self.selectedSkill = self.skillList[1]
  self.active = true
  self.easeType = 'linear'
end;

---@return table[]
function ActionUI:setButtonLandingPositions()
  local sideOffsets = {x = 1.5 * self.buttonDims.w, y = self.buttonDims.h / 1.5}
  local backOffsets = {x = self.buttonDims.w, y = self.buttonDims.h}
  local landingPositions = {
    {
      x     = self.x,
      y     = self.y,
      scale = 1
    },
    {
      x     = self.x - sideOffsets.x,
      y     = self.y - sideOffsets.y,
      scale = Button.SIDE_BUTTON_SCALE
    },
    {
      x     = self.x - backOffsets.x,
      y     = self.y - backOffsets.y,
      scale = Button.BACK_BUTTON_SCALE,
    },
    {
      x     = self.x + backOffsets.x,
      y     = self.y - backOffsets.y,
      scale = Button.BACK_BUTTON_SCALE,
    },
    {
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
  for _,button in ipairs(self.buttons) do
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
  self.selectedSkill = nil
  self.selectedItem = nil
end;

function ActionUI:deactivate()
  self.active = false
  print('action ui is no longer active')
end

function ActionUI:keypressed(key) --> void
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function ActionUI:gamepadpressed(joystick, button) --> void
  if self.active then
----------------------- Button Tweening ---------------------------
    if self.uiState == 'actionSelect' or self.uiState == 'submenuing' then
      if button == 'dpright' then                         -- spin the wheel left
        if self.uiState == 'submenuing' then
          self.activeButton:gamepadpressed(joystick, button)
          self.uiState = 'actionSelect'
        end
        for _,b in ipairs(self.buttons) do
          b.index = (b.index % #self.buttons) + 1
          b.layer = b:idxToLayer()
        end
        sortLayers(self.buttons)
        self:tweenButtons()
      elseif button == 'dpleft' then                      -- spin the wheel right
        if self.uiState == 'submenuing' then
          self.activeButton:gamepadpressed(joystick, button)
          self.uiState = 'actionSelect'
        end
        for _,b in ipairs(self.buttons) do
          b.index = b.index - 1
          if b.index == 0 then b.index = #self.buttons end
          b.layer = b:idxToLayer()
        end
        sortLayers(self.buttons)
        self:tweenButtons()

----------------------- Action Selection -------------------------
      elseif button == self.actionButton then
        if self.activeButton == self.passButton then
          Signal.emit('PassTurn')
        elseif self.activeButton == self.soloButton then
          self.selectedSkill = self.activeButton.selectedSkill
          self.backButton.isHidden = false
          Signal.emit('SkillSelected', self.selectedSkill)
        elseif self.activeButton == self.flourButton or self.activeButton == self.itemButton then
          self.uiState = 'submenuing'
          self.selectedSkill = self.activeButton.actionList[self.activeButton.listIndex]
          self.activeButton:gamepadpressed(joystick, button)
        end
      elseif self.uiState == 'submenuing' then
          self.activeButton:gamepadpressed(joystick, button)
      end
    elseif self.uiState == 'targeting' then
      if self.selectedSkill.isSingleTarget then
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
            self.tIndex = math.min(#self.targets, self.tIndex + 1)
          end
        elseif button == 'dpdown' then
          self.tIndex = math.min(#self.targets, self.tIndex + 1)
        elseif button == self.actionButton then
          if self.highlightBack then
            Signal.emit('SkillDeselected')
            self.highlightBack = false
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
      else
        if button == 'dpleft' then
          self.highlightBack = true
        elseif button == 'dpright' and self.highlightBack then
          self.highlightBack = false
        elseif button == self.actionButton then
          if self.highlightBack then
            Signal.emit('SkillDeselected')
            self.highlightBack = false
            if self.activeButton == self.soloButton then
              self.uiState = 'actionSelect'
            else
              self.uiState = 'submenuing'
            end
          else
            Signal.emit('TargetConfirm', self.targetType)
            self.uiState = 'moving'
          end
        end
      end
    end
  end
end;

---@param dt number
function ActionUI:update(dt)
  if input.joystick then
    if JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'right') then
      self:gamepadpressed(input.joystick, 'dpright')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'left') then
      self:gamepadpressed(input.joystick, 'dpleft')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'up') then
      self:gamepadpressed(input.joystick, 'dpup')
    elseif JoystickUtils.isAxisRepeaterTriggered(input.joystick, 'down') then
      self:gamepadpressed(input.joystick, 'dpdown')
    end
  end
end;

function ActionUI:draw()
  if self.active then
    if self.uiState == 'targeting' then
      self.backButton:draw()
      local target
      if self.highlightBack then
        target = self.backButton
      else
        target = self.targets[self.tIndex]
      end

      love.graphics.draw(self.targetCursor, target.pos.x + ActionUI.X_OFFSET, target.pos.y + ActionUI.Y_OFFSET)
    elseif self.uiState ~= 'moving' then
      for i=1,#self.buttons do
        self.buttons[i]:draw()
      end
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(self.activeButton.description,
        self.activeButton.descriptionPos.x, self.activeButton.descriptionPos.y)
      love.graphics.setColor(1, 1, 1)
    end
  end
end;

return ActionUI