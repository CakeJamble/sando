require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')

-- return function(ref, qteSuccess)
--   local skill = ref.skill
--   local goalX, goalY = ref.tPos.x, ref.tPos.y
--   local stagingPos = {x = ref.pos.x, y = ref.pos.y}
--   local hasCollided = false
--   local damage = 0 + ref.battleStats['attack']

--   if qteSuccess then

--   -- Attack by charging from left to right
--   flux.to(ref.pos, skill.duration, {x = goalX + 80, y = goalY}):ease(skill.beginTweenType)
--     :onupdate(function()
--       if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
--         ref:dealDamage(damage, qteSuccess)
--         -- ref.target:takeDamage(damage)
--         hasCollided = true
--       end
--     end)
--     :oncomplete(function() tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, skill.duration, skill.returnTweenType) end)
-- end;

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
  flux.to(ref.pos, qteManager.activeQTE.duration, {x = stagingPos.x, y = stagingPos.y})
    -- Then attack by charging from left to right
    :after(ref.pos, skill.duration, {x = goalX, y = goalY}):ease(skill.beginTweenType)
      :onupdate(function()
        if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
          ref.target:takeDamage(damage)
          hasCollided = true
        end
      end)
      :oncomplete(function() tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, skill.duration, skill.returnTweenType) end)



  -- flux.to(ref.pos, skill.duration, {x = goalX, y = goalY}):ease(skill.beginTweenType)
  --   :onupdate(function()
  --     if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
  --       ref.target:takeDamage(damage)
  --       hasCollided = true
  --     end
  --   end)
  --   :oncomplete(function() tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, skill.duration, skill.returnTweenType) end)
end;