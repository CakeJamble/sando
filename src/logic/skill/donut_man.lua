require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteManager)
  local skill = ref.skill
  local target = ref.target
  local goalX, goalY = target.hitbox.x + (target.hitbox.w / 2), target.hitbox.y + (target.hitbox.h / 3)
  local xMidPoint = ref.hitbox.x + (target.hitbox.w/ 2) - goalX
  if ref.hitbox.x > target.hitbox.x then
    xMidPoint = ref.hitbox.x + (target.hitbox.w/ 2) - xMidPoint
  else
    xMidPoint = ref.hitbox.x + (target.hitbox.w/ 2) + xMidPoint
  end


  local arcHeight = target.hitbox.y - target.hitbox.h
  local donutFlyingTime = 0.8
      -- Projectile
  local donut = Projectile(ref.hitbox.x + ref.hitbox.w, ref.hitbox.y + (ref.hitbox.h / 2))
  Signal.emit('ProjectileMade', donut)

  Timer.after(qteManager.activeQTE.duration,
    function()

      -- Tween projectile to the target in an arc (quadout then quad in for feel of gravity)
      flux.to(donut.pos, donutFlyingTime / 2, {x = xMidPoint, y = arcHeight})
        :ease('quadout')
        :after(donut.pos, donutFlyingTime / 2, {x = goalX, y = goalY})
          :ease('quadin')
          :oncomplete(
            function()
              local preHealHP = target.battleStats.hp
              target:heal(5)
              print(target.entityName .. ' healed 5.')
              print('HP was ' .. preHealHP .. ' and is now ' .. target.battleStats.hp)
              Signal.emit('DespawnProjectile')
              Timer.after(0.25, function() Signal.emit('NextTurn') end)
            end
          )
    end)
end;