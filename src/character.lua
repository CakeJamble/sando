--! file: Character
require("skill_sheet")
require("stat_sheet")
require("entity")
local class = require 'libs/middleclass'
Character = class('Character')

-- Integers used for calculating required exp to level up. Changes at soft cap
Character.static.EXP_POW_SCALE = 1.8
Character.static.EXP_MULT_SCALE = 4
Character.static.EXP_BASE_ADD = 10

  -- Character constructor
    -- preconditions: stats dict and skills dict
    -- postconditions: Creates a valid character
function Character:initialize(stats, skills)
  Entity.initialize(self, stats, skills)
  self.current_skills = {}
  self.level = 1
  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15

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
    self.experienceRequired = getExperienceRequired(self)
    Character.updateSkills(self)
  end
end;

  -- Gets the required exp for the next level
    -- preconditions: none
    -- postconditions: updates self.experiencedRequired based on polynomial scaling
function Character:getRequiredExperiece() --> int
  result = 0
  if self.level < 3 then
    result = self.level^Character.static.EXP_POW_SCALE + self.level * Character.static.EXP_MULT_SCALE + Character.static.EXP_BASE_ADD
  else
    result = self.level^Character.static.EXP_POW_SCALE + self.level * Character.static.EXP_MULT_SCALE
  end
    
  return result
end;
  
  -- Checks for new learnable skills on lvl up from a table of the character's skills
    -- preconditions: none
    -- postconditions: updates self.current_skills
function Character:updateSkills()
end;

function Character:getCurrentSkills() --> table
  return self.current_skills
end;

function Character:update(dt)
  Entity:update(dt)
end;

function Character:draw()
  Entity:draw()
end;
