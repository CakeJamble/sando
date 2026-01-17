local SoundManager = require('class.ui.SoundManager')
local Entity = require("class.entities.Entity")
local ActionUI = require("class.ui.ActionUI")
local Signal = require('libs.hump.signal')
local Timer = require('libs.hump.timer')
local flux = require('libs.flux.flux')
local statGrowthFunctions = require('util.calc_new_stats')
local Class = require "libs.hump.class"
local animx = require('libs.animx')

---@type Character
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

function Character:startTurn()
  Entity.startTurn(self)
  self.actionUI = ActionUI(self, self.targets.characters, self.targets.enemies)
  self.actionUI.active = true
  Signal.emit('OnStartTurn', self)
end

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

function Character:validateSkillCost(cost)
  return self.currentFP >= cost - self.fpCostMod
end;

function Character:deductFP(cost)
  self.currentFP = math.min(math.max(0, cost - self.fpCostMod), self.currentFP)
end;

function Character:applyStatus(status)
  if Character.canBeDebuffed then
    Entity.applyStatus(self, status)
  end
end;

function Character:modifyBattleStat(stat, stage)
  if stage < 0 then
    if Character.canBeDebuffed then
      Entity.modifyBattleStat(self, stat, stage)
    end
  else
    Entity.modifyBattleStat(self, stat, stage)
  end
end;

function Character:raiseMaxHP(pct)
  local ratio = self.battleStats.hp / self.baseStats.hp
  local amount = math.floor(0.5 + self.baseStats.hp * pct)
  self.baseStats.hp = self.baseStats.hp + amount
  local newCurrHP = math.floor(0.5 + self.baseStats.hp * ratio)
  self.battleStats.hp = newCurrHP
end;

function Character:lowerMaxHP(pct)
  self.baseStats.hp = math.floor(0.5 + self.baseStats.hp * pct)
  self.battleStats.hp = math.min(self.baseStats.hp, self.battleStats.hp)
end;

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

function Character:takeDamagePierce(amount)
  Entity.takeDamagePierce(self, amount)
  -- For Status Effect that prevents KO on own turn
  if self.cannotLose and self.isFocused then
    self.battleStats['hp'] = math.max(1, self.battleStats['hp'])
  end
end;

function Character:refresh(amount)
  self.battleStats.fp = math.min(self.baseStats.fp, self.battleStats.fp + amount)
end;

function Character:removeCurses()
  self.curses = {}
end

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

function Character:gainExp(amount)
  self.totalExp = self.totalExp + amount
  self.experience = self.experience + amount

  -- leveling up until exp is less than exp required for next level
  while self.experience >= self.experienceRequired do
    self.level = self.level + 1
    self.experienceRequired = self:getRequiredExperience()
  end
end;

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

function Character:learnSkill(skill)
  table.insert(self.currentSkills, skill)
end;

function Character:yieldSkillSelect()
  return coroutine.yield({
    routineType = "skillChoice",
    character = self
  })
end;

--[[----------------------------------------------------------------------------------------------------
        Defensive States (Guard, Jump)
----------------------------------------------------------------------------------------------------]]

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
