return function(character)
	for _,skill in ipairs(character.currentSkills) do
		skill.cost = skill.cost - 1
	end
end;