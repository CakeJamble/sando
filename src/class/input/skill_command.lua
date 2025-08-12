require('class.input.command')
SkillCommand = Class{__includes = Command}

function SkillCommand:init(entity, qteManager)
  Command.init(self, entity)
  self.qteManager = qteManager

  self.done = false
  self.qteResult = nil
  self.waitingForQTE = false
  self.isInterruptible = false
end

function SkillCommand:start(turnManager)
  local qteResolve = function(isSuccess)
    self.entity.skill.isSuccess = isSuccess
  end
  self:registerSignal('OnQTEResolved', qteResolve)

  local projectileMade = function(projectile)
    table.insert(entity.projectiles, projectile)
  end
  local despawnProjectile = function(index)
    local i = index or 1
    table.remove(entity.projectiles, i)
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
    self.qteManager:setQTE(qteType, self.entity.actionButton, self.entity.skill)
    self.qteManager.activeQTE:setUI(self.entity)
    self.qteManager.activeQTE:beginQTE(function()
      -- self.qteResult = result
      -- self.waitingForQTE = false
      self:executeSkill()
    end)
  else
    self:executeSkill()
  end
end;

function SkillCommand:executeSkill()
  self.entity.skill.proc(self.entity, self.qteManager)
end

function SkillCommand:update(dt)
  -- If waiting on QTE, update QTE manager
  if self.qteManager and self.waitingForQTE then
    self.qteManager:update(dt)
  end
end

function SkillCommand:isDone()
  return self.done
end
