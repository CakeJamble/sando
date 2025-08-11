--! file: gamestates/combat
require("class.entities.enemy")
require("class.ui.action_ui")
require('gamestates.character_select')
require("util.globals")
require('class.entities.character_team')
require('class.entities.enemy_team')
require('class.input.command_manager')
-- require('class.scheduler.turn_manager')
require('class.scheduler.atb_scheduler')
require('class.scheduler.stb_scheduler')

local generateEncounter = require('util.encounter_generator')
local imgui = require('libs.cimgui')
local ffi = require('ffi')
local showDebugWindow = false
local hitboxCheckboxState = ffi.new("bool[1]", false)
local hitboxYPosCheckboxState = ffi.new("bool[1]", false)
local tweenHPLossCheckboxState = ffi.new("bool[1]", false)
local atbSystem = ffi.new("bool[1]", false)

local combat = {}
local numFloors = 50
local TEMP_BG = 'asset/sprites/background/temp-combat-bg.png'
local CHARACTER_SELECT_PATH = 'asset/sprites/character_select/'
local BAKE_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'bake_portrait.png'
local MARCO_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'marco_portrait.png'
local MARIA_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'maria_portrait.png'
local KEY_PORTRAIT_PATH = CHARACTER_SELECT_PATH .. 'key_portrait.png'
local COMBAT_UI_PATH = 'asset/sprites/combat/'
local COMBAT_TEAM_UI_PATH = COMBAT_UI_PATH .. 'combat-team-ui.png'
local HP_HOLDER = COMBAT_UI_PATH .. 'hp-holder.png'

function combat:init()
  imgui.love.Init()

  self.background = love.graphics.newImage(TEMP_BG)
  self.combatTeamUI = love.graphics.newImage(COMBAT_TEAM_UI_PATH)
  self.hpHolder1 = love.graphics.newImage(HP_HOLDER)
  self.hpHolder2 = love.graphics.newImage(HP_HOLDER)
  self.hpUIDims = {
    x = 20,
    y = 6,
    offset = 40
  }
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

  for i=1,numFloors do
    self.encounteredPools[i] = {}
  end
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
      print(self.targetedCharacterIndex)
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
      flux.to(self.characterTeamHP[self.targetedCharacterIndex], healthDropDuration, {currHP = newHP}):ease('linear'):delay(delay)
    end
  )
end;

function combat:enter(previous)
  self.lockCamera = false
  self.characterTeam = loadCharacterTeam()
  self.rewardExp = 0
  self.rewardMoney = 0

  self.characterTeamHP = {}

  for i,entity in ipairs(self.characterTeam.members) do
    table.insert(self.characterTeamHP,{
      name = entity.entityName,
      currHP = entity.battleStats.hp,
      totalHP = entity.baseStats.hp
    })
  end
  
  self.enemyTeam = generateEncounter(self.floorNumber)

  -- self.turnManager = ATBScheduler(self.characterTeam, self.enemyTeam)
  self.turnManager = STBScheduler(self.characterTeam, self.enemyTeam)
  Signal.emit('OnStartCombat')
  Signal.emit('OnEnterScene')
end;

function combat:keypressed(key)
  if key == '`' then
    showDebugWindow = not showDebugWindow
  elseif key == 'p' then
    Gamestate.push(states['pause'], self.characterTeam.inventory)
  else
    self.characterTeam:keypressed(key)
  end
end;

function combat:mousemoved(x, y, dx, dy, istouch)
  imgui.love.MouseMoved(x, y)
end;

function combat:mousepressed(x, y, button, istouch, presses)
  imgui.love.MousePressed(button)
end;

function combat:mousereleased(x, y, button, istouch, presses)
  imgui.love.MouseReleased(button)
end;

function combat:gamepadpressed(joystick, button)
  if button == 'start' then
    Gamestate.push(states['pause'])
  end
  if self.turnManager and self.turnManager.qteManager.activeQTE then
    self.turnManager.qteManager:gamepadpressed(joystick, button)
  else
    self.characterTeam:gamepadpressed(joystick, button)
  end
end;

function combat:gamepadreleased(joystick, button)
  if self.turnManager and self.turnManager.qteManager.activeQTE then
    self.turnManager.qteManager:gamepadreleased(joystick, button)
  else
    self.characterTeam:gamepadreleased(joystick, button)
  end
end;

function combat:update(dt)
  flux.update(dt)
  if self.turnManager then
    self.turnManager:update(dt)
  end
  if self.lockCamera then
    local cameraTarget = self.turnManager.activeEntity
    camera:lockWindow(cameraTarget.x, cameraTarget.y, 0, cameraTarget.x + 100, 0, cameraTarget.y + 100)
  end
  Timer.update(dt)

  -- imgui
  imgui.love.Update(dt)
  imgui.NewFrame()

  if showDebugWindow then
    imgui.Begin('Debug Window')
    
    if imgui.Checkbox("Show Hitboxes", hitboxCheckboxState) then
      Entity.drawHitboxes = hitboxCheckboxState[0]
    end

    if imgui.Checkbox("Show Hitbox Positions", hitboxYPosCheckboxState) then
      Entity.drawHitboxPositions = hitboxYPosCheckboxState[0]
    end

    if imgui.Checkbox("Gradual HP Loss", tweenHPLossCheckboxState) then
      Entity.tweenHP = tweenHPLossCheckboxState[0]
    end

    if imgui.Checkbox("ATB System", atbSystem) then
      TurnManager.isATB = atbSystem[0]
      Entity.isATB = atbSystem[0]
    end

    imgui.End()
  end

end;

function combat:draw()
  push:start()
  camera:attach()
  love.graphics.draw(self.background, 0, 0, 0, 1, 1.2)
  love.graphics.draw(self.combatTeamUI, 0, 0, 0, 1, 0.75)
  -- love.graphics.draw(self.hpHolder1, 10, 10, 0, 1, 0.75)
  -- love.graphics.draw(self.hpHolder2, 10, 50, 0, 1, 0.75)
  for i,entity in ipairs(self.characterTeamHP) do
    local text = entity.name .. ': ' .. math.ceil(entity.currHP) .. ' / ' .. entity.totalHP
    love.graphics.print(text, self.hpUIDims.x, self.hpUIDims.y + ((i-1) * self.hpUIDims.offset))
  end
  self.characterTeam:draw()
  self.enemyTeam:draw()
  if self.turnManager then
    self.turnManager:draw()
  end

  camera:detach()
  push:finish()
  imgui.Render()
  imgui.love.RenderDrawLists()
end;

function combat:quit()
  imgui.love.Shutdown()
end;
  
return combat