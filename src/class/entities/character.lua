local SoundManager = require('class.ui.SoundManager')
local Entity = require("class.entities.Entity")
local ActionUI = require("class.ui.ActionUI")
local Signal = require('libs.hump.signal')
local Timer = require('libs.hump.timer')
local flux = require('libs.flux.flux')
local statGrowthFunctions = require('util.calc_new_stats')
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
---@field actionButton string
---@field skillPool table[]
---@field blockMod integer
---@field level integer
---@field growthFunctions function[]
---@field currentSkills table[]
---@field qteSuccess boolean
---@field totalExp integer
---@field experience integer
---@field experienceRequired integer
---@field currentFP integer
---@field fpCostMod integer
---@field cannotLose boolean
---@field equips {[string]: table}
---@field isGuarding boolean
---@field canGuard boolean
---@field canJump boolean
---@field isJumping boolean
---@field landingLagMods number[]
---@field hasLCanceled boolean
---@field canLCancel boolean
---@field jumpHeight integer
---@field sfx SoundManager
---@field actionUI ActionUI
local Character = Class { __includes = Entity,
  EXP_POW_SCALE = 1.8, EXP_MULT_SCALE = 4, EXP_BASE_ADD = 10,
  -- For testing
  yPos = 500,
  xPos = 200,
  yOffset = 90,
  xCombatStart = -200,
  statRollsOnLevel = 1,
  combatStartEnterDuration = 1,
  guardActiveDur = 0.25,
  guardCooldownDur = 0.75,
  jumpDur = 0.5,
  landingLag = 0.5,
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
  self.skillPool = data.skillPool
  self.blockMod = 1
  self.level = 1
  self.growthFunctions = statGrowthFunctions[self.entityName]
  self.currentSkills = {}
  self:updateSkills()

  local animPath = "asset/sprites/entities/character/" .. self.entityName .. "/"
  self.actor = self:createActor(data.animations, animPath)
  self.actor:switch('idle')

  self.qteSuccess = true
  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15
  self.currentFP = data.fp
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
  self.jumpHeight = 100
  self.sfx = SoundManager(AllSounds.sfx.entities.character[self.entityName])

  Signal.register('OnEnterScene',
    function()
      flux.to(self.pos, self.combatStartEnterDuration, { x = Character.xPos })
          :onstart(function() self.actor:switch('run') end)
          :oncomplete(function()
            self.actor:switch('idle')
            self.canJump = true
          end)
    end
  )
end;

--[[----------------------------------------------------------------------------------------------------
        Turn Scheduling Logic
----------------------------------------------------------------------------------------------------]]

-- Sets up turn state, inits an ActionUI, and emits the `OnStartTurn` signal
function Character:startTurn()
  Entity.startTurn(self)
  self.actionUI = ActionUI(self, self.targets.characters, self.targets.enemies)
  self.actionUI.active = true
  Signal.emit('OnStartTurn', self)
end

--[[Stores a reference to all valid targets on the field to `self.targetableEntities`
in a table of the format `{characters: Character[], enemies: Enemy[]}`]]
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

--[[Deconstructs the Character's Action UI, and sets other relevant variables to
a valid state for relinquishing control to the Scheduler]]
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
---@return boolean
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

--[[Applies a stat modifier that lasts until the end of the encounter.
This function should not be used to modify HP or FP.]]
---@param stat string
---@param stage integer
---@see Entity.heal
---@see Character.takeDamage
---@see Character.takeDamagePierce
---@see Character.deductFP
---@see Character.refresh
function Character:modifyBattleStat(stat, stage)
  if stage < 0 then
    if Character.canBeDebuffed then
      Entity.modifyBattleStat(self, stat, stage)
    end
  else
    Entity.modifyBattleStat(self, stat, stage)
  end
end;

--[[Raises the Character's Max HP by a given percentage, rounding up.
Will also restore HP to maintain the previous ratio of `battleStats.hp / baseStates.hp`]]
---@param pct number
function Character:raiseMaxHP(pct)
  local ratio = self.battleStats.hp / self.baseStats.hp
  local amount = math.floor(0.5 + self.baseStats.hp * pct)
  self.baseStats.hp = self.baseStats.hp + amount
  local newCurrHP = math.floor(0.5 + self.baseStats.hp * ratio)
  self.battleStats.hp = newCurrHP
end;

--[[Raises the Character's Max HP by a given percentage, rounding up.
If Max HP falls below current HP, then current HP will be set to the new Max HP]]
---@param pct number
function Character:lowerMaxHP(pct)
  self.baseStats.hp = math.floor(0.5 + self.baseStats.hp * pct)
  self.battleStats.hp = math.min(self.baseStats.hp, self.battleStats.hp)
end;

--[[Applies damage to the Character with the following checks for modifiers
and/or state changes.

  1. Is the Character guarding?
  2. Does this damage KO the Character?
  3. Apply additional defense modifiers

After taking damage, the `OnHPChanged` & `OnAttacked` signals are emitted.]]
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

-- Applies damage to the Character, bypassing all modifiers and defenses
---@param amount integer
function Character:takeDamagePierce(amount)
  Entity.takeDamagePierce(self, amount)
  -- For Status Effect that prevents KO on own turn
  if self.cannotLose and self.isFocused then
    self.battleStats['hp'] = math.max(1, self.battleStats['hp'])
  end
end;

-- Restores FP by the amount passed in
---@param amount integer
function Character:refresh(amount)
  self.battleStats.fp = math.min(self.baseStats.fp, self.battleStats.fp + amount)
end;

function Character:removeCurses()
  self.curses = {}
end

-- Makes the Character flinch and take piercing damage (WIP)
---@param additionalPenalty? integer
function Character:recoil(additionalPenalty)
  if not additionalPenalty then additionalPenalty = 0 end
  self.currentAnimTag = 'flinch'
  self.canJump = false
  local recoilTime = 0.5 + additionalPenalty
  -- self:takeDamagePierce(amount) ??
  Timer.after(recoilTime,
    function()
      self.canJump = true
      self.currentAnimTag = 'idle'
    end)
end;

--[[ Iterates over the array of landing lag modifiers
and multiplies them to a copy of the base landing lag.]]
---@return number
function Character:getLandingLag()
  local lag = self.baseLandingLag
  for _, mult in pairs(self.landingLagMods) do
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

--[[----------------------------------------------------------------------------------------------------
        Leveling & Move Pool
----------------------------------------------------------------------------------------------------]]

--[[ Gains exp, leveling up when applicable. Updates the following:

  - `self.totalExp`
  - `self.experience`
  - `self.level`
  - `self.experienceRequired`

Continues updating `self.level` until `self.experience` is less that `self.experienceRequired`.]]
---@param amount integer
function Character:gainExp(amount)
  self.totalExp = self.totalExp + amount
  self.experience = self.experience + amount

  -- leveling up until exp is less than exp required for next level
  while self.experience >= self.experienceRequired do
    self.level = self.level + 1
    self.experienceRequired = self:getRequiredExperience()
  end
end;

--[[Increments the Character's level and boosts their stats
according to their growth functions. Preserves their HP & FP ratios.]]
---@return { string: integer } # Stats from previous level
function Character:levelUp()
  local oldStats = {}
  for stat, fcn in ipairs(self.growthFunctions) do
    oldStats[stat] = self.baseStats[stat]
    self.baseStats[stat] = fcn(self.level)

    if stat == "hp" or stat == "fp" then
      local proportion = self.battleStats[stat] / oldStats[stat]
      self.battleStats[stat] = math.floor(0.5 + (proportion * self.baseStats[stat]))
    end
  end
  return oldStats
end;

-- Gets the required exp for the next level based on polynomial scaling
---@return integer result Required amount of experience for next level up
function Character:getRequiredExperience()
  local result
  if self.level < 3 then
    result = self.level ^ Character.EXP_POW_SCALE + self.level * Character.EXP_MULT_SCALE +
        Character.EXP_BASE_ADD
  else
    result = self.level ^ Character.EXP_POW_SCALE + self.level * Character.EXP_MULT_SCALE
  end

  return result
end;

--[[Updates `self.currentSkills` and then returns a list of strings
containing the names of the skills added.]]
---@return string[]
function Character:updateSkills()
  local result = {}
  for _, skill in pairs(self.skillPool) do
    if self.level == skill.unlockedAtLvl then
      table.insert(self.currentSkills, skill)
      table.insert(result, skill.name)
    end
  end
  return result
end;

-- Adds a new skill to `self.currentSkills`, bypassing the Character's skill pool.
---@param skill table
function Character:learnSkill(skill)
  table.insert(self.currentSkills, skill)
end;

-- WIP for interaction with learning a new skill from a list of possible choices
---@return any
function Character:yieldSkillSelect()
  return coroutine.yield({
    routineType = "skillChoice",
    character = self
  })
end;

--[[----------------------------------------------------------------------------------------------------
        Defensive States (Guard, Jump)
----------------------------------------------------------------------------------------------------]]

--[[Raises the Character's defense by 1 stage, then starts 2 timers.
After the first timer ends, the defense is reverted to its original value.
After the second timer ends, the Character's guard cooldown ends.
Character's can begin a guard while jumping, but cannot begin a jump while guarding.]]
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
    if not self.isJumping then
      self.canJump = true
    end
    self.guardCooldownFinished = true
    print(self.entityName .. ' is done guarding')
  end)
end;

--[[Begins a jump, and disables jumping functionality until the landing lag after
the Character lands ends. Jumps can also be interrupted by collision.]]
---@see Character.land
---@see Character.interruptJump
function Character:beginJump()
  self.isJumping = true
  self.canJump = false
  -- Goes up then down, then resets conditional checks for guard/jump
  local landY = self.oPos.y
  local shadow = flux.to(self.shadowDims, Character.jumpDur / 2, { w = self.hitbox.w / 3 })
      :ease('quadout')
      :after(self.shadowDims, Character.jumpDur / 2, { w = self.hitbox.w / 2 })
      :ease('quadin')
  local jump = flux.to(self.pos, Character.jumpDur / 2, { y = landY - self.jumpHeight })
      :ease('quadout')
      :onstart(function() self.actor:switch('jump') end)
      :after(self.pos, Character.jumpDur / 2, { y = landY })
      :onstart(function() self.actor:switch('fall') end)
      :ease('quadin')
      :onupdate(function()
        if not self.hasLCanceled and landY <= self.pos.y + (self.jumpHeight / 4) then
          self.canLCancel = true
        end
      end)
      :oncomplete(function() self:land() end)
  self.tweens['jump'] = jump
  self.tweens['shadow'] = shadow
  self.sfx:play("jump")
end;

--[[Sets the playback speed for the landing animation based on
`self.baseLandingLag` & `self.landingLagMods`.
Performing a Fall-Cancel will hasten the duration of the landing state.]]
---@see Character.getLandingLag
function Character:land()
  local landingLag = self:getLandingLag()
  local land = self.actor:getAnimation('land')

  -- Sync landing animation with landing lag
  land:setDelay(landingLag / land:getSize())
  self.actor:switch('land')

  -- Squash on land
  flux.to(self.pos, 0.125, { sy = 0.4 })
      :ease('quadout')
      :after(0.125, { sy = 0.5 })
      :ease('quadin')
  Timer.after(landingLag,
    function()
      self.isJumping = false
      self.canJump = true
      self.landingLag = Character.landingLag
      self.canLCancel = false
      self.landingLagMods["LCancel"] = nil
      self.hasLCanceled = false
      self.actor:switch('idle')
    end)
end

--[[Usually invoked upon collision, this will stop the progress of a jump and
place the Character into a tumbling state. Fall-Cancel checks are still applied.]]
function Character:interruptJump()
  local tumbleDuration = (Character.jumpDur / 2)
  self:recoil(tumbleDuration)
  local landY = self.oPos.y
  self.tweens['jump']:stop()
  local tumble = flux.to(self.pos, Character.jumpDur / 2, { y = landY }):ease('bouncein')
      :onupdate(function()
        if not self.hasLCanceled and landY <= self.pos.y + (self.jumpHeight / 4) then
          self.canLCancel = true
        end
      end)
      :oncomplete(function() self:land() end)
  self.tweens['tumble'] = tumble
end;

--[[----------------------------------------------------------------------------------------------------
        Input
----------------------------------------------------------------------------------------------------]]

---@param dt number
function Character:updateInput(dt)
  -- Check guard toggle
  if Player:pressed('guardToggle') then
    self.isGuardToggled = not self.isGuardToggled
    -- Check guard & jump
  elseif Player:pressed(self.actionButton) then
    if self.isGuardToggled or Player:down("guard") and self.canGuard then
      self:beginGuard()
    elseif self.canJump then
      self:beginJump()
    end
  elseif Player:released("guard") and not self.isGuardToggled then
    self.canGuard = false
    -- Check L-Cancel
  elseif Player:pressed("fallCancel") and self.canLCancel then
    self.landingLagMods["LCancel"] = 0.5
    self.hasLCanceled = true
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Animation
----------------------------------------------------------------------------------------------------]]
--[[Creates all skill animations from the Character's `self.currentSkills` table.
This is to avoid slowing down an initial load of skills that may never be used.]]
---@param dir string The directory where animations are located
---@param actor table Reference to eh AnimX actor object housing animations
function Character:createSkillAnimations(dir, actor)
  for _, skill in ipairs(self.currentSkills) do
    local skillPath = dir .. skill.tag .. "/"
    for _, name in ipairs(skill.animations) do
      local path = skillPath .. name .. ".png"
      local fullName = skill.tag .. "_" .. name -- ex: needle_stab & wind_up -> needle_stab_wind_up
      local animation = animx.newAnimation(path)
      if name == "wobble" or "wobble_fail" then
        animation:loop()
      end
      actor:addAnimation(fullName, animation)
    end
  end
end;

--[[----------------------------------------------------------------------------------------------------
        Update & Draw
----------------------------------------------------------------------------------------------------]]

---@param dt number
function Character:update(dt)
  Entity.update(self, dt)
  if self.actionUI and self.actionUI.active then
    self.actionUI:update(dt)
  else
    self:updateInput(dt)
  end

  if self.isJumping then
    self.shadowDims.y = self.oPos.y + (self.jumpHeight * 0.95) - self.pos.oy
  end
end;

function Character:draw()
  Entity.draw(self)
  love.graphics.setColor(1, 1, 1)
  if self.actionUI and self.actionUI.active then
    self.actionUI:draw()
  end
end;

return Character
