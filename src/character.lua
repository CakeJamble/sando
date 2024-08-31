--! file: Character
require("skill_sheet")
require("stat_sheet")
require("entity")
Class = require "libs.hump.class"

Team = {}

Character = Class{__includes = Entity,
  init = function(self, stats, skills)
    character = Entity(stats, skills)
    table.insert(Team, character)
    self.level = 1
    self.totalExp = 0
    self.experience = 0
    self.experienceRequired = 15    -- lvl 1 -> lvl 2 requires 15 exp
    
    -- Integers used for calculating required exp to level up. Changes at soft cap
    self.expPowScale = 1.8
    self.expMultScale = 4
    self.expBaseReq = 10
  end;
  
  -- Scales the required exp for the next level based on the current level
  getRequiredExperience = function(self) --> int
    result = 0
    if self.level < 3
      result = self.level^self.expPowScale + self.level * self.expMultScale + self.expBaseReq
    else
      result = self.level^self.expPowScale + self.level * self.expMultScale
    end
    
    return result
  end;
  
  gainExp = function(self, amount)
    self.totalExp = self.totalExp + amount
    self.experience = self.experience + amount
    
    while self.experience >= self.experienceRequired do
      self.level = self.level + 1
      self.experienceRequired = getExperienceRequired(self)
      updateSkills(self)
      
      if self.level > self.softCap then
        softcapExpScalers()
      end
    end
  end;
  
  updateSkills = function(self)
    local currentSkills = Entity.
    -- for _,v in ipairs() do
      
  end;
  
  softcapExpScalers = function(self)
    self.expPowScale = 2
    self.expMultScale = 6
  end;
    
}
bake = Character(get_bake_stats(), get_bake_skills())
marco = Character(get_marco_stats(), get_marco_skills())
maria = Character(get_maria_stats(), get_maria_skills())
key = Character(get_key_stats(), get_key_skills())