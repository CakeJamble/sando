require('util.globals')
local Projectile = require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteBonus, qteManager)
  local skill = ref.skill
  local targets = ref.targets
  local damage = ref.battleStats['attack'] + skill.damage
  local luck = ref.battleStats.luck
  if qteBonus then
    damage = qteBonus(damage)
  end

  local tPos = {}
  for _,target in ipairs(targets) do
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
  local hasCollided = {}
  for i=1, numProjectiles do
    table.insert(hasCollided, false)
  end

  for i=1, numProjectiles do
    local x,y = ref.pos.x + ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2)
    local egg = Projectile(x, y, skill.castsShadow, i)
    table.insert(ref.projectiles, egg)

    local tIndex = love.math.random(1, #targets)
    local goalX, goalY = tPos[tIndex].x, tPos[tIndex].y
    local target = targets[tIndex]
    local goalShadowY = target.hitbox.y + target.hitbox.h
    local startX, startY = egg.pos.x, egg.pos.y
    local eggTween = flux.to(egg.pos, eggFlightTime, {x = goalX})
      :ease(skill.beginTweenType)
      :onstart(function() egg:tweenShadow(eggFlightTime, goalShadowY) end)
      :onupdate(
      function()
        local t = (egg.pos.x - startX) / (goalX - startX)
        egg.pos.y = startY + (goalY - startY) * t + peakHeight * (1 - (2 * t - 1)^2)

        if not hasCollided[i] and Collision.rectsOverlap(egg.hitbox, target.hitbox) then
          target:takeDamage(damage, luck)
          hasCollided[i] = true
          table.remove(ref.projectiles, i)
        end
      end)
      :delay((i-1) * timeBtwnThrows)
    table.insert(attack, eggTween)
  end
end;