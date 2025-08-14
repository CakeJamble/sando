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
  -- local goalPos = {
  --   {x = tPos[1].x - (2 * tPos[1].w), y = tPos[1].y + tPos[1].h},
  --   {x = ref.hitbox.x - (ref.hitbox.w / 2), y = tPos[2].y + tPos[2].h},
  -- }

  local goalPos = {}
  for i,pos in ipairs(tPos) do
    local x, y
    local xOffset = 2 * pos.w
    if i % 2 == 1 then
      x = pos.x - xOffset
    else
      x = pos.x + xOffset
    end
    y = pos.y + pos.h
    table.insert(goalPos, {x=x,y=y})

    -- Tween behind next target
    if i < #tPos then
      local nextTarget = tPos[i+1]
      table.insert(goalPos, {x=x,y=nextTarget.y + nextTarget.h})
    end
  end

  -- rebound onto user at the end (if dodged perfectly)
  table.insert(goalPos, {x = ref.hitbox.x + (ref.hitbox.w / 2), y = ref.hitbox.y + (ref.hitbox.h / 2)})

  local flame = Projectile(ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2), skill.castsShadow, 1)
  table.insert(ref.projectiles, flame)
  
  local checkCollision = function()
    for i,target in ipairs(targets) do
      if not hasCollided[i] and Collision.rectsOverlap(flame.hitbox, target.hitbox) then
        target:takeDamage(damage)
        hasCollided[i] = true
        flawlessDodge = false
      end
    end
  end

  -- Tweening for N Targets + Rebound onto ref
  local attack = flux.to(flame.pos, flameTravelTime, {x = goalPos[1].x, y = goalPos[1].y})
    :ease(skill.beginTweenType)
    :onupdate(checkCollision)

  for i=2, #goalPos do
    local t = flameTravelTime
    
    -- Make flame faster so it can be jumped over
    if i % 2 == 1 then
      t = t / 3
    end

    attack = attack:after(t, {x=goalPos[i].x, y=goalPos[i].y}):ease(skill.beginTweenType):onupdate(checkCollision)

    -- Rebound onto user
    if i == #goalPos then
      attack = attack:oncomplete(function()
        if flawlessDodge then
          ref:takeDamage(damage)
        end
        table.remove(ref.projectiles, 1)
        ref:endTurn(skill.duration)
      end)
    end
  end

  ref.tweens['attack'] = attack

end;