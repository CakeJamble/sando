return function(character)
	local skill = character.skill
	local fp = character.battleStats.fp

	if fp < (math.floor(0.5 + character.baseStats.fp * 0.3)) then
		skill.damage = math.ceil(skill.damage * 1.5)
	end
end;