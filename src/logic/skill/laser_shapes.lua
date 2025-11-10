local Projectile = require('class.entities.projectile')
local Signal = require('libs.hump.signal')
local flux = require('libs.flux')
local Collision = require('libs.collision')
local getRandPair = require('util.table_utils').getRandPair
local calcSpacingFromTarget = require('util.calc_spacing')

---@param ref Enemy
return function(ref, qteManager)
	local skill = ref.skill
	local luck = ref.battleStats.luck
	local damage = ref.battleStats.attrack + skill.damage
	local target = ref.targets[1]

	local projectileName, projectileData = getRandPair(skill.projectiles)
	local animation = skill.animation[projectileName]
	local x, y = ref.pos.x - ref.hitbox.w, ref.pos.y + (ref.hitbox.h / 2)
	local w, h = projectileData.width, projectileData.height
	local projectile = Projectile(x, y, w, h, skill.castsShadow, 1, animation)
	table.insert(ref.projectiles, projectile)

	-- Goal Y actually depends on projectile type. Needs to be fixed later
	local goalX, goalY = -2 * projectile.hitbox.w, target.oPos.y + target.hitbox.h
	local hasCollided = false
	local attack
	local stagingTime = 1
	local chargeTime = 1.5
	local space = calcSpacingFromTarget("near", "enemy")
	local tx, ty = ref.pos.x + space.x, ref.pos.y + space.y
	attack = flux.to(ref.pos, stagingTime, {x=tx,y=ty})
		:oncomplete(function()
			-- change the animation type to charging
		end)

	if projectileName == "wall" then
		attack = attack:after(chargeTime, {x = tx + 80})
	end

	attack = attack:after(projectile.pos, 1, {x = goalX, y = goalY})
		:onstart(function()
			-- change animation type to attacking state (firing?)
		end)
		:onupdate(function()
			if not hasCollided and Collision.rectsOverlap(projectile.hitbox, target.hitbox) then
				hasCollided = true

				-- Wall type projectile paralyzes if not blocked. Doesn't deal damage
				if projectileName == "wall" and not target.isGuarding then
					target:applyStatus('paralyze')
				else
					target:takeDamage(damage, luck)
				end
			end
		end)
		:oncomplete(function()
			table.remove(ref.projectiles, 1)
			ref:endTurn(skill.duration, nil, skill.returnTweenType)
		end)
		ref.tweens['attack'] = attack
end;