return function(character)
	-- choose skill
	local skill = character.currentSkills[1]

	-- somehow select target
	character:learnSkill(skill)
end;