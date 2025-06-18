--! filename: Enemy
require ("util.stat_sheet")
require("util.skill_sheet")
require("class.entity")
require("util.enemy_list")
require("util.enemy_skill_list")
require('class.enemy_offense_state')

Class = require "libs.hump.class"
Enemy = Class{__includes = Entity, 
  -- for testing
  xPos = 450, yPos = 110}

function Enemy:init(enemyName, enemyType)
  self.type = 'enemy'
  Entity.init(self, getStatsByName(enemyName, enemyType), Enemy.xPos, Enemy.yPos)
  Entity.setAnimations(self, enemyType .. '/')
  self.expReward = self.baseStats['experienceReward']
  self.moneyReward = self.baseStats['moneyReward']
  self.lootReward = self.baseStats.rewardsDistribution
  self.selectedSkill = nil
  self.offenseState = EnemyOffenseState(self.x, self.y, self.battleStats)
  Enemy.yPos = Enemy.yPos + 150
end;

function Enemy:setupOffense()
  -- pick a random skill
  local skillIndex = love.math.random(1, #self.skillList)
  self.selectedSkill = self.skillList[skillIndex]
  self.offenseState:setSkill(self.selectedSkill)

  -- pick a random target
  local tIndex = love.math.random(1, #self.targets.characters)
  Signal.emit('TargetConfirm', 'characters', tIndex)
end;

function Enemy:knockOut()
  local reward = {}
  reward.exp = self.expReward
  reward.money = self.moneyReward
  reward.loot = self.lootReward
  return reward
end;

-- function Enemy:randPickLoot(lootPool)
--   if not lootPool then return end
--   local lootType = lootPool[math.random(1, #lootPool)]
--   local lootIndex = lootType[math.random(1, #lootPool.lootType)]
--   local lootDict = lootPool.lootType[lootIndex]
--   local loot = {}
--   if lootType == 'gear' then
--     loot = Gear(lootDict)
--   elseif lootType == 'consumable' then
--     loot = Consumable(lootDict)
--   else -- lootType == 'tool'
--     loot = Tool(lootDict)
--   end
--   return loot
-- end;

function Enemy:update(dt)
  Entity.update(self, dt)
  if self.state == 'offense' then
    self.offenseState:update(dt)
    if self.offenseState.frameCount > self.offenseState.animFrameLength then
      self.state = 'move'
      self.hasUsedAction = true
      Signal.emit('MoveBack')
    end
  elseif self.state == 'move' or self.state == 'moveback' then
    if not self.turnFinish then
      self.movementState:update(dt)
      self.x = self.movementState.x
      self.y = self.movementState.y
      if self.isFocused and self.movementState.state == 'idle' and self.hasUsedAction then
        self:endTurn()
        Signal.emit('NextTurn')
      end
    end
  end
end;

function Enemy:draw()
  if self.state == 'offense' then
    self.offenseState:draw()
  else
    Entity.draw(self)
  end
end;
