return function(character)
	for _,target in ipairs(character.targets) do
		local isVulnerable = false
		for _,status in ipairs(target.statuses) do
			if status == "vulnerable" then isVulnerable = true end
		end

		if isVulnerable then
			character.skill.damage = character.skill.damage + math.floor(0.5 + 0.4 * character.skill.damage)
		end
	end
end;