--! filename: Character
--[[
  Character class
  Used to create a character object, which consists of
  a character's stats, skills, states, and gear.
]]
-- require("util.skill_sheet")
-- require("util.stat_sheet")
local SoundManager = require('class.ui.sound_manager')
local Entity = require("class.entities.entity")
local ActionUI = require("class.ui.action_ui")
local Signal = require('libs.hump.signal')
local Timer = require('libs.hump.timer')
local flux = require('libs.flux')
-- require("class.item.gear")


local Class = require "libs.hump.class"

---@class Character: Entity
---@field EXP_POW_SCALE number
---@field EXP_MULT_SCALE integer
---@field EXP_BASE_ADD integer
---@field xCombatStart integer
---@field yPos integer
---@field xPos integer
---@field yOffset integer
---@field combatStartEnterDuration number
---@field guardActiveDur number
---@field guardCooldownDur number
---@field jumpDur number
---@field landingLag number
---@field inventory Inventory
---@field canBeDebuffed boolean
---@field numEquipSlots integer
---@field numAccessorySlots integer
local Character = Class{__includes = Entity,
  EXP_POW_SCALE = 1.8, EXP_MULT_SCALE = 4, EXP_BASE_ADD = 10,
  -- For testing
  yPos = 130,
  xPos = 80,
  yOffset = 90,
  xCombatStart = -20,
  statRollsOnLevel = 1,
  combatStartEnterDuration = 0.75,
  guardActiveDur = 0.25,
  guardCooldownDur = 0.75,
  jumpDur = 0.5,
  landingLag = 0.25,
  inventory = nil,
  canBeDebuffed = true,
  numEquipSlots = 2,
  numAccessorySlots = 2
}

---@param data table
---@param actionButton string
function Character:init(data, actionButton)
  Entity.init(self, data, Character.xCombatStart, Character.yPos, "character")
  self.actionButton = actionButton
  self.basic = data.basic
  self.skillPool = data.skillPool
  self.blockMod = 1
  self.level = 1
  self.currentSkills = {}
  self:updateSkills()
  self.qteSuccess = true
  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15
  self:setAnimations()

  -- local baseSFXTypes = {'jump'}
  -- self.sfx = self:setSFX('character/', baseSFXTypes)
  Character.yPos = Character.yPos + Character.yOffset
  self.currentFP = data.fp
  -- self.currentDP = stats.dp
  self.fpCostMod = 0
  self.cannotLose = false
  self.equips = {
    equip = {},
    accessory = {}
  }
  self.numEquipSlots = Character.numEquipSlots
  self.numAccessorySlots = Character.numAccessorySlots

  self.combatStartEnterDuration = Character.combatStartEnterDuration
  Character.combatStartEnterDuration = Character.combatStartEnterDuration + 0.1

  self.isGuarding = false
  self.canGuard = false
  self.canJump = false
  self.guardCooldownFinished = true
  self.isJumping = false
  self.baseLandingLag = Character.landingLag
  self.landingLagMods = {}
  self.landingLag = Character.landingLag
  self.hasLCanceled = false
  self.canLCancel = false

  self.sfx = SoundManager(AllSounds.sfx.entities.character[self.entityName])
  Signal.register('OnEnterScene',
    function()
      flux.to(self.pos, self.combatStartEnterDuration, {x = Character.xPos})
        :oncomplete(function()
          self.oPos.x = self.pos.x
          self.oPos.y = self.pos.y
          self.canJump = true
        end)
    end
  )
end;

--[[----------------------------------------------------------------------------------------------------
        Turn Scheduling Logic
----------------------------------------------------------------------------------------------------]]

function Character:startTurn()
  Entity.startTurn(self)
  self.actionUI = ActionUI(self, self.targets.characters, self.targets.enemies)
  self.actionUI.active = true
  -- Signal.emit('OnStartTurn', self)

  -- Timer.after(0.25, function()
  --   self.actionUI:set(self)
  -- end
  -- )
end

---@param targets { [string]: Entity[]}
---@param targetType string
function Character:setTargets(targets, targetType)
  if targetType == 'any' then
    Entity.setTargets(self, targets)
    self.actionUI.targetableEntities = {
      ['characters'] = targets.characters,
      ['enemies'] = targets.enemies
    }
  else
    self.targetableEntities = targets[targetType]
    self.actionUI.targets = targets[targetType]
    self.actionUI.targetType = targetType
  end
end;

---@param duration integer
---@param stagingPos? table
---@param tweenType? string
function Character:endTurn(duration, stagingPos, tweenType)
  Entity.endTurn(self, duration, stagingPos, tweenType)
  self.actionUI:unset()
  self.actionUI = nil
  self.qteSuccess = false
  self.canJump = true
  self.canGuard = false
  Character.canBeDebuffed = true
end;

--[[----------------------------------------------------------------------------------------------------
        Stats & Statuses
----------------------------------------------------------------------------------------------------]]

---@param cost integer
function Character:validateSkillCost(cost)
  return self.currentFP >= cost - self.fpCostMod
end;

---@param cost integer
function Character:deductFP(cost)
  self.currentFP = math.min(math.max(0, cost - self.fpCostMod), self.currentFP)
end;

---@param status string
function Character:applyStatus(status)
  if Character.canBeDebuffed then
    Entity.applyStatus(self, status)
  end
end;

---@param stat string
---@param stage integer
function Character:modifyBattleStat(stat, stage)
  if stage < 0 then
    if Character.canBeDebuffed then
      Entity.modifyBattleStat(self, stat, stage)
    end
  else
    Entity.modifyBattleStat(self, stat, stage)
  end
end;

---@param pct number
function Character:raiseMaxHP(pct)
  local ratio = self.battleStats.hp / self.baseStats.hp
  local amount = math.floor(0.5 + self.baseStats.hp * pct)
  self.baseStats.hp = self.baseStats.hp + amount
  local newCurrHP = math.floor(0.5 + self.baseStats.hp * ratio)
  self.battleStats.hp = newCurrHP
end;

---@param pct number
function Character:lowerMaxHP(pct)
  self.baseStats.hp = math.floor(0.5 + self.baseStats.hp * pct)
  self.battleStats.hp = math.min(self.baseStats.hp, self.battleStats.hp)
end;

---@param amount integer
---@param attackerLuck integer
function Character:takeDamage(amount, attackerLuck)
  local bonusApplied = false
  if self.isGuarding then
    self.battleStats.defense = self.battleStats.defense + self.blockMod
    bonusApplied = true
  end

  Entity.takeDamage(self, amount, attackerLuck)
  local isDamage = true
  -- For Status Effect that prevents KO on own turn
  if self.cannotLose and self.isFocused then
    self.battleStats['hp'] = math.max(1, self.battleStats['hp'])
  end

  if bonusApplied then
    self.battleStats.defense = self.battleStats.defense - self.blockMod
  end
  Signal.emit('OnHPChanged', self.amount, isDamage, Entity.tweenHP)
  Signal.emit('OnAttacked', self)
end;

---@param amount integer
function Character:takeDamagePierce(amount)
  Entity.takeDamagePierce(self, amount)
  -- For Status Effect that prevents KO on own turn
  if self.cannotLose and self.isFocused then
    self.battleStats['hp'] = math.max(1, self.battleStats['hp'])
  end
end;

-- restores FP (similar to Entity:heal())
---@param amount integer
function Character:refresh(amount)
  self.battleStats.fp = math.min(self.baseStats.fp, self.battleStats.fp + amount)
end;

---@param additionalPenalty? integer
function Character:recoil(additionalPenalty)
  if not additionalPenalty then additionalPenalty = 0 end
  self.currentAnimTag = 'flinch'
  self.canJump = false
  local recoilTime = 0.5 + additionalPenalty
  Timer.after(recoilTime,
    function()
      self.canJump = true
      self.currentAnimTag = 'idle'
    end)
end;

---@return number
function Character:getLandingLag()
  local lag = self.baseLandingLag
  for _,mult in pairs(self.landingLagMods) do
    lag = lag * mult
  end
  return lag
end;

--[[----------------------------------------------------------------------------------------------------
        Equipped Items (Equips & Accessories)
----------------------------------------------------------------------------------------------------]]

function Character:equip(item, itemType)
  table.insert(self.equips[itemType], item)
  if item.signal == "OnEquip" then
    item.proc.equip(self)
  end
end;

---@param itemType string
---@param pos integer
---@return { [string]: any }
function Character:unequip(itemType, pos)
  local item = table.remove(self.equips[itemType], pos)
  if item.signal == "OnEquip" then
    item.proc.unequip(self)
  end
  return item
end;

---@deprecated
function Character:applyGear()
  for _, equip in pairs(self.gear:getEquips()) do
    local statMod = equip:getStatModifiers()
    Entity:modifyBattleStat(statMod['stat'], statMod['amount'])
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Leveling & Move Pool
----------------------------------------------------------------------------------------------------]]

--[[ Gains exp, leveling up when applicable
      - preconditions: an amount of exp to gain
      - postconditions: updates self.totalExp, self.experience, self.level, self.experienceRequired
          Continues this until self.experience is less that self.experienceRequired ]]
---@param amount integer
function Character:gainExp(amount)
  self.totalExp = self.totalExp + amount
  self.experience = self.experience + amount

  -- leveling up until exp is less than exp required for next level
  while self.experience >= self.experienceRequired do
    self.level = self.level + 1
    self.experienceRequired = self:getRequiredExperience()
    -- TODO: need to signal to current gamestate to push new level up reward state
  end
end;

-- Gets the required exp for the next level
  -- preconditions: none
  -- postconditions: updates self.experiencedRequired based on polynomial scaling
function Character:getRequiredExperience() --> int
  local result
  if self.level < 3 then
    result = self.level^Character.EXP_POW_SCALE + self.level * Character.EXP_MULT_SCALE + Character.EXP_BASE_ADD
  else
    result = self.level^Character.EXP_POW_SCALE + self.level * Character.EXP_MULT_SCALE
  end

  return result
end;

function Character:updateSkills()
  local result = {}
  for _,skill in pairs(self.skillPool) do
    if self.level == skill.unlockedAtLvl then
      table.insert(self.currentSkills, skill)
      table.insert(result, skill.name)
    end
  end
  return result
end;

---@param skill table
function Character:learnSkill(skill)
  table.insert(self.currentSkills, skill)
end;

---@return any
function Character:yieldSkillSelect()
  return coroutine.yield({
    routineType = "skillChoice",
    character = self
  })
end;

--[[----------------------------------------------------------------------------------------------------
        Animation
----------------------------------------------------------------------------------------------------]]

function Character:setAnimations()
  local path = 'asset/sprites/entities/character/' .. self.entityName .. '/'
  Entity.setAnimations(self, path)

  local basicSprite = love.graphics.newImage(path .. 'basic.png')
  self.animations['basic'] = self:populateFrames(basicSprite)

  self:setDefenseAnimations(path)
end;

---@param path string
function Character:setDefenseAnimations(path)
  local block = love.graphics.newImage(path .. 'block.png')
  local jump = love.graphics.newImage(path .. 'jump.png')
  self.animations['block'] = self:populateFrames(block)
  self.animations['jump'] = self:populateFrames(jump)
end;

--[[----------------------------------------------------------------------------------------------------
        Input
----------------------------------------------------------------------------------------------------]]

---@deprecated
function Character:keypressed(key)
  -- if self.state == 'offense' then
  --   self.offenseState:keypressed(key)
  -- elseif self.state == 'defense' then
  --   self.defenseState:keypressed(key)
  -- elseif self.actionUI.active then
  --   self.actionUI:keypressed(key)
  --   if self.actionUI.uiState == 'targeting' then
  --     Signal.emit('Targeting', self.targets)
  --   end
  -- end
  -- if in movement state, does nothing
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function Character:gamepadpressed(joystick, button)
  if self.actionUI and self.actionUI.active then
    self.actionUI:gamepadpressed(joystick, button)
  else
    self:checkGuardAndJump(button)
  end

  -- L-Cancel
  if button == 'leftshoulder' and self.canLCancel then
    print('l-cancel success')
    -- self.landingLag = self.landingLag / 2
    self.landingLagMods["LCancel"] = 0.5
    self.hasLCanceled = true
  end
end;

---@param joystick love.Joystick
---@param button love.GamepadButton
function Character:gamepadreleased(joystick, button)
  if button == 'rightshoulder' then
      self.canGuard = false
  end
end;

function Character:checkGuardAndJump(button)
  if self:isAlive() then
    if button == 'rightshoulder' and not self.isJumping and self.guardCooldownFinished then
      self.canGuard = true
    elseif button == self.actionButton then
      if self.canGuard then
        self:beginGuard()
      elseif self.canJump then
        self:beginJump()
      end
    end
  end
end;

function Character:beginGuard()
  self.isGuarding = true
  self.canJump = false
  self.canGuard = false -- for cooldown
  self.guardCooldownFinished = false
  local originalDefense = self.battleStats.defense
  self:modifyBattleStat('defense', 1)
  Signal.emit('OnGuard', self)

  Timer.after(Character.guardActiveDur, function()
    self.isGuarding = false
    self.battleStats.defense = originalDefense
  end)

  Timer.after(Character.guardCooldownDur, function()
    self.canJump = true
    self.guardCooldownFinished = true
    print(self.entityName .. ' is done guarding')
  end)
end;

function Character:beginJump()
  self.isJumping = true
  self.canGuard = false
  self.canJump = false

  -- Goes up then down, then resets conditional checks for guard/jump
  local landY = self.oPos.y
  local shadow = flux.to(self.shadowDims, Character.jumpDur/2, {w = self.hitbox.w / 3})
    :ease('quadout')
    :after(self.shadowDims, Character.jumpDur/2, {w = self.hitbox.w / 2})
      :ease('quadin')
  local jump = flux.to(self.pos, Character.jumpDur/2, {y = landY - self.frameHeight})
    :ease('quadout')
    :after(self.pos, Character.jumpDur/2, {y = landY})
    :ease('quadin')
    :onupdate(function()
      if not self.hasLCanceled and landY <= self.pos.y + (self.frameHeight / 4) then
        self.canLCancel = true
      end
    end)
    :oncomplete(
      function()
        local landingLag = self:getLandingLag()
        Timer.after(landingLag,
          function()
            self.isJumping = false
            self.canJump = true
            self.landingLag = Character.landingLag
            self.canLCancel = false
            self.landingLagMods["LCancel"] = nil
            self.hasLCanceled = false

          end)
      end)
  self.tweens['jump'] = jump
  self.tweens['shadow'] = shadow
  self.sfx:play("jump")
end;

function Character:interruptJump()
  local tumbleDuration = (Character.jumpDur/2)
  self:recoil(tumbleDuration)
  local landY = self.oPos.y
  self.tweens['jump']:stop()
  local tumble = flux.to(self.pos, Character.jumpDur/2, {y=landY}):ease('bouncein')
  self.tweens['tumble'] = tumble
end;

--[[----------------------------------------------------------------------------------------------------
        Update & Draw
----------------------------------------------------------------------------------------------------]]

---@param dt number
function Character:update(dt)
  Entity.update(self, dt)

  if self.isJumping then
    self.shadowDims.y = self.oPos.y + (self.frameHeight * 0.95)
  end

  if self.actionUI and self.actionUI.active then
    self.actionUI:update(dt)
  end

end;

function Character:draw()
  Entity.draw(self)
  love.graphics.setColor(1,1,1)
  if self.actionUI and self.actionUI.active then
    self.actionUI:draw()
  end
end;

return Character