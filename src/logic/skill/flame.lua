require('util.globals')
require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')

-- Duration field of flame skill is the skill to hit ONE target
return function(ref, qteManager)
  local skill = ref.skill
  local targets = ref.targets
  local tPos = {}
  for i,target in ipairs(targets) do
    table.insert(tPos, target.hitbox)
  end
  local damage = ref.battleStats['attack'] + skill.damage
  local flameTravelTime = skill.duration
  local flawlessDodge = true
  local hasCollided = {}
  for _ in ipairs(targets) do
    table.insert(hasCollided, false)
  end

  -- Pathing projectile between 2 targets
  local goalPos = {
    {x = tPos[1].x - (2 * tPos[1].w), y = tPos[1].y + tPos[1].h},
    {x = ref.hitbox.x - (ref.hitbox.w / 2), y = tPos[2].y + tPos[2].h},
  }

  table.insert(goalPos, {x = ref.hitbox.x + (ref.hitbox.w / 2), y = ref.hitbox.y + (ref.hitbox.h / 2)})

  local flame = Projectile(ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2), skill.castsShadow, 1)
  table.insert(ref.projectiles, flame)
  
  local checkCollision = function()
    for i,target in ipairs(targets) do
      if not hasCollided[i] and Collision.rectsOverlap(flame.hitbox, target.hitbox) then
        target:takeDamage(damage)
        hasCollided[i] = true
        flawlessDodge = false
        print('collision at index ' .. i, target.entityName .. 'takes damage: ' .. damage)
      end
    end
  end

  local onUpdate = function()
    checkCollision()
  end

-- Tweening for 2 Targets + Rebound onto ref
  local goalX, goalY = goalPos[1].x, goalPos[1].y
  local attack = flux.to(flame.pos, flameTravelTime, {x = goalPos[1].x, y = goalPos[1].y})
    :ease(skill.beginTweenType)
    :onupdate(onUpdate)
    :after(flame.pos, flameTravelTime, {x = goalPos[1].x, y = goalPos[2].y})
      :ease(skill.beginTweenType)
      :onupdate(onUpdate)
    :after(flame.pos, flameTravelTime, {x = goalPos[2].x, y = goalPos[2].y})
      :ease(skill.beginTweenType)
      :onupdate(onUpdate)
    :after(flame.pos, flameTravelTime, {x = goalPos[3].x, y = goalPos[3].y})
      :ease(skill.beginTweenType)
      :oncomplete(function()
        if flawlessDodge then
          ref:takeDamage(damage)
        end
        table.remove(ref.projectiles, 1)
        ref:endTurn(skill.duration)
      end)

  ref.tweens['attack'] = attack

end;