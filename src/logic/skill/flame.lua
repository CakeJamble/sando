require('util.globals')
local Projectile = require('class.entities.projectile')
local flux = require('libs.flux')
local Collision = require('libs.collision')
local addBezierSegment = require('util.add_bezier_segment')
-- Duration field of flame skill is the skill to hit ONE target
---@param ref Enemy
---@param qteManager? QTEManager
return function(ref, qteManager)
  local stageX, stageY = ref.stagingPositions.projectileAttack.x, ref.stagingPositions.projectileAttack.y
  flux.to(ref.pos, 1, {x = stageX, y = stageY})
  :oncomplete(function()
    local skill = ref.skill
    local targets = ref.targets
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

    for i=start, stop, step do
      local target = targets[i]
      table.insert(tPos, target.hitbox)
      table.insert(hasCollided, false)
    end
    table.insert(tPos, ref.hitbox)

    local flame = Projectile(ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2), skill.castsShadow, 1)
    table.insert(ref.projectiles, flame)

    -- Bezier Curve
    local vertices = {}
    local startX, startY = flame.pos.x, flame.pos.y
    table.insert(vertices, startX); table.insert(vertices, startY);
    local offsetX = 80 -- num px in front/behind before next bezier segment for collision
    local sign = -1
    for i,hitbox in ipairs(tPos) do
      local sign = (i % 2 == 0) and 1 or -1
      offsetX = sign * offsetX
      local goalX, goalY = hitbox.x + hitbox.w / 2, hitbox.y + hitbox.h
      local prevX, prevY = vertices[#vertices - 1], vertices[#vertices]
      addBezierSegment(vertices, prevX, prevY, goalX, goalY, offsetX)
    end

    local curve = love.math.newBezierCurve(vertices)
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

    local attack = flux.to(flame, flameTravelTime * 2 * (#targets), {progress = 1}):ease("linear")
      :onupdate(function()
        flame.pos.x, flame.pos.y = curve:evaluate(flame.progress)
        checkCollision()
      end)
      :oncomplete(function()
        if flawlessDodge then ref:takeDamage(damage, luck) end
        flux.to(flame.dims, 0.25, {r=0}):ease("linear")
          :oncomplete(function() table.remove(ref.projectiles, 1) end)
        ref:endTurn(skill.duration)
      end)

    ref.tweens['attack'] = attack
  end)

end;