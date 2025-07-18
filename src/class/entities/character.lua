--! filename: Character
--[[
  Character class
  Used to create a character object, which consists of 
  a character's stats, skills, states, and gear.
]]
-- require("util.skill_sheet")
-- require("util.stat_sheet")
require("class.entities.entity")
require("class.entities.offense_state")
require("class.entities.defense_state")
require("class.ui.action_ui")
require("class.item.gear")


Class = require "libs.hump.class"
Character = Class{__includes = Entity, 
  EXP_POW_SCALE = 1.8, EXP_MULT_SCALE = 4, EXP_BASE_ADD = 10,
  -- For testing
  yPos = 110,
  xPos = 50,
  xCombatStart = -20,
  ACTION_ICON_STEM = 'asset/sprites/input_icons/xbox_double/',
  statRollsOnLevel = 1,
  combatStartEnterDuration = 0.75,
  guardActiveDur = 0.25,
  guardCooldownDur = 0.75,
  jumpDur = 0.5,
  landingLag = 0.25
}

-- Character constructor
  -- preconditions: stats dict and skills dict
  -- postconditions: Creates a valid characters
function Character:init(data, actionButton)
  self.type = 'character'
  Entity.init(self, data, Character.xCombatStart, Character.yPos)
  self.actionButton = actionButton
  self.basic = data.basic
  self.skillPool = data.skillPool
  self.blockMod = 1
  self.level = 1
  self.currentSkills = {}
  self:updateSkills()

  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15
  Entity.setAnimations(self, 'character/')
  Character.yPos = Character.yPos + 150
  -- self.currentFP = stats.fp
  -- self.currentDP = stats.dp

  self.actionUI = ActionUI()
  self.cannotLose = false
  self.equips = {}
  
  self.combatStartEnterDuration = Character.combatStartEnterDuration
  Character.combatStartEnterDuration = Character.combatStartEnterDuration + 0.1

  self.isGuarding = false
  self.canGuard = false
  self.canJump = true
  self.isJumping = false
  self.landingLag = Character.landingLag
  self.hasLCanceled = false
  self.canLCancel = false

  Signal.register('OnStartCombat',
    function()
      flux.to(self.pos, self.combatStartEnterDuration, {x = Character.xPos})
        :oncomplete(function()
          self.oPos.x = self.pos.x
          self.oPos.y = self.pos.y
        end)
    end
  )
end;

function Character:startTurn(hazards)
  Entity.startTurn(self)
  Signal.emit('OnStartTurn', self)

  for i,hazard in pairs(hazards.characterHazards) do
    hazard:proc(self)
  end
  Timer.after(0.5, function()
    self.actionUI:set(self)
  end
  )
end

function Character:endTurn()
  Entity.endTurn(self)
  self.actionUI:unset()
end;

function Character:setDefenseAnimations()
  local path = 'asset/sprites/entities/character/' .. self.entityName .. '/'
  local block = path .. 'block.png'
  local dodge = path .. 'dodge.png'
  block = love.graphics.newImage(block)
  dodge = love.graphics.newImage(dodge)

  local animations = {
    blockAnimation = self:populateFrames(block),
    dodgeAnimation = self:populateFrames(dodge),
    idleAnimation = self.movementAnimations.idle
  }
  self.defenseState.animations = animations
end;

function Character:takeDamage(amount)
  local bonusApplied = false
  if self.isGuarding then
    self.battleStats.defense = self.battleStats.defense + self.blockMod
    bonusApplied = true
  end

  Entity.takeDamage(self, amount)
  Signal.emit('OnDamageTaken', self.amount)
  -- For Status Effect that prevents KO on own turn
  if self.cannotLose and self.isFocused then
    self.battleStats['hp'] = math.max(1, self.battleStats['hp'])
  end

  if bonusApplied then
    self.battleStats.defense = self.battleStats.defense - self.blockMod
  end
end;

function Character:takeDamagePierce(amount)
  Entity.takeDamagePierce(amount)
  -- For Status Effect that prevents KO on own turn
  if self.cannotLose and self.isFocused then
    self.battleStats['hp'] = math.max(1, self.battleStats['hp'])
  end
end;

function Character:cleanse()
  -- cleanse all curses
  -- play cleanse animation
end;


function Character:setTargets(characterMembers, enemyMembers)
  print('setting targets for ', self.entityName)
  Entity.setTargets(self, characterMembers, enemyMembers)
  self.actionUI:setTargets(characterMembers, enemyMembers)
end;

--[[ Gains exp, leveling up when applicable
      - preconditions: an amount of exp to gain
      - postconditions: updates self.totalExp, self.experience, self.level, self.experienceRequired
          Continues this until self.experience is less that self.experienceRequired ]]
function Character:gainExp(amount)
  self.totalExp = self.totalExp + amount
  self.experience = self.experience + amount

  -- leveling up until exp is less than exp required for next level
  while self.experience >= self.experienceRequired do
    self.level = self.level + 1
    print(Entity:getEntityName() .. ' reached level ' .. self.level .. '!')
    self.experienceRequired = Character:getRequiredExperience()
    Character:updateSkills()
    -- TODO: need to signal to current gamestate to push new level up reward state
  end
end;

-- Gets the required exp for the next level
  -- preconditions: none
  -- postconditions: updates self.experiencedRequired based on polynomial scaling
function Character:getRequiredExperience() --> int
  local result = 0
  if self.level < 3 then
    result = self.level^Character.EXP_POW_SCALE + self.level * Character.EXP_MULT_SCALE + Character.EXP_BASE_ADD
  else
    result = self.level^Character.EXP_POW_SCALE + self.level * Character.EXP_MULT_SCALE
  end

  return result
end;

--[[ Checks for new learnable skills on lvl up from a table of the character's skills
      - preconditions: none
      - postconditions: updates self.current_skills ]]
function Character:updateSkills()
  for i,skill in pairs(self.skillPool) do
    if self.level == skill.unlockedAtLvl then
      table.insert(self.currentSkills, skill)
    end
  end
end;

function Character:applyGear()
  for i, equip in pairs(self.gear:getEquips()) do
    local statMod = equip:getStatModifiers()
    Entity:modifyBattleStat(statMod['stat'], statMod['amount'])
  end
end;


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

function Character:gamepadpressed(joystick, button)
  if self.actionUI.active then
    self.actionUI:gamepadpressed(joystick, button)
  else
    self:checkGuardAndJump(button)
  end

  -- L-Cancel
  if button == 'leftshoulder' and self.canLCancel then
    print('l-cancel success')
    self.landingLag = self.landingLag / 2
    self.hasLCanceled = true
  end
end;

function Character:gamepadreleased(joystick, button)
  if self.state == 'defense' then
    if button == 'rightshoulder' then
      self.canGuard = false
    end
  end
end;

function Character:checkGuardAndJump(button)
  if button == 'rightshoulder' and not self.isJumping then
    self.canGuard = true
  elseif button == self.actionButton then    
    if self.canGuard then
      print('gonna guard')
      self:beginGuard()
    elseif self.canJump then
      print('gonna jump')
      self:beginJump()
    end
  end
end;

function Character:beginGuard()
  self.isGuarding = true
  self.canJump = false  
  self.canGuard = false -- for cooldown
  -- print(self.entityName .. ' began guarding')

  Timer.after(Character.guardActiveDur, function()
    self.isGuarding = false
    -- print(self.entityName .. ' ended guard')
  end)

  Timer.after(Character.guardCooldownDur, function()
    self.canGuard = true
    self.canJump = true
    -- print(self.entityName .. ' came off guard cooldown')
  end)
end;

function Character:beginJump()
  self.isJumping = true
  self.canGuard = false
  self.canJump = false

  -- Goes up then down, then resets conditional checks for guard/jump
  local landY = self.pos.y
  flux.to(self.pos, Character.jumpDur/2, {y = self.pos.y - self.frameHeight})
    :after(self.pos, Character.jumpDur/2, {y = landY})
    :onupdate(function()
      if not self.hasLCanceled and landY <= self.pos.y + (self.frameHeight / 4) then
        self.canLCancel = true
        print('canLCancel')
      end
    end)
    :oncomplete(
      function()
        self.isJumping = false
        self.canJump = true
        self.landingLag = Character.landingLag
        self.canLCancel = false
        self.hasLCanceled = false
        print('finished landing')
      end):delay(self.landingLag)
end;
    
function Character:update(dt)
  Entity.update(self, dt)
  self.actionUI:update(dt)
end;

function Character:draw()
  Entity.draw(self)
  self.actionUI:draw()
end;
