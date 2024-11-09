--! filename: skill
require('projectile')

local class = require 'libs/middleclass'
Skill = class('Skill')

  -- Skill Constructor
    -- preconditions: A table of a single Character skill
    -- postconditions: A Skill with an animation appended to the skill dict
function Skill:initialize(t, width, height)
  self.skill = t
  self.hitType = t['hit_type']
  self.animation = Skill:newAnimation(self.skill['sprite_path'], width, height, self.skill['duration'])
  projectiles = {}
  self.frameCount = 0
  self.projectileCount = 0
  self.projectileRate = t['projectile_rate']
  self.projectileCountLimit = t['projectile_count']
  self.projectileAnimation = Skill:newAnimation(self.skill['projectile_path'], self.skill['projectile_width'], self.skill['projectile_height'], self.skill['duration'])
end;


function Skill:getSkillTable()
  return self.skill
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

function Skill:update(dt)
  if self.hitType == 'projectile' then
    self.frameCount = self.frameCount + 1
    
    if self.frameCount >= self.projectileRate and self.projectileCount < self.projectileCountLimit then
      table.insert(projectiles, Projectile(self.projectileAnimation, userX, userY, userWidth, userHeight, targetX, targetY, dx, dy, a, r, tR, damage))
      self.projectileCount = self.projectileCount + 1
    end
    
    for i, projectile in pairs(projectiles) do
      projectile:update(dt)
    end
    
  end
end;

function Skill:draw()
  love.graphics.draw(animation.spriteSheet, animation.frames[math.floor(animation.currentFrame)], 100, 100)

  if self.hitType == 'projectile' then
    for i, projectile in pairs(projectiles) do
      projectile:draw()
    end
  end

end;