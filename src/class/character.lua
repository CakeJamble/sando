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
  yPos = 100,
  xPos = 100
}

  -- Character constructor
    -- preconditions: stats dict and skills dict
    -- postconditions: Creates a valid character
function Character:init(stats, actionButton)
  Entity:init(stats, Character.xPos, Character.yPos)
  self.actionButton = actionButton
  self.fp = stats['fp']
  self.basic = {}
  self.currentSkills = Character:setBaseSkill(Entity:getSkills())
  self.level = 1
  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15
  Entity:setAnimations('character/')
  Character.yPos = Character.yPos + 150
  
  self.offenseState = OffenseState(actionButton, Entity:getBattleStats())
  self.defenseState = DefenseState(actionButton, Entity:getBattleStats()['defense'])
  
  self.selectedSkill = nil
  self.actionUI = ActionUI(Entity:getX(), Entity:getY(), current_skills)
  self.gear = Gear()
end;

  -- Sets the basic attack and the starting skill for a character
function Character:setBaseSkill(skillList)    --> void
  self.basic = skillList[1]
  local startingSkill = skillList[2]
  return startingSkill
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

function Character:getActionUI()
  return self.actionUI
end;

function Character:setSelectedSkill()
  self.selectedSkill = self.offenseState:getSkill()
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

function Character:keypressed(key)
  if key == self.actionButton then

    if self.state == 'defense' then
      self.defenseState:keypressed(key)
    elseif self.state == 'offense' then
      self.offenseState:keypressed(key)
    else  -- self.state == 'waiting' then
      print('strike a pose')
    end
    
  end
end;
    
function Character:update(dt)
  Entity:update(dt)
  if self.state == 'offense' then
    self.offenseState:update(dt)
  elseif self.state == 'defense' then
    self.defenseState:update(dt)
  end
end;

function Character:draw()
  Entity:draw()
end;
