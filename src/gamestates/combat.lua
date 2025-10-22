local SoundManager = require('class.ui.sound_manager')
local Entity = require('class.entities.entity')
local Projectile = require('class.entities.projectile')
local JoystickUtils = require('util.joystick_utils')

local ATBScheduler = require('class.scheduler.atb_scheduler')
local STBScheduler = require('class.scheduler.stb_scheduler')
local CTBScheduler = require('class.scheduler.ctb_scheduler')
local Signal = require('libs.hump.signal')
local Timer = require("libs.hump.timer")
local flux = require('libs.flux')
local Log = require('class.log')

local saveRun = require('util.save_run')
local saveTeam = require('util.save_team')
local generateEncounter = require('util.encounter_generator')
local imgui = require('libs.cimgui')
local ffi = require('ffi')
local showDebugWindow = false
local hitboxCheckboxState = ffi.new("bool[1]", false)
local hitboxYPosCheckboxState = ffi.new("bool[1]", false)
local tweenHPLossCheckboxState = ffi.new("bool[1]", false)
local atbSystem = ffi.new("bool[1]", false)

local combat = {}
local TEMP_BG = 'asset/sprites/background/temp-combat-bg.png'
local COMBAT_UI_PATH = 'asset/sprites/combat/'
local COMBAT_TEAM_UI_PATH = COMBAT_UI_PATH .. 'combat-team-ui.png'
local HP_HOLDER = COMBAT_UI_PATH .. 'hp-holder.png'

function combat:init()
  imgui.love.Init()
  shove.createLayer('background')
  shove.createLayer('entity', {zIndex = 10})
  shove.createLayer('ui', {zIndex = 100})
  self.background = love.graphics.newImage(TEMP_BG)
  self.combatTeamUI = love.graphics.newImage(COMBAT_TEAM_UI_PATH)
  self.hpHolder1 = love.graphics.newImage(HP_HOLDER)
  self.hpHolder2 = love.graphics.newImage(HP_HOLDER)
  self.hpUIDims = {
    x = 20,
    y = 6,
    offset = 40
  }
  self.bgYOffset = self.combatTeamUI:getHeight() * 0.75
  self.cursorX = 0
  self.cursorY = 0
  self.rewardExp = 0
  self.rewardMoney = 0
  self.enemyCount = 0
  self.enemyTeamIndex = 1
  self.characterTeamIndex = 1
  self.turnCount = 1
  self.encounteredPools = {}
  self.floorNumber = 1
  self.paused = false
  self.targetedCharacterIndex = 1

  Signal.register('TargetConfirm',
    function(targetType, tIndex)
      if targetType == 'characters' then
        self.targetedCharacterIndex = tIndex
      end
    end
  )
  Signal.register('OnHPChanged',
    function(amount, isDamage, hpIsTweened)
      local character = self.characterTeamHP[self.targetedCharacterIndex]
      local healthDropDuration = 0.5
      if hpIsTweened then
        healthDropDuration = 15
      end

      if not isDamage then
        amount = -1 * amount
        healthDropDuration = 0.5
      end

      local delay = 0.25
      local newHP = math.min(character.totalHP, math.max(0, character.currHP - amount))
      flux.to(self.characterTeamHP[self.targetedCharacterIndex], healthDropDuration, {currHP = newHP})
        :ease('linear'):delay(delay)
    end
  )
end;

---@param previous table
---@param opts table
function combat:enter(previous, opts)
  self.lockCamera = false
  self.soundManager = SoundManager(AllSounds.music)
  self.soundManager:setGlobalVolume(0.1)
  self.soundManager:play("tetris_placeholder")
  self.act = opts.act or 1
  self.floor = opts.floor or 1
  self.characterTeam = opts.team
  self.log = opts.log
  self.rewardExp = 0
  self.rewardMoney = 0

  -- HP UI
  self.characterTeamHP = {}
  for _,entity in ipairs(self.characterTeam.members) do
    table.insert(self.characterTeamHP,{
      name = entity.entityName,
      currHP = entity.battleStats.hp,
      totalHP = entity.baseStats.hp
    })
  end

  self.enemyTeam = generateEncounter(self.floorNumber)
  
  saveRun('combat',self.act,
    self.floor, self.encounteredPools, 123)
  saveTeam(self.characterTeam)

  self.turnManager = self:setTurnManager(self.characterTeam.inventory.toolManager)
  self.turnManager:enter()

  Signal.emit('OnStartCombat')
  Signal.emit('OnEnterScene')
end;

function combat:leave()
  saveRun('combat',self.act,
    self.floor, self.encounteredPools, 123)
  self.soundManager:stopAll()
end;

---@param toolManager ToolManager
---@return STBScheduler|CTBScheduler|ATBScheduler
function combat:setTurnManager(toolManager)
  local has = function(t, elem)
    for _,item in ipairs(t) do
      if item.name == elem then return true
      end
    end
    return false
  end

  local turnManager
  if has(toolManager.tools, "ATB") then
    turnManager = ATBScheduler(self.characterTeam, self.enemyTeam)
  elseif has(toolManager.tools, "CTB") then
    turnManager = CTBScheduler(self.characterTeam, self.enemyTeam)
  else
    turnManager = STBScheduler(self.characterTeam, self.enemyTeam)
  end

  return turnManager
end;

---@param key string
---@deprecated
function combat:keypressed(key)
  if key == '`' then
    showDebugWindow = not showDebugWindow
  elseif key == 'p' then
    Gamestate.push(states['pause'], self.characterTeam.inventory)
  else
    self.characterTeam:keypressed(key)
  end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function combat:gamepadpressed(joystick, button)
  if button == 'start' then
    -- Gamestate.push(states['pause'])
    self.paused = not self.paused
    if self.paused then Signal.emit("OnPause") else Signal.emit("OnResume") end
  end
  if self.turnManager and self.turnManager.qteManager.activeQTE then
    self.turnManager.qteManager:gamepadpressed(joystick, button)
  else
    self.characterTeam:gamepadpressed(joystick, button)
  end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function combat:gamepadreleased(joystick, button)
  if self.turnManager and self.turnManager.qteManager.activeQTE then
    self.turnManager.qteManager:gamepadreleased(joystick, button)
  else
    self.characterTeam:gamepadreleased(joystick, button)
  end
end;

---@param dt number
function combat:update(dt)
  if not self.paused then
    flux.update(dt)

    if self.turnManager then
      self.turnManager:update(dt)
    end
    Timer.update(dt)
    self:updateJoystick()
  end
  self:updateIMGUI(dt)
end;

-- Might interfere with QTE Joystick mechanics, circle back later to make sure
function combat:updateJoystick()
  if input.joystick then
    -- Left Stick
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

---@param dt number
function combat:updateIMGUI(dt)
  imgui.love.Update(dt)
  imgui.NewFrame()

  if showDebugWindow then
    imgui.Begin('Debug Window')

    if imgui.Checkbox("Show Hitboxes", hitboxCheckboxState) then
      Entity.drawHitboxes = hitboxCheckboxState[0]
      Projectile.drawHitboxes = hitboxCheckboxState[0]
    end

    if imgui.Checkbox("Show Hitbox Positions", hitboxYPosCheckboxState) then
      Entity.drawHitboxPositions = hitboxYPosCheckboxState[0]
    end

    if imgui.Checkbox("Gradual HP Loss", tweenHPLossCheckboxState) then
      Entity.tweenHP = tweenHPLossCheckboxState[0]
    end

    if imgui.Checkbox("ATB System", atbSystem) then
      Entity.isATB = atbSystem[0]
      for _,entity in ipairs(self.characterTeam.members) do
        entity:setProgressBarPos()
      end
      for _,entity in ipairs(self.enemyTeam.members) do
        entity:setProgressBarPos()
      end
    end

    imgui.End()
  end
end;

function combat:draw()
  shove.beginDraw()
  camera:attach()

  shove.beginLayer('background')
  love.graphics.draw(self.background, 0, self.bgYOffset, 0, 1, 1.2)
  love.graphics.draw(self.combatTeamUI, 0, 0, 0)
  for i,entity in ipairs(self.characterTeamHP) do
    local text = entity.name .. ': ' .. math.ceil(entity.currHP) .. ' / ' .. entity.totalHP
    love.graphics.print(text, self.hpUIDims.x, self.hpUIDims.y + ((i-1) * self.hpUIDims.offset))
  end
  shove.endLayer()

  shove.beginLayer('ui')
  if self.turnManager then
    self.turnManager:draw()
  end
  shove.endLayer()

  love.graphics.translate(0, self.bgYOffset)
  shove.beginLayer('entity')
  self.characterTeam:draw()
  self.enemyTeam:draw()
  shove.endLayer()

  camera:detach()
  shove.endDraw()
  imgui.Render()
  imgui.love.RenderDrawLists()
end;

--------- Overrides required to use cimgui

function combat:quit()
  imgui.love.Shutdown()
end;

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean
function combat:mousemoved(x, y, dx, dy, istouch)
  imgui.love.MouseMoved(x, y)
end;

---@param x number
---@param y number
---@param button string
---@param istouch boolean
---@param presses number
function combat:mousepressed(x, y, button, istouch, presses)
  imgui.love.MousePressed(button)
end;

---@param x number
---@param y number
---@param button string
---@param istouch boolean
---@param presses number
function combat:mousereleased(x, y, button, istouch, presses)
  imgui.love.MouseReleased(button)
end;
return combat