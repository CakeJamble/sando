return function(character, consumable)
	local exp = character.experienceRequired
	character:gainExp(exp)
end;