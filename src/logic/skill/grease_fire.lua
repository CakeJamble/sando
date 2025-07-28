require('util.globals')
require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteManager)
  local skill = ref.skill
  local tPos = ref.target.hitbox
  local goalX, goalY = tPos.x + 80, tPos.y
  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage
  -- local wokFlyingTime = 0.8

  -- Create a Scone Projectile
  local wok = Projectile(ref.pos.x + ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2))
  Signal.emit('ProjectileMade', wok)
  ref.currentAnimTag = skill.tag
  -- Tween the scone projectile through the target
  local attack = flux.to(wok.pos, skill.duration, {x = goalX, y = goalY + (ref.target.hitbox.h / 2)}):ease(skill.beginTweenType)
    :onupdate(function()
      wok:update()
      if not hasCollided and Collision.rectsOverlap(wok.hitbox, ref.target.hitbox) then
        ref.target:takeDamage(damage)
        hasCollided = true
        flux.to(wok.dims, 0.25, {r = 0}):ease('linear')
          :oncomplete(function() Signal.emit('DespawnProjectile') end)
      end
    end)
    :oncomplete(function()
      ref:endTurn(skill.duration, stagingPos, skill.returnTweenType)
    end)
    ref.tweens['attack'] = attack
end;