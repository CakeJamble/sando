require('util.globals')
local Projectile = require('class.entities.projectile')
local Signal = require('libs.hump.signal')
local flux = require('libs.flux')
local Collision = require('libs.collision')
local createBezierCurve = require('util.create_quad_bezier_curve')

-- Duration field of flame skill is the skill to hit ONE target
---@param ref Enemy
---@param qteManager? QTEManager
return function(ref, qteManager)
  local targets = ref.targets
  local stageX = ref.pos.x - 20
  local stageY = (targets[1].pos.y + targets[#targets].pos.y) / 2
  flux.to(ref.pos, 1, {x = stageX, y = stageY})
  :oncomplete(function()
    local skill = ref.skill
    local damage = ref.battleStats['attack'] + skill.damage
    local luck = ref.battleStats.luck
    local flameTravelTime = skill.duration
    local hasCollided = false

    -- Does flame travel Top-to-Bottom or Bottom-to-Top
    local chance = love.math.random()
    local isTopToBottom = chance <= 0.5
    local tPos = {}
    local start, stop, step
    local direction
    if isTopToBottom then
      start, stop, step = 1, #targets, 1
      direction = "right"
    else
      start, stop, step = #targets, 1, -1
      direction = "left"
    end

--! uncomment when animation is done
    -- ref:telegraphSkill(skill.name, direction)

    -- Add positions to flame's path in the order dictated by the coin flip
    for i=start, stop, step do
      local target = targets[i]
      local x,y = target.hitbox.x + (target.hitbox.w / 2), target.hitbox.y + target.hitbox.h
      table.insert(tPos, {x=x,y=y,target=target})
    end
    local rx,ry = ref.hitbox.x + ref.hitbox.w / 2, ref.hitbox.y + ref.hitbox.h
    table.insert(tPos, {x=rx, y=ry,target=nil})

    local flame = Projectile(ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2), skill.castsShadow, 1)
    table.insert(ref.projectiles, flame)

    -- Define path & collision, then begin skill
    local curve = createBezierCurve(flame.pos.x, flame.pos.y, tPos[1].x, tPos[1].y, 1, isTopToBottom)
    flame.progress = 0

    local checkCollision = function(target)
      if hasCollided then
        return
      end
      if target and not target.isJumping then
        print(target.entityName .. " took " .. damage .. " damage")
        hasCollided = true
        target:takeDamage(damage, luck)
        ref.tweens.attack:stop()
        table.remove(ref.projectiles, 1)
        Signal.emit("OnSkillResolved", ref)
        ref:endTurn(skill.duration)
      elseif not target then -- recoil onto user
        ref:takeDamage(damage, 0)
        ref.tweens.attack:stop()
        table.remove(ref.projectiles, 1)
        Signal.emit("OnSkillResolved", ref)
        ref:endTurn(skill.duration)
      end
    end

    local attack = flux.to(flame, flameTravelTime, {progress = 1}):ease("linear")
      :onupdate(function()
        flame.pos.x, flame.pos.y = curve:evaluate(flame.progress)
      end)
      :oncomplete(function() 
        checkCollision(tPos[1].target)
        flame.progress = 0
      end)

    for i=2, #tPos do
      local prev = tPos[i-1]
      local curr = tPos[i]
      local c = createBezierCurve(prev.x, prev.y, curr.x, curr.y, i, isTopToBottom)
      attack = attack:after(flameTravelTime/2, {progress = 1}):ease("linear")
        :onupdate(function()
          flame.pos.x, flame.pos.y = c:evaluate(flame.progress)
        end)
        :oncomplete(function()
          checkCollision(curr.target)
          flame.progress = 0
        end)
    end
    ref.tweens['attack'] = attack
  end)
end;