local flux = require('libs.flux')
local Timer = require('libs.hump.timer')
local Signal = require('libs.hump.signal')
local Projectile = require('class.entities.projectile')
local Collision = require('libs.collision')

---@param ref Enemy
return function(ref)
	local skill = ref.skill
	local duration = 1
	local originX = ref.hitbox.x
	local targets = ref.targets
	local damage = ref.battleStats.attack + skill.damage
	local luck = ref.battleStats.luck
	local goalX = -30
	local tweens = {}
	local collisions = {}
	for i,target in ipairs(targets) do
		local x,y = ref.pos.x - ref.hitbox.w, target.oPos.y + target.hitbox.h
		local projectile = Projectile(x, y, skill.castsShadow, i)
		table.insert(ref.projectiles, projectile)
		table.insert(collisions, false)

		local tween = flux.to(projectile.pos, duration, {x = goalX}):ease('quadin')
			:onupdate(function()
				if not collisions[i] and Collision.rectsOverlap(projectile.hitbox, target.hitbox) then
					target:takeDamage(damage, luck)
					collisions[i] = true
				end
			end)

		table.insert(tweens, tween)
	end

	Timer.after(duration, function()
		for _,projectile in ipairs(ref.projectiles) do
			local i = projectile.index
			table.remove(ref.projectiles, i)
		end
		Signal.emit("OnSkillResolved", ref)
		ref:endTurn(skill.duration, nil, skill.returnTweenType)
	end)
end;