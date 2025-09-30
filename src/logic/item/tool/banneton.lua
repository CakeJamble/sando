-- Signal: OnSkillResolved
---@param character Character
return function(character)
	local burnChance = 0.25
	local targets = character.targets
	for _,target in ipairs(targets) do
		local canBurn = true
		local statuses = target.statuses
		for _,status in ipairs(statuses) do
			if status == 'burn' then
				canBurn = false
			end
		end
		if canBurn then
			if burnChance >= love.math.random() then
				target:applyStatus('burn')
			end
		end
	end
end;