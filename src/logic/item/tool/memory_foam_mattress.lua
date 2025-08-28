return function(character)
	character.skill.damage = character.skill.damage + math.floor(0.5 + character.skill.damage * 0.4)
end;