require('util.globals')
local flux = require('libs.flux')
local Collision = require('libs.collision')
local Timer = require('libs.hump.timer')

return function(ref)
	local skill = ref.skill
  local target = ref.targets[1]

  local yOffset = ref.hitbox.h - target.hitbox.h
  if ref.hitbox.h < target.hitbox.h then
    yOffset = -1 * yOffset
  end

  local xOffset = 50
  local tPos = target.hitbox
  local goalX, goalY = tPos.x - xOffset, tPos.y + yOffset

  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage
  local luck = ref.battleStats['luck']
  local targetLuck = target.battleStats.luck

  local spaceFromTarget = calcSpacingFromTarget(skill.stagingType, ref.type)
  local stagingPos = {
    x = tPos.x + spaceFromTarget.x,
    y = goalY + spaceFromTarget.y
  }
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
            local attack = flux.to(ref.pos, skill.duration, {x = goalX, y = goalY})
              :ease(skill.beginTweenType)
              :onupdate(function()
                if not hasCollided and Collision.rectsOverlap(ref.hitbox, target.hitbox) then
                  hasCollided = true
                  -- check counter-attack
                  if Collision.isOverhead(ref.hitbox, target.hitbox) then
                    ref:takeDamage(target.battleStats.attack, targetLuck)
                    target:stopTween('jump')
                    ref:attackInterrupt()
                    target:beginJump()
                  else
                    target:takeDamage(damage, luck)
                    print('collision')
                    if target.isJumping then
                      target:interruptJump()
                    end
                  end
                end
              end)
              :oncomplete(function()
                ref:endTurn(skill.duration, stagingPos, skill.returnTweenType)
              end)
              ref.tweens['attack'] = attack
            end)
        end)
end;