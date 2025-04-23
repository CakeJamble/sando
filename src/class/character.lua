--! filename: Character
--[[
  Character class
  Used to create a character object, which consists of 
  a character's stats, skills, states, and gear.
]]
require("util.skill_sheet")
require("util.stat_sheet")
require("class.entity")
require("class.offense_state")
require("class.defense_state")
require("class.action_ui")
require("class.gear")


Class = require "libs.hump.class"
Character = Class{__includes = Entity, 
  EXP_POW_SCALE = 1.8, EXP_MULT_SCALE = 4, EXP_BASE_ADD = 10,
  -- For testing
  yPos = 200,
  xPos = 100,
  ACTION_ICON_STEM = 'asset/sprites/input_icons/xbox_double/',
}

  -- Character constructor
    -- preconditions: stats dict and skills dict
    -- postconditions: Creates a valid character
function Character:init(stats, actionButton)
  Entity.init(self, stats, Character.xPos, Character.yPos)
  self.actionButton = actionButton
  self.basic = stats.skillList[1]
  self.currentSkills = stats.skillList
  self.chosenSkill = nil
  self.level = 1
  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15
  Entity.setAnimations(self, 'character/')
  Character.yPos = Character.yPos + 150
  self.currentFP = stats.fp
  self.currentDP = stats.dp
  self.setSkill = nil

  -- temp for testing
  self.actionIcon = love.graphics.newImage(Character.ACTION_ICON_STEM .. 'xbox_button_color_' .. actionButton .. '_outline.png')
  self.actionIconDepressed = love.graphics.newImage(Character.ACTION_ICON_STEM .. 'xbox_button_color_' .. actionButton .. '.png')
  self.actionIcons = {['raised'] = self.actionIcon, ['depressed'] = self.actionIconDepressed}
  self.offenseState = OffenseState(self.x, self.y, actionButton, self.battleStats, self.actionIcons)
  self.defenseState = DefenseState(self.x, self.y, actionButton, self.battleStats['defense'], self.actionIcons)
  self.movementState = MovementState(self.x, self.y)
  self.actionUI = ActionUI()

  self.selectedSkill = nil
  self.gear = Gear()
  self.state = 'idle'
  self.enemyTargets = {}
  self.hasUsedAction = false
  self.turnFinish = false
  self.enemyCandidates = nil
  self.target = nil
  
  -- Signal.register('NextTurn',
  --   function(activeEntity)
  --     if self.isFocused then
  --       self.actionUI:set(activeEntity)
  --     else
  --       self.actionUI.active = false
  --     end
  --   end
  -- );

  Signal.register('SkillSelected',
    function(skill)
      -- self.actionUI.uiState = 'targeting'
      -- self.chosenSkill = skill
      self.offenseState:setSkill(skill)
    end
  );
  
  Signal.register('TargetSelect',
    function(enemyPositions)
      self.targetCandidates = enemyPositions
      self.actionUI:initializeTarget(enemyPositions)
    end
  );
  
  Signal.register('TargetConfirm',
    function(target)
      self.target = target
    end
  );
  
  Signal.register('MoveToEnemy',
    function(x, y)
      if self.isFocused then
        self.movementState:moveTowards(x, y, true)
        self.state = 'move'
      end
    end
  );

  Signal.register('Attack',
    function()
      if self.isFocused then
        self.state = 'offense'
      end
    end
  );

  Signal.register('MoveBack',
    function()
      if self.isFocused then
        self.movementState:moveBack()
        self.state = 'move'
      end
    end
  );

end;



function Character:registerCombatSignals(inputManager)
  -- Register signals for inputs
  Signal.register('guard', Character:Guard())
  Signal.register('jump', Character:Jump())
  Signal.register('toggle', Character:Toggle())
  --Signal.register('startTurn', Character:StartTurn)
end;

function Character:startTurn()
  self.isFocused = true
  self.actionUI:set(self)
end

function Character:endTurn()
  self.isFocused = false
  self.actionUI:unset()
end;

function Character:Guard()
end;

function Character:Jump()
end;

function Character:Toggle()
end;

function Character:StartTurn()
  --[[
    1. Setup Signals for Confirm / Cancel
    2. Load Skills to Action UI? (not currently contained here)
  ]]
  Signal.register('select', Character:Select())
  Signal.register('cancel', Character:Cancel())
end;


  -- Gains exp, leveling up when applicable
    -- preconditions: an amount of exp to gain
    -- postconditions: updates self.totalExp, self.experience, self.level, self.experienceRequired
                      -- continues this until self.experience is less that self.experienceRequired
function Character:gainExp(amount)
  self.totalExp = self.totalExp + amount
  self.experience = self.experience + amount
    
    -- leveling up until exp is less than exp required for next level
  while self.experience >= self.experienceRequired do
    self.level = self.level + 1
    print(Entity:getEntityName() .. ' reached level ' .. self.level .. '!')
    self.experienceRequired = Character:getRequiredExperience(self.level)
    Character:updateSkills(self.level)
    -- TODO: need to signal to current gamestate to push new level up reward state
  end
end;

  -- Gets the required exp for the next level
    -- preconditions: none
    -- postconditions: updates self.experiencedRequired based on polynomial scaling
function Character:getRequiredExperience(lvl) --> int
  result = 0
  if lvl < 3 then
    result = lvl^Character.EXP_POW_SCALE + lvl * Character.EXP_MULT_SCALE + Character.EXP_BASE_ADD
  else
    result = lvl^Character.EXP_POW_SCALE + lvl * Character.EXP_MULT_SCALE
  end
    
  return result
end;
  
  -- Checks for new learnable skills on lvl up from a table of the character's skills
    -- preconditions: none
    -- postconditions: updates self.current_skills
function Character:updateSkills(lvl)
  for i,skill in pairs(Entity:getSkills()) do
    if lvl == skill['unlock'] then
      table.insert(self.current_skills, skill)
      local skillLearnedMsg = Entity:getEntityName() .. ' learned the ' .. skill['attack_type'] .. ' skill: ' .. skill['skill_name'] .. '!'
      print(skillLearnedMsg)
    end
  end  
end;

function Character:getCurrentSkills() --> table
  return self.current_skills
end;

function Character:getUIState()
  return self.ui:getUIState()
end;

function Character:getGear()
  return self.gear
end

function Character:equip(equip)
  self.gear:equip(equip)
end;

function Character:unequip(equip)
  self.gear:unequip(equip)
end;

function Character:applyGear()
  for i, equip in pairs(self.gear:getEquips()) do
    local statMod = equip:getStatModifiers()
    Entity:modifyBattleStat(statMod['stat'], statMod['amount'])
  end
end;

function Character:setSelectedSkill(selectedSkill, x, y)
  self.setSkill = selectedSkill
  self.offenseState:setSkill(selectedSkill, x, y)
end;

function Character:keypressed(key)
  
  if self.state == 'offense' then
    -- set self.enemyTargets here (TODO)
    self.offenseState:keypressed(key)
  elseif self.state == 'defense' then
    self.defenseState:keypressed(key)
  elseif self.actionUI.active then
    self.actionUI:keypressed(key)
    
    if self.actionUI.uiState == 'targeting' then
      Signal.emit('Targeting', targets)
    end

  end
  -- if in movement state, does nothing
end;

function Character:gamepadpressed(joystick, button)
  if self.state == 'offense' then
    -- set self.enemyTargets here (TODO)
    self.offenseState:gamepadpressed(joystick, button)
  elseif self.state == 'defense' then
    self.defenseState:gamepadpressed(joystick, button)
  elseif self.actionUI.active then
    self.actionUI:gamepadpressed(joystick, button)
  end
  -- if in movement state, does nothing
end;
    
function Character:update(dt)
  Entity.update(self, dt)
  self.actionUI:update(dt)
  
  if self.state == 'offense' then
    self.offenseState:update(dt)
    if self.offenseState.frameCount > self.offenseState.animFrameLength then
      self.state = 'move'
      self.hasUsedAction = true
      -- self.movementState:moveBack()
      Signal.emit('MoveBack')
    end
  elseif self.state == 'defense' then
    self.defenseState:update(dt)
  elseif self.state == 'move' then
    if not self.turnFinish then 
      self.movementState:update(dt)
      self.x = self.movementState.x
      self.y = self.movementState.y
      if self.movementState.state == 'idle' and self.hasUsedAction then
        -- Emit Signal for the TurnManager to start next turn
        self.turnFinish = true
      end
    end
  end
end;

function Character:draw()
  if self.state == 'offense' then
    self.offenseState:draw()
  else 
    Entity.draw(self)
    self.actionUI:draw()
  end
end;
