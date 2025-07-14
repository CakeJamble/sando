require('util.globals')
require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteManager)
  local skill = ref.skill
  local goalX, goalY = ref.tPos.x + 80, ref.tPos.y
  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage
  local stagingPos = {
    x = ref.tPos.x,
    y = ref.tPos.y}

  local spaceFromTarget = calcSpacingFromTarget(skill.stagingType, ref.type)
  stagingPos.x = stagingPos.x + spaceFromTarget.x
  stagingPos.y = stagingPos.y + spaceFromTarget.y

  -- Move from starting position to staging position before changing to animation assoc with skill use
  flux.to(ref.pos, qteManager.activeQTE.stagingTime, {x = stagingPos.x, y = stagingPos.y})
    :oncomplete(function()
      -- Create a Scone Projectile
      local scone = Scone(ref.pos.x + 15, ref.pos.y + 5)
      -- Tween the scone projectile through the target
      flux.to(scone.pos, skill.duration, {x = goalX, y = goalY}):ease(skill.beginTweenType)
        :onupdate(function()
          if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
            ref.target:takeDamage(damage)
            hasCollided = true
          end
        end)
      end)
        :oncomplete(function() tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, skill.duration, skill.returnTweenType) end)
end;