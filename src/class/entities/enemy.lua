local Entity = require("class.entities.Entity")
local Signal = require('libs.hump.signal')
local Class = require('libs.hump.class')
local flux = require('libs.flux')
local starParticles = require('asset.particle.ko')
local Timer = require('libs.hump.timer')
local SoundManager = require('class.ui.SoundManager')

---@class Enemy: Entity
---@field xPos integer
---@field yPos integer
---@field yOffset integer
---@field enemyType string `common`, `elite`, or `boss`
---@field expReward integer
---@field moneyReward integer
---@field lootReward {[string]: number}
---@field procAI function
---@field sfx SoundManager
---@field phaseData table Current phase of Enemy. Nil if not a multiphase Enemy
local Enemy = Class { __includes = Entity,
  -- for testing
  xPos = 450, yPos = 150, yOffset = 90 }

---@param data table
function Enemy:init(data)
  self.enemyType = data.enemyType
  Entity.init(self, data, Enemy.xPos, Enemy.yPos, "enemy")
  local animPath = "asset/sprites/entities/enemy/" .. self.entityName .. "/"
  self.actor = self:createActor(data.animations, animPath)
  self.actor:switch('idle')
  self.expReward = data.experienceReward
  self.moneyReward = data.moneyReward
  self.lootReward = self.setRewardsDistribution(data.rewardsDistribution)
  self.procAI = data.ai
  Enemy.yPos = Enemy.yPos + Enemy.yOffset
  self.sfx = SoundManager(AllSounds.sfx.entities.enemy[self.entityName])
  self.isMultiphase = data.isMultiphase or false
  self.phaseData = data.phaseData

  Signal.register('OnStartCombat',
    function()
      self.oPos.x = self.pos.x
      self.oPos.y = self.pos.y
    end)
end;

-- Sets valid targets
---@param targets { [string]: Entity[] }
---@param targetType string
function Enemy:setTargets(targets, targetType)
  if targetType == 'any' then
    Entity.setTargets(self, targets)
  else
    self.targetableEntities = targets[targetType]
  end
end;

-- WIP Basic piercing damage with disappearing on KO
---@param amount integer
function Enemy:takeDamagePierce(amount)
  Entity.takeDamagePierce(self, amount)
  if self.currentAnimTag == 'ko' then
    flux.to(self.pos, 1.5, { a = 0 })
  end
end;

-- WIP Basic fainting
function Enemy:startFainting()
  Entity.startFainting(self)
  flux.to(self.pos, 1.5, { a = 0 })
  self.sfx:play("ko")
end;

---@param rewardsDistribution integer[]
---@return { [string]: integer}
function Enemy.setRewardsDistribution(rewardsDistribution)
  return {
    uncommon = rewardsDistribution[1],
    rare = rewardsDistribution[2]
  }
end;

--[[Uses behavior tree defined in their logic file to select an action on their turn.
After an action is selected, emits the `TargetConfirm` signal.]]
---@param validTargets table{ characters: Character[], enemies: Enemy[] }
function Enemy:setupOffense(validTargets)
  self.targets, self.skill = self.procAI(self, validTargets)
  Signal.emit('TargetConfirm')
end;

-- Initiates a phase change when conditions are met
function Enemy:checkPhase()
  local currentPhase = self.phaseData.phase
  if self.phaseData.isMultiphase then
    self.phaseData.phase = self.phaseData:check()
  end

  if self.phaseData.phase ~= currentPhase then
    Signal.emit("OnPhaseChange", self)
  end
end;

---@deprecated
---@param targetType string
---@param  isSingleTarget boolean
function Enemy:targetSelect(targetType, isSingleTarget)
  local targets = {}

  if isSingleTarget then
    local tIndex = love.math.random(1, #self.targetableEntities)
    table.insert(targets, self.targetableEntities[tIndex])
  else
    for _, entity in ipairs(self.targetableEntities) do
      table.insert(targets, entity)
    end
  end

  return targets
end;

---@deprecated Should be using ai logic files (or decision trees)
---@param skillPool table
---@param numValidTargets integer
function Enemy.getRandomSkill(skillPool, numValidTargets)
  local skill

  if numValidTargets == 1 then
    local singleTargetSkills = {}
    for _, s in ipairs(skillPool) do
      if s.isSingleTarget then
        table.insert(singleTargetSkills, s)
      end
    end

    local i = love.math.random(1, #singleTargetSkills)
    skill = singleTargetSkills[i]
  else
    local i = love.math.random(1, #skillPool)
    skill = skillPool[i]
  end

  return skill
end;

---@return table
function Enemy:getRewards()
  local reward = {
    exp = self.expReward,
    money = self.moneyReward,
    rarities = self.lootReward -- table(uncommon: number, rare: number)
  }
  return reward
end;

return Enemy
