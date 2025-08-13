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
  
  -- Pathing projectile between targets
  local goalPos = {}
  for i,pos in ipairs(tPos) do
    local goalX    
    local goalY = pos.y + pos.h
    local xSpaceFromTarget = pos.w * 2
    if i % 2 == 1 then
      goalX = pos.x - xSpaceFromTarget
    else
      goalX = pos.x + xSpaceFromTarget
    end

    table.insert(goalPos, {x = goalX, y = goalY})
    if i < #tPos then
      local nextTargetPos = tPos[i+1]
      table.insert(goalPos, {x = goalX, y = nextTargetPos.y + nextTargetPos.h})
    end
  end

  local hasCollided = {}
  for _ in ipairs(targets) do
    table.insert(hasCollided, false)
  end

  local damage = ref.battleStats['attack'] + skill.damage
  local flameTravelTime = skill.duration

  local flame = Projectile(ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2))
  table.insert(ref.projectiles, flame)
  
  local checkCollision = function()
    for i,target in ipairs(targets) do
      if not hasCollided[i] and Collision.rectsOverlap(flame.hitbox, target.hitbox) then
        target:takeDamage(damage)
        hasCollided[i] = true
        print('collision at index ' .. i, damage)
      end
    end
  end

  local goalX, goalY = goalPos[1].x, goalPos[1].y
  local attack = flux.to(flame.pos, flameTravelTime, {x = goalX, y = goalY})
    :ease(skill.beginTweenType)
    :onupdate(function()
      flame:update()
      checkCollision()
    end)

  -- Flame continues on path. Is not destroyed on collision.
  for i=2, #goalPos do
    attack:after(flameTravelTime, {x = goalPos[i].x, y = goalPos[i].y})
    :ease(skill.beginTweenType)
    :onupdate(function()
      flame:update()
      checkCollision()
    end)
    :oncomplete(function() print('made it to index ' .. i) end)
  end

end;