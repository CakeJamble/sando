require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')

return function(ref)
	local skill = ref.skill
  local yOffset = ref.frameHeight - ref.target.frameHeight
  local goalX, goalY = ref.target.oPos.x, ref.target.oPos.y - yOffset
  local stagingPos = {x = ref.tPos.x, y = ref.tPos.y - yOffset}
  local hasCollided = false
  local damage = 0 + ref.battleStats['attack']

  local spaceFromTarget = calcSpacingFromTarget(skill.stagingType, ref.type)
  stagingPos.x = stagingPos.x + spaceFromTarget.x
  stagingPos.y = stagingPos.y + spaceFromTarget.y
  ref.tPos.x = stagingPos.x
  ref.tPos.y = stagingPos.y

  -- Move from starting position to staging position before changing to animation assoc with skill
  local stage = flux.to(ref.pos, skill.stagingTime, {x = stagingPos.x, y = stagingPos.y})
  ref.currentAnimTag = 'move'
  ref.tweens['stage'] = stage
  stage:oncomplete(
      function()
        ref.currentAnimTag = skill.tag
        Timer.after(1,
          function()
            local attack = flux.to(ref.pos, skill.duration, {x = goalX - 80, y = goalY})
              :ease(skill.beginTweenType)
              :onupdate(function()
                if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
                  hasCollided = true  
                  -- check counter-attack
                  if Collision.isOverhead(ref.hitbox, ref.target.hitbox) then
                    ref:takeDamage(ref.target.battleStats['attack'])
                    ref.target:stopTween('jump')
                    ref:attackInterrupt()
                    ref.target:beginJump()
                    print('counterattack success')
                  else
                    ref.target:takeDamage(damage)
                    print('collision')
                    if ref.target.isJumping then
                      ref.target:interruptJump()
                    end
                  end
                end
              end)
              :oncomplete(function() 
                ref.currentAnimTag = 'move'
                ref:endTurn(skill.duration, stagingPos, skill.returnTweenType)
              end)
              ref.tweens['attack'] = attack
            end)
        end)
    -- -- Attack by charging from right to left
    -- :after(ref.pos, skill.duration, {x = goalX - 80, y = goalY}):ease(skill.beginTweenType)
    --   :onupdate(function()
    --     if not hasCollided and Collision.rectsOverlap(ref.hitbox, ref.target.hitbox) then
    --       -- check counter-attack
    --       if Collision.isOverhead(ref.hitbox, ref.target.hitbox) then
    --         ref:takeDamage(ref.target.battleStats['attack'])
    --         hasCollided = true
    --         ref.target:stopTween('jump')
    --         ref.target:beginJump()
    --         print('counterattack success')
    --       else
    --         ref.target:takeDamage(damage)
    --         print('collision')
    --         hasCollided = true

    --       end
    --     end
    --   end)
    --   :oncomplete(function() 
    --     ref.currentAnimTag = 'move'
    --     ref:endTurn(skill.duration, stagingPos, skill.returnTweenType)
    --   end)
end;