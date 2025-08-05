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

  local donut = Projectile(ref.hitbox.x + ref.hitbox.w, ref.hitbox.y + (ref.hitbox.h / 2), 1)
  Signal.emit('ProjectileMade', donut)

  Timer.after(qteManager.activeQTE.duration,
    function()

      -- Tween projectile to the target in an arc (quadout then quad in for feel of gravity)
      local attack = flux.to(donut.pos, donutFlyingTime / 2, {x = xMidPoint, y = arcHeight})
        :ease('quadout')
        :after(donut.pos, donutFlyingTime / 2, {x = goalX, y = goalY})
          :ease('quadin')
          :oncomplete(
            function()
              target:heal(5)
              Signal.emit('DespawnProjectile')
              ref:endTurn(skill.duration, stagingPos, skill.returnTweenType)
            end)
        ref.tweens['attack'] = attack
    end)
end;