return function(enemy, character)
	local isTarget = false
	for _,target in ipairs(enemy.targets) do
		if target == character then
			isTarget = true
		end
	end

	if isTarget and enemy.skill.isMultihit then
		character:modifyBattleStat('defense', 1)
	end
end;