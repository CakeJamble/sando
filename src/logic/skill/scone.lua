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
  local sconeFlyingTime = 0.8

  Timer.after(skill.duration, function()
    -- Create a Scone Projectile
    local scone = Projectile(ref.pos.x + ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2))
    Signal.emit('ProjectileMade', scone)
    -- Tween the scone projectile through the target
    flux.to(scone.pos, sconeFlyingTime, {x = goalX, y = goalY + (ref.target.hitbox.h / 2)}):ease(skill.beginTweenType)
      :onupdate(function()
        scone:update()
        if not hasCollided and Collision.rectsOverlap(scone.hitbox, ref.target.hitbox) then
          ref.target:takeDamage(damage)
          hasCollided = true
          flux.to(scone.dims, 0.25, {r = 0}):ease('linear')
            :oncomplete(function() Signal.emit('DespawnProjectile') end)
        end
      end)
      :oncomplete(function() Signal.emit('NextTurn') end)
  end)
end;