require('util.globals')
local Projectile = require('class.entities.projectile')
local flux = require('libs.flux')
local Signal = require('libs.hump.signal')
local Collision = require('libs.collision')

return function(ref, qteBonus, qteManager)
  local skill = ref.skill
  local target = ref.targets[1]
  local tPos = target.hitbox
  local goalX, goalY = tPos.x + tPos.w / 2, tPos.y
  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage
  local goalShadowY = tPos.y + tPos.h
  local burnChance = 0.3
  if qteBonus then
    burnChance = qteBonus(burnChance)
  end

  -- Create a Scone Projectile
  local wok = Projectile(ref.pos.x + ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2), skill.castsShadow, 1)
  local startX, startY = wok.pos.x, wok.pos.y
  local peakHeight = -tPos.h
  Signal.emit('ProjectileMade', wok)
  ref.currentAnimTag = skill.tag
  -- Tween the scone projectile through the target
  local cam = flux.to(camera, skill.duration, {x = goalX}):ease('quadout')
  ref.tweens['camera'] = cam
  local attack = flux.to(wok.pos, skill.duration, {x = goalX}):ease(skill.beginTweenType)
    :onstart(function() wok:tweenShadow(skill.duration, goalShadowY); end)
    :onupdate(function()
      -- over duration, tween y in a parabola towards target
      local t = (wok.pos.x - startX) / (goalX - startX)
      wok.pos.y = startY + (goalY - startY) * t + peakHeight * (1 - (2 * t - 1)^2)

      if not hasCollided and Collision.rectsOverlap(wok.hitbox, target.hitbox) then
        target:takeDamage(damage)
        local rand = love.math.random()
        if burnChance >= rand then
          target:applyStatus('burn')
        end
        hasCollided = true
        flux.to(wok.dims, 0.25, {r = 0}):ease('linear')
          :oncomplete(function() Signal.emit('DespawnProjectile') end)
      end
    end)
    :oncomplete(function()
      ref:endTurn(skill.duration, nil, skill.returnTweenType)
    end)
    ref.tweens['attack'] = attack
end;