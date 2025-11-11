local flux = require('libs.flux')
local Collision = require('libs.collision')
local Timer = require('libs.hump.timer')
local Signal = require('libs.hump.signal')
local calcSpacingFromTarget = require('util.calc_spacing')

---@param ref Enemy
return function(ref)
	local skill = ref.skill
	local target = ref.targets[1]
	local frameWindow = skill.frameWindow
	local goalX, goalY = target.hitbox.x, target.hitbox.y + target.hitbox.h - skill.hitbox.h

	local yOffset = ref.hitbox.h - target.hitbox.h
	if ref.hitbox.h < target.hitbox.h then yOffset = -yOffset end

	local strikeHitbox = skill.hitbox
	local hasCollided = false
	local spaceFromTarget = calcSpacingFromTarget(skill.stagingType, ref.type)
	local stagingPos = {x = target.hitbox.x + spaceFromTarget.x, y = target.hitbox.y + yOffset + spaceFromTarget.y}
	ref.tPos = {x = stagingPos.x, y = stagingPos.y}

	local damage = ref.battleStats.attack + skill.damage
	local luck = ref.battleStats.luck

	local stage = flux.to(ref.pos, skill.stagingTime, {x = stagingPos.x, y = stagingPos.y})
	ref.currentAnimTag = "move"
	ref.tweens['stage'] = stage

	stage:oncomplete(
		function()
			ref.currentAnimTag = skill.tag
			local attack = flux.to(strikeHitbox, skill.duration, {x = goalX, y = goalY})
				:onupdate(function()
					skill.hitbox.isActive = ref.spriteNum >= frameWindow[1] and ref.spriteNum <= frameWindow[2]

					if not hasCollided and skill.hitbox.isActive and Collision.rectsOverlap(skill.hitbox, target.hitbox) then
						hasCollided = true
						target:takeDamage(damage, luck)
					end
				end)
				:oncomplete(function()
					ref:endTurn(skill.duration, stagingPos, skill.returnTweenType)
				end)
				ref.tweens['attack'] = attack
		end)
end;