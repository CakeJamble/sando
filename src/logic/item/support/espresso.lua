require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(item, entity)
	local target = entity.targets[1]
	local goalX, goalY = target.hitbox.x + (target.hitbox.w / 2), target.hitbox.y + (target.hitbox.h / 3)
	  local xMidPoint = entity.hitbox.x + (target.hitbox.w/ 2) - goalX
  if entity.hitbox.x > target.hitbox.x then
    xMidPoint = entity.hitbox.x + (target.hitbox.w/ 2) - xMidPoint
  else
    xMidPoint = entity.hitbox.x + (target.hitbox.w/ 2) + xMidPoint
  end


  local arcHeight = target.hitbox.y - target.hitbox.h
  local projectileFlyingTime = 0.8

  local espresso = Projectile(entity.hitbox.x + entity.hitbox.w, entity.hitbox.y + (entity.hitbox.h / 2), 1)
  table.insert(entity.projectiles, espresso)

      -- Tween projectile to the target in an arc (quadout then quad in for feel of gravity)
  local item = flux.to(espresso.pos, projectileFlyingTime / 2, {x = xMidPoint, y = arcHeight})
    :ease('quadout')
    :after(espresso.pos, projectileFlyingTime / 2, {x = goalX, y = goalY})
      :ease('quadin')
      :oncomplete(
        function()
          target:heal(item.amount)
          table.remove(entity.projectiles, 1)
          entity:endTurn(skill.duration)
        end)
    entity.tweens['item'] = item
end;