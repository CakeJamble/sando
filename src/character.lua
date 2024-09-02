--! file: Character
require("skill_sheet")
require("stat_sheet")
require("entity")
require("action_ui")

local class = require 'libs/middleclass'
Character = class('Character', Entity)

-- Integers used for calculating required exp to level up. Changes at soft cap
Character.static.EXP_POW_SCALE = 1.8
Character.static.EXP_MULT_SCALE = 4
Character.static.EXP_BASE_ADD = 10

  -- Character constructor
    -- preconditions: stats dict and skills dict
    -- postconditions: Creates a valid character
function Character:initialize(stats, skills)
  Entity.initialize(self, stats, skills)
  current_skills = {}
  self.level = 1
  self.totalExp = 0
  self.experience = 0
  self.experienceRequired = 15
  idle = Character:setIdle(Entity:getName())
  ui = ActionUI(Entity:getEntityName())
  

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

function Character:setIdle(name) --> love.graphics.newImage
  local path = 'asset/sprites/entities/character/' .. name .. '/idle.png'
  image = love.graphics.newImage(path)
  local frameWidth = Entity:getFWidth()
  local frameHeight = Entity:getFHeight()
  local width = image:getWidth()
  local height = image:getHeight()
  local numFrames = 5
  
  for i=0,numFrames do
    table.insert(frames, love.graphics.newQuad(i * frameWidth, 0, frameWidth, frameHeight, width, height))
  end
  
  return image
end;

function Character:update(dt)
  Entity:update(dt)
end;

function Character:draw()
  love.graphics.draw(idle, frames[math.floor(currentFrame)], 100, 100)
end;
