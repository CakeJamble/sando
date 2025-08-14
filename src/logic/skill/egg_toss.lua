require('util.globals')
require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteManager)
  local skill = ref.skill
  local targets = ref.targets

  local tPos = {}
  for i,target in ipairs(targets) do
    local pos = {
      x = target.hitbox.x + target.hitbox.w / 2,
      y = target.hitbox.y + target.hitbox.h / 3
    }
    table.insert(tPos, pos)
  end

  local numProjectiles = 5
  local eggFlightTime = 2
  local timeBtwnThrows = 0.3
  local peakHeight = -100
  local attack = {}

  local parabolaFleight = function()
    local t = (egg.pos.x - startX) / (goalX - startX)
    egg.pos.y = startY + (goalY - startY) * t + peakHeight * (1 - (2 * t - 1)^2)

    if not hasCollided and Collision.rectsOverlap(egg.hitbox, target.hitbox) then
      target:takeDamage(damage)
      hasCollided = true
      table.remove(ref.projectiles, egg.index)
    end
  end

  for i=1, numProjectiles do
    local x,y = ref.pos.x + ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2)
    local egg = Projectile(x, y, skill.castsShadow, i)
    table.insert(ref.projectiles, egg)

    local tIndex = love.math.random(1, #targets)
    local goalX = tPos[tIndex].x
    local target = targets[tIndex]
    local startX, startY = egg.pos.x, egg.pos.y
    local eggTween = flux.to(egg.pos, eggFlightTime, {x = goalX})
      :ease(skill.beginTweenType)
      :onupdate(parabolaFleight)
      :delay((i-1) * timeBtwnThrows)
    table.insert(attack, eggTween)
  end
end;