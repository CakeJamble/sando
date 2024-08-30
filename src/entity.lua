--! file: entity.lua
require("stat_sheet")

-- global table where all entities are stored
Entities = {} 
-- base table with all variables for the entity object
Class = require "libs.hump.class"

Entity = Class {
  -- Creates and returns an animation for an Entity
  newAnimation = function(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}
  
    for y = 0, image:getHeight() - height, height do
      for x = 0, image:getWidth() - width, width do
        table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
      end
    end
  
    animation.duration = duration or 1
    animation.currentTime = 0
    
    return animation
  end;
  
  -- Creates and returns a list of animations for an Entity
  addAnimations = function(skill_dict)
    local animations = {}
    for i, skill in ipairs(skill_dict) do
      sprite_path = skill["sprite_path"]
      animation = newAnimation(sprite_path, sprite_path:getWidth(), sprite_path:getHeight(), duration)
      animations[i] = animation
      i = i + 1
    end
    return animations
  end; 
  
  init = function(self, stats, skills)
    self.stats = stats
    self.current_stats = stats
    self.skills = skills
    self.current_skills = {}
    self.entity = {self.stats, self.skills, self.current_stats, self.current_skills}
    table.insert(Entities, entity)
    self.animations = Entity:addAnimations(self.current_skills)
    return entity
  end;
  


  getPos = function(self)
    return self.stats["pos"]
  end;
  
  getStats = function(self)
    return self.stats
  end;
  
  getCurrentSkills = function(self)
    return self.current_skills
  end;
  
  heal = function(self, amount) -- -> void
    self.current_stats["hp"] = math.min(self.stats["hp"], self.current_stats["hp"] + amount)
  end;
  
  takeDamage = function(self, amount) -- -> void
    self.current_stats["hp"] = math.max(0, self.current_stats["hp"] - amount)
  end;
  
  isAlive = function(self) -- -> bool
    return self.current_stats['hp'] > 0
  end;
  
  getState = function(self) -- -> String
    if(isAlive) then
      return 'idle'
    else
      return 'ko'
    end
  end

  
}