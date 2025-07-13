require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteSuccess)
	local skill = ref.skill
  local goalX, goalY = ref.tPos.x, ref.tPos.y
  local stagingPos = {x = ref.pos.x, y = ref.pos.y}
  local hasCollided = false
  local damage = 0 + ref.battleStats['attack']

  -- Attack by charging from right to left
  flux.to(ref.pos, skill.duration, {x = goalX - 80, y = goalY}):ease(skill.beginTweenType)
    :onupdate(function()
      if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
        ref:dealDamage(damage)
        hasCollided = true
      end
    end)
    :oncomplete(function() tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, skill.duration, skill.returnTweenType) end)
end;