local Projectile = require('class.entities.projectile')
local Signal = require('libs.hump.signal')
local flux = require('libs.flux')
local Collision = require('libs.collision')
local createBezierCurve = require('util.create_quad_bezier_curve')

return function(ref, qteManager)
	local skill = ref.skill
	local luck = ref.battleStats.luck
	local damage = ref.battleStats.attack + skill.damage
	local target = ref.targets[1]
	local tPos = target.hitbox

	local animation = skill.animation.daikon
	local projectileData = skill.projectiles.daikon
	local pX, pY = ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2)
	local pW, pH = projectileData.width, projectileData.height
	local projectile = Projectile(pX, pY, pW, pH, skill.castsShadow, 1, animation)
	local goalX, goalY = -2 * projectile.hitbox.w, target.oPos.y + target.hitbox.h
	table.insert(ref.projectiles, projectile)

	-- First Arc in bounce path
	local x0, y0 = projectile.pos.x, projectile.pos.y
	local x1,y1 = tPos.x + ((ref.hitbox.x - tPos.x) / 2), goalY
	local curve = createBezierCurve(x0, y0, x1, y1, 1, true)

	local x2, y2 = tPos.x + ((ref.hitbox.x - tPos.x) / 4), y1
	local x3, y3 = goalX, goalY

	projectile.progress = 0
	local hasCollided = false

	-- Bounce 1
	local attack = flux.to(projectile, 1, {progress = 1}):ease('linear')
		:onstart(function() projectile:tweenShadow(1, goalY) end)
		:onupdate(function()
			projectile.pos.x, projectile.pos.y = curve:evaluate(projectile.progress)
	 	end)
		:oncomplete(function()
			projectile.progress = 0
			curve = createBezierCurve(x1, y1, x2, y2, 1, true)
		end)

	-- Bounce 2
	attack = attack:after(projectile, 0.5, {progress = 1}):ease('linear')
		:onupdate(function()
			projectile.pos.x, projectile.pos.y = curve:evaluate(projectile.progress)
		end)
		:oncomplete(function()
			projectile.progress = 0
			curve = createBezierCurve(x2, y2, x3, y3, 1, true)

			-- janky way of making it jump higher w/o changing util function
			local cx,cy = curve:getControlPoint(2)
			curve:setControlPoint(2, cx, cy - 80)
		end)

	-- Bounce 3 (collision possible here)
	attack = attack:after(projectile, 1, {progress = 1}):ease('linear')
		:onupdate(function()
			projectile.pos.x, projectile.pos.y = curve:evaluate(projectile.progress)
			if not hasCollided and Collision.rectsOverlap(projectile.hitbox, target.hitbox) then
				target:takeDamage(damage, luck)
				hasCollided = true
				flux.to(projectile.hitbox, 0.25, {w=0,h=0}):oncomplete(function() table.remove(ref.projectiles, 1) end)
			end
		end)
		:oncomplete(function()
			Signal.emit("OnSkillResolved", ref)
			ref:endTurn(skill.duration, nil, skill.returnTweenType)
			projectile.progress = 0
		end)
	ref.tweens['attack'] = attack
end;