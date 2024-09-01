--! filename: skill

local class = require 'libs/middleclass'
Skill = class('Skill')

  -- Skill Constructor
    -- preconditions: A table of a single Character skill
    -- postconditions: A Skill with an animation appended to the skill dict
function Skill:initialize(t)
  self.skill = t
  self.animation = Skill:newAnimation(self.skill['sprite_path'], 96, 96, 9)
end;


function Skill:getName()
  return self.skill['name']
end;

function Skill:getDamageInfo()
  return {self.skill['damage'], self.skill['damage_type'], self.skill['target_type']}
end;

function Skill:getEffectInfo()
  return {self.skill['effects'], self.skill['proc']}
end;

function Skill:getAnimation()
  return self.animation
end;


  -- Create and return a new animation
    -- preconditions: A love.graphics.newImage object, the width, height, and duration (number of frames)
    -- postconditions: Returns an animation using a table of quads from a spritesheet
function Skill:newAnimation(path, width, height, duration)
  local animation = {}
  animation.spriteSheet = love.graphics.newImage(path)
  animation.frames = {}
  for i=0,duration do
    table.insert(animation.frames, love.graphics.newQuad(i * width, 0, width, height, animation.spriteSheet:getWidth(), animation.spriteSheet:getHeight()))
  end
  
  animation.duration = duration or 1
  animation.currentFrame = 0
    
  return animation
end;

function Skill:draw()
  love.graphics.draw(animation.spriteSheet, animation.frames[math.floor(animation.currentFrame)], 100, 100)
end;
