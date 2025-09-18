require('util.globals')
local Projectile = require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')
local Timer = require('libs.hump.timer')

return function(ref, qteBonus, qteManager)
  local skill = ref.skill
  local target = ref.targets[1]
  local tPos = target.hitbox
  local goalX, goalY = tPos.x + tPos.w / 2, tPos.y + tPos.h / 2
  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage
  local luck = ref.battleStats.luck
  if qteBonus ~= nil then
    print('old damage:', damage)
    damage = qteBonus(damage)
    print('new damage:', damage)
  end
  local sconeFlyingTime = 0.4
  local peakHeight = -tPos.h/2

  Timer.after(skill.duration, function()
    -- Create a Scone Projectile
    local scone = Projectile(ref.pos.x + ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2), skill.castsShadow, 1)
    local startX, startY = scone.pos.x, scone.pos.y
    table.insert(ref.projectiles, scone)

    -- vertex
    local controlX = startX + goalX / 2
    local controlY = math.min(startY, goalY) - peakHeight
    local curve = love.math.newBezierCurve(startX, startY, controlX, controlY, goalX, goalY)

    -- tween value
    scone.progress = 0

    local attack = flux.to(scone, sconeFlyingTime, {progress = 1}):ease(skill.beginTweenType)
      :onupdate(function()
        -- update position
        scone.pos.x, scone.pos.y = curve:evaluate(scone.progress)

        -- collision
        if not hasCollided and Collision.rectsOverlap(scone.hitbox, target.hitbox) then
          target:takeDamage(damage, luck)
          hasCollided = true
          flux.to(scone.dims, 0.25, {r=0}):ease("linear")
            :oncomplete(function() table.remove(ref.projectiles, 1) end)
        end
      end)
      :oncomplete(function()
        ref:endTurn(skill.duration, nil, skill.returnTweenType)
      end)
  end)
end;