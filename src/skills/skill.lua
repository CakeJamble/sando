-- see data.skills.README.md for documentation on skill data

local function newSkill(data)
  return {
    name            = data.name,
    damage          = data.damage,
    isOffensive 		= data.isOffensive,
    targetType 			= data.targetType,
    effects         = data.effects,
    chance          = data.chance or 0,
    cost            = data.cost,
    spritePath      = data.spritePath,
    soundPath       = data.soundPath,
    duration        = data.duration,
    stagingTime     = data.stagingTime,
    stagingType     = data.stagingType,
    qteType         = data.qteType,
    qteBonus        = data.qteBonus,
    description     = data.description,
    unlockedAtLvl		= data.unlockedAtLvl,
    beginTweenType  = data.beginTweenType,
    returnTweenType = data.returnTweenType,
    isDodgeable     = data.isDodgeable,
    hasProjectile   = data.hasProjectile,
    proc            = data.proc
  }
end

return newSkill



--! filename: skill
-- require('class.qte.projectile')

-- Class = require 'libs.hump.class'
-- Skill = Class{}

-- -- needs position to draw?
--   -- Skill Constructor
--     -- preconditions: A table of a single Character skill
--     -- postconditions: A Skill with an animation appended to the skill dict
-- function Skill:init(skillDict, width, height)
--   self.dict = skillDict
--   self.proc = skillDict.proc
--   self.skillName = skillDict['skill_name']
--   self.damage = skillDict['damage']
--   self.cost = skillDict['cost']
--   self.description = skillDict['description']
--   self.instructions = skillDict['instructions']
--   self.targetType = skillDict['target_type']
--   self.animation = self:newAnimation(love.graphics.newImage(skillDict.sprite_path), width, height, 1)
--   self.qte_bonus = skillDict['qte_bonus']
--   self.qteType = skillDict['qte_type']
--   self.partners = skillDict.partners
--   projectiles = {}
--   self.frameCount = 0
--   self.duration = skillDict.duration
--   self.qte_window = skillDict.qte_window
--   self.projectileCount = 0
--   self.projectileRate = skillDict['projectile_rate']
--   self.projectileCountLimit = skillDict['projectile_count']
--   if(skillDict.damage_type == 'projectile') then
--     self.projectileAnimation = Skill:newAnimation(skillDict['projectile_path'], self.skill['projectile_width'], self.skill['projectile_height'], self.skill['duration'])
--   end
--   local sound_path = skillDict.sound_path
--   self.sound = love.audio.newSource(sound_path, "static")
--   self.sound:setVolume(0.8)
-- end;

-- function Skill:reset()
--   self.damage = self.dict['damage']
--   self.qte_bonus = self.dict['qte_bonus']
-- end;

--   -- Create and return a new animation
--     -- preconditions: A love.graphics.newImage object, the width, height, and duration (number of frames)
--     -- postconditions: Returns an animation using a table of quads from a spritesheet
-- function Skill:newAnimation(image, width, height, duration)
--   local animation = {}
--   animation.spriteSheet = image
--   animation.quads = {}
  
--   for y=0, image:getHeight() - height, height do
--     for x=0, image:getWidth() - width, width do
--       table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
--     end
--   end

--   animation.duration = duration or 1
--   animation.currentTime = 0
  
--   return animation
-- end;

-- function Skill:update(dt)
--   self.animation.currentTime = self.animation.currentTime + dt
--   if self.animation.currentTime >= self.animation.duration then
--       self.animation.currentTime = self.animation.currentTime - self.animation.duration
--   end
--   if self.hitType == 'projectile' then
--     self.frameCount = self.frameCount + 1
    
--     if self.frameCount >= self.projectileRate and self.projectileCount < self.projectileCountLimit then
--       table.insert(projectiles, Projectile(self.projectileAnimation, self.userX, self.userY, self.userWidth, self.userHeight, self.targetX, self.targetY, self.dx, self.dy, self.a, self.r, self.tR, self.damage))
--       self.projectileCount = self.projectileCount + 1
--     end
    
--     for i, projectile in pairs(projectiles) do
--       projectile:update(dt)
--     end
--   end
  
-- end;

-- function Skill:draw(x, y)
--   local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
--   love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], x, y, 0, 1)
--   if self.hitType == 'projectile' then
--     for i, projectile in pairs(projectiles) do
--       projectile:draw()
--     end
--   end
  
-- end;