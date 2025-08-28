return function(characterTeam)
	-- select character
	local character = characterTeam.members[1]
	-- select any skill
	local skill = character.skillPool[1]
	-- teach them
	print(skill.cost)
end;