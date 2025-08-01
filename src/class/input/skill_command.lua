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
end

function SkillCommand:start(turnManager)
  if self.entity.type == 'character' and self.skill.qteType then
    -- Begin QTE for player skills that require it
    self.waitingForQTE = true
    self.qteManager:setQTE(self.skill.qteType, self.entity.actionButton, self.skill)
    self.qteManager.activeQTE:setUI(self.entity)
    self.qteManager.activeQTE:beginQTE(function()
      -- self.qteResult = result
      self.waitingForQTE = false
      self:executeSkill()
    end)
  else
    self:executeSkill()
  end
end;

function SkillCommand:executeSkill()
  self.skill.proc(self.entity, self.qteManager)
  self.done = true
end

function SkillCommand:update(dt)
  -- If waiting on QTE, update QTE manager
  if self.waitingForQTE then
    self.qteManager:update(dt)
  end
end

function SkillCommand:isDone()
  return self.done
end
