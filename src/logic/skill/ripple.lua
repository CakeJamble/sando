require ('util.globals')
local flux = require('libs.flux')
local Timer = require('libs.hump.timer')

return function(ref)
	local skill = ref.skill
	local originX = ref.hitbox.x
	local targets = ref.target
	local rippleSpeed = 50
	local damage = ref.battleStats.attack + skill.damage

	for _,t in ipairs(targets) do
		local dist = math.abs(t.hitbox.x - originX)
		local travelTime = dist / rippleSpeed
		Timer.after(travelTime,
		function()
			if not t.isJumping then
				t:takeDamage(damage)
		end)
	end
end;