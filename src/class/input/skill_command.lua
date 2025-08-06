require('class.input.command')
SkillCommand = Class{__includes = Command}

function SkillCommand:init(entity, target, skill, qteManager)
  Command.init(self, entity)
  self.actor = entity
  self.target = target
  self.skill = skill
  self.qteManager = qteManager

  self.done = false
  self.qteResult = nil
  self.waitingForQTE = false
  self.isInterruptible = false
  self.signalHandlers = {}
end

function SkillCommand:start(turnManager)
  self.signalHandlers.qteSuccess = function(isSuccess)
    self.skill.isSuccess = isSuccess
  end
  Signal.register('OnQTEResolved', self.signalHandlers.qteSuccess)

  self.signalHandlers.projectileMade = function(projectile)
    table.insert(entity.projectiles)
  end
  self.signalHandlers.despawnProjectile = function(index)
    local i = index or 1
    table.remove(entity.projectiles, i)
  end
  Signal.register('ProjectileMade', self.signalHandlers.projectileMade)
  Signal.register('DespawnProjectile', self.signalHandlers.despawnProjectile)

  self.signalHandlers.endTurn = function()
    self:cleanupSignals()
    self.done = true
  end
  Signal.register('OnEndTurn', self.signalHandlers.endTurn)

  if self.qteManager and self.skill.qteType then
    -- Begin QTE for player skills that require it
    self.waitingForQTE = true
    self.qteManager:setQTE(self.skill.qteType, self.entity.actionButton, self.skill)
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

function SkillCommand:cleanupSignals()
  Signal.remove('ProjectileMade', self.signalHandlers.projectileMade)
  Signal.remove('DespawnProjectile', self.signalHandlers.despawnProjectile)
  Signal.remove('OnEndTurn', self.signalHandlers.endTurn)
  Signal.remove('OnQTEResolved', self.signalHandlers.qteSuccess)
end;

function SkillCommand:executeSkill()
  self.skill.proc(self.entity, self.qteManager)
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
