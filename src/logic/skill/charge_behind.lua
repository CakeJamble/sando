local flux = require('libs.flux')
local Collision = require('libs.collision')
local Timer = require('libs.hump.timer')
local Signal = require('libs.hump.signal')
local calcSpacingFromTarget = require('util.calc_spacing')

-- Exit right-side of the screen and appear from left-side, charging through the target
---@param ref Enemy|Character
return function(ref)
	local skill = ref.skill
  local target = ref.targets[1]
  ref.currentAnimTag = 'move'
  -- exit screen left
  local exitX = shove.getViewportWidth() + (2 * ref.hitbox.w)
  local attack = flux.to(ref.pos, 2, {x = exitX})
    :oncomplete(function()
      -- warp behind target
      ref.pos.x = 0 - ref.hitbox.w
      ref.pos.y = target.hitbox.y + target.pos.oy
      ref.pos.sx = -1
      ref.pos.sy = 1
    end)

  local yOffset = ref.hitbox.h - target.hitbox.h
  if ref.hitbox.h < target.hitbox.h then
    yOffset = -1 * yOffset
  end

  local xOffset = 50
  local tPos = target.hitbox
  local goalX, goalY = tPos.x + tPos.w + xOffset, tPos.y + yOffset

  local hasCollided = false
  local damage = ref.battleStats['attack'] + skill.damage
  local luck = ref.battleStats['luck']
  local targetLuck = target.battleStats.luck

  -- Charge from behind, ending in front of target
  attack = attack:after(1, {x = goalX})
    :delay(0.5)
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
        ref.pos.sx = 1
        ref.pos.sy = 1
        Signal.emit('OnSkillResolved', ref)
        ref:endTurn(skill.duration, nil, skill.returnTweenType)
      end)
  ref.tweens['attack'] = attack
end;