require('util.globals')
local Projectile = require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')
local createBezierCurve = require('util.create_quad_bezier_curve')

-- Duration field of flame skill is the skill to hit ONE target
---@param ref Enemy
---@param qteManager? QTEManager
return function(ref, qteManager)
  local skill = ref.skill
  local targets = ref.targets
  local stageX = ref.pos.x - 20
  local stageY = (targets[1].pos.y + targets[#targets].pos.y) / 2
  flux.to(ref.pos, 1, {x = stageX, y = stageY})
  :oncomplete(function()

    local damage = ref.battleStats['attack'] + skill.damage
    local luck = ref.battleStats.luck
    local flameTravelTime = skill.duration
    local flawlessDodge = true

    -- Targets of skill
    -- Top to bottom vs bottom to top
    local chance = love.math.random()
    local isTopToBottom = chance <= 0.5
    local tPos = {}
    local hasCollided = {}
    local start, stop, step
    if isTopToBottom then
      start, stop, step = 1, #targets, 1
      -- ref:signalLeft()
    else
      start, stop, step = #targets, 1, -1
      -- ref:signalRight()
    end

    -- Add positions to flame's path based on coin flip above
    for i=start, stop, step do
      local target = targets[i]
      local x,y = target.hitbox.x + (target.hitbox.w / 2), target.hitbox.y + target.hitbox.h
      table.insert(tPos, {x=x,y=y})
      table.insert(hasCollided, false)
    end
    local rx,ry = ref.hitbox.x + ref.hitbox.w / 2, ref.hitbox.y + ref.hitbox.h
    table.insert(tPos, {x=rx, y=ry})

    local flame = Projectile(ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2), skill.castsShadow, 1)
    table.insert(ref.projectiles, flame)

    -- Define path & collision, then begin skill
    local curve = createBezierCurve(flame.pos.x, flame.pos.y, tPos[1].x, tPos[1].y)
    flame.progress = 0

    local checkCollision = function()
      for i,target in ipairs(targets) do
        -- if not hasCollided[i] and Collision.rectsOverlap(flame.hitbox, target.hitbox) then
        if not hasCollided[i] and flame.hitbox.x == tPos[i].x and flame.hitbox.y == tPos[i].y and target.isJumping == false then
          target:takeDamage(damage, luck)
          hasCollided[i] = true
          flawlessDodge = false
          ref.tweens.attack:stop()
          flux.to(flame.dims, 0.25, {r=0}):ease("linear")
            :oncomplete(function() table.remove(ref.projectiles, 1) end)
          ref:endTurn(skill.duration)
        end
      end
    end
    local attack = flux.to(flame, flameTravelTime, {progress = 1}):ease("linear")
      :onupdate(function()
        flame.pos.x, flame.pos.y = curve:evaluate(flame.progress)
        checkCollision()
      end)
      :oncomplete(function() flame.progress = 0 end)

    for i=2, #tPos do
      local v = {}
      local x, y = tPos[i-1].x, tPos[i-1].y
      goalX, goalY = tPos[i].x, tPos[i].y
      local c = createBezierCurve(x, y, goalX, goalY)
      attack = attack:after(flameTravelTime, {progress = 1}):ease("linear")
        :onupdate(function()
          flame.pos.x, flame.pos.y = c:evaluate(flame.progress)
          checkCollision()
        end)
        :oncomplete(function() flame.progress = 0 end)
    end
    ref.tweens['attack'] = attack
  end)

end;