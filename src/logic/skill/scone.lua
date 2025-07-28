require('util.globals')
require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteManager)
  local skill = ref.skill
  local tPos = ref.target.hitbox
  local goalX, goalY = tPos.x + tPos.w / 2, tPos.y + tPos.h / 2
  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage
  local sconeFlyingTime = 0.4
  local peakHeight = -tPos.h/2

  Timer.after(skill.duration, function()
    -- Create a Scone Projectile
    local scone = Projectile(ref.pos.x + ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2))
    local startX, startY = scone.pos.x, scone.pos.y
    Signal.emit('ProjectileMade', scone)
    -- Tween the scone projectile through the target
    local attack = flux.to(scone.pos, sconeFlyingTime, {x = goalX}):ease(skill.beginTweenType)
      :onupdate(function()
        scone:update()

      -- over duration, tween y in a parabola towards target
      local t = (scone.pos.x - startX) / (goalX - startX)
      scone.pos.y = startY + (goalY - startY) * t + peakHeight * (1 - (2 * t - 1)^2)

        if not hasCollided and Collision.rectsOverlap(scone.hitbox, ref.target.hitbox) then
          ref.target:takeDamage(damage)
          hasCollided = true
          flux.to(scone.dims, 0.25, {r = 0}):ease('linear')
            :oncomplete(function() Signal.emit('DespawnProjectile') end)
        end
      end)
      :oncomplete(function() ref:endTurn(skill.duration, stagingPos, skill.returnTweenType) end)
      ref.tweens['attack'] = attack
  end)
end;