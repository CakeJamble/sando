local flux = require('libs.flux')
local Projectile = require('class.entities.projectile')
local Timer = require('libs.hump.timer')
local Signal = require('libs.hump.signal')

---@param ref Character
return function(ref, qteBonus, qteManager)
  local skill = ref.skill
  local target = ref.targets[1]
  local goalX, goalY = target.hitbox.x + (target.hitbox.w / 2), target.hitbox.y + (target.hitbox.h / 3)
  local xMidPoint = ref.hitbox.x + (target.hitbox.w/ 2) - goalX
  if ref.hitbox.x > target.hitbox.x then
    xMidPoint = ref.hitbox.x + (target.hitbox.w/ 2) - xMidPoint
  else
    xMidPoint = ref.hitbox.x + (target.hitbox.w/ 2) + xMidPoint
  end

  -- temp: using defense stat to determine heal amount
  local amount = ref.battleStats.defense
  if qteBonus then
    amount = qteBonus(amount)
  end


  local arcHeight = target.hitbox.y - target.hitbox.h
  local donutFlyingTime = 0.8
  local goalShadowY = target.hitbox.y + target.hitbox.h

  local animation = skill.animation.donut
  local projectileData = skill.projectiles.donut
  local px, py = ref.hitbox.x + ref.hitbox.w, ref.hitbox.y + (ref.hitbox.h / 2)
  local pw, ph = projectileData.width, projectileData.height
  local donut = Projectile(px, py, pw, ph, skill.castsShadow, 1, animation)
  table.insert(ref.projectiles, donut)

  Timer.after(qteManager.activeQTE.duration,
    function()
      -- Tween projectile to the target in an arc (quadout then quad in for feel of gravity)
      local attack = flux.to(donut.pos, donutFlyingTime / 2, {x = xMidPoint, y = arcHeight})
        :ease('quadout')
        :onstart(function() donut:tweenShadow(donutFlyingTime, goalShadowY); end)
        :after(donut.pos, donutFlyingTime / 2, {x = goalX, y = goalY})
          :ease('quadin')
          :oncomplete(
            function()
              target:heal(amount)
              table.remove(ref.projectiles, 1)
              Signal.emit("OnSkillResolved", ref)
              ref:endTurn(skill.duration, nil, skill.returnTweenType)
            end)
        ref.tweens['attack'] = attack
    end)
end;