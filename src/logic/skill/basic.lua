require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref, qteManager)
  local skill = ref.skill
  local xOffset = 40
  local yOffset = ref.frameHeight - ref.target.frameHeight
  local stagingPos = {
    x = ref.tPos.x,
    y = ref.tPos.y - yOffset}


  local goalX, goalY = ref.tPos.x + xOffset - ref.frameWidth, ref.tPos.y - yOffset
  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage

  local spaceFromTarget = calcSpacingFromTarget(skill.stagingType, ref.type)
  stagingPos.x = stagingPos.x + spaceFromTarget.x
  stagingPos.y = stagingPos.y + spaceFromTarget.y

  -- Move from starting position to staging position before changing to animation assoc with skill use
  flux.to(ref.pos, qteManager.activeQTE.duration, {x = stagingPos.x, y = stagingPos.y})
    :oncomplete(
      function()
        ref.currentAnimTag = skill.tag
        -- Attack by charging from left to right
        flux.to(ref.pos, skill.duration, {x=goalX,y=goalY}):ease(skill.beginTweenType)
          :delay(0.7) -- give animation time to start
          :onupdate(
            function()
              if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
                ref.target:takeDamage(damage)
                hasCollided = true
              end
            end)
          :oncomplete(
            function()
              ref.currentAnimTag = 'move'
              tweenToStagingPosThenStartingPos(ref.pos, stagingPos, ref.oPos, skill.duration, skill.returnTweenType)
              ref.target.currentAnimTag = 'idle'
            end)
      end)
end;