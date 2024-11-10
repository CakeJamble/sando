--! file: Character
require("skill_sheet")
require("stat_sheet")
require("entity")
require("offense_state")


local class = require 'libs/middleclass'
Character = class('Character', Entity)



-- Integers used for calculating required exp to level up. Changes at soft cap
Character.static.EXP_POW_SCALE = 1.8
Character.static.EXP_MULT_SCALE = 4
Character.static.EXP_BASE_ADD = 10

-- why are these static?
Character.static.yPos = 100
Character.static.xPos = 100

  -- Character constructor
    -- preconditions: stats dict and skills dict
    -- postconditions: Creates a valid character
function Character:initialize(stats, skills, actionButton)
  Entity:initialize(stats, Character.static.xPos, Character.static.xPos)
  self.actionButton = actionButton
  self.fp = stats['fp']
  self.basic = {}
  current_skills = {}
  Character:setBaseSkills()
  self.level = 1
  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15
  Entity:setAnimations('character/')
  Character.static.yPos = Character.static.yPos + 150
  
  self.offenseState = OffenseState(actionButton, Entity:getBattleStats())
  self.defenseState = nil
  
  self.selectedSkill = nil
  self.actionUI = ActionUI(Entity:getX(), Entity:getY(), current_skills)
end;

  -- Sets the basic attack and the starting skill for a character
function Character:setBaseSkills()    --> void
  local allSkills = Entity:getSkills()
  self.basic = allSkills[1]
  local startingSkill = allSkills[2]
  table.insert(current_skills, startingSkill)
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
    
    -- push a new state onto the stack that will allow the player to select a stat to boost
  end
end;

  -- Gets the required exp for the next level
    -- preconditions: none
    -- postconditions: updates self.experiencedRequired based on polynomial scaling
function Character:getRequiredExperience(lvl) --> int
  result = 0
  if lvl < 3 then
    result = lvl^Character.static.EXP_POW_SCALE + lvl * Character.static.EXP_MULT_SCALE + Character.static.EXP_BASE_ADD
  else
    result = lvl^Character.static.EXP_POW_SCALE + lvl * Character.static.EXP_MULT_SCALE
  end
    
  return result
end;
  
  -- Checks for new learnable skills on lvl up from a table of the character's skills
    -- preconditions: none
    -- postconditions: updates self.current_skills
function Character:updateSkills(lvl)
  for i,skill in pairs(Entity:getSkills()) do
    if lvl == skill['unlock'] then
      table.insert(current_skills, skill)
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

function Character:setSelectedSkill()
  self.selectedSkill = self.offenseState:get

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
  if not Character:attacking() then
    Entity:draw()
  else
    if self.selectedSkill not nil then
      self.selectedSkill:draw()
    end
  end
end;
