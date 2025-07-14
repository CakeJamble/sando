require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteSuccess)
	local skill = ref.skill
  local goalX, goalY = ref.tPos.x, ref.tPos.y
  local stagingPos = {x = ref.pos.x, y = ref.pos.y}
  local hasCollided = false
  local damage = 0 + ref.battleStats['attack']

  local stagingPos = {
    x = ref.tPos.x, y = ref.tPos.y
  }
  local spaceFromTarget = calcSpacingFromTarget(skill.stagingType, ref.type)
  stagingPos.x = stagingPos.x + spaceFromTarget.x
  stagingPos.y = stagingPos.y + spaceFromTarget.y

  -- Move from starting position to staging position before changing to animation assoc with skill
  flux.to(ref.pos, skill.stagingTime, {x = stagingPos.x, y = stagingPos.y})
    -- Attack by charging from right to left
    :after(ref.pos, skill.duration, {x = goalX - 80, y = goalY}):ease(skill.beginTweenType)
      :onupdate(function()
        if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
          ref.target:takeDamage(damage)
          hasCollided = true
        end
      end)
      :oncomplete(function() tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, skill.duration, skill.returnTweenType) end)
end;