return function(characterTeam)
	for _,member in ipairs(characterTeam.members) do
		member:lowerMaxHP(0.5)
		for _,skill in ipairs(member.skillPool) do
			table.insert(skill.effects, 'lifesteal')
		end
		for _,skill in ipairs(member.currentSkills) do
			table.insert(skill.effects, 'lifesteal')
		end
	end
end;