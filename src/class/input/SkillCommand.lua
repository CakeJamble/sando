local Command = require('class.input.Command')
local Class = require('libs.hump.class')

---@type SkillCommand
local SkillCommand = Class{__includes = Command}

---@param entity Entity
---@param qteManager? QTEManager
function SkillCommand:init(entity, qteManager)
  Command.init(self, entity)
  self.qteManager = qteManager
  self.qteResult = nil
  self.waitingForQTE = false
  self.isInterruptible = false
end

function SkillCommand:start()
  -- local qteResolve = function(isSuccess)
  --   self.entity.skill.isSuccess = isSuccess
  -- end
  -- self:registerSignal('OnQTEResolved', qteResolve)

  local projectileMade = function(projectile)
    table.insert(self.entity.projectiles, projectile)
  end
  local despawnProjectile = function(index)
    local i = index or 1
    table.remove(self.entity.projectiles, i)
  end
  self:registerSignal('ProjectileMade', projectileMade)
  self:registerSignal('DespawnProjectile', despawnProjectile)

  local endTurn = function()
    self:cleanupSignals()
    self.done = true
  end
  self:registerSignal('OnEndTurn', endTurn)

  local qteType = self.entity.skill.qteType
  if self.qteManager and qteType then
    -- Begin QTE for player skills that require it
    self.waitingForQTE = true
    self.qteManager:setQTE(qteType, self.entity.actionButton)
    self.qteManager.activeQTE:setUI(self.entity)
    self.qteManager.activeQTE:beginQTE(function(qteSuccess)
      local bonus
      if qteSuccess then
        bonus = self.getQTEBonus(self.entity.skill.qteBonus)
      end
      self.qteManager:reset()
      self:executeSkill(bonus)
    end)
  else
    self:executeSkill()
  end
end;

function SkillCommand.getQTEBonus(qteBonus)
  local result
  print(qteBonus)
  if qteBonus == 'damage' then
    result = function(damage)
      return damage + math.floor(0.5 + (0.25 * damage))
    end
  elseif qteBonus == 'burn' then
    result = function(burnChance)
      return burnChance + (burnChance * 0.25)
    end
  end
  return result
end;

function SkillCommand:executeSkill(qteBonus)
  self.entity.skill.proc(self.entity, qteBonus, self.qteManager)
end

function SkillCommand:update(dt)
  -- If waiting on QTE, update QTE manager
  if self.qteManager and self.waitingForQTE then
    self.qteManager:update(dt)
  end
end

return SkillCommand