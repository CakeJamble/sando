--! filename: projectile

local class = require 'libs/middleclass'

Projectile = class('Projectile')

Projectile.static.SPEED_LIMIT = 300
Projectile.static.GRAVITY = 300     -- TODO allow for projectiles to travel in an arc. Current implementation only moves in a straight line

function Projectile:initialize(spritePath, userX, userY, userWidth, userHeight, targetX, targetY, dx, dy, a, r, tR, damage)
  self.image = love.graphics.newImage(spritePath)
  self.width = self.image:getWidth()
  self.height = self.image:getHeight()
  self.x = userX
  self.y = userY
  self.r = r
  self.tR = tR  
  self.targetX = targetX
  self.targetY = targetY
  self.damage = damage
  self.angle = math.atan(targetX - userX, targetY - userY)
  self.vectorX = math.cos(self.angle)
  self.vectorY = math.sin(self.angle)
  self.dx = self.speed * math.cos(self.angle)   -- x velocity
  self.dy = self.speed * math.sin(self.angle)   -- y velocity
  self.speed = math.sqrt(self.dx^2 + self.dy^2) -- x,y velocity used for checking speed limit
  self.a =  a                                   -- acceleration
  self.hasCollided = false
end;

function Projectile:accelerate(dt)
  self.dx = self.dx + self.a * self.vectorX * dt
  self.dy = self.dy + self.a * self.vectorY * dt
end;

function Projectile:checkCollision()
  local distX = self.targetX - self.x
  local distY = self.targetY - self.y
  local distance = math.sqrt(distX^2 + distY^2)
  
  -- Check if the distance is lte to the sum of the projectile's radius and the target's radius
  return distance <= (self.r + self.tR)
end;


function Projectile:update(dt)
  if not self.hasCollided then
      
    -- Check if projectile hit the speed limit
    if speed > Projectile.static.SPEED_LIMIT then
      Projectile:accelerate(dt)
    end
    
    -- Update current speed
    self.speed = math.sqrt(self.dx^2, self.dy^2)
    
    -- Update position
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    
    if Projectile:checkCollision() then
      self.hasCollided = true
    end
    
  end
end;

  
function Projectile:draw()
  if not self.hasCollided then
    love.graphics.draw(self.image, self.x, self.x)
  end
end;